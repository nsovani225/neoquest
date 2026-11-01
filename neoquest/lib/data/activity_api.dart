import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/activity.dart';

abstract interface class ActivityApi {
  Future<List<Activity>> listActivities({
    String query = '',
    String category = 'All',
  });
  Future<Activity?> getActivity(String id);
  Future<Activity> createActivity(Activity activity);
  Future<void> toggleSaved(String id);
  Future<Set<String>> savedIds();
}

class FirestoreActivityApi implements ActivityApi {
  FirestoreActivityApi({FirebaseFirestore? firestore, FirebaseAuth? auth})
    : _db = firestore ?? FirebaseFirestore.instance,
      _auth = auth ?? FirebaseAuth.instance;

  final FirebaseFirestore _db;
  final FirebaseAuth _auth;
  CollectionReference<Map<String, dynamic>> get _activities =>
      _db.collection('activities');

  Future<void> seedMissingSamples() async {
    final user = _auth.currentUser;
    if (user == null) return;
    try {
      final existing = await _activities.get();
      final existingIds = existing.docs.map((doc) => doc.id).toSet();
      final batch = _db.batch();
      for (final activity in seed) {
        if (existingIds.contains(activity.id)) continue;
        batch.set(_activities.doc(activity.id), {
          ...activity.toJson()..remove('id'),
          'creatorId': user.uid,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }
      await batch.commit();
    } on FirebaseException {
      // Auth can be used before the Firestore database has been created.
    }
  }

  static const seed = <Activity>[
    Activity(
      id: 'marina',
      name: 'Berkeley Marina',
      category: 'Outdoors',
      description:
          'Golden-hour walks, sailboats, and a wide-open view of the Bay.',
      location: 'Berkeley Marina · 2.1 mi',
      price: r'$$',
      duration: '1–2 hours',
      rating: 4.8,
      emoji: '⛵',
      colors: [44, 124, 155, 174, 222, 221],
      imageUrl: 'https://images.unsplash.com/photo-1500375592092-40eb2168fd21?auto=format&fit=crop&w=1000&q=85',
    ),
    Activity(
      id: 'tilden',
      name: 'Tilden Regional Park',
      category: 'Nature',
      description: 'Wander shady trails and find a new favorite picnic spot.',
      location: 'Tilden Park · 5.1 mi',
      price: r'$',
      duration: '2+ hours',
      rating: 4.9,
      emoji: '🌿',
      colors: [83, 135, 105, 215, 239, 192],
      imageUrl: 'https://images.unsplash.com/photo-1448375240586-882707db888b?auto=format&fit=crop&w=1000&q=85',
    ),
    Activity(
      id: 'adventure',
      name: 'Adventure Playground',
      category: 'Play',
      description:
          'A delightfully unusual playground built for climbing and creating.',
      location: 'Marina Blvd · 2.8 mi',
      price: 'Free',
      duration: 'Around 1 hour',
      rating: 4.7,
      emoji: '🛝',
      colors: [239, 154, 92, 255, 224, 176],
      imageUrl: 'https://images.unsplash.com/photo-1596461404969-9ae70f2830c1?auto=format&fit=crop&w=1000&q=85',
    ),
    Activity(
      id: 'lake-anza',
      name: 'Lake Anza',
      category: 'Outdoors',
      description:
          'A quiet lake tucked into the hills. Bring a book or take a dip.',
      location: 'Tilden Park · 4.3 mi',
      price: 'Free',
      duration: 'Around 2 hours',
      rating: 4.8,
      emoji: '🦆',
      colors: [71, 129, 173, 184, 224, 239],
      imageUrl: 'https://images.unsplash.com/photo-1470770841072-f978cf4d019e?auto=format&fit=crop&w=1000&q=85',
    ),
    Activity(
      id: 'cheese-board',
      name: 'The Cheese Board',
      category: 'Food & drink',
      description: 'Share a legendary slice and see what the neighborhood is lining up for.',
      location: 'North Berkeley · 0.8 mi',
      price: r'$',
      duration: 'Around 1 hour',
      rating: 4.7,
      emoji: '🍕',
      colors: [225, 113, 86, 255, 221, 181],
      imageUrl: 'https://images.unsplash.com/photo-1513104890138-7c749659a591?auto=format&fit=crop&w=1000&q=85',
    ),
    Activity(
      id: 'campanile',
      name: 'Campanile views',
      category: 'Explore',
      description:
          'Take in the campus, climb the tower, and catch the city from above.',
      location: 'UC Berkeley · 0.4 mi',
      price: r'$',
      duration: 'Around 1 hour',
      rating: 4.6,
      emoji: '🔔',
      colors: [102, 97, 177, 224, 221, 248],
      imageUrl: 'https://images.unsplash.com/photo-1518005020951-eccb494ad742?auto=format&fit=crop&w=1000&q=85',
    ),
  ];

  @override
  Future<List<Activity>> listActivities({
    String query = '',
    String category = 'All',
  }) async {
    QuerySnapshot<Map<String, dynamic>> snap;
    try {
      snap = await _activities.get();
    } on FirebaseException {
      return seed
          .where((item) => category == 'All' || item.category == category)
          .toList();
    }
    final records = snap.docs.isEmpty
        ? seed
        : snap.docs
              .map((doc) => Activity.fromJson({'id': doc.id, ...doc.data()}))
              .toList();
    final q = query.trim().toLowerCase();
    return records.where((item) {
      final categoryMatch = category == 'All' || item.category == category;
      final queryMatch =
          q.isEmpty ||
          '${item.name} ${item.category} ${item.location} ${item.description}'
              .toLowerCase()
              .contains(q);
      return categoryMatch && queryMatch;
    }).toList();
  }

  @override
  Future<Activity?> getActivity(String id) async {
    try {
      final doc = await _activities.doc(id).get();
      if (doc.exists) return Activity.fromJson({'id': doc.id, ...doc.data()!});
    } on FirebaseException {
      // Show the bundled sample record while Firestore is unavailable.
    }
    for (final activity in seed) {
      if (activity.id == id) return activity;
    }
    return null;
  }

  @override
  Future<Activity> createActivity(Activity activity) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw FirebaseAuthException(
        code: 'unauthenticated',
        message: 'Sign in to publish a side quest.',
      );
    }
    await _activities.doc(activity.id).set({
      ...activity.toJson()..remove('id'),
      'creatorId': user.uid,
      'createdAt': FieldValue.serverTimestamp(),
    });
    return activity;
  }

  CollectionReference<Map<String, dynamic>> _saved(String uid) =>
      _db.collection('users').doc(uid).collection('saved');

  @override
  Future<void> toggleSaved(String id) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw FirebaseAuthException(
        code: 'unauthenticated',
        message: 'Sign in to save side quests.',
      );
    }
    final ref = _saved(user.uid).doc(id);
    final doc = await ref.get();
    if (doc.exists) {
      await ref.delete();
    } else {
      await ref.set({
        'activityId': id,
        'createdAt': FieldValue.serverTimestamp(),
      });
    }
  }

  @override
  Future<Set<String>> savedIds() async {
    final user = _auth.currentUser;
    if (user == null) return <String>{};
    try {
      final snap = await _saved(user.uid).get();
      return snap.docs.map((doc) => doc.id).toSet();
    } on FirebaseException {
      return <String>{};
    }
  }
}
