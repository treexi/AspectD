/// ============================================================
/// @Inject 示例：埋点统计 - 在方法内部指定位置插入埋点代码
///
/// 场景：想在 login() 方法内部、登录成功后插入一行埋点上报代码。
/// @Inject 可以在目标方法的【指定行号】处注入代码。
/// lineNum 是目标文件的绝对行号（1-based）。
/// ============================================================
import 'package:beike_aspectd/aspectd.dart';
import 'package:example/log_store.dart';

@Aspect()
@pragma("vm:entry-point")
class InjectHook {
  @pragma("vm:entry-point")
  InjectHook();

  /// 在 UserService.login() 方法第12行（isLoggedIn = true 之后）注入埋点
  @Inject("package:example/services.dart", "UserService", "-login",
      lineNum: 12)
  @pragma("vm:entry-point")
  void hookLoginTrack(PointCut pointcut) {
    dynamic username; //Aspectd Ignore
    LogStore.instance.add('Inject', '埋点上报: 用户 $username 登录成功');
  }
}
