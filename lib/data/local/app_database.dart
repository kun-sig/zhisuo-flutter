import 'package:sqflite/sqflite.dart';

/// 应用级 SQLite 数据库入口。
///
/// 职责：
/// 1. 负责数据库初始化/升级。
/// 2. 负责创建科目业务所需的基础表与索引。
/// 3. 对外提供统一 `Database` 实例与事务入口。
class AppDatabase {
  /// 数据库文件名。
  static const String _dbName = 'zhisuo.db';

  /// 数据库版本号。
  ///
  /// 版本说明：
  /// - v1: `subject_categories` / `subject_tags` / `subjects`
  /// - v2: 新增 `subject_click_stats`
  /// - v3: `subject_click_stats` 新增 `is_latest`
  static const int _dbVersion = 3;

  /// 单例数据库连接缓存，避免重复打开文件。
  Database? _db;

  /// 获取数据库连接（懒加载）。
  Future<Database> get database async {
    if (_db != null) {
      return _db!;
    }
    _db = await _openDatabase();
    return _db!;
  }

  /// 提供统一事务入口，确保多步写操作原子性。
  Future<T> transaction<T>(Future<T> Function(Transaction txn) action) async {
    final db = await database;
    return db.transaction(action);
  }

  /// 打开数据库文件并挂载建表/升级回调。
  Future<Database> _openDatabase() async {
    final databasesPath = await getDatabasesPath();
    final path = '$databasesPath/$_dbName';

    return openDatabase(
      path,
      version: _dbVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  /// 首次建库逻辑。
  ///
  /// 数据表说明：
  /// - `subject_categories`: 科目分类表
  ///   - `id`: 分类主键
  ///   - `name`: 分类名称
  ///   - `description`: 分类描述
  ///   - `sort_order`: 排序值
  /// - `subject_tags`: 科目标签表
  ///   - `id`: 标签主键
  ///   - `subject_category_id`: 所属分类 ID
  ///   - `name`: 标签名称
  ///   - `description`: 标签描述
  ///   - `sort_order`: 排序值
  /// - `subjects`: 科目表
  ///   - `id`: 科目主键
  ///   - `subject_category_id`: 所属分类 ID
  ///   - `subject_tag_id`: 所属标签 ID
  ///   - `name`: 科目名称
  ///   - `description`: 科目描述
  ///   - `sort_order`: 排序值
  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE subject_categories (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        description TEXT NOT NULL,
        sort_order INTEGER NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE subject_tags (
        id TEXT PRIMARY KEY,
        subject_category_id TEXT NOT NULL,
        name TEXT NOT NULL,
        description TEXT NOT NULL,
        sort_order INTEGER NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE subjects (
        id TEXT PRIMARY KEY,
        subject_category_id TEXT NOT NULL,
        subject_tag_id TEXT NOT NULL,
        name TEXT NOT NULL,
        description TEXT NOT NULL,
        sort_order INTEGER NOT NULL
      )
    ''');

    // 常用查询字段建立索引，降低分类/标签过滤成本。
    await db.execute(
      'CREATE INDEX idx_subject_tags_category ON subject_tags(subject_category_id)',
    );
    await db.execute(
      'CREATE INDEX idx_subjects_category ON subjects(subject_category_id)',
    );
    await db.execute(
      'CREATE INDEX idx_subjects_tag ON subjects(subject_tag_id)',
    );

    // 点击统计表创建（热门与最近点击能力依赖）。
    await _createSubjectClickStatsTable(db);
  }

  /// 数据库升级逻辑。
  ///
  /// 采用“按版本区间增量迁移”策略，保证跨版本升级安全。
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await _createSubjectClickStatsTable(db);
    }
    if (oldVersion < 3) {
      await _ensureIsLatestColumn(db);
    }
  }

  /// 创建点击统计表。
  ///
  /// 表字段说明：
  /// - `subject_id`: 科目 ID（主键）
  /// - `click_count`: 点击次数累计值
  /// - `updated_at`: 最近一次点击时间（毫秒时间戳）
  /// - `is_latest`: 是否为“最近点击”的科目（0/1，理论上仅一条为 1）
  Future<void> _createSubjectClickStatsTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS subject_click_stats (
        subject_id TEXT PRIMARY KEY,
        click_count INTEGER NOT NULL,
        updated_at INTEGER NOT NULL,
        is_latest INTEGER NOT NULL DEFAULT 0
      )
    ''');
    // 热门排序、最近点击读取依赖的索引。
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_subject_click_count ON subject_click_stats(click_count DESC)',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_subject_click_updated_at ON subject_click_stats(updated_at DESC)',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_subject_click_is_latest ON subject_click_stats(is_latest DESC)',
    );
  }

  /// 兼容旧库：确保 `subject_click_stats` 存在 `is_latest` 字段并回填数据。
  Future<void> _ensureIsLatestColumn(Database db) async {
    final columns = await db.rawQuery('PRAGMA table_info(subject_click_stats)');
    final hasIsLatest =
        columns.any((row) => row['name']?.toString() == 'is_latest');
    if (!hasIsLatest) {
      await db.execute(
        'ALTER TABLE subject_click_stats ADD COLUMN is_latest INTEGER NOT NULL DEFAULT 0',
      );
    }
    // 升级后统一重算“最近点击”标记，避免历史脏状态。
    await db.execute('UPDATE subject_click_stats SET is_latest = 0');
    await db.execute('''
      UPDATE subject_click_stats
      SET is_latest = 1
      WHERE subject_id = (
        SELECT subject_id
        FROM subject_click_stats
        ORDER BY updated_at DESC, click_count DESC
        LIMIT 1
      )
    ''');
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_subject_click_is_latest ON subject_click_stats(is_latest DESC)',
    );
  }
}
