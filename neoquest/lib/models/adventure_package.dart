class AdventurePackage {
  final String id;
  final String name;
  final String description;
  final List<String> activityIds;
  final String category;

  const AdventurePackage({
    required this.id,
    required this.name,
    required this.description,
    required this.activityIds,
    required this.category,
  });
}