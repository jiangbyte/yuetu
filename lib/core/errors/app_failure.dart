/// 统一业务失败包装，便于 UI 层展示。
class AppFailure implements Exception {
  AppFailure(this.message, {this.cause});

  final String message;
  final Object? cause;

  @override
  String toString() => message;
}
