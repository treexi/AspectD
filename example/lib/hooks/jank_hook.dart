/// ============================================================
/// 页面卡顿监控说明
///
/// JankDemoPage 的性能问题由 RegexHook 自动捕获（无需额外 hook）：
/// - PageDataLoader.loadProductList() → initState 中的慢操作
/// - PageDataLoader.formatPrice() → build 中的重复计算
///
/// 因为 PageDataLoader 在 services.dart 中，
/// 已被 @Call("package:example/services.dart", ".*", "-.*", isRegex:true) 覆盖。
///
/// 注意：@Execute 对私有 State 类（_XxxState）的 initState/build
/// 目前有 transformer bug，暂不支持直接 hook。
/// 解决方案：把耗时逻辑抽到 service 类，让 regex hook 自动捕获。
/// ============================================================
library;
