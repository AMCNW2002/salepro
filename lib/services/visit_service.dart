import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/visit_model.dart';

class VisitService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> markVisit(VisitModel visit) async {
    final now = visit.timestamp;
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    final existingVisits = await _firestore
        .collection('visits')
        .where('shopId', isEqualTo: visit.shopId)
        .where('repId', isEqualTo: visit.repId)
        .get();

    final hasVisitedToday = existingVisits.docs.any((doc) {
      final timestamp = (doc.data()['timestamp'] as Timestamp).toDate();
      return timestamp.isAfter(startOfDay) && timestamp.isBefore(endOfDay);
    });

    if (hasVisitedToday) {
      throw Exception('Already visited this shop today.');
    }

    await _firestore.collection('visits').add(visit.toMap());
  }

  Stream<List<VisitModel>> getVisitsForShop(String shopId) {
    return _firestore
        .collection('visits')
        .where('shopId', isEqualTo: shopId)
        .snapshots()
        .map((snapshot) {
      final visits = snapshot.docs
          .map((doc) => VisitModel.fromMap(doc.data(), doc.id))
          .toList();
      visits.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      return visits;
    });
  }

  Stream<List<VisitModel>> getVisitsForRep(String repId) {
    return _firestore
        .collection('visits')
        .where('repId', isEqualTo: repId)
        .snapshots()
        .map((snapshot) {
      final visits = snapshot.docs
          .map((doc) => VisitModel.fromMap(doc.data(), doc.id))
          .toList();
      visits.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      return visits;
    });
  }
}
