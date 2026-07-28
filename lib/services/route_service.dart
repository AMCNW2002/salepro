import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/route_model.dart';

class RouteService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> createRoute({required String name, required String description}) async {
    final docRef = _firestore.collection('routes').doc();
    final route = RouteModel(
      routeId: docRef.id,
      name: name,
      description: description,
      createdAt: DateTime.now(),
    );
    await docRef.set(route.toMap());
  }

  Future<void> updateRoute({required String routeId, required String name, required String description}) async {
    await _firestore.collection('routes').doc(routeId).update({
      'name': name,
      'description': description,
    });
  }

  Future<void> deleteRoute(String routeId) async {
    await _firestore.collection('routes').doc(routeId).delete();
  }

  Stream<List<RouteModel>> getRoutes() {
    return _firestore.collection('routes').orderBy('createdAt', descending: true).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => RouteModel.fromMap(doc.data(), doc.id)).toList();
    });
  }
}
