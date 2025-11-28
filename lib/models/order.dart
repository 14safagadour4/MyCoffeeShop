// lib/models/order.dart

class Order {
  final String id;
  final List<Map<String, dynamic>> items; // [{name,price,image?,qty?}, ...]
  final double total;
  final DateTime date;
  final bool isDelivery;
  final Map<String, dynamic>? deliveryData; // {name,phone,address,notes}

  Order({
    required this.id,
    required this.items,
    required this.total,
    required this.date,
    this.isDelivery = false,
    this.deliveryData,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'items': items.map((it) => Map<String, dynamic>.from(it)).toList(),
      'total': total,
      'date': date.toIso8601String(),
      'isDelivery': isDelivery,
      'deliveryData': deliveryData != null
          ? Map<String, dynamic>.from(deliveryData!)
          : null,
    };
  }

  factory Order.fromMap(Map<dynamic, dynamic> map) {
    return Order(
      id: map['id']?.toString() ?? '',
      items: (map['items'] as List<dynamic>?)
              ?.map((e) => Map<String, dynamic>.from(e as Map))
              .toList() ??
          [],
      total: (map['total'] is num)
          ? (map['total'] as num).toDouble()
          : double.tryParse('${map['total']}') ?? 0.0,
      date: DateTime.tryParse(map['date']?.toString() ?? '') ?? DateTime.now(),
      isDelivery: map['isDelivery'] == true,
      deliveryData: map['deliveryData'] != null
          ? Map<String, dynamic>.from(map['deliveryData'])
          : null,
    );
  }
}
