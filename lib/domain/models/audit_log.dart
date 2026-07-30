class AuditLog {
  final String id;
  final String companyId;
  final String userId;
  final String entity;
  final String entityId;
  final String action;
  final DateTime timestamp;
  final String? details;

  AuditLog({
    required this.id,
    required this.companyId,
    required this.userId,
    required this.entity,
    required this.entityId,
    required this.action,
    required this.timestamp,
    this.details,
  });

  factory AuditLog.fromJson(Map<String, dynamic> json) {
    return AuditLog(
      id: json['id'] as String,
      companyId: json['companyId'] as String,
      userId: json['userId'] as String,
      entity: json['entity'] as String,
      entityId: json['entityId'] as String,
      action: json['action'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      details: json['details'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'companyId': companyId,
      'userId': userId,
      'entity': entity,
      'entityId': entityId,
      'action': action,
      'timestamp': timestamp.toIso8601String(),
      'details': details,
    };
  }
}
