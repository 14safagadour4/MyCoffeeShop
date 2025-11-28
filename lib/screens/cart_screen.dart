import 'package:flutter/material.dart';
import 'delivery_form_screen.dart';
import 'package:intl/intl.dart';
import '../models/invoice_model.dart';

class CartScreen extends StatefulWidget {
  final List<Map<String, dynamic>> cart;
  final List<Invoice> invoiceHistory; // Historique reçu du parent
  final Function(Invoice)? onOrderConfirmed;

  const CartScreen({
    super.key,
    required this.cart,
    required this.invoiceHistory, // Maintenant obligatoire
    this.onOrderConfirmed,
  });

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  bool _isDelivery = false;
  Map<String, dynamic>? _deliveryInfo;
  // SUPPRIMÉ: final List<Invoice> _invoiceHistory = [];

  double get total {
    return widget.cart.fold(0, (sum, item) {
      return sum + (item["price"] * (item["quantity"] ?? 1));
    });
  }

  double get deliveryFee {
    return _isDelivery ? 3.0 : 0.0;
  }

  double get grandTotal {
    return total + deliveryFee;
  }

  String _generateInvoiceId() {
    return 'INV-${DateTime.now().millisecondsSinceEpoch}';
  }

  void _confirmOrder() {
    if (_isDelivery && _deliveryInfo == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text("Veuillez d'abord remplir les informations de livraison"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Créer la facture
    final invoice = Invoice(
      id: _generateInvoiceId(),
      date: DateTime.now(),
      total: grandTotal,
      isDelivery: _isDelivery,
      deliveryInfo: _deliveryInfo,
      items: List<Map<String, dynamic>>.from(widget.cart),
      status: "confirmed",
    );

    // Appeler le callback pour sauvegarder dans l'historique parent
    if (widget.onOrderConfirmed != null) {
      widget.onOrderConfirmed!(invoice);
    }

    // Afficher la confirmation
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Commande Confirmée ✅"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Merci pour votre commande!"),
            SizedBox(height: 10),
            Text("Numéro de facture: ${invoice.id}"),
            Text("Total: ${grandTotal.toStringAsFixed(2)} DT"),
            if (_isDelivery && _deliveryInfo != null) ...[
              SizedBox(height: 10),
              Text("Livraison à: ${_deliveryInfo!['address']}"),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop(); // Retour au menu
            },
            child: Text("OK"),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _showInvoiceDetails(invoice);
            },
            child: Text("Voir détails"),
          ),
        ],
      ),
    );
  }

  void _showInvoiceDetails(Invoice invoice) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Container(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "📋 Détails de la facture",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.brown,
              ),
            ),
            SizedBox(height: 16),
            _buildInvoiceDetailRow("Numéro:", invoice.id),
            _buildInvoiceDetailRow(
                "Date:", DateFormat('dd/MM/yyyy HH:mm').format(invoice.date)),
            _buildInvoiceDetailRow(
                "Type:", invoice.isDelivery ? "Livraison" : "Sur place"),
            _buildInvoiceDetailRow("Statut:", invoice.status),
            SizedBox(height: 16),
            Text(
              "Articles:",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            ...invoice.items
                .map((item) => Padding(
                      padding: EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: Text(item["name"]),
                          ),
                          Expanded(
                            child: Text(
                                "${item["quantity"]} x ${item["price"]} DT"),
                          ),
                          Expanded(
                            child: Text(
                              "${(item["price"] * (item["quantity"] ?? 1)).toStringAsFixed(2)} DT",
                              textAlign: TextAlign.right,
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    ))
                ,
            SizedBox(height: 16),
            Divider(),
            _buildInvoiceDetailRow(
                "Sous-total:", "${total.toStringAsFixed(2)} DT"),
            _buildInvoiceDetailRow(
                "Frais de livraison:", "${deliveryFee.toStringAsFixed(2)} DT"),
            _buildInvoiceDetailRow(
              "TOTAL:",
              "${invoice.total.toStringAsFixed(2)} DT",
              isBold: true,
              color: Colors.brown,
            ),
            if (invoice.isDelivery && invoice.deliveryInfo != null) ...[
              SizedBox(height: 16),
              Text(
                "Informations de livraison:",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              _buildInvoiceDetailRow("Nom:", invoice.deliveryInfo!['name']),
              _buildInvoiceDetailRow(
                  "Téléphone:", invoice.deliveryInfo!['phone']),
              _buildInvoiceDetailRow(
                  "Adresse:", invoice.deliveryInfo!['address']),
            ],
            SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text("Fermer"),
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      _showInvoiceHistory();
                    },
                    child: Text("Historique"),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInvoiceDetailRow(String label, String value,
      {bool isBold = false, Color? color}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
                color: color,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: TextStyle(
                fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showInvoiceHistory() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Container(
        padding: EdgeInsets.all(20),
        height: MediaQuery.of(context).size.height * 0.8,
        child: Column(
          children: [
            Text(
              "📜 Historique des factures",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.brown,
              ),
            ),
            SizedBox(height: 16),
            widget.invoiceHistory.isEmpty // Utiliser l'historique du parent
                ? Expanded(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.receipt_long,
                              size: 64, color: Colors.grey),
                          SizedBox(height: 16),
                          Text(
                            "Aucune facture",
                            style: TextStyle(fontSize: 16, color: Colors.grey),
                          ),
                          Text(
                            "Vos commandes apparaîtront ici",
                            style: TextStyle(fontSize: 14, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  )
                : Expanded(
                    child: ListView.builder(
                      itemCount: widget.invoiceHistory
                          .length, // Utiliser l'historique du parent
                      itemBuilder: (context, index) {
                        final invoice = widget.invoiceHistory.reversed
                            .toList()[index]; // Utiliser l'historique du parent
                        return Card(
                          margin: EdgeInsets.only(bottom: 10),
                          child: ListTile(
                            leading: Icon(
                              invoice.isDelivery
                                  ? Icons.delivery_dining
                                  : Icons.restaurant,
                              color: Colors.brown,
                            ),
                            title: Text("Facture ${invoice.id}"),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(DateFormat('dd/MM/yyyy HH:mm')
                                    .format(invoice.date)),
                                Text("${invoice.total.toStringAsFixed(2)} DT"),
                                Text(
                                  invoice.isDelivery
                                      ? "Livraison"
                                      : "Sur place",
                                  style: TextStyle(
                                    color: invoice.isDelivery
                                        ? Colors.green
                                        : Colors.blue,
                                  ),
                                ),
                              ],
                            ),
                            trailing: Icon(Icons.arrow_forward_ios, size: 16),
                            onTap: () {
                              Navigator.pop(context);
                              _showInvoiceDetails(invoice);
                            },
                          ),
                        );
                      },
                    ),
                  ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Fermer"),
            ),
          ],
        ),
      ),
    );
  }

  void _goToDeliveryForm() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DeliveryFormScreen(),
      ),
    );

    if (result != null && result is Map<String, dynamic>) {
      setState(() {
        _deliveryInfo = result;
        _isDelivery = true;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Informations de livraison enregistrées"),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  void _removeFromCart(int index) {
    setState(() {
      widget.cart.removeAt(index);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Produit retiré du panier"),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _updateQuantity(int index, int newQuantity) {
    if (newQuantity <= 0) {
      _removeFromCart(index);
      return;
    }

    setState(() {
      widget.cart[index]["quantity"] = newQuantity;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Panier"),
        backgroundColor: Colors.brown,
        actions: [
          if (widget.cart.isNotEmpty) ...[
            IconButton(
              icon: Icon(Icons.history),
              onPressed: _showInvoiceHistory,
              tooltip: "Historique des factures",
            ),
            IconButton(
              icon: Icon(Icons.delete_sweep),
              onPressed: () {
                setState(() {
                  widget.cart.clear();
                  _isDelivery = false;
                  _deliveryInfo = null;
                });
              },
              tooltip: "Vider le panier",
            ),
          ],
        ],
      ),
      body: widget.cart.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.shopping_cart_outlined,
                      size: 80, color: Colors.grey),
                  SizedBox(height: 20),
                  Text(
                    "Votre panier est vide",
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  SizedBox(height: 10),
                  Text(
                    "Ajoutez des produits depuis le menu",
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: _showInvoiceHistory,
                    icon: Icon(Icons.history),
                    label: Text("Voir l'historique des factures"),
                  ),
                ],
              ),
            )
          : Column(
              children: [
                // Liste des produits
                Expanded(
                  child: ListView.builder(
                    padding: EdgeInsets.all(16),
                    itemCount: widget.cart.length,
                    itemBuilder: (context, index) {
                      final item = widget.cart[index];
                      final quantity = item["quantity"] ?? 1;
                      final itemTotal = item["price"] * quantity;

                      return Card(
                        margin: EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          leading: Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color: Colors.brown[100],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Center(
                              child: Text(
                                item["name"][0],
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.brown,
                                ),
                              ),
                            ),
                          ),
                          title: Text(item["name"]),
                          subtitle: Text("${item["price"]} DT x $quantity"),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: Icon(Icons.remove_circle_outline,
                                    color: Colors.red),
                                onPressed: () =>
                                    _updateQuantity(index, quantity - 1),
                              ),
                              Text("$quantity"),
                              IconButton(
                                icon: Icon(Icons.add_circle_outline,
                                    color: Colors.green),
                                onPressed: () =>
                                    _updateQuantity(index, quantity + 1),
                              ),
                              SizedBox(width: 10),
                              Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    "${itemTotal.toStringAsFixed(2)} DT",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.delete,
                                        color: Colors.grey, size: 18),
                                    onPressed: () => _removeFromCart(index),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),

                // Section livraison
                if (_isDelivery && _deliveryInfo != null)
                  Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.green[50],
                      border: Border(top: BorderSide(color: Colors.green)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "📦 Livraison à domicile",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                            fontSize: 16,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text("Nom: ${_deliveryInfo!['name']}"),
                        Text("Téléphone: ${_deliveryInfo!['phone']}"),
                        Text("Adresse: ${_deliveryInfo!['address']}"),
                        SizedBox(height: 8),
                        Row(
                          children: [
                            Text(
                              "Frais de livraison: $deliveryFee DT",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Spacer(),
                            TextButton(
                              onPressed: _goToDeliveryForm,
                              child: Text("Modifier"),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                // Section total et boutons
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.brown[50],
                    border: Border(top: BorderSide(color: Colors.brown)),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Sous-total:"),
                          Text("${total.toStringAsFixed(2)} DT"),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Frais de livraison:"),
                          Text("$deliveryFee DT"),
                        ],
                      ),
                      Divider(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Total:",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            "${grandTotal.toStringAsFixed(2)} DT",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.brown,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: _goToDeliveryForm,
                              icon: Icon(Icons.delivery_dining),
                              label: Text(_isDelivery
                                  ? "Modifier Livraison"
                                  : "Livraison à domicile"),
                              style: OutlinedButton.styleFrom(
                                foregroundColor:
                                    _isDelivery ? Colors.green : Colors.brown,
                                side: BorderSide(
                                    color: _isDelivery
                                        ? Colors.green
                                        : Colors.brown),
                                padding: EdgeInsets.symmetric(vertical: 12),
                              ),
                            ),
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: _confirmOrder,
                              icon: Icon(Icons.check_circle),
                              label: Text("Confirmer"),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.brown,
                                foregroundColor: Colors.white,
                                padding: EdgeInsets.symmetric(vertical: 12),
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (!_isDelivery)
                        Padding(
                          padding: EdgeInsets.only(top: 8),
                          child: Text(
                            "Commande sur place",
                            style: TextStyle(
                              color: Colors.grey,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
