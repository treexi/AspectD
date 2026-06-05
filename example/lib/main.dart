import 'package:flutter/material.dart';

// 导入 hook 模块（确保编译时被 AspectD 识别）
// ignore_for_file: unused_import
import 'package:example/hooks/call_hook.dart';
import 'package:example/hooks/execute_hook.dart';
import 'package:example/hooks/inject_hook.dart';
import 'package:example/hooks/add_hook.dart';
import 'package:example/hooks/field_get_hook.dart';
import 'package:example/hooks/regex_hook.dart';
import 'package:example/hooks/jank_hook.dart';

import 'package:example/pages/home_page.dart';
import 'package:example/widgets/log_overlay.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AspectD Example',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      // 全局悬浮日志面板，任意页面都能看到 Hook 输出
      builder: (context, child) => LogOverlay(child: child!),
      home: const HomePage(),
    );
  }
}
