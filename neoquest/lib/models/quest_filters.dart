class QuestFilters {
  const QuestFilters({
    this.category = 'All',
    this.maxDistance = 10,
    this.maxBudget = 60,
    this.groupSize = 2,
    this.maxDurationMinutes = 240,
    this.minRating = 0,
    this.transportation = const [],
    this.availability = const [],
  });

  final String category;
  final double maxDistance;
  final int maxBudget;
  final int groupSize;
  final int maxDurationMinutes;
  final double minRating;
  final List<String> transportation;
  final List<String> availability;

  bool get isDefault =>
      category == 'All' &&
      maxDistance == 10 &&
      maxBudget == 60 &&
      groupSize == 2 &&
      maxDurationMinutes == 240 &&
      minRating == 0 &&
      transportation.isEmpty &&
      availability.isEmpty;

  factory QuestFilters.fromQuery(Map<String, String> query) => QuestFilters(
    category: query['category'] ?? 'All',
    maxDistance: double.tryParse(query['distance'] ?? '') ?? 10,
    maxBudget: int.tryParse(query['budget'] ?? '') ?? 60,
    groupSize: int.tryParse(query['group'] ?? '') ?? 2,
    maxDurationMinutes: int.tryParse(query['duration'] ?? '') ?? 240,
    minRating: double.tryParse(query['rating'] ?? '') ?? 0,
    transportation: (query['transport'] ?? '')
        .split(',')
        .where((value) => value.isNotEmpty)
        .toList(),
    availability: (query['availability'] ?? '')
        .split(',')
        .where((value) => value.isNotEmpty)
        .toList(),
  );

  Map<String, String> toQuery() => {
    'category': category,
    'distance': '$maxDistance',
    'budget': '$maxBudget',
    'group': '$groupSize',
    'duration': '$maxDurationMinutes',
    'rating': '$minRating',
    'transport': transportation.join(','),
    'availability': availability.join(','),
  };

  QuestFilters copyWith({
    String? category,
    double? maxDistance,
    int? maxBudget,
    int? groupSize,
    int? maxDurationMinutes,
    double? minRating,
    List<String>? transportation,
    List<String>? availability,
  }) => QuestFilters(
    category: category ?? this.category,
    maxDistance: maxDistance ?? this.maxDistance,
    maxBudget: maxBudget ?? this.maxBudget,
    groupSize: groupSize ?? this.groupSize,
    maxDurationMinutes: maxDurationMinutes ?? this.maxDurationMinutes,
    minRating: minRating ?? this.minRating,
    transportation: transportation ?? this.transportation,
    availability: availability ?? this.availability,
  );
}
