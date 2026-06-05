/// ============================================================
/// @Call 示例：性能监控 - 自动统计方法调用耗时
///
/// 场景：想知道网络请求耗时多久，不改业务代码，用 AOP 自动打点。
/// @Call 在方法的【调用处】拦截，调用前后可加逻辑。
/// ============================================================
import 'package:beike_aspectd/aspectd.dart';
import 'package:example/log_store.dart';

@Aspect()
@pragma("vm:entry-point")
class CallHook {
  @pragma("vm:entry-point")
  CallHook();

  /// 拦截 NetworkManager.get() 的每一个调用处
  /// 自动记录请求 URL 和耗时
  @Call("package:example/services.dart", "NetworkManager", "-get")
  @pragma("vm:entry-point")
  dynamic hookNetworkGet(PointCut pointcut) {
    final url = pointcut.positionalParams?[0] ?? '';
    final stopwatch = Stopwatch()..start();
    final result = pointcut.proceed();
    stopwatch.stop();
    LogStore.instance.add('Call',
        '网络请求 GET $url 耗时: ${stopwatch.elapsedMicroseconds}μs');
    return result;
  }
}
