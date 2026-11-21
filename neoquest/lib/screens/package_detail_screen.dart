
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../data/activity_api.dart';
import '../models/activity.dart';
import '../models/adventure_package.dart';
import '../theme.dart';

class PackageDetailScreen extends StatefulWidget {
  const PackageDetailScreen({
    super.key,
    required this.api,
    required this.package,
  });

  final ActivityApi api;
  final AdventurePackage package;

  @override
  State<PackageDetailScreen> createState() =>
      _PackageDetailScreenState();
}

class _PackageDetailScreenState
    extends State<PackageDetailScreen> {
  late final Future<List<Activity>> _activities;

  @override
  void initState() {
    super.initState();
    _activities = _loadActivities();
  }

  Future<List<Activity>> _loadActivities() async {
    final results = await Future.wait(
      widget.package.activityIds.map(widget.api.getActivity),
    );

    return results.whereType<Activity>().toList();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Activity>>(
      future: _activities,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Center(
            child: Text('Unable to load this package.'),
          );
        }

        if (!snapshot.hasData) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        final activities = snapshot.data!;

        if (activities.isEmpty) {
          return const Center(
            child: Text('No activities found in this package.'),
          );
        }

        final totalBudget = activities.fold<int>(
          0,
          (sum, activity) =>
              sum + activity.budgetAmount,
        );

        final totalMinutes = activities.fold<int>(
          0,
          (sum, activity) =>
              sum + activity.durationMinutes,
        );

        final points = activities
            .map(
              (activity) => LatLng(
                activity.latitude,
                activity.longitude,
              ),
            )
            .toList();

        return SingleChildScrollView(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 1000,
              ),
              child: Padding(
                padding: const EdgeInsets.all(28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextButton.icon(
                      onPressed: () {
                        Navigator.pushNamed(
                          context,
                          '/packages',
                        );
                      },
                      icon: const Icon(
                        Icons.arrow_back,
                      ),
                      label: const Text(
                        'All packages',
                      ),
                    ),

                    const SizedBox(height: 18),

                    Text(
                      widget.package.name,
                      style: const TextStyle(
                        fontSize: 34,
                        fontWeight: FontWeight.w800,
                        color: NeoColors.ink,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      widget.package.description,
                    ),

                    const SizedBox(height: 16),

                    Text(
                      '${activities.length} SideQuests · '
                      '$totalMinutes activity minutes · '
                      '\$$totalBudget estimated budget',
                    ),

                    const SizedBox(height: 26),

                    const Text(
                      'Your itinerary',
                      style: TextStyle(
                        fontSize: 23,
                        fontWeight: FontWeight.w800,
                        color: NeoColors.ink,
                      ),
                    ),

                    const SizedBox(height: 12),

                    ...activities.asMap().entries.map(
                      (entry) {
                        final index = entry.key;
                        final activity = entry.value;

                        return Card(
                          margin: const EdgeInsets.only(
                            bottom: 10,
                          ),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor:
                                  NeoColors.violet,
                              child: Text(
                                '${index + 1}',
                                style: const TextStyle(
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            title: Text(
                              activity.name,
                            ),
                            subtitle: Text(
                              activity.location,
                            ),
                            trailing: const Icon(
                              Icons.arrow_forward_ios_rounded,
                            ),
                            onTap: () {
                              Navigator.pushNamed(
                                context,
                                '/activity/${Uri.encodeComponent(activity.id)}',
                              );
                            },
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 25),

                    const Text(
                      'Adventure map',
                      style: TextStyle(
                        fontSize: 23,
                        fontWeight: FontWeight.w800,
                        color: NeoColors.ink,
                      ),
                    ),

                    const SizedBox(height: 12),

                    ClipRRect(
                      borderRadius:
                          BorderRadius.circular(20),
                      child: SizedBox(
                        height: 400,
                        child: FlutterMap(
                          options: MapOptions(
                            initialCenter: points.first,
                            initialZoom: 12,
                          ),
                          children: [
                            TileLayer(
                              urlTemplate:
                                  'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                              userAgentPackageName:
                                  'com.neoquest.web',
                            ),

                            MarkerLayer(
                              markers: activities
                                  .asMap()
                                  .entries
                                  .map(
                                    (entry) => Marker(
                                      point: points[
                                          entry.key],
                                      width: 45,
                                      height: 45,
                                      child: CircleAvatar(
                                        backgroundColor:
                                            NeoColors.violet,
                                        child: Text(
                                          '${entry.key + 1}',
                                          style:
                                              const TextStyle(
                                            color:
                                                Colors.white,
                                            fontWeight:
                                                FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                  )
                                  .toList(),
                            ),

                            RichAttributionWidget(
                              attributions: [
                                TextSourceAttribution(
                                  'OpenStreetMap contributors',
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}