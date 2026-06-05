import 'package:flutter/foundation.dart';

/// 全局日志存储，用于收集 AspectD hook 产生的日志并通知 UI 刷新。
/// 同时打印到控制台，也可在页面上实时展示。
class LogStore extends ChangeNotifier {
  LogStore._();

  static final LogStore instance = LogStore._();

  final List<LogEntry> _logs = [];

  List<LogEntry> get logs => List.unmodifiable(_logs);

  /// 添加一条日志，同时 print 到控制台
  void add(String tag, String message) {
    final entry = LogEntry(
      tag: tag,
      message: message,
      timestamp: DateTime.now(),
    );
    _logs.add(entry);
    debugPrint('[$tag] $message');
    notifyListeners();
  }

  /// 清空日志
  void clear() {
    _logs.clear();
    notifyListeners();
  }
}

/// 单条日志记录
class LogEntry {
  final String tag;
  final String message;
  final DateTime timestamp;

  LogEntry({
    required this.tag,
    required this.message,
    required this.timestamp,
  });

  String get formatted =>
      '${timestamp.hour.toString().padLeft(2, '0')}:'
      '${timestamp.minute.toString().padLeft(2, '0')}:'
      '${timestamp.second.toString().padLeft(2, '0')} '
      '[$tag] $message';
}
