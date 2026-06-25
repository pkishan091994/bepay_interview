import 'package:bepay_interview/features/send_flow/domain/entities/recipient.dart';

class RecipientModel extends Recipient {
  const RecipientModel({
    required super.id,
    required super.name,
    required super.address,
    required super.type,
    required super.isExternal,
    super.badge,
    super.timestamp,
  });

  factory RecipientModel.fromJson(Map<String, dynamic> json) {
    return RecipientModel(
      id: json['id'] as String,
      name: json['name'] as String,
      address: json['address'] as String,
      type: _parseType(json['type'] as String),
      isExternal: json['isExternal'] as bool,
      badge: json['badge'] as String?,
      timestamp: json['timestamp'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'type': type.name,
      'isExternal': isExternal,
      'badge': badge,
      'timestamp': timestamp,
    };
  }

  static RecipientType _parseType(String typeStr) {
    return RecipientType.values.firstWhere(
      (e) => e.name == typeStr,
      orElse: () => RecipientType.bepayId,
    );
  }
}
