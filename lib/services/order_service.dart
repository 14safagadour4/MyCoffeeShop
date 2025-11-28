import 'package:firebase_database/firebase_database.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// 👉 alias pour éviter le conflit
import '../models/order.dart' as app;

class OrderService {
  final DatabaseReference _rtdb = FirebaseDatabase.instance.ref();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> saveOrderRealtime(app.Order order) async {
    final ref = _rtdb.child('orders').push();
    await ref.set(order.toMap());
  }

  Future<void> saveOrderFirestore(app.Order order) async {
    await _firestore.collection('orders').doc(order.id).set(order.toMap());
  }

  Future<void> saveOrderBoth(app.Order order) async {
    await Future.wait([
      saveOrderRealtime(order),
      saveOrderFirestore(order),
    ]);
  }

  Stream<List<app.Order>> streamOrdersFirestore() {
    return _firestore
        .collection('orders')
        .orderBy('date', descending: true)
        .snapshots()
        .map((snap) =>
            snap.docs.map((d) => app.Order.fromMap(d.data())).toList());
  }
}
