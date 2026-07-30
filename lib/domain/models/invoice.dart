enum InvoiceStatus { draft, sent, paid, overdue }

class Invoice {
  final String id;
  final String invoiceNumber;
  final String customerId;
  final DateTime issueDate;
  final DateTime dueDate;
  final double subtotal;
  final double taxAmount;
  final double discount;
  final double total;
  final InvoiceStatus status;
  final String? notes;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Invoice({
    required this.id,
    required this.invoiceNumber,
    required this.customerId,
    required this.issueDate,
    required this.dueDate,
    this.subtotal = 0.0,
    this.taxAmount = 0.0,
    this.discount = 0.0,
    this.total = 0.0,
    this.status = InvoiceStatus.draft,
    this.notes,
    this.createdAt,
    this.updatedAt,
  });

  factory Invoice.fromJson(Map<String, dynamic> json) {
    return Invoice(
      id: json['id'] as String,
      invoiceNumber: json['invoiceNumber'] as String,
      customerId: json['customerId'] as String,
      issueDate: DateTime.parse(json['issueDate'] as String),
      dueDate: DateTime.parse(json['dueDate'] as String),
      subtotal: (json['subtotal'] as num).toDouble(),
      taxAmount: (json['taxAmount'] as num).toDouble(),
      discount: (json['discount'] as num).toDouble(),
      total: (json['total'] as num).toDouble(),
      status: InvoiceStatus.values.firstWhere(
        (e) => e.name == (json['status'] as String),
        orElse: () => InvoiceStatus.draft,
      ),
      notes: json['notes'] as String?,
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt'] as String) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt'] as String) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'invoiceNumber': invoiceNumber,
      'customerId': customerId,
      'issueDate': issueDate.toIso8601String(),
      'dueDate': dueDate.toIso8601String(),
      'subtotal': subtotal,
      'taxAmount': taxAmount,
      'discount': discount,
      'total': total,
      'status': status.name,
      'notes': notes,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  Invoice copyWith({
    String? id,
    String? invoiceNumber,
    String? customerId,
    DateTime? issueDate,
    DateTime? dueDate,
    double? subtotal,
    double? taxAmount,
    double? discount,
    double? total,
    InvoiceStatus? status,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Invoice(
      id: id ?? this.id,
      invoiceNumber: invoiceNumber ?? this.invoiceNumber,
      customerId: customerId ?? this.customerId,
      issueDate: issueDate ?? this.issueDate,
      dueDate: dueDate ?? this.dueDate,
      subtotal: subtotal ?? this.subtotal,
      taxAmount: taxAmount ?? this.taxAmount,
      discount: discount ?? this.discount,
      total: total ?? this.total,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
