import 'user_model.dart'; // <-- n'oublie pas ce import

class OrderItem {
  final String name;
  final double price;
  final int quantity;

  OrderItem({
    required this.name,
    required this.price,
    this.quantity = 1,
  });
}

class Order {
  final MyUser user;
  final List<OrderItem> items;
  final double deliveryFee;

  Order({
    required this.user,
    required this.items,
    this.deliveryFee = 0,
  });

  double get total =>
      items.fold(0.0, (sum, item) => sum + item.price * item.quantity) +
      deliveryFee;
}
