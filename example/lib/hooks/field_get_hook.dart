/// ============================================================
/// @FieldGet 示例：动态配置 / A/B 测试 - 替换字段读取值
///
/// 场景：AppConfig.apiHost 写死了生产地址，测试时想切到测试环境，
///       不改源码，用 @FieldGet 在编译期替换字段返回值。
/// ============================================================
import 'package:beike_aspectd/aspectd.dart';
import 'package:example/log_store.dart';

@Aspect()
@pragma("vm:entry-point")
class FieldGetHook {
  /// 拦截 AppConfig.apiHost 字段读取，替换为测试环境地址
  @pragma("vm:entry-point")
  @FieldGet('package:example/services.dart', 'AppConfig', 'apiHost', false)
  static String hookApiHost(PointCut pointCut) {
    LogStore.instance.add('FieldGet', 'apiHost 被替换: production → testing');
    return 'https://api.testing.com';
  }
}
