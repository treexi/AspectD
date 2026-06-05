/// ============================================================
/// @Add 示例：给已有类动态添加方法
///
/// 场景：NetworkManager 是别人写的/第三方库的类，你想给它加一个
///       带缓存功能的请求方法，但不想（或不能）改它的源码。
/// @Add 可以在编译期给目标类注入新方法。
/// ============================================================
import 'package:beike_aspectd/aspectd.dart';
import 'package:example/log_store.dart';

@Aspect()
@pragma("vm:entry-point")
class AddHook {
  @pragma("vm:entry-point")
  AddHook();

  /// 给 NetworkManager 添加一个 cachedGet 方法
  /// 运行时可通过 dynamic 调用: (networkManager as dynamic).cachedGet(url)
  @Add("package:example/services.dart", "NetworkManager")
  @pragma("vm:entry-point")
  dynamic cachedGet(PointCut pointCut, String url) {
    LogStore.instance.add('Add', '调用动态添加的 cachedGet("$url") - 优先读缓存');
    return '{"code":200, "data":"cached_result", "from":"cache"}';
  }
}
