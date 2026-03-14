import 'dart:convert';

import 'package:flutter/services.dart';

/// 应用运行配置（来自 assets 配置文件）。
class AppConfig {
  AppConfig._({
    required this.env,
    required this.apiBaseUrl,
  });

  final String env;
  final String apiBaseUrl;

  static AppConfig? _instance;

  static AppConfig get instance {
    final value = _instance;
    if (value == null) {
      throw StateError('AppConfig is not loaded. Call AppConfig.load() first.');
    }
    return value;
  }

  static const String _envKey = 'APP_ENV';
  static const String _defaultEnv = 'dev';

  /// 加载配置文件。
  ///
  /// 配置路径规则：`assets/config/app_config_<env>.json`
  /// - env 通过 `--dart-define=APP_ENV=dev|test|prod` 指定；
  /// - 未指定时默认 `dev`。
  static Future<void> load() async {
    final env = const String.fromEnvironment(
      _envKey,
      defaultValue: _defaultEnv,
    );
    final configPath = 'assets/config/app_config_$env.json';
    final raw = await rootBundle.loadString(configPath);
    final dynamic decoded = jsonDecode(raw);
    if (decoded is! Map) {
      throw FormatException(
        'Invalid config format in $configPath, expected JSON object.',
      );
    }

    final map = decoded.map((key, value) => MapEntry(key.toString(), value));
    final apiBaseUrl = (map['apiBaseUrl'] ?? '').toString().trim();
    if (apiBaseUrl.isEmpty) {
      throw StateError('Missing or empty "apiBaseUrl" in $configPath');
    }

    _instance = AppConfig._(
      env: env,
      apiBaseUrl: apiBaseUrl,
    );
  }
}
