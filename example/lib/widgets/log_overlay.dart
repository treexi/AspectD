import 'package:flutter/material.dart';
import 'package:example/log_store.dart';

/// 全局悬浮日志面板 - 在任意页面都能看到 Hook 输出
class LogOverlay extends StatefulWidget {
  final Widget child;
  const LogOverlay({super.key, required this.child});

  @override
  State<LogOverlay> createState() => _LogOverlayState();
}

class _LogOverlayState extends State<LogOverlay> {
  bool _expanded = true;
  double _panelHeight = 220;
  Offset _dragOffset = Offset.zero;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        // 悬浮日志面板
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: _expanded ? _buildPanel() : _buildCollapsedButton(),
        ),
      ],
    );
  }

  Widget _buildCollapsedButton() {
    return Align(
      alignment: Alignment.bottomRight,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: AnimatedBuilder(
          animation: LogStore.instance,
          builder: (context, _) {
            final count = LogStore.instance.logs.length;
            return FloatingActionButton.small(
              heroTag: 'log_overlay',
              backgroundColor: Colors.black87,
              onPressed: () => setState(() => _expanded = true),
              child: Text('$count', style: const TextStyle(color: Colors.white, fontSize: 12)),
            );
          },
        ),
      ),
    );
  }

  Widget _buildPanel() {
    return Container(
      height: _panelHeight,
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(blurRadius: 8, color: Colors.black26)],
        borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
      ),
      child: Column(
        children: [
          // 顶部拖拽条 + 操作按钮
          GestureDetector(
            onVerticalDragUpdate: (details) {
              setState(() {
                _panelHeight = (_panelHeight - details.delta.dy).clamp(100.0, 500.0);
              });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade400,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text('Hook 日志',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                  const Spacer(),
                  GestureDetector(
                    onTap: () => LogStore.instance.clear(),
                    child: const Icon(Icons.delete_outline, size: 18, color: Colors.grey),
                  ),
                  const SizedBox(width: 12),
                  GestureDetector(
                    onTap: () => setState(() => _expanded = false),
                    child: const Icon(Icons.keyboard_arrow_down, size: 20, color: Colors.grey),
                  ),
                ],
              ),
            ),
          ),
          // 日志列表
          Expanded(child: _buildLogList()),
        ],
      ),
    );
  }

  Widget _buildLogList() {
    return AnimatedBuilder(
      animation: LogStore.instance,
      builder: (context, _) {
        final logs = LogStore.instance.logs;
        if (logs.isEmpty) {
          return const Center(
            child: Text('暂无日志', style: TextStyle(color: Colors.grey, fontSize: 12)),
          );
        }
        return ListView.builder(
          reverse: true,
          itemCount: logs.length,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          itemBuilder: (context, index) {
            final log = logs[logs.length - 1 - index];
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 1),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTag(log.tag),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(log.message,
                        style: const TextStyle(fontSize: 12, color: Colors.black)),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildTag(String tag) {
    Color color = Colors.grey;
    if (tag.contains('Call')) color = Colors.blue;
    if (tag.contains('Execute')) color = Colors.orange;
    if (tag.contains('Inject')) color = Colors.purple;
    if (tag.contains('Add')) color = Colors.green;
    if (tag.contains('FieldGet')) color = Colors.red;
    if (tag.contains('Regex')) color = Colors.teal;
    if (tag.contains('Jank') || tag.contains('Build')) color = Colors.deepOrange;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(3),
      ),
      child: Text(tag,
          style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: color)),
    );
  }
}
