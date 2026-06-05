/// ============================================================
/// 模拟业务类 - 用于被 AspectD Hook 拦截
/// ============================================================

/// 用户服务 - 模拟登录、获取用户信息
class UserService {
  static bool isLoggedIn = false;

  /// 登录
  void login(String username, String password) {
    isLoggedIn = true;
  }

  /// 获取用户信息
  String getUserInfo() {
    return '用户: Tracy, VIP等级: 3';
  }
}

/// 网络请求管理 - 模拟发起请求
class NetworkManager {
  /// 发起 GET 请求
  String get(String url) {
    return '{"code":200, "data":"ok"}';
  }

  /// 发起 POST 请求
  String post(String url, Map<String, dynamic> body) {
    return '{"code":200, "msg":"success"}';
  }
}

/// 订单服务 - 模拟下单
class OrderService {
  /// 创建订单
  String createOrder(String productName, int quantity) {
    return 'ORDER_${DateTime.now().millisecondsSinceEpoch}';
  }
}

/// App 配置
class AppConfig {
  /// 服务器地址（可被 @FieldGet 替换）
  String apiHost = 'https://api.production.com';

  /// 是否开启调试模式
  bool debugMode = false;
}

/// ============================================================
/// 以下为模拟耗时业务 - 用于 Regex Hook 性能监控演示
/// ============================================================

/// 数据库操作 - 模拟本地数据读写
class DatabaseHelper {
  /// 查询用户列表（模拟慢查询）
  List<String> queryUsers() {
    // 模拟数据库扫描耗时
    var sum = 0;
    for (var i = 0; i < 100000; i++) {
      sum += i;
    }
    return ['Tracy', 'Alice', 'Bob'];
  }

  /// 插入一条记录
  bool insert(String table, Map<String, dynamic> data) {
    // 模拟写入
    var sum = 0;
    for (var i = 0; i < 50000; i++) {
      sum += i;
    }
    return true;
  }
}

/// JSON 解析 - 模拟大数据反序列化
class JsonParser {
  /// 解析商品列表（模拟大 JSON）
  List<Map<String, dynamic>> parseProductList(String json) {
    // 模拟复杂解析
    final list = <Map<String, dynamic>>[];
    for (var i = 0; i < 1000; i++) {
      list.add({'id': i, 'name': 'Product_$i', 'price': i * 10.5});
    }
    return list;
  }

  /// 解析用户详情
  Map<String, dynamic> parseUserDetail(String json) {
    return {'name': 'Tracy', 'vip': 3, 'balance': 9999.99};
  }
}

/// 页面数据加载 - 模拟 initState 中的耗时操作
class PageDataLoader {
  /// 同步加载商品列表（模拟 initState 中的慢操作）
  List<String> loadProductList() {
    var sum = 0;
    for (var i = 0; i < 500000; i++) {
      sum += i;
    }
    return List.generate(50, (i) => '商品 ${i + 1} - ¥${(i + 1) * 29.9}');
  }

  /// 格式化价格（模拟 build 中的重复计算）
  String formatPrice(int index) {
    var result = '';
    for (var i = 0; i < 10000; i++) {
      result = '¥${(index + 1) * 29.9}';
    }
    return result;
  }
}

/// 图片处理 - 模拟图片压缩/缓存
class ImageProcessor {
  /// 压缩图片（模拟 CPU 密集型操作）
  String compress(String path, int quality) {
    var sum = 0;
    for (var i = 0; i < 200000; i++) {
      sum += i;
    }
    return '${path}_compressed_q$quality';
  }

  /// 计算缓存 key
  String cacheKey(String url) {
    return url.hashCode.toRadixString(16);
  }
}

