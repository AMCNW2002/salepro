import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/payment_model.dart';

class PaymentService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> collectPayment(PaymentModel payment) async {
    final batch = _firestore.batch();
    
    final paymentRef = _firestore.collection('payments').doc(payment.paymentId);
    final shopRef = _firestore.collection('shops').doc(payment.shopId);

    // Save payment
    batch.set(paymentRef, payment.toMap());

    // Decrease balance
    batch.update(shopRef, {
      'balanceDue': FieldValue.increment(-payment.amount)
    });

    await batch.commit();
  }

  Stream<List<PaymentModel>> getPaymentsForShop(String shopId) {
    return _firestore
        .collection('payments')
        .where('shopId', isEqualTo: shopId)
        .snapshots()
        .map((snapshot) {
      final payments = snapshot.docs
          .map((doc) => PaymentModel.fromMap(doc.data(), doc.id))
          .toList();
      payments.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      return payments;
    });
  }

  Stream<List<PaymentModel>> getPaymentsForRep(String repId) {
    return _firestore
        .collection('payments')
        .where('repId', isEqualTo: repId)
        .snapshots()
        .map((snapshot) {
      final payments = snapshot.docs
          .map((doc) => PaymentModel.fromMap(doc.data(), doc.id))
          .toList();
      payments.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      return payments;
    });
  }

  Stream<List<PaymentModel>> getAllPayments() {
    return _firestore
        .collection('payments')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => PaymentModel.fromMap(doc.data(), doc.id))
          .toList();
    });
  }
}
