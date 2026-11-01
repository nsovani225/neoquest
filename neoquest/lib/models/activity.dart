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

  factory Activity.fromJson(Map<String, dynamic> json) => Activity(
    id: json['id'] as String,
    name: json['name'] as String,
    category: json['category'] as String? ?? 'Explore',
    description: json['description'] as String? ?? '',
    location: json['location'] as String? ?? 'Berkeley, CA',
    price: json['price'] as String? ?? 'Free',
    duration: json['duration'] as String? ?? '1–2 hours',
    rating: (json['rating'] as num?)?.toDouble() ?? 4.5,
    emoji: json['emoji'] as String? ?? '✨',
    colors:
        (json['colors'] as List<dynamic>? ?? const [99, 91, 219, 234, 232, 255])
            .cast<int>(),
    imageUrl: json['imageUrl'] as String?,
    isCommunityQuest: json['isCommunityQuest'] as bool? ?? false,
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
  );
}
