// models/invoice_model.dart
class Invoice {
  final String id;
  final DateTime date;
  final double total;
  final bool isDelivery;
  final Map<String, dynamic>? deliveryInfo;
  final List<Map<String, dynamic>> items;
  final String status;

  Invoice({
    required this.id,
    required this.date,
    required this.total,
    required this.isDelivery,
    this.deliveryInfo,
    required this.items,
    this.status = "confirmed",
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date.millisecondsSinceEpoch,
      'total': total,
      'isDelivery': isDelivery,
      'deliveryInfo': deliveryInfo,
      'items': items,
      'status': status,
    };
  }

  factory Invoice.fromMap(Map<String, dynamic> map) {
    return Invoice(
      id: map['id'] ?? '',
      date: DateTime.fromMillisecondsSinceEpoch(map['date'] ?? 0),
      total: (map['total'] as num).toDouble(),
      isDelivery: map['isDelivery'] ?? false,
      deliveryInfo: map['deliveryInfo'],
      items: List<Map<String, dynamic>>.from(map['items'] ?? []),
      status: map['status'] ?? 'confirmed',
    );
  }
}
