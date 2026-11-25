import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../data/side_quest_api.dart';
import '../models/multi_stop_side_quest.dart';
import '../theme.dart';

class SideQuestDetailScreen extends StatefulWidget {
  const SideQuestDetailScreen({
    super.key,
    required this.sideQuestApi,
    required this.routeId,
  });

  final SideQuestApi sideQuestApi;
  final String routeId;

  @override
  State<SideQuestDetailScreen> createState() => _SideQuestDetailScreenState();
}

class _SideQuestDetailScreenState extends State<SideQuestDetailScreen> {
  late Future<MultiStopSideQuest?> _route;

  @override
  void initState() {
    super.initState();
    _route = widget.sideQuestApi.getRoute(widget.routeId);
  }

  Future<void> _edit(String id) async {
    final updated = await Navigator.pushNamed<bool>(
      context,
      '/sidequests/${Uri.encodeComponent(id)}/edit',
    );
    if (updated == true && mounted) {
      setState(() => _route = widget.sideQuestApi.getRoute(widget.routeId));
    }
  }

  Future<void> _delete(MultiStopSideQuest route) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete this side quest?'),
        content: Text('“${route.name}” will be removed from your packages.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(backgroundColor: NeoColors.violet),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirm != true) return;
    try {
      await widget.sideQuestApi.deleteRoute(route.id);
      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/packages',
          (route) => route.settings.name == '/',
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not delete this side quest: $error')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) => FutureBuilder<MultiStopSideQuest?>(
    future: _route,
    builder: (context, snapshot) {
      if (snapshot.hasError) {
        return const Center(child: Text('Could not load this side quest.'));
      }
      if (!snapshot.hasData) {
        return const Center(child: CircularProgressIndicator());
      }
      final route = snapshot.data;
      if (route == null || route.stops.isEmpty) {
        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('This side quest could not be found.'),
              TextButton(
                onPressed: () => Navigator.pushNamed(context, '/packages'),
                child: const Text('Back to packages'),
              ),
            ],
          ),
        );
      }
      final points = route.stops
          .map((stop) => LatLng(stop.latitude, stop.longitude))
          .toList();
      final fitPoints = points.toSet().length == 1
          ? [
              ...points,
              LatLng(
                points.first.latitude + .002,
                points.first.longitude + .002,
              ),
            ]
          : points;
      return SingleChildScrollView(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1000),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 26, 24, 58),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextButton.icon(
                    onPressed: () => Navigator.pushNamed(context, '/packages'),
                    icon: const Icon(Icons.arrow_back_rounded),
                    label: const Text('Packages'),
                  ),
                  const SizedBox(height: 12),
                  LayoutBuilder(
                    builder: (context, box) {
                      final actions = Wrap(
                        spacing: 8,
                        children: [
                          OutlinedButton.icon(
                            onPressed: () => _edit(route.id),
                            icon: const Icon(Icons.edit_outlined, size: 18),
                            label: const Text('Edit'),
                          ),
                          OutlinedButton.icon(
                            onPressed: () => _delete(route),
                            icon: const Icon(
                              Icons.delete_outline_rounded,
                              size: 18,
                            ),
                            label: const Text('Delete'),
                          ),
                        ],
                      );
                      final title = Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'YOUR SIDE QUEST',
                            style: TextStyle(
                              fontSize: 10,
                              letterSpacing: 1.5,
                              color: NeoColors.violet,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            route.name,
                            style: const TextStyle(
                              fontSize: 34,
                              letterSpacing: -1,
                              fontWeight: FontWeight.w800,
                              color: NeoColors.ink,
                            ),
                          ),
                          if (route.description.trim().isNotEmpty) ...[
                            const SizedBox(height: 7),
                            Text(
                              route.description,
                              style: const TextStyle(
                                color: NeoColors.muted,
                                height: 1.5,
                              ),
                            ),
                          ],
                          const SizedBox(height: 7),
                          Text(
                            '${route.stops.length} stops · in your chosen order',
                            style: const TextStyle(
                              color: NeoColors.muted,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      );
                      return box.maxWidth > 700
                          ? Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(child: title),
                                const SizedBox(width: 16),
                                actions,
                              ],
                            )
                          : Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                title,
                                const SizedBox(height: 14),
                                actions,
                              ],
                            );
                    },
                  ),
                  const SizedBox(height: 28),
                  const Text(
                    'Your route',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: NeoColors.ink,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...route.stops.asMap().entries.map((entry) {
                    final index = entry.key;
                    final stop = entry.value;
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: NeoColors.violet,
                          child: Text(
                            '${index + 1}',
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                        title: Text(
                          stop.name,
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                        subtitle: Text(
                          stop.kind == SideQuestStopKind.customPlace
                              ? 'Custom place · ${stop.location}'
                              : stop.location,
                        ),
                        trailing: stop.kind == SideQuestStopKind.activity
                            ? const Icon(Icons.open_in_new_rounded, size: 18)
                            : null,
                        onTap: stop.activityId == null
                            ? null
                            : () => Navigator.pushNamed(
                                context,
                                '/activity/${Uri.encodeComponent(stop.activityId!)}',
                              ),
                      ),
                    );
                  }),
                  const SizedBox(height: 22),
                  const Text(
                    'Adventure map',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: NeoColors.ink,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(22),
                    child: SizedBox(
                      height: MediaQuery.sizeOf(context).width < 600
                          ? 340
                          : 440,
                      child: FlutterMap(
                        options: MapOptions(
                          initialCenter: points.first,
                          initialZoom: 12,
                          initialCameraFit: CameraFit.bounds(
                            bounds: LatLngBounds.fromPoints(fitPoints),
                            padding: const EdgeInsets.all(56),
                          ),
                        ),
                        children: [
                          TileLayer(
                            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                            userAgentPackageName: 'com.neoquest.web',
                          ),
                          PolylineLayer(
                            polylines: [
                              Polyline(
                                points: points,
                                strokeWidth: 5,
                                color: NeoColors.violet,
                              ),
                            ],
                          ),
                          MarkerLayer(
                            markers: route.stops.asMap().entries.map((entry) {
                              return Marker(
                                point: points[entry.key],
                                width: 48,
                                height: 56,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: NeoColors.violet,
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
                                  alignment: Alignment.center,
                                  child: Text(
                                    '${entry.key + 1}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
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
