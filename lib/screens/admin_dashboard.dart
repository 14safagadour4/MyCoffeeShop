import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:intl/intl.dart';
import '../models/invoice_model.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  final db = FirebaseDatabase.instance.ref();
  List<Invoice> allOrders = [];
  List<Invoice> filteredOrders = [];
  bool isLoading = true;
  String filterStatus =
      'all'; // 'all', 'confirmed', 'preparing', 'ready', 'delivered'

  @override
  void initState() {
    super.initState();
    _loadAllOrders();
  }

  void _loadAllOrders() {
    db.child("orders").onValue.listen((event) {
      final data = event.snapshot.value as Map?;
      if (data == null) {
        if (mounted) {
          setState(() {
            isLoading = false;
          });
        }
        return;
      }

      final List<Invoice> loadedOrders = [];
      data.forEach((key, value) {
        if (value != null) {
          loadedOrders.add(Invoice(
            id: value["id"]?.toString() ?? key,
            date: DateTime.parse(value["date"] ?? DateTime.now().toString()),
            total: (value["total"] as num?)?.toDouble() ?? 0.0,
            isDelivery: value["isDelivery"] ?? false,
            deliveryInfo: value["deliveryInfo"] != null
                ? Map<String, dynamic>.from(value["deliveryInfo"])
                : null,
            items: List<Map<String, dynamic>>.from(value["items"] ?? []),
            status: value["status"] ?? "confirmed",
          ));
        }
      });

      if (mounted) {
        setState(() {
          allOrders = loadedOrders;
          filteredOrders = _filterOrders(loadedOrders, filterStatus);
          isLoading = false;
        });
      }
    });
  }

  List<Invoice> _filterOrders(List<Invoice> orders, String status) {
    if (status == 'all') return orders;
    return orders.where((order) => order.status == status).toList();
  }

  void _updateOrderStatus(String orderId, String newStatus) {
    db.child("orders/$orderId/status").set(newStatus);
  }

  double get todayRevenue {
    final today = DateTime.now();
    return allOrders
        .where((order) =>
            order.date.day == today.day &&
            order.date.month == today.month &&
            order.date.year == today.year)
        .fold(0, (sum, order) => sum + order.total);
  }

  int get pendingOrders {
    return allOrders
        .where((order) =>
            order.status == 'confirmed' || order.status == 'preparing')
        .length;
  }

  Widget _buildStatsCard(
      String title, String value, Color color, IconData icon) {
    return Card(
      elevation: 4,
      child: Container(
        padding: EdgeInsets.all(16),
        width: 150,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
            SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderCard(Invoice order) {
    return Card(
      margin: EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Commande #${order.id.substring(0, 8)}",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getStatusColor(order.status),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _getStatusText(order.status),
                    style: TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            Text(
              DateFormat('dd/MM/yyyy HH:mm').format(order.date),
              style: TextStyle(color: Colors.grey),
            ),
            SizedBox(height: 8),
            Text(
              "${order.items.length} article(s) - ${order.total.toStringAsFixed(2)} DT",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            if (order.isDelivery && order.deliveryInfo != null) ...[
              SizedBox(height: 8),
              Text(
                "📍 ${order.deliveryInfo!['address']}",
                style: TextStyle(color: Colors.blue),
              ),
            ],
            SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: order.status,
                    items: [
                      DropdownMenuItem(
                          value: 'confirmed', child: Text('Confirmée')),
                      DropdownMenuItem(
                          value: 'preparing', child: Text('En préparation')),
                      DropdownMenuItem(value: 'ready', child: Text('Prête')),
                      DropdownMenuItem(
                          value: 'delivered', child: Text('Livrée')),
                    ],
                    onChanged: (newStatus) {
                      if (newStatus != null) {
                        _updateOrderStatus(order.id, newStatus);
                      }
                    },
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'confirmed':
        return Colors.orange;
      case 'preparing':
        return Colors.blue;
      case 'ready':
        return Colors.green;
      case 'delivered':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'confirmed':
        return 'Confirmée';
      case 'preparing':
        return 'En préparation';
      case 'ready':
        return 'Prête';
      case 'delivered':
        return 'Livrée';
      default:
        return status;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Dashboard Admin"),
        backgroundColor: Colors.red,
        actions: [
          PopupMenuButton<String>(
            onSelected: (status) {
              setState(() {
                filterStatus = status;
                filteredOrders = _filterOrders(allOrders, status);
              });
            },
            itemBuilder: (context) => [
              PopupMenuItem(value: 'all', child: Text('Toutes les commandes')),
              PopupMenuItem(value: 'confirmed', child: Text('Confirmées')),
              PopupMenuItem(value: 'preparing', child: Text('En préparation')),
              PopupMenuItem(value: 'ready', child: Text('Prêtes')),
              PopupMenuItem(value: 'delivered', child: Text('Livrées')),
            ],
          ),
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Statistiques
                  Text(
                    "Aperçu du jour",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 16),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildStatsCard(
                          "Revenue du jour",
                          "${todayRevenue.toStringAsFixed(2)} DT",
                          Colors.green,
                          Icons.attach_money,
                        ),
                        SizedBox(width: 12),
                        _buildStatsCard(
                          "Commandes en cours",
                          "$pendingOrders",
                          Colors.orange,
                          Icons.pending_actions,
                        ),
                        SizedBox(width: 12),
                        _buildStatsCard(
                          "Total commandes",
                          "${allOrders.length}",
                          Colors.blue,
                          Icons.shopping_cart,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 24),

                  // Liste des commandes
                  Text(
                    "Commandes récentes",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 16),

                  if (filteredOrders.isEmpty)
                    Center(
                      child: Column(
                        children: [
                          Icon(Icons.receipt_long,
                              size: 64, color: Colors.grey),
                          SizedBox(height: 16),
                          Text("Aucune commande trouvée"),
                        ],
                      ),
                    )
                  else
                    Column(
                      children: filteredOrders
                          .map((order) => _buildOrderCard(order))
                          .toList(),
                    ),
                ],
              ),
            ),
    );
  }
}
