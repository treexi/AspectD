/// ============================================================
/// @Call + isRegex 示例：通配符性能监控 - 自动发现慢方法
///
/// 实际场景：App 偶现卡顿，不确定哪个方法慢。用通配符 Hook 拦截
/// 整个业务模块的所有方法调用，超过阈值自动上报，快速定位瓶颈。
///
/// 防递归：用 static _isProcessing 标志位，hook 内部的调用直接放行。
/// ============================================================
import 'package:beike_aspectd/aspectd.dart';
import 'package:example/log_store.dart';

@Aspect()
@pragma("vm:entry-point")
class RegexHook {
  @pragma("vm:entry-point")
  RegexHook();

  /// 重入保护
  static bool _isProcessing = false;

  /// 慢方法阈值（微秒），超过此值标记告警
  static const int _slowThreshold = 500; // 0.5ms

  /// 通配符拦截 services.dart 下所有类的所有实例方法
  @Call("package:example/services.dart", ".*", "-.*", isRegex: true)
  @pragma("vm:entry-point")
  dynamic hookAllMethods(PointCut pointcut) {
    if (_isProcessing) return pointcut.proceed();
    _isProcessing = true;
    try {
      final className = pointcut.target?.runtimeType.toString() ?? 'Unknown';
      final methodName = pointcut.function ?? 'unknown';
      final stopwatch = Stopwatch()..start();
      final result = pointcut.proceed();
      stopwatch.stop();
      final cost = stopwatch.elapsedMicroseconds;

      if (cost >= _slowThreshold) {
        LogStore.instance.add(
            'Regex', '⚠️ $className.$methodName 耗时: ${cost}μs');
      } else {
        LogStore.instance.add(
            'Regex', '$className.$methodName 耗时: ${cost}μs');
      }
      return result;
    } finally {
      _isProcessing = false;
    }
  }
}
