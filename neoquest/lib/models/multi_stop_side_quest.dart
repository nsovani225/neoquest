import 'package:cloud_firestore/cloud_firestore.dart';

import 'activity.dart';

enum SideQuestStopKind { activity, customPlace }

class SideQuestStop {
  const SideQuestStop({
    required this.id,
    required this.kind,
    required this.name,
    required this.location,
    required this.latitude,
    required this.longitude,
    this.activityId,
  });

  final String id;
  final SideQuestStopKind kind;
  final String name;
  final String location;
  final double latitude;
  final double longitude;
  final String? activityId;

  factory SideQuestStop.fromActivity(Activity activity) => SideQuestStop(
    id: 'activity-${activity.id}',
    kind: SideQuestStopKind.activity,
    activityId: activity.id,
    name: activity.name,
    location: activity.location,
    latitude: activity.latitude,
    longitude: activity.longitude,
  );

  factory SideQuestStop.fromMap(Map<String, dynamic> map) => SideQuestStop(
    id: map['id'] as String,
    kind: map['kind'] == 'customPlace'
        ? SideQuestStopKind.customPlace
        : SideQuestStopKind.activity,
    activityId: map['activityId'] as String?,
    name: map['name'] as String? ?? 'Side quest stop',
    location: map['location'] as String? ?? '',
    latitude: (map['latitude'] as num).toDouble(),
    longitude: (map['longitude'] as num).toDouble(),
  );

  Map<String, dynamic> toMap() => {
    'id': id,
    'kind': kind.name,
    'activityId': activityId,
    'name': name,
    'location': location,
    'latitude': latitude,
    'longitude': longitude,
  };
}

class MultiStopSideQuest {
  const MultiStopSideQuest({
    required this.id,
    required this.name,
    required this.description,
    required this.stops,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String name;
  final String description;
  final List<SideQuestStop> stops;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  factory MultiStopSideQuest.fromDocument(
    String id,
    Map<String, dynamic> data,
  ) => MultiStopSideQuest(
    id: id,
    name: data['name'] as String? ?? 'My side quest',
    description: data['description'] as String? ?? '',
    stops: (data['stops'] as List<dynamic>? ?? const [])
        .whereType<Map>()
        .map((stop) => SideQuestStop.fromMap(Map<String, dynamic>.from(stop)))
        .toList(),
    createdAt: _readDate(data['createdAt']),
    updatedAt: _readDate(data['updatedAt']),
  );

  Map<String, dynamic> toMap() => {
    'name': name,
    'description': description,
    'stops': stops.map((stop) => stop.toMap()).toList(),
  };

  MultiStopSideQuest copyWith({
    String? id,
    String? name,
    String? description,
    List<SideQuestStop>? stops,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => MultiStopSideQuest(
    id: id ?? this.id,
    name: name ?? this.name,
    description: description ?? this.description,
    stops: stops ?? this.stops,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );

  static DateTime? _readDate(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    return null;
  }
}
