import 'package:flutter/foundation.dart' show visibleForTesting;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/activity.dart';
import '../models/quest_filters.dart';

@visibleForTesting
List<Activity> filterUnvisitedActivities(
  Iterable<Activity> activities,
  Set<String> visitedIds,
) => activities.where((activity) => !visitedIds.contains(activity.id)).toList();

abstract interface class ActivityApi {
  Future<List<Activity>> listActivities({
    String query = '',
    String category = 'All',
    QuestFilters filters = const QuestFilters(),
  });
  Future<Activity?> getActivity(String id);
  Future<Activity> createActivity(Activity activity);
  Future<void> toggleSaved(String id);
  Future<Set<String>> savedIds();
  Future<Set<String>> visitedIds();
  Future<void> markVisited(Activity activity);
  Future<void> unmarkVisited(String id);
  Future<void> seedMissingSamples();
}

class FirestoreActivityApi implements ActivityApi {
  FirestoreActivityApi({FirebaseFirestore? firestore, FirebaseAuth? auth})
    : _db = firestore ?? FirebaseFirestore.instance,
      _auth = auth ?? FirebaseAuth.instance;

  final FirebaseFirestore _db;
  final FirebaseAuth _auth;
  CollectionReference<Map<String, dynamic>> get _activities =>
      _db.collection('activities');

  static const _filterFields = [
    'latitude',
    'longitude',
    'distanceMiles',
    'budgetAmount',
    'minGroupSize',
    'maxGroupSize',
    'durationMinutes',
    'transportation',
    'availability',
  ];

  @override
  Future<void> seedMissingSamples() async {
    final user = _auth.currentUser;
    if (user == null) return;
    try {
      final existing = await _activities.get();
      final byId = {for (final doc in existing.docs) doc.id: doc.data()};
      final batch = _db.batch();
      var changes = 0;
      for (final activity in seed) {
        final ref = _activities.doc(activity.id);
        final current = byId[activity.id];
        final allData = activity.toJson()..remove('id');
        if (current == null) {
          batch.set(ref, {
            ...allData,
            'creatorId': user.uid,
            'createdAt': FieldValue.serverTimestamp(),
          });
          changes++;
        } else {
          // Backfill only missing filter/map metadata. Existing descriptions,
          // names, ratings, and other community edits remain untouched.
          final missing = <String, dynamic>{};
          for (final field in _filterFields) {
            if (!current.containsKey(field)) missing[field] = allData[field];
          }
          if (missing.isNotEmpty) {
            batch.set(ref, missing, SetOptions(merge: true));
            changes++;
          }
        }
      }
      if (changes > 0) await batch.commit();
    } on FirebaseException {
      // Keep authentication usable while the project owner finishes setup.
    }
  }

  static const seed = <Activity>[
    Activity(
      id: 'marina',
      name: 'Berkeley Marina',
      category: 'Outdoors',
      description:
          'Golden-hour walks, sailboats, and a wide-open view of the Bay.',
      location: 'Berkeley Marina',
      price: r'$$',
      duration: '1–2 hours',
      rating: 4.8,
      emoji: '⛵',
      colors: [44, 124, 155, 174, 222, 221],
      imageUrl: 'https://images.unsplash.com/photo-1500375592092-40eb2168fd21?auto=format&fit=crop&w=1000&q=85',
      latitude: 37.8647,
      longitude: -122.3149,
      distanceMiles: 2.1,
      budgetAmount: 20,
      minGroupSize: 1,
      maxGroupSize: 8,
      durationMinutes: 100,
      transportation: ['Walking', 'Bike', 'Public transit'],
      availability: ['Daytime', 'Sunset', 'Anytime'],
    ),
    Activity(
      id: 'tilden',
      name: 'Tilden Regional Park',
      category: 'Nature',
      description: 'Wander shady trails and find a new favorite picnic spot.',
      location: 'Tilden Park',
      price: r'$',
      duration: '2+ hours',
      rating: 4.9,
      emoji: '🌿',
      colors: [83, 135, 105, 215, 239, 192],
      imageUrl: 'https://images.unsplash.com/photo-1448375240586-882707db888b?auto=format&fit=crop&w=1000&q=85',
      latitude: 37.8929,
      longitude: -122.2447,
      distanceMiles: 5.1,
      budgetAmount: 10,
      minGroupSize: 1,
      maxGroupSize: 12,
      durationMinutes: 150,
      transportation: ['Car', 'Bike', 'Public transit'],
      availability: ['Daytime', 'Anytime'],
    ),
    Activity(
      id: 'adventure',
      name: 'Adventure Playground',
      category: 'Play',
      description:
          'A delightfully unusual playground built for climbing and creating.',
      location: 'Marina Boulevard',
      price: 'Free',
      duration: 'Around 1 hour',
      rating: 4.7,
      emoji: '🛝',
      colors: [239, 154, 92, 255, 224, 176],
      imageUrl: 'https://images.unsplash.com/photo-1596461404969-9ae70f2830c1?auto=format&fit=crop&w=1000&q=85',
      latitude: 37.8652,
      longitude: -122.3148,
      distanceMiles: 2.8,
      budgetAmount: 0,
      minGroupSize: 1,
      maxGroupSize: 8,
      durationMinutes: 60,
      transportation: ['Walking', 'Bike', 'Public transit'],
      availability: ['Daytime', 'Anytime'],
    ),
    Activity(
      id: 'lake-anza',
      name: 'Lake Anza',
      category: 'Outdoors',
      description:
          'A quiet lake tucked into the hills. Bring a book or take a dip.',
      location: 'Tilden Park',
      price: 'Free',
      duration: 'Around 2 hours',
      rating: 4.8,
      emoji: '🦆',
      colors: [71, 129, 173, 184, 224, 239],
      imageUrl: 'https://images.unsplash.com/photo-1470770841072-f978cf4d019e?auto=format&fit=crop&w=1000&q=85',
      latitude: 37.8966,
      longitude: -122.2444,
      distanceMiles: 4.3,
      budgetAmount: 0,
      minGroupSize: 1,
      maxGroupSize: 8,
      durationMinutes: 120,
      transportation: ['Car', 'Bike'],
      availability: ['Daytime', 'Anytime'],
    ),
    Activity(
      id: 'cheese-board',
      name: 'The Cheese Board',
      category: 'Food & drink',
      description: 'Share a legendary slice and see what the neighborhood is lining up for.',
      location: 'North Berkeley',
      price: r'$',
      duration: 'Around 1 hour',
      rating: 4.7,
      emoji: '🍕',
      colors: [225, 113, 86, 255, 221, 181],
      imageUrl: 'https://images.unsplash.com/photo-1513104890138-7c749659a591?auto=format&fit=crop&w=1000&q=85',
      latitude: 37.8791,
      longitude: -122.2691,
      distanceMiles: 0.8,
      budgetAmount: 15,
      minGroupSize: 1,
      maxGroupSize: 8,
      durationMinutes: 60,
      transportation: ['Walking', 'Bike', 'Public transit'],
      availability: ['Lunch', 'Dinner', 'Anytime'],
    ),
    Activity(
      id: 'campanile',
      name: 'Campanile views',
      category: 'Explore',
      description:
          'Take in the campus, climb the tower, and catch the city from above.',
      location: 'UC Berkeley',
      price: r'$',
      duration: 'Around 1 hour',
      rating: 4.6,
      emoji: '🔔',
      colors: [102, 97, 177, 224, 221, 248],
      imageUrl: 'https://images.unsplash.com/photo-1518005020951-eccb494ad742?auto=format&fit=crop&w=1000&q=85',
      latitude: 37.8722,
      longitude: -122.2578,
      distanceMiles: 0.4,
      budgetAmount: 5,
      minGroupSize: 1,
      maxGroupSize: 6,
      durationMinutes: 60,
      transportation: ['Walking', 'Bike', 'Public transit'],
      availability: ['Daytime', 'Anytime'],
    ),
  ];

  @override
  Future<List<Activity>> listActivities({
    String query = '',
    String category = 'All',
    QuestFilters filters = const QuestFilters(),
  }) async {
    List<Activity> records;
    try {
      final snap = await _activities.get();
      records = snap.docs.isEmpty
          ? seed
          : snap.docs
                .map((doc) => Activity.fromJson({'id': doc.id, ...doc.data()}))
                .toList();
    } on FirebaseException {
      records = seed;
    }
    final activeCategory = category == 'All' ? filters.category : category;
    final q = query.trim().toLowerCase();
    final visited = await visitedIds();
    final matching = records.where((item) {
      final categoryMatch =
          activeCategory == 'All' ||
          (activeCategory == 'Community' && item.isCommunityQuest) ||
          item.category.toLowerCase() == activeCategory.toLowerCase() ||
          (activeCategory == 'Outdoor' &&
              ['outdoors', 'nature'].contains(item.category.toLowerCase())) ||
          (activeCategory == 'Food & drinks' &&
              item.category.toLowerCase().contains('food'));
      final queryMatch =
          q.isEmpty ||
          '${item.name} ${item.category} ${item.location} ${item.description}'
              .toLowerCase()
              .contains(q);
      final groupMatch =
          item.minGroupSize <= filters.groupSize &&
          item.maxGroupSize >= filters.groupSize;
      final transportMatch =
          filters.transportation.isEmpty ||
          filters.transportation.any(item.transportation.contains);
      final availabilityMatch =
          filters.availability.isEmpty ||
          filters.availability.any(item.availability.contains);
      return categoryMatch &&
          queryMatch &&
          groupMatch &&
          item.distanceMiles <= filters.maxDistance &&
          item.budgetAmount <= filters.maxBudget &&
          item.durationMinutes <= filters.maxDurationMinutes &&
          item.rating >= filters.minRating &&
          transportMatch &&
          availabilityMatch;
    });
    return filterUnvisitedActivities(matching, visited)
      ..sort((a, b) => a.distanceMiles.compareTo(b.distanceMiles));
  }

  @override
  Future<Activity?> getActivity(String id) async {
    try {
      final doc = await _activities.doc(id).get();
      if (doc.exists) return Activity.fromJson({'id': doc.id, ...doc.data()!});
    } on FirebaseException {
      // Display bundled samples if Firestore is temporarily unavailable.
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

  CollectionReference<Map<String, dynamic>> _hangouts(String uid) =>
      _db.collection('users').doc(uid).collection('hangouts');

  @override
  Future<Set<String>> visitedIds() async {
    final user = _auth.currentUser;
    if (user == null) return <String>{};
    final snap = await _hangouts(user.uid).get();
    return snap.docs.map((doc) => doc.id).toSet();
  }

  @override
  Future<void> markVisited(Activity activity) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw FirebaseAuthException(
        code: 'unauthenticated',
        message: 'Sign in to add a quest to your history.',
      );
    }
    final ref = _hangouts(user.uid).doc(activity.id);
    await _db.runTransaction((transaction) async {
      final existing = await transaction.get(ref);
      if (existing.exists) return;
      transaction.set(ref, {
        'activityId': activity.id,
        'activityName': activity.name,
        'category': activity.category,
        'date': FieldValue.serverTimestamp(),
      });
    });
  }

  @override
  Future<void> unmarkVisited(String id) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw FirebaseAuthException(
        code: 'unauthenticated',
        message: 'Sign in to update your quest history.',
      );
    }
    await _hangouts(user.uid).doc(id).delete();
  }
}
