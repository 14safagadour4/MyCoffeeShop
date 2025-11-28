import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'dart:async';
import 'cart_screen.dart';
import '../models/invoice_model.dart';
import 'chat_screen.dart';

class MenuScreen extends StatefulWidget {
  final String clientId;
  final String tableId;
  final Map<String, List<String>> clientHistory;

  const MenuScreen({
    super.key,
    required this.clientId,
    required this.tableId,
    required this.clientHistory,
  });

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  final db = FirebaseDatabase.instance.ref();

  List<Map<String, dynamic>> categories = [];
  List<Map<String, dynamic>> products = [];
  List<Map<String, dynamic>> filteredProducts = [];
  List<Map<String, dynamic>> cart = [];
  List<Invoice> invoiceHistory = [];

  bool isLoading = true;
  bool hasError = false;
  String selectedCategory = "1";
  String currentLanguage = 'fr'; // 'fr', 'en', 'ar'
  StreamSubscription? _categoriesSubscription;
  StreamSubscription? _productsSubscription;

  // Traductions - seulement l'interface
  final Map<String, Map<String, String>> translations = {
    'fr': {
      'menu': 'Menu',
      'table': 'Table',
      'loading': 'Chargement du menu...',
      'error': 'Erreur de chargement',
      'check_connection': 'Vérifiez votre connexion Internet',
      'retry': 'Réessayer',
      'no_products': 'Aucun produit disponible',
      'for_category': 'pour cette catégorie',
      'added_to_cart': 'ajouté au panier 🛒',
      'order_confirmed': 'Commande confirmée avec succès!',
      'history': 'Historique',
      'orders_history': 'Historique des Commandes',
      'no_orders': 'Aucune commande',
      'orders_appear': 'Vos commandes apparaîtront ici',
      'order_details': 'Détails de la commande',
      'invoice_number': 'Numéro',
      'date': 'Date',
      'type': 'Type',
      'status': 'Statut',
      'delivery': 'Livraison',
      'on_site': 'Sur place',
      'items': 'Articles',
      'total': 'Total',
      'delivery_info': 'Informations de livraison',
      'name': 'Nom',
      'phone': 'Téléphone',
      'address': 'Adresse',
      'close': 'Fermer',
      'categories': 'Catégories',
      'products': 'Produits',
      'cart': 'Panier',
      'confirmed': 'Confirmée',
      'delivery_fee': 'Frais de livraison',
      'see_details': 'Voir détails',
      'order': 'Commande',
      'drinks': 'Boissons',
      'desserts': 'Desserts',
      'good_eat': 'Bonnes Bouffes',
      'coffees': 'Cafés',
    },
    'en': {
      'menu': 'Menu',
      'table': 'Table',
      'loading': 'Loading menu...',
      'error': 'Loading error',
      'check_connection': 'Check your internet connection',
      'retry': 'Retry',
      'no_products': 'No products available',
      'for_category': 'for this category',
      'added_to_cart': 'added to cart 🛒',
      'order_confirmed': 'Order confirmed successfully!',
      'history': 'History',
      'orders_history': 'Orders History',
      'no_orders': 'No orders',
      'orders_appear': 'Your orders will appear here',
      'order_details': 'Order Details',
      'invoice_number': 'Number',
      'date': 'Date',
      'type': 'Type',
      'status': 'Status',
      'delivery': 'Delivery',
      'on_site': 'On site',
      'items': 'Items',
      'total': 'Total',
      'delivery_info': 'Delivery Information',
      'name': 'Name',
      'phone': 'Phone',
      'address': 'Address',
      'close': 'Close',
      'categories': 'Categories',
      'products': 'Products',
      'cart': 'Cart',
      'confirmed': 'Confirmed',
      'delivery_fee': 'Delivery fee',
      'see_details': 'See details',
      'order': 'Order',
      'drinks': 'Drinks',
      'desserts': 'Desserts',
      'good_eat': 'Good Eat',
      'coffees': 'Coffees',
    },
    'ar': {
      'menu': 'قائمة الطعام',
      'table': 'طاولة',
      'loading': 'جاري تحميل القائمة...',
      'error': 'خطأ في التحميل',
      'check_connection': 'تحقق من اتصال الإنترنت',
      'retry': 'إعادة المحاولة',
      'no_products': 'لا توجد منتجات متاحة',
      'for_category': 'لهذه الفئة',
      'added_to_cart': 'تمت الإضافة إلى السلة 🛒',
      'order_confirmed': 'تم تأكيد الطلب بنجاح!',
      'history': 'السجل',
      'orders_history': 'سجل الطلبات',
      'no_orders': 'لا توجد طلبات',
      'orders_appear': 'ستظهر طلباتك هنا',
      'order_details': 'تفاصيل الطلب',
      'invoice_number': 'الرقم',
      'date': 'التاريخ',
      'type': 'النوع',
      'status': 'الحالة',
      'delivery': 'توصيل',
      'on_site': 'في الموقع',
      'items': 'المنتجات',
      'total': 'المجموع',
      'delivery_info': 'معلومات التوصيل',
      'name': 'الاسم',
      'phone': 'الهاتف',
      'address': 'العنوان',
      'close': 'إغلاق',
      'categories': 'الفئات',
      'products': 'المنتجات',
      'cart': 'السلة',
      'confirmed': 'مؤكدة',
      'delivery_fee': 'رسوم التوصيل',
      'see_details': 'رؤية التفاصيل',
      'order': 'طلب',
      'drinks': 'مشروبات',
      'desserts': 'حلويات',
      'good_eat': 'أكلات لذيذة',
      'coffees': 'قهوة',
    },
  };

  String translateCategory(String categoryName) {
    String cleanName = categoryName.trim().toLowerCase();

    if (cleanName.contains('drink') ||
        cleanName == 'drinks' ||
        cleanName == 'boissons') {
      return translate('drinks');
    }
    if (cleanName.contains('dessert') ||
        cleanName == 'desserts' ||
        cleanName == 'حلويات') {
      return translate('desserts');
    }
    if (cleanName.contains('good eat') ||
        cleanName.contains('good_eat') ||
        cleanName.contains('snack') ||
        cleanName == 'أكلات لذيذة') {
      return translate('good_eat');
    }
    if (cleanName.contains('coffee') ||
        cleanName.contains('cafe') ||
        cleanName == 'coffees' ||
        cleanName == 'قهوة') {
      return translate('coffees');
    }

    return categoryName;
  }

  String translate(String key) {
    return translations[currentLanguage]![key] ?? key;
  }

  @override
  void initState() {
    super.initState();
    print(
        "🟡 MenuScreen init - Client: ${widget.clientId}, Table: ${widget.tableId}");
    _testFirebaseConnection();
    _loadData();
  }

  void _testFirebaseConnection() async {
    try {
      final testRef = FirebaseDatabase.instance.ref();
      final snapshot = await testRef.child('test').once();
      print("🟢 Firebase connecté avec succès");
    } catch (e) {
      print("🔴 Erreur Firebase: $e");
    }
  }

  @override
  void dispose() {
    _categoriesSubscription?.cancel();
    _productsSubscription?.cancel();
    super.dispose();
  }

  void _loadData() {
    _categoriesSubscription = db.child("Categories").onValue.listen((event) {
      final data = event.snapshot.value as Map?;
      if (data == null) {
        print("Aucune catégorie trouvée");
        if (mounted) {
          setState(() {
            isLoading = false;
          });
        }
        return;
      }

      final List<Map<String, dynamic>> loadedCategories = [];
      data.forEach((key, value) {
        if (value != null) {
          loadedCategories.add({
            "id": value["id"]?.toString() ?? "",
            "name": value["name"]?.toString() ?? "",
          });
        }
      });

      if (mounted) {
        setState(() {
          categories = loadedCategories;
          _checkLoadingComplete();
        });
      }
    }, onError: (error) {
      print("Erreur categories: $error");
      if (mounted) {
        setState(() {
          hasError = true;
          isLoading = false;
        });
      }
    });

    _productsSubscription = db.child("Products").onValue.listen((event) {
      final data = event.snapshot.value as Map?;
      if (data == null) {
        print("Aucun produit trouvé");
        if (mounted) {
          setState(() {
            isLoading = false;
          });
        }
        return;
      }

      final List<Map<String, dynamic>> loadedProducts = [];
      data.forEach((key, value) {
        if (value != null) {
          loadedProducts.add({
            "id": value["id"]?.toString() ?? "",
            "name": value["name"]?.toString() ?? "",
            "price": (value["price"] as num?)?.toDouble() ?? 0.0,
            "image": value["image"]?.toString() ?? "",
            "category": value["category"]?.toString() ?? "",
          });
        }
      });

      if (mounted) {
        setState(() {
          products = loadedProducts;
          filterProducts();
          _checkLoadingComplete();
        });
      }
    }, onError: (error) {
      print("Erreur products: $error");
      if (mounted) {
        setState(() {
          hasError = true;
          isLoading = false;
        });
      }
    });
  }

  void _checkLoadingComplete() {
    if (categories.isNotEmpty && products.isNotEmpty && isLoading) {
      print(
          "✅ Chargement terminé - Catégories: ${categories.length}, Produits: ${products.length}");
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }

    Future.delayed(Duration(seconds: 10), () {
      if (mounted && isLoading) {
        print("⏰ Timeout de chargement atteint");
        setState(() {
          isLoading = false;
          hasError = true;
        });
      }
    });
  }

  void filterProducts() {
    filteredProducts =
        products.where((p) => p["category"] == selectedCategory).toList();
    print(
        "🔄 Filtrage produits - Catégorie: $selectedCategory, Résultats: ${filteredProducts.length}");
  }

  void _addToCart(Map<String, dynamic> product) {
    final existingIndex =
        cart.indexWhere((item) => item["id"] == product["id"]);

    if (existingIndex >= 0) {
      setState(() {
        cart[existingIndex]["quantity"] =
            (cart[existingIndex]["quantity"] ?? 1) + 1;
      });
    } else {
      setState(() {
        cart.add({
          "id": product["id"],
          "name": product["name"],
          "price": product["price"],
          "image": product["image"],
          "quantity": 1,
        });
      });
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("${product["name"]} ${translate('added_to_cart')}"),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _handleOrderConfirmed(Invoice invoice) {
    print("✅ Commande confirmée: ${invoice.id}");

    setState(() {
      invoiceHistory.add(invoice);
      cart.clear();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
            "${translate('order')} #${invoice.id.substring(0, 8)}... ${translate('order_confirmed')}"),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 3),
      ),
    );
  }

  void _goToCart() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CartScreen(
          cart: cart,
          invoiceHistory: invoiceHistory,
          onOrderConfirmed: _handleOrderConfirmed,
        ),
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
              "📜 ${translate('orders_history')}",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.brown,
              ),
            ),
            SizedBox(height: 16),
            invoiceHistory.isEmpty
                ? Expanded(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.receipt_long,
                              size: 64, color: Colors.grey),
                          SizedBox(height: 16),
                          Text(
                            translate('no_orders'),
                            style: TextStyle(fontSize: 16, color: Colors.grey),
                          ),
                          Text(
                            translate('orders_appear'),
                            style: TextStyle(fontSize: 14, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  )
                : Expanded(
                    child: ListView.builder(
                      itemCount: invoiceHistory.length,
                      itemBuilder: (context, index) {
                        final invoice = invoiceHistory.reversed.toList()[index];
                        return Card(
                          margin: EdgeInsets.only(bottom: 10),
                          child: ListTile(
                            leading: Icon(
                              invoice.isDelivery
                                  ? Icons.delivery_dining
                                  : Icons.restaurant,
                              color: Colors.brown,
                            ),
                            title: Text(
                                "${translate('order')} ${invoice.id.substring(0, 8)}..."),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("${invoice.total.toStringAsFixed(2)} DT"),
                                Text(
                                  invoice.isDelivery
                                      ? translate('delivery')
                                      : translate('on_site'),
                                  style: TextStyle(
                                    color: invoice.isDelivery
                                        ? Colors.green
                                        : Colors.blue,
                                  ),
                                ),
                                Text(
                                  "${invoice.date.day}/${invoice.date.month}/${invoice.date.year} ${invoice.date.hour}:${invoice.date.minute.toString().padLeft(2, '0')}",
                                  style: TextStyle(
                                      fontSize: 12, color: Colors.grey),
                                ),
                              ],
                            ),
                            trailing: Icon(Icons.arrow_forward_ios, size: 16),
                            onTap: () {
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
              child: Text(translate('close')),
            ),
          ],
        ),
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
              "📋 ${translate('order_details')}",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.brown,
              ),
            ),
            SizedBox(height: 16),
            _buildInvoiceDetailRow(
                "${translate('invoice_number')}:", invoice.id),
            _buildInvoiceDetailRow("${translate('date')}:",
                "${invoice.date.day}/${invoice.date.month}/${invoice.date.year} ${invoice.date.hour}:${invoice.date.minute.toString().padLeft(2, '0')}"),
            _buildInvoiceDetailRow(
                "${translate('type')}:",
                invoice.isDelivery
                    ? translate('delivery')
                    : translate('on_site')),
            _buildInvoiceDetailRow(
                "${translate('status')}:", translate('confirmed')),
            SizedBox(height: 16),
            Text("${translate('items')}:",
                style: TextStyle(fontWeight: FontWeight.bold)),
            ...invoice.items
                .map((item) => Padding(
                      padding: EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        children: [
                          Expanded(flex: 2, child: Text(item["name"])),
                          Expanded(
                              child: Text(
                                  "${item["quantity"]} x ${item["price"]} DT")),
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
                .toList(),
            SizedBox(height: 16),
            Divider(),
            _buildInvoiceDetailRow("${translate('total')}:",
                "${invoice.total.toStringAsFixed(2)} DT",
                isBold: true, color: Colors.brown),
            if (invoice.isDelivery && invoice.deliveryInfo != null) ...[
              SizedBox(height: 16),
              Text("${translate('delivery_info')}:",
                  style: TextStyle(fontWeight: FontWeight.bold)),
              _buildInvoiceDetailRow(
                  "${translate('name')}:", invoice.deliveryInfo!['name']),
              _buildInvoiceDetailRow(
                  "${translate('phone')}:", invoice.deliveryInfo!['phone']),
              _buildInvoiceDetailRow(
                  "${translate('address')}:", invoice.deliveryInfo!['address']),
            ],
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 50),
              ),
              child: Text(translate('close')),
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

  int get totalCartItems {
    int total = 0;
    for (var item in cart) {
      total += (item["quantity"] ?? 1) as int;
    }
    return total;
  }

  Widget _buildProductImage(String imageName, String productName) {
    try {
      return Image.asset(
        "assets/images/$imageName",
        width: 60,
        height: 60,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return _buildFallbackImage(productName);
        },
      );
    } catch (e) {
      return _buildFallbackImage(productName);
    }
  }

  Widget _buildFallbackImage(String productName) {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: Colors.brown[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Text(
          productName.isNotEmpty ? productName[0] : "?",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.brown,
            fontSize: 18,
          ),
        ),
      ),
    );
  }

  // Widget pour le sélecteur de langue
  Widget _buildLanguageSelector() {
    return PopupMenuButton<String>(
      icon: Icon(Icons.language, color: Colors.white),
      onSelected: (String language) {
        setState(() {
          currentLanguage = language;
        });
      },
      itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
        PopupMenuItem<String>(
          value: 'fr',
          child: Row(
            children: [
              Text('🇫🇷'),
              SizedBox(width: 8),
              Text('Français'),
            ],
          ),
        ),
        PopupMenuItem<String>(
          value: 'en',
          child: Row(
            children: [
              Text('🇺🇸'),
              SizedBox(width: 8),
              Text('English'),
            ],
          ),
        ),
        PopupMenuItem<String>(
          value: 'ar',
          child: Row(
            children: [
              Text('🇹🇳'),
              SizedBox(width: 8),
              Text('العربية'),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
            "${translate('menu')} – ${translate('table')} ${widget.tableId}"),
        backgroundColor: Colors.brown,
        actions: [
          // Sélecteur de langue
          _buildLanguageSelector(),
          // Bouton Historique
          IconButton(
            icon: Icon(Icons.history, color: Colors.white),
            onPressed: _showInvoiceHistory,
            tooltip: translate('history'),
          ),
          // Bouton Panier
          Stack(
            children: [
              IconButton(
                icon: Icon(Icons.shopping_cart, color: Colors.white),
                onPressed: _goToCart,
                tooltip: translate('cart'),
              ),
              if (totalCartItems > 0)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    constraints: BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    child: Text(
                      totalCartItems.toString(),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      body: Stack(
        children: [
          // Votre contenu principal existant
          Directionality(
            textDirection:
                currentLanguage == 'ar' ? TextDirection.rtl : TextDirection.ltr,
            child: Column(
              children: [
                // CATÉGORIES HORIZONTALES
                Container(
                  height: 70,
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    border:
                        Border(bottom: BorderSide(color: Colors.grey[300]!)),
                  ),
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: categories.length,
                    itemBuilder: (context, index) {
                      final c = categories[index];
                      final selected = c["id"] == selectedCategory;

                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedCategory = c["id"];
                            filterProducts();
                          });
                        },
                        child: Container(
                          margin:
                              EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                          padding: EdgeInsets.symmetric(
                              horizontal: 20, vertical: 10),
                          decoration: BoxDecoration(
                            color: selected ? Colors.brown : Colors.white,
                            borderRadius: BorderRadius.circular(25),
                            border: Border.all(
                              color:
                                  selected ? Colors.brown : Colors.grey[300]!,
                              width: 2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 4,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              translateCategory(c["name"]),
                              style: TextStyle(
                                color: selected ? Colors.white : Colors.black,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),

                // PRODUITS
                Expanded(
                  child: filteredProducts.isEmpty
                      ? _buildNoProductsWidget()
                      : GridView.builder(
                          padding: EdgeInsets.all(15),
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 15,
                            mainAxisSpacing: 15,
                            childAspectRatio: 0.8,
                          ),
                          itemCount: filteredProducts.length,
                          itemBuilder: (context, index) {
                            final item = filteredProducts[index];
                            return _buildProductCard(item);
                          },
                        ),
                ),
              ],
            ),
          ),

          // BOUTON CHATBOT FLOTTANT CORRIGÉ
          Positioned(
            bottom: 20,
            right: 20,
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ChatScreen()),
                );
              },
              child: Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.brown,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.brown.withOpacity(0.4),
                      blurRadius: 12,
                      spreadRadius: 2,
                    ),
                  ],
                  border: Border.all(color: Colors.white, width: 3),
                ),
                child: ClipOval(
                  child: Image.asset(
                    "assets/images/Barista2.png",
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Center(
                        child: Icon(Icons.chat, color: Colors.white, size: 28),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error, size: 64, color: Colors.red),
          SizedBox(height: 16),
          Text(
            translate('error'),
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text(translate('check_connection')),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              setState(() {
                isLoading = true;
                hasError = false;
                categories.clear();
                products.clear();
              });
              _loadData();
            },
            child: Text(translate('retry')),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: Colors.brown),
          SizedBox(height: 16),
          Text(translate('loading')),
          SizedBox(height: 8),
          Text(
            "${translate('categories')}: ${categories.length} | ${translate('products')}: ${products.length}",
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildNoProductsWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            translate('no_products'),
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
          Text(
            translate('for_category'),
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildProductCard(Map<String, dynamic> item) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () => _addToCart(item),
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Image
            Expanded(
              flex: 3,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(12),
                  ),
                  color: Colors.brown[50],
                ),
                child: _buildProductImage(item["image"], item["name"]),
              ),
            ),

            // Info produit
            Expanded(
              flex: 2,
              child: Padding(
                padding: EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      item["name"],
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "${item["price"]} DT",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.brown,
                            fontSize: 16,
                          ),
                        ),
                        Icon(
                          Icons.add_circle,
                          color: Colors.brown,
                          size: 20,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
