import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../models/visit_model.dart';
import '../models/rep_location_model.dart';

class RepService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<UserModel>> getAllReps() {
    return _firestore
        .collection('users')
        .where('role', isEqualTo: 'rep')
        .snapshots()
        .map((snapshot) {
      print("Found ${snapshot.docs.length} reps in Firestore");
      return snapshot.docs.map((doc) => UserModel.fromMap(doc.data(), doc.id)).toList();
    });
  }

  Stream<List<RepLocationModel>> getRepLocationsStream() {
    return _firestore
        .collection('rep_current_locations')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => RepLocationModel.fromMap(doc.data(), doc.id)).toList();
    });
  }

  Future<void> assignRouteToRep(String repId, String routeId) async {
    await _firestore.collection('users').doc(repId).update({
      'routeId': routeId,
      'routeUpdatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> recordVisit({
    required String shopId,
    required String repId,
    required String routeId,
  }) async {
    final docRef = _firestore.collection('visits').doc();
    final visit = VisitModel(
      visitId: docRef.id,
      shopId: shopId,
      repId: repId,
      routeId: routeId,
      visited: true,
      timestamp: DateTime.now(),
    );
    await docRef.set(visit.toMap());
  }
}
