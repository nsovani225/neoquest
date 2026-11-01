class Activity {
  const Activity({
    required this.id,
    required this.name,
    required this.category,
    required this.description,
    required this.location,
    required this.price,
    required this.duration,
    required this.rating,
    required this.emoji,
    required this.colors,
    this.imageUrl,
    this.isCommunityQuest = false,
    this.latitude = 37.8715,
    this.longitude = -122.273,
    this.distanceMiles = 1,
    this.budgetAmount = 0,
    this.minGroupSize = 1,
    this.maxGroupSize = 8,
    this.durationMinutes = 90,
    this.transportation = const ['Walking', 'Public transit'],
    this.availability = const ['Anytime'],
  });

  final String id;
  final String name;
  final String category;
  final String description;
  final String location;
  final String price;
  final String duration;
  final double rating;
  final String emoji;
  final List<int> colors;
  final String? imageUrl;
  final bool isCommunityQuest;
  final double latitude;
  final double longitude;
  final double distanceMiles;
  final int budgetAmount;
  final int minGroupSize;
  final int maxGroupSize;
  final int durationMinutes;
  final List<String> transportation;
  final List<String> availability;

  factory Activity.fromJson(Map<String, dynamic> json) => Activity(
    id: json['id'] as String,
    name: json['name'] as String? ?? 'Side quest',
    category: json['category'] as String? ?? 'Explore',
    description: json['description'] as String? ?? '',
    location: json['location'] as String? ?? 'Berkeley, CA',
    price: json['price'] as String? ?? 'Free',
    duration: json['duration'] as String? ?? '1–2 hours',
    rating: (json['rating'] as num?)?.toDouble() ?? 4.5,
    emoji: json['emoji'] as String? ?? '✨',
    colors:
        (json['colors'] as List<dynamic>? ?? const [99, 91, 219, 234, 232, 255])
            .map((value) => (value as num).toInt())
            .toList(),
    imageUrl: json['imageUrl'] as String?,
    isCommunityQuest: json['isCommunityQuest'] as bool? ?? false,
    latitude: (json['latitude'] as num?)?.toDouble() ?? 37.8715,
    longitude: (json['longitude'] as num?)?.toDouble() ?? -122.273,
    distanceMiles: (json['distanceMiles'] as num?)?.toDouble() ?? 1,
    budgetAmount: (json['budgetAmount'] as num?)?.toInt() ?? 0,
    minGroupSize: (json['minGroupSize'] as num?)?.toInt() ?? 1,
    maxGroupSize: (json['maxGroupSize'] as num?)?.toInt() ?? 8,
    durationMinutes: (json['durationMinutes'] as num?)?.toInt() ?? 90,
    transportation:
        (json['transportation'] as List<dynamic>? ??
                const ['Walking', 'Public transit'])
            .map((value) => value.toString())
            .toList(),
    availability: (json['availability'] as List<dynamic>? ?? const ['Anytime'])
        .map((value) => value.toString())
        .toList(),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'category': category,
    'description': description,
    'location': location,
    'price': price,
    'duration': duration,
    'rating': rating,
    'emoji': emoji,
    'colors': colors,
    'imageUrl': imageUrl,
    'isCommunityQuest': isCommunityQuest,
    'latitude': latitude,
    'longitude': longitude,
    'distanceMiles': distanceMiles,
    'budgetAmount': budgetAmount,
    'minGroupSize': minGroupSize,
    'maxGroupSize': maxGroupSize,
    'durationMinutes': durationMinutes,
    'transportation': transportation,
    'availability': availability,
  };

  Activity copyWith({
    String? id,
    String? name,
    String? category,
    String? description,
    String? location,
    String? price,
    String? duration,
    double? rating,
    String? emoji,
    List<int>? colors,
    String? imageUrl,
    bool? isCommunityQuest,
    double? latitude,
    double? longitude,
    double? distanceMiles,
    int? budgetAmount,
    int? minGroupSize,
    int? maxGroupSize,
    int? durationMinutes,
    List<String>? transportation,
    List<String>? availability,
  }) => Activity(
    id: id ?? this.id,
    name: name ?? this.name,
    category: category ?? this.category,
    description: description ?? this.description,
    location: location ?? this.location,
    price: price ?? this.price,
    duration: duration ?? this.duration,
    rating: rating ?? this.rating,
    emoji: emoji ?? this.emoji,
    colors: colors ?? this.colors,
    imageUrl: imageUrl ?? this.imageUrl,
    isCommunityQuest: isCommunityQuest ?? this.isCommunityQuest,
    latitude: latitude ?? this.latitude,
    longitude: longitude ?? this.longitude,
    distanceMiles: distanceMiles ?? this.distanceMiles,
    budgetAmount: budgetAmount ?? this.budgetAmount,
    minGroupSize: minGroupSize ?? this.minGroupSize,
    maxGroupSize: maxGroupSize ?? this.maxGroupSize,
    durationMinutes: durationMinutes ?? this.durationMinutes,
    transportation: transportation ?? this.transportation,
    availability: availability ?? this.availability,
  );
}
