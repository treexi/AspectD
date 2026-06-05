/// ============================================================
/// @Execute 示例：权限校验 - 下单前自动检查登录状态
///
/// 场景：createOrder 必须登录后才能调用，不想每个调用处都写 if 判断。
/// @Execute 在方法的【定义处】包装，只要方法被执行就会触发。
/// 与 @Call 的区别：@Call 拦截调用者，@Execute 拦截被调用者本身。
/// ============================================================
import 'package:beike_aspectd/aspectd.dart';
import 'package:example/log_store.dart';
import 'package:example/services.dart';

@Aspect()
@pragma("vm:entry-point")
class ExecuteHook {
  @pragma("vm:entry-point")
  ExecuteHook();

  /// 拦截 OrderService.createOrder() 方法体
  /// 执行前检查登录状态，未登录则拦截
  @Execute("package:example/services.dart", "OrderService", "-createOrder")
  @pragma("vm:entry-point")
  dynamic hookCreateOrder(PointCut pointcut) {
    if (!UserService.isLoggedIn) {
      LogStore.instance.add('Execute', '下单被拦截: 用户未登录，请先登录！');
      return null;
    }
    final product = pointcut.positionalParams?[0] ?? '';
    LogStore.instance.add('Execute', '权限通过，正在创建订单: $product');
    return pointcut.proceed();
  }
}
