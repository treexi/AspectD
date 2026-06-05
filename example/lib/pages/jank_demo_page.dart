import 'package:flutter/material.dart';
import 'package:example/log_store.dart';
import 'package:example/services.dart';

/// 卡顿演示页 - 故意制造性能问题，用 Hook 监控验证
class JankDemoPage extends StatefulWidget {
  const JankDemoPage({super.key});

  @override
  State<JankDemoPage> createState() => _JankDemoPageState();
}

class _JankDemoPageState extends State<JankDemoPage> {
  final _loader = PageDataLoader();
  List<String> _items = [];
  int _buildCount = 0;
  int _counter = 0;

  @override
  void initState() {
    super.initState();
    // 问题1: initState 中同步加载数据（会被 regex hook 捕获）
    _items = _loader.loadProductList();
  }

  @override
  Widget build(BuildContext context) {
    _buildCount++;
    LogStore.instance.add('Build', '第 $_buildCount 次 build');

    return Scaffold(
      appBar: AppBar(
        title: const Text('卡顿演示'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: '触发无关 rebuild',
            onPressed: () {
              setState(() {
                _counter++; // 问题2: 只改了 counter，但整页 rebuild
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            color: Colors.amber.shade50,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('点击 + 触发 rebuild，计数: $_counter',
                    style: const TextStyle(fontSize: 14)),
                Text('build 次数: $_buildCount',
                    style: const TextStyle(fontSize: 12, color: Colors.red)),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _items.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(_items[index]),
                  // 问题3: 每次 build 都重新计算价格（会被 regex hook 捕获）
                  subtitle: Text(_loader.formatPrice(index)),
                  leading: CircleAvatar(child: Text('${index + 1}')),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
