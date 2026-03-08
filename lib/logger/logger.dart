import 'dart:async';
import 'dart:collection';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart' as lg;
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';

class Logger {
  Logger._();

  static lg.Logger? _logger;
  static late Directory _logDir;

  static final DateFormat _dateFormat = DateFormat('yyyy-MM-dd');
  static const int _maxFileSize = 10 * 1024 * 1024; // 10MB
  static const int _retentionDays = 3;

  static String _currentDate = '';
  static int _fileIndex = 0;
  static File? _currentFile;

  static final _queue = Queue<String>();
  static bool _isWriting = false;

  /// 初始化
  static Future<void> init() async {
    final dir = await getApplicationDocumentsDirectory();
    _logDir = Directory('${dir.path}/logs');

    if (!_logDir.existsSync()) {
      _logDir.createSync(recursive: true);
    }

    _rotateFileIfNeeded();
    await _cleanOldLogs();

    _logger = lg.Logger(
      printer: _OneLinePrinter(),
      output: lg.MultiOutput([
        lg.ConsoleOutput(),
        _AsyncFileOutput(),
      ]),
    );

    /// 捕获 Flutter 层异常
    FlutterError.onError = (details) {
      e(details.exceptionAsString(), stackTrace: details.stack);
      flush();
    };

    /// 捕获 Dart 异常
    PlatformDispatcher.instance.onError = (error, stack) {
      e(error.toString(), stackTrace: stack);
      flush();
      return true;
    };
  }

  static void d(dynamic message) {
    if (kDebugMode) _logger?.d(message);
  }

  static void i(dynamic message) => _logger?.i(message);

  static void w(dynamic message) => _logger?.w(message);

  static void e(dynamic message, {dynamic error, StackTrace? stackTrace}) {
    _logger?.e(message, error: error, stackTrace: stackTrace);
  }

  /// 异步写入入口
  static void _enqueue(String line) {
    _queue.add(line);
    _processQueue();
  }

  static void _processQueue() async {
    if (_isWriting) return;
    _isWriting = true;

    while (_queue.isNotEmpty) {
      final line = _queue.removeFirst();
      _rotateFileIfNeeded();
      await _currentFile!.writeAsString(
        '$line\n',
        mode: FileMode.append,
      );
    }

    _isWriting = false;
  }

  /// 强制 flush
  static Future<void> flush() async {
    while (_queue.isNotEmpty) {
      await Future.delayed(const Duration(milliseconds: 10));
    }
  }

  /// 文件轮转（跨天 + 超过大小）
  static void _rotateFileIfNeeded() {
    final today = _dateFormat.format(DateTime.now());

    if (_currentDate != today) {
      _currentDate = today;
      _fileIndex = 0;
    }

    while (true) {
      final file = File('${_logDir.path}/app_${_currentDate}_$_fileIndex.log');

      if (!file.existsSync()) {
        file.createSync();
        _currentFile = file;
        break;
      }

      if (file.lengthSync() >= _maxFileSize) {
        _fileIndex++;
      } else {
        _currentFile = file;
        break;
      }
    }
  }

  /// 保留最近3天
  static Future<void> _cleanOldLogs() async {
    final files = _logDir
        .listSync()
        .whereType<File>()
        .where((f) => f.path.endsWith('.log'))
        .toList();

    files
        .sort((a, b) => b.statSync().modified.compareTo(a.statSync().modified));

    final cutoff = DateTime.now().subtract(Duration(days: _retentionDays));

    for (final file in files) {
      if (file.statSync().modified.isBefore(cutoff)) {
        file.deleteSync();
      }
    }
  }
}

class _AsyncFileOutput extends lg.LogOutput {
  @override
  void output(lg.OutputEvent event) {
    for (var line in event.lines) {
      Logger._enqueue(line);
    }
  }
}

class _OneLinePrinter extends lg.LogPrinter {
  @override
  List<String> log(lg.LogEvent event) {
    final time = DateTime.now().toIso8601String();
    final level = event.level.name.toUpperCase();
    final caller = _getCaller();

    return ['[$time] [$level] $caller ${event.message}'];
  }

  String _getCaller() {
    final stack = StackTrace.current.toString().split('\n');

    for (final line in stack) {
      if (!line.contains('logger.dart') &&
          !line.contains('_OneLinePrinter') &&
          line.contains('.dart')) {
        final match = RegExp(r'([^\/]+\.dart):(\d+):\d+').firstMatch(line);
        if (match != null) {
          return '${match.group(1)}:${match.group(2)}';
        }
      }
    }
    return '';
  }
}
