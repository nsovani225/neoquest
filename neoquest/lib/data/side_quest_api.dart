import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/multi_stop_side_quest.dart';

class SideQuestApi {
  SideQuestApi({FirebaseFirestore? firestore, FirebaseAuth? auth})
    : _db = firestore ?? FirebaseFirestore.instance,
      _auth = auth ?? FirebaseAuth.instance;

  final FirebaseFirestore _db;
  final FirebaseAuth _auth;

  CollectionReference<Map<String, dynamic>> get _routes {
    final user = _requireUser();
    return _db.collection('users').doc(user.uid).collection('sidequests');
  }

  User _requireUser() {
    final user = _auth.currentUser;
    if (user == null) {
      throw FirebaseAuthException(
        code: 'unauthenticated',
        message: 'Sign in to manage your side quests.',
      );
    }
    return user;
  }

  void _validate(MultiStopSideQuest route) {
    if (route.name.trim().isEmpty) {
      throw ArgumentError('Give your side quest a name.');
    }
    if (route.stops.length < 2) {
      throw ArgumentError('Add at least two stops to your side quest.');
    }
    for (final stop in route.stops) {
      if (!stop.latitude.isFinite ||
          !stop.longitude.isFinite ||
          stop.latitude < -90 ||
          stop.latitude > 90 ||
          stop.longitude < -180 ||
          stop.longitude > 180) {
        throw ArgumentError('Each stop needs a valid map location.');
      }
    }
  }

  Future<List<MultiStopSideQuest>> listRoutes() async {
    final snapshot = await _routes.get();
    final routes = snapshot.docs
        .map((doc) => MultiStopSideQuest.fromDocument(doc.id, doc.data()))
        .toList();
    routes.sort((a, b) {
      final aDate = a.updatedAt ?? a.createdAt;
      final bDate = b.updatedAt ?? b.createdAt;
      if (aDate == null) return bDate == null ? 0 : 1;
      if (bDate == null) return -1;
      return bDate.compareTo(aDate);
    });
    return routes;
  }

  Future<MultiStopSideQuest?> getRoute(String id) async {
    final doc = await _routes.doc(id).get();
    if (!doc.exists) return null;
    return MultiStopSideQuest.fromDocument(doc.id, doc.data()!);
  }

  Future<MultiStopSideQuest> createRoute(MultiStopSideQuest route) async {
    _validate(route);
    final ref = _routes.doc();
    await ref.set({
      ...route.toMap(),
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
    return route.copyWith(id: ref.id);
  }

  Future<void> updateRoute(MultiStopSideQuest route) async {
    _validate(route);
    if (route.id.isEmpty) throw ArgumentError('A saved route needs an ID.');
    await _routes.doc(route.id).update({
      ...route.toMap(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> deleteRoute(String id) async {
    await _routes.doc(id).delete();
  }
}
