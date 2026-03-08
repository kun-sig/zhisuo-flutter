import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:zhisuo_flutter/logger/logger.dart';

import 'app.dart';

void main() {
  // 捕获 Dart 异步异常
  runZonedGuarded<Future<void>>(
    () async {
      WidgetsFlutterBinding.ensureInitialized();
      SystemChrome.setSystemUIOverlayStyle(
        const SystemUiOverlayStyle(
          systemNavigationBarColor: Colors.transparent,
        ),
      );
      // make flutter draw behind navigation bar
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
      await Logger.init();
      runApp(const App());
    },
    (error, stackTrace) {
      Logger.e('Uncaught async error', error: error, stackTrace: stackTrace);
      Logger.flush(); // 崩溃前 flush
    },
  );
}
