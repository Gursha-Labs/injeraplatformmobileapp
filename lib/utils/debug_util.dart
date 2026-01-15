// utils/debug_util.dart
import 'dart:convert';
import 'package:flutter/foundation.dart';

class DebugUtil {
  static void logJson(String tag, dynamic data) {
    if (kDebugMode) {
      try {
        if (data is Map || data is List) {
          final encoder = JsonEncoder.withIndent('  ');
          final prettyJson = encoder.convert(data);
          print('[$tag] $prettyJson');
        } else {
          print('[$tag] $data');
        }
      } catch (e) {
        print('[$tag ERROR formatting JSON] $e');
        print('[$tag RAW] $data');
      }
    }
  }

  static void logError(String tag, dynamic error, StackTrace stackTrace) {
    if (kDebugMode) {
      print('══════════════════════════════════════════════════════════');
      print('[$tag ERROR] $error');
      print('[$tag STACKTRACE] $stackTrace');
      print('══════════════════════════════════════════════════════════');
    }
  }
}
