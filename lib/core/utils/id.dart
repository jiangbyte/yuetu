import 'package:uuid/uuid.dart';

const _uuid = Uuid();

/// 生成本地唯一 ID（兼容旧 createId 风格，改用 UUID 更稳）。
String createId() => _uuid.v4().replaceAll('-', '').substring(0, 16);
