import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../data/activity_api.dart';
import '../models/activity.dart';
import '../models/quest_filters.dart';
import '../theme.dart';
import '../widgets/activity_icon.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key, required this.api, required this.filters});
  final ActivityApi api;
  final QuestFilters filters;

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  late Future<List<Activity>> _activities;
  final MapController _mapController = MapController();
  bool _mapReady = false;
  @override
  void initState() {
    super.initState();
    _activities = widget.api.listActivities(filters: widget.filters);
  }

  Future<void> _openActivity(String id) async {
    await Navigator.pushNamed(context, '/activity/$id');
    if (mounted) {
      setState(() {
        _activities = widget.api.listActivities(filters: widget.filters);
      });
    }
  }

  @override
  Widget build(BuildContext context) => FutureBuilder<List<Activity>>(
    future: _activities,
    builder: (context, snapshot) {
      if (snapshot.hasError) {
        return const Center(child: Text('The map ideas could not load.'));
      }
      if (!snapshot.hasData) {
        return const Center(child: CircularProgressIndicator());
      }
      final activities = snapshot.data!;
      final center = activities.isEmpty
          ? const LatLng(37.8715, -122.273)
          : LatLng(activities.first.latitude, activities.first.longitude);
      return Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1240),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(26, 35, 26, 50),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                LayoutBuilder(
                  builder: (context, box) {
                    const intro = Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'BERKELEY, CA',
                          style: TextStyle(
                            fontSize: 10,
                            letterSpacing: 1.5,
                            color: NeoColors.violet,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        SizedBox(height: 9),
                        Text(
                          'A map full of maybes.',
                          style: TextStyle(
                            fontSize: 34,
                            letterSpacing: -1,
                            fontWeight: FontWeight.w800,
                            color: NeoColors.ink,
                          ),
                        ),
                        SizedBox(height: 6),
                        Text(
                          'Tap a pin, find a place, make a day of it.',
                          style: TextStyle(
                            fontSize: 14,
                            color: NeoColors.muted,
                          ),
                        ),
                      ],
                    );
                    final actions = Wrap(
                      spacing: 8,
                      children: [
                        OutlinedButton.icon(
                          onPressed: () => Navigator.pushNamed(
                            context,
                            Uri(
                              path: '/list',
                              queryParameters: widget.filters.toQuery(),
                            ).toString(),
                          ),
                          icon: const Icon(Icons.view_list_rounded, size: 18),
                          label: const Text('List view'),
                        ),
                        FilledButton.tonalIcon(
                          onPressed: () => Navigator.pushNamed(
                            context,
                            Uri(
                              path: '/filters',
                              queryParameters: widget.filters.toQuery(),
                            ).toString(),
                          ),
                          icon: const Icon(Icons.tune_rounded, size: 18),
                          label: const Text('Filters'),
                        ),
                      ],
                    );
                    return box.maxWidth > 790
                        ? Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              const Expanded(child: intro),
                              const SizedBox(width: 12),
                              actions,
                            ],
                          )
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              intro,
                              const SizedBox(height: 12),
                              actions,
                            ],
                          );
                  },
                ),
                const SizedBox(height: 22),
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(25),
                    child: Stack(
                      children: [
                        FlutterMap(
                          mapController: _mapController,
                          options: MapOptions(
                            initialCenter: center,
                            initialZoom: 12.7,
                            minZoom: 9,
                            maxZoom: 18,
                            onMapReady: () {
                              if (mounted) setState(() => _mapReady = true);
                            },
                          ),
                          children: [
                            TileLayer(
                              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                              userAgentPackageName: 'com.neoquest.web',
                            ),
                            MarkerLayer(
                              markers: activities
                                  .map(
                                    (activity) => Marker(
                                      point: LatLng(
                                        activity.latitude,
                                        activity.longitude,
                                      ),
                                      width: 52,
                                      height: 58,
                                      child: Tooltip(
                                        message: activity.name,
                                        child: InkWell(
                                          onTap: () =>
                                              _openActivity(activity.id),
                                          child: Column(
                                            children: [
                                              Container(
                                                width: 43,
                                                height: 43,
                                                decoration: BoxDecoration(
                                                  color: NeoColors.ink,
                                                  shape: BoxShape.circle,
                                                  border: Border.all(
                                                    color: Colors.white,
                                                    width: 3,
                                                  ),
                                                  boxShadow: const [
                                                    BoxShadow(
                                                      color: Color(0x33000000),
                                                      blurRadius: 9,
                                                      offset: Offset(0, 4),
                                                    ),
                                                  ],
                                                ),
                                                child: Icon(
                                                  activityIcon(activity),
                                                  size: 19,
                                                  color: NeoColors.lime,
                                                ),
                                              ),
                                              const Icon(
                                                Icons.arrow_drop_down_rounded,
                                                color: NeoColors.ink,
                                                size: 17,
                                              ),
                                            ],
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
                        Positioned(
                          left: 15,
                          top: 15,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 9,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: .96),
                              borderRadius: BorderRadius.circular(13),
                              boxShadow: const [
                                BoxShadow(
                                  color: Color(0x12000000),
                                  blurRadius: 12,
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.place_rounded,
                                  color: NeoColors.violet,
                                  size: 17,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  '${activities.length} nearby ideas',
                                  style: const TextStyle(
                                    color: NeoColors.ink,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Positioned(
                          right: 15,
                          top: 15,
                          child: Material(
                            color: Colors.white.withValues(alpha: .96),
                            borderRadius: BorderRadius.circular(13),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  tooltip: 'Zoom in',
                                  onPressed: _mapReady
                                      ? () => _mapController.move(
                                          _mapController.camera.center,
                                          _mapController.camera.zoom + 1,
                                        )
                                      : null,
                                  icon: const Icon(Icons.add_rounded),
                                ),
                                const SizedBox(
                                  width: 24,
                                  child: Divider(height: 1),
                                ),
                                IconButton(
                                  tooltip: 'Zoom out',
                                  onPressed: _mapReady
                                      ? () => _mapController.move(
                                          _mapController.camera.center,
                                          _mapController.camera.zoom - 1,
                                        )
                                      : null,
                                  icon: const Icon(Icons.remove_rounded),
                                ),
                                const SizedBox(
                                  width: 24,
                                  child: Divider(height: 1),
                                ),
                                IconButton(
                                  tooltip: 'Recenter on Berkeley',
                                  onPressed: _mapReady
                                      ? () => _mapController.move(center, 12.7)
                                      : null,
                                  icon: const Icon(
                                    Icons.my_location_rounded,
                                    size: 19,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        if (activities.isEmpty)
                          const Center(
                            child: Card(
                              child: Padding(
                                padding: EdgeInsets.all(20),
                                child: Text(
                                  'No quests match yet. Try widening your filters.',
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Around you',
                        style: TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.w800,
                          color: NeoColors.ink,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pushNamed(
                        context,
                        Uri(
                          path: '/list',
                          queryParameters: widget.filters.toQuery(),
                        ).toString(),
                      ),
                      child: const Text('See all'),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                SizedBox(
                  height: 112,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: activities.length,
                    separatorBuilder: (_, _) => const SizedBox(width: 12),
                    itemBuilder: (context, index) => _MapQuestCard(
                      activity: activities[index],
                      onTap: () => _openActivity(activities[index].id),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}

class _MapQuestCard extends StatelessWidget {
  const _MapQuestCard({required this.activity, required this.onTap});
  final Activity activity;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => SizedBox(
    width: 275,
    child: Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(17),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(17),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: SizedBox(
                  width: 88,
                  height: 88,
                  child: activity.imageUrl == null
                      ? ColoredBox(
                          color: NeoColors.lilac,
                          child: Icon(
                            activityIcon(activity),
                            color: NeoColors.violet,
                          ),
                        )
                      : Image.network(
                          activity.imageUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) => ColoredBox(
                            color: NeoColors.lilac,
                            child: Icon(
                              activityIcon(activity),
                              color: NeoColors.violet,
                            ),
                          ),
                        ),
                ),
              ),
              const SizedBox(width: 11),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      activity.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: NeoColors.ink,
                        fontWeight: FontWeight.w800,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      activity.location,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: NeoColors.muted,
                        fontSize: 11,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      '${activity.distanceMiles.toStringAsFixed(1)} mi  ·  ${activity.price}',
                      style: const TextStyle(
                        color: NeoColors.violet,
                        fontWeight: FontWeight.w700,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
