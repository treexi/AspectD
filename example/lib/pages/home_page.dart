import 'package:flutter/material.dart';
import 'package:example/log_store.dart';
import 'package:example/services.dart';
import 'package:example/pages/jank_demo_page.dart';

/// 首页 - 每个按钮对应一个 Hook 场景
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('AspectD 实战示例')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _ScenarioButton(
              title: '场景1: 性能监控（@Call）',
              subtitle: '自动统计 NetworkManager.get() 耗时',
              color: Colors.blue,
              onTap: () {
                final net = NetworkManager();
                final result = net.get('/api/user/info');
                LogStore.instance.add('结果', 'GET 返回: $result');
              },
            ),
            const SizedBox(height: 8),
            _ScenarioButton(
              title: '场景2: 权限校验（@Execute）',
              subtitle: '下单前自动检查登录状态',
              color: Colors.orange,
              onTap: () {
                final order = OrderService();
                final result = order.createOrder('iPhone 15', 1);
                LogStore.instance.add('结果', '订单号: $result');
              },
            ),
            const SizedBox(height: 8),
            _ScenarioButton(
              title: '场景3: 埋点注入（@Inject）',
              subtitle: '在 login() 内部自动插入埋点上报',
              color: Colors.purple,
              onTap: () {
                final user = UserService();
                user.login('Tracy', '123456');
                LogStore.instance.add('结果', '登录完成, isLoggedIn=${UserService.isLoggedIn}');
              },
            ),
            const SizedBox(height: 8),
            _ScenarioButton(
              title: '场景4: 动态加方法（@Add）',
              subtitle: '给 NetworkManager 添加 cachedGet()',
              color: Colors.green,
              onTap: () {
                dynamic net = NetworkManager();
                final result = net.cachedGet('/api/home/banner');
                LogStore.instance.add('结果', 'cachedGet 返回: $result');
              },
            ),
            const SizedBox(height: 8),
            _ScenarioButton(
              title: '场景5: 配置替换（@FieldGet）',
              subtitle: '读取 AppConfig.apiHost 时替换为测试环境',
              color: Colors.red,
              onTap: () {
                final config = AppConfig();
                final host = config.apiHost;
                LogStore.instance.add('结果', '实际读到的 apiHost = $host');
              },
            ),
            const SizedBox(height: 8),
            _ScenarioButton(
              title: '场景6: 通配符监控（@Call+isRegex）',
              subtitle: '自动发现慢方法: DB查询/JSON解析/图片压缩',
              color: Colors.teal,
              onTap: () {
                final db = DatabaseHelper();
                db.queryUsers();
                db.insert('orders', {'product': 'iPhone', 'qty': 1});

                final parser = JsonParser();
                parser.parseProductList('[...]');
                parser.parseUserDetail('{}');

                final img = ImageProcessor();
                img.compress('/sdcard/photo.jpg', 80);
                img.cacheKey('https://img.cdn.com/1.jpg');

                LogStore.instance.add('结果', '超过500μs的方法会标记 ⚠️');
              },
            ),
            const SizedBox(height: 8),
            _ScenarioButton(
              title: '场景7: 页面卡顿检测',
              subtitle: 'initState耗时 + build重复渲染（查看悬浮日志）',
              color: Colors.deepOrange,
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const JankDemoPage()),
                );
              },
            ),
            // 为悬浮面板留出空间
            const SizedBox(height: 240),
          ],
        ),
      ),
    );
  }
}

/// 场景按钮组件
class _ScenarioButton extends StatelessWidget {
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _ScenarioButton({
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          border: Border.all(color: color.withOpacity(0.3)),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(Icons.play_circle_outline, color: color, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: TextStyle(
                          fontSize: 14, fontWeight: FontWeight.w600, color: color)),
                  Text(subtitle,
                      style: const TextStyle(fontSize: 12, color: Colors.grey)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
