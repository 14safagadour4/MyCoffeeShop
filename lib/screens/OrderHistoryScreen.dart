// lib/screens/order_history_screen.dart
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import '../models/order.dart';

class OrderHistoryScreen extends StatefulWidget {
  // Option A: pass local list OR listen to Firebase (we do Firebase)
  const OrderHistoryScreen({super.key});

  @override
  State<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen> {
  final DatabaseReference _ordersRef = FirebaseDatabase.instance.ref('orders');
  List<Order> _orders = [];

  @override
  void initState() {
    super.initState();
    _listenOrders();
  }

  void _listenOrders() {
    _ordersRef.onValue.listen((event) {
      final snapshot = event.snapshot;
      final Map<dynamic, dynamic>? map =
          snapshot.value as Map<dynamic, dynamic>?;
      if (map == null) {
        setState(() => _orders = []);
        return;
      }
      final list = <Order>[];
      map.forEach((key, value) {
        try {
          final order = Order.fromMap(value as Map<dynamic, dynamic>);
          list.add(order);
        } catch (_) {}
      });
      // sort by date desc
      list.sort((a, b) => b.date.compareTo(a.date));
      setState(() => _orders = list);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Text("📜 Historique des commandes"),
          backgroundColor: Colors.brown[400]),
      backgroundColor: const Color(0xFFF5E6D3),
      body: _orders.isEmpty
          ? const Center(
              child: Text("Aucune commande pour le moment 🥲",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)))
          : ListView.builder(
              itemCount: _orders.length,
              itemBuilder: (context, idx) {
                final o = _orders[idx];
                return Card(
                  margin:
                      const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                  child: ListTile(
                    title: Text(
                        "Commande ${o.id} — ${o.date.day}/${o.date.month}/${o.date.year}"),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Total: ${o.total.toStringAsFixed(2)} DT"),
                        Text(
                            "Type: ${o.isDelivery ? 'Livraison' : 'Sur place'}"),
                        if (o.isDelivery && o.deliveryData != null)
                          Text("Adresse: ${o.deliveryData!['address'] ?? '-'}"),
                        const SizedBox(height: 6),
                        ...o.items.map((it) =>
                            Text("- ${it['name']} (${it['price']} DT)")),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
