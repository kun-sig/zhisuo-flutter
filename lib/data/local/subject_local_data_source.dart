import 'package:sqflite/sqflite.dart';

import '../models/subject/subject_models.dart';
import 'app_database.dart';

/// 科目本地数据源（SQLite）。
///
/// 职责：
/// 1. 提供科目/标签/分类的本地读写。
/// 2. 提供点击统计（热门、最近点击）读写。
/// 3. 在全量刷新后清理失效点击记录，避免垃圾数据累积。
class SubjectLocalDataSource {
  SubjectLocalDataSource(this._database);

  /// 数据库访问入口。
  final AppDatabase _database;

  /// 全量替换本地科目菜单基础数据（分类/标签/科目）。
  ///
  /// 关键逻辑：
  /// - 采用事务确保“删旧 + 插新”原子性，避免中间态。
  /// - 刷新完成后立即清理点击统计中的失效科目记录。
  Future<void> replaceAll({
    required List<SubjectCategoryItem> categories,
    required List<SubjectTagItem> tags,
    required List<SubjectItem> subjects,
  }) async {
    await _database.transaction<void>((txn) async {
      // 先删旧数据，保证本地与远端快照完全一致。
      await txn.delete('subjects');
      await txn.delete('subject_tags');
      await txn.delete('subject_categories');

      // 批量插入分类。
      final categoryBatch = txn.batch();
      for (final category in categories) {
        categoryBatch.insert(
          'subject_categories',
          {
            'id': category.id,
            'name': category.name,
            'description': category.description,
            'sort_order': category.order,
          },
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
      await categoryBatch.commit(noResult: true);

      // 批量插入标签。
      final tagBatch = txn.batch();
      for (final tag in tags) {
        tagBatch.insert(
          'subject_tags',
          {
            'id': tag.id,
            'subject_category_id': tag.subjectCategoryId,
            'name': tag.name,
            'description': tag.description,
            'sort_order': tag.order,
          },
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
      await tagBatch.commit(noResult: true);

      // 批量插入科目。
      final subjectBatch = txn.batch();
      for (final subject in subjects) {
        subjectBatch.insert(
          'subjects',
          {
            'id': subject.id,
            'subject_category_id': subject.subjectCategoryId,
            'subject_tag_id': subject.subjectTagId,
            'name': subject.name,
            'description': subject.description,
            'sort_order': subject.order,
          },
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
      await subjectBatch.commit(noResult: true);

      // 同步清理点击统计，防止引用已被删除的科目。
      await _cleanupSubjectClickStats(txn);
    });
  }

  /// 查询全部分类（按排序值、名称升序）。
  Future<List<SubjectCategoryItem>> getCategories() async {
    final db = await _database.database;
    final rows = await db.query(
      'subject_categories',
      orderBy: 'sort_order ASC, name ASC',
    );
    return rows
        .map(
          (row) => SubjectCategoryItem(
            id: row['id']?.toString() ?? '',
            name: row['name']?.toString() ?? '',
            description: row['description']?.toString() ?? '',
            order: _toInt(row['sort_order']),
          ),
        )
        .toList();
  }

  /// 查询某分类下全部标签（按排序值、名称升序）。
  Future<List<SubjectTagItem>> getTagsByCategory(String categoryId) async {
    final db = await _database.database;
    final rows = await db.query(
      'subject_tags',
      where: 'subject_category_id = ?',
      whereArgs: [categoryId],
      orderBy: 'sort_order ASC, name ASC',
    );
    return rows
        .map(
          (row) => SubjectTagItem(
            id: row['id']?.toString() ?? '',
            subjectCategoryId: row['subject_category_id']?.toString() ?? '',
            name: row['name']?.toString() ?? '',
            description: row['description']?.toString() ?? '',
            order: _toInt(row['sort_order']),
          ),
        )
        .toList();
  }

  /// 查询某分类下全部科目（按排序值、名称升序）。
  Future<List<SubjectItem>> getSubjectsByCategory(String categoryId) async {
    final db = await _database.database;
    final rows = await db.query(
      'subjects',
      where: 'subject_category_id = ?',
      whereArgs: [categoryId],
      orderBy: 'sort_order ASC, name ASC',
    );
    return rows
        .map(
          (row) => SubjectItem(
            id: row['id']?.toString() ?? '',
            subjectCategoryId: row['subject_category_id']?.toString() ?? '',
            subjectTagId: row['subject_tag_id']?.toString() ?? '',
            name: row['name']?.toString() ?? '',
            description: row['description']?.toString() ?? '',
            order: _toInt(row['sort_order']),
          ),
        )
        .toList();
  }

  /// 增加某科目点击次数，并更新“最近点击”标记。
  ///
  /// 关键逻辑：
  /// - 当前点击科目 `click_count + 1`。
  /// - 当前点击科目 `is_latest = 1`。
  /// - 其他科目 `is_latest = 0`。
  Future<void> increaseSubjectClickCount(String subjectId) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    await _database.transaction<void>((txn) async {
      final rows = await txn.query(
        'subject_click_stats',
        columns: ['click_count'],
        where: 'subject_id = ?',
        whereArgs: [subjectId],
        limit: 1,
      );
      if (rows.isEmpty) {
        // 首次点击：新增统计行。
        await txn.insert(
          'subject_click_stats',
          {
            'subject_id': subjectId,
            'click_count': 1,
            'updated_at': now,
            'is_latest': 1,
          },
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      } else {
        // 非首次点击：在原计数基础上累加。
        final current = _toInt(rows.first['click_count']);
        await txn.update(
          'subject_click_stats',
          {
            'click_count': current + 1,
            'updated_at': now,
            'is_latest': 1,
          },
          where: 'subject_id = ?',
          whereArgs: [subjectId],
        );
      }

      // 保证“最近点击”全表唯一。
      await txn.update(
        'subject_click_stats',
        {
          'is_latest': 0,
        },
        where: 'subject_id <> ? AND is_latest = 1',
        whereArgs: [subjectId],
      );
    });
  }

  /// 是否存在任意点击记录。
  ///
  /// 用于控制“热门”分类是否展示。
  Future<bool> hasSubjectClicks() async {
    final db = await _database.database;
    final rows = await db.rawQuery(
      'SELECT 1 FROM subject_click_stats WHERE click_count > 0 LIMIT 1',
    );
    return rows.isNotEmpty;
  }

  /// 查询最近点击科目的 ID。
  ///
  /// 排序规则：
  /// 1. `is_latest` 优先
  /// 2. `updated_at` 次之
  /// 3. `click_count` 兜底
  Future<String> getLatestClickedSubjectId() async {
    final db = await _database.database;
    final rows = await db.rawQuery(
      '''
      SELECT subject_id
      FROM subject_click_stats
      WHERE click_count > 0
      ORDER BY is_latest DESC, updated_at DESC, click_count DESC
      LIMIT 1
      ''',
    );
    if (rows.isEmpty) {
      return '';
    }
    return rows.first['subject_id']?.toString() ?? '';
  }

  /// 查询热门科目列表（默认最多 100 条）。
  ///
  /// 排序规则：
  /// 1. 最近点击优先
  /// 2. 点击次数降序
  /// 3. 最近点击时间降序
  /// 4. 科目自身排序值、名称兜底
  Future<List<SubjectItem>> getHotSubjectsRanked({int limit = 100}) async {
    final db = await _database.database;
    final rows = await db.rawQuery(
      '''
      SELECT
        s.id,
        s.subject_category_id,
        s.subject_tag_id,
        s.name,
        s.description,
        s.sort_order
      FROM subject_click_stats c
      INNER JOIN subjects s ON s.id = c.subject_id
      WHERE c.click_count > 0
      ORDER BY c.is_latest DESC, c.click_count DESC, c.updated_at DESC, s.sort_order ASC, s.name ASC
      LIMIT ?
      ''',
      [limit],
    );
    return rows
        .map(
          (row) => SubjectItem(
            id: row['id']?.toString() ?? '',
            subjectCategoryId: row['subject_category_id']?.toString() ?? '',
            subjectTagId: row['subject_tag_id']?.toString() ?? '',
            name: row['name']?.toString() ?? '',
            description: row['description']?.toString() ?? '',
            order: _toInt(row['sort_order']),
          ),
        )
        .toList();
  }

  /// 清理点击统计脏数据，并重算“最近点击”标记。
  ///
  /// 场景：全量刷新科目后，历史点击中可能存在“本地已删除科目”。
  Future<void> _cleanupSubjectClickStats(Transaction txn) async {
    // 删除已不在 subjects 表中的点击记录。
    await txn.execute('''
      DELETE FROM subject_click_stats
      WHERE subject_id NOT IN (SELECT id FROM subjects)
    ''');

    // 先全部置 0，再按最新时间重新标记 1，避免并发脏状态。
    await txn.update(
      'subject_click_stats',
      {
        'is_latest': 0,
      },
    );

    await txn.rawUpdate('''
      UPDATE subject_click_stats
      SET is_latest = 1
      WHERE subject_id = (
        SELECT subject_id
        FROM subject_click_stats
        ORDER BY updated_at DESC, click_count DESC
        LIMIT 1
      )
    ''');
  }

  /// 动态数值安全转 int。
  int _toInt(dynamic value) {
    if (value is int) {
      return value;
    }
    if (value is num) {
      return value.toInt();
    }
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }
}
