import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../data/activity_api.dart';
import '../data/side_quest_api.dart';
import '../models/activity.dart';
import '../models/multi_stop_side_quest.dart';
import '../theme.dart';

class SideQuestBuilderScreen extends StatefulWidget {
  const SideQuestBuilderScreen({
    super.key,
    required this.activityApi,
    required this.sideQuestApi,
    this.routeId,
  });

  final ActivityApi activityApi;
  final SideQuestApi sideQuestApi;
  final String? routeId;

  @override
  State<SideQuestBuilderScreen> createState() => _SideQuestBuilderScreenState();
}

class _SideQuestBuilderScreenState extends State<SideQuestBuilderScreen> {
  final _form = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _description = TextEditingController();
  final _search = TextEditingController();
  final List<SideQuestStop> _stops = [];
  late final Future<List<Activity>> _activities;
  bool _loadingRoute = false;
  bool _routeMissing = false;
  bool _saving = false;

  bool get _isEditing => widget.routeId != null;

  @override
  void initState() {
    super.initState();
    _activities = widget.activityApi.listActivities(
      includeVisited: true,
      applyFilters: false,
    );
    if (_isEditing) _loadRoute();
  }

  @override
  void dispose() {
    _name.dispose();
    _description.dispose();
    _search.dispose();
    super.dispose();
  }

  Future<void> _loadRoute() async {
    setState(() => _loadingRoute = true);
    try {
      final route = await widget.sideQuestApi.getRoute(widget.routeId!);
      if (!mounted) return;
      if (route == null) {
        setState(() {
          _routeMissing = true;
          _loadingRoute = false;
        });
        return;
      }
      _name.text = route.name;
      _description.text = route.description;
      setState(() {
        _stops
          ..clear()
          ..addAll(route.stops);
        _loadingRoute = false;
      });
    } on FirebaseException catch (error) {
      if (!mounted) return;
      setState(() {
        _routeMissing = true;
        _loadingRoute = false;
      });
      _showMessage(error.message ?? 'Could not load this side quest.');
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  bool _containsActivity(String id) =>
      _stops.any((stop) => stop.activityId == id);

  void _toggleActivity(Activity activity) {
    setState(() {
      final index = _stops.indexWhere((stop) => stop.activityId == activity.id);
      if (index >= 0) {
        _stops.removeAt(index);
      } else {
        _stops.add(SideQuestStop.fromActivity(activity));
      }
    });
  }

  Future<void> _addCustomPlace() async {
    final stop = await showDialog<SideQuestStop>(
      context: context,
      builder: (_) => const _CustomPlacePickerDialog(),
    );
    if (stop != null && mounted) setState(() => _stops.add(stop));
  }

  void _reorder(int oldIndex, int newIndex) {
    setState(() {
      final stop = _stops.removeAt(oldIndex);
      _stops.insert(newIndex, stop);
    });
  }

  Future<void> _save() async {
    if (!_form.currentState!.validate()) return;
    if (_stops.length < 2) {
      _showMessage('Add at least two stops to build your side quest.');
      return;
    }
    setState(() => _saving = true);
    final route = MultiStopSideQuest(
      id: widget.routeId ?? '',
      name: _name.text.trim(),
      description: _description.text.trim(),
      stops: List.unmodifiable(_stops),
    );
    try {
      late final MultiStopSideQuest result;
      if (_isEditing) {
        await widget.sideQuestApi.updateRoute(route);
        if (mounted) Navigator.pop(context, true);
        return;
      } else {
        result = await widget.sideQuestApi.createRoute(route);
      }
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/sidequests/${result.id}');
      }
    } on FirebaseAuthException catch (error) {
      if (mounted) _showMessage(error.message ?? 'Sign in to save this route.');
      if (mounted && error.code == 'unauthenticated') {
        Navigator.pushNamed(context, '/signin?returnTo=/packages');
      }
    } on FirebaseException catch (error) {
      if (mounted) {
        _showMessage(error.message ?? 'Could not save your side quest.');
      }
    } on ArgumentError catch (error) {
      if (mounted) {
        _showMessage(error.message?.toString() ?? 'Check your stops.');
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loadingRoute) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_routeMissing) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('This side quest could not be found.'),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => Navigator.pushNamed(context, '/packages'),
              child: const Text('Back to packages'),
            ),
          ],
        ),
      );
    }
    return FutureBuilder<List<Activity>>(
      future: _activities,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Center(child: Text('Could not load activities.'));
        }
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final query = _search.text.trim().toLowerCase();
        final activities = snapshot.data!
            .where(
              (activity) =>
                  query.isEmpty ||
                  '${activity.name} ${activity.location} ${activity.category}'
                      .toLowerCase()
                      .contains(query),
            )
            .toList();
        return SingleChildScrollView(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 900),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 30, 24, 64),
                child: Form(
                  key: _form,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextButton.icon(
                        onPressed: () => _isEditing
                            ? Navigator.pop(context)
                            : Navigator.pushNamedAndRemoveUntil(
                                context,
                                '/packages',
                                (route) => route.settings.name == '/',
                              ),
                        icon: const Icon(Icons.arrow_back_rounded),
                        label: Text(
                          _isEditing ? 'Back to side quest' : 'Packages',
                        ),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        _isEditing
                            ? 'Edit your side quest'
                            : 'Build a side quest',
                        style: const TextStyle(
                          fontSize: 32,
                          letterSpacing: -0.8,
                          fontWeight: FontWeight.w800,
                          color: NeoColors.ink,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Choose a few good stops, then put them in the order you want to explore.',
                        style: TextStyle(color: NeoColors.muted, height: 1.5),
                      ),
                      const SizedBox(height: 24),
                      TextFormField(
                        controller: _name,
                        decoration: const InputDecoration(
                          labelText: 'Side quest name',
                          hintText: 'A Berkeley afternoon',
                        ),
                        validator: (value) =>
                            value == null || value.trim().isEmpty
                            ? 'Give your side quest a name.'
                            : null,
                      ),
                      const SizedBox(height: 13),
                      TextFormField(
                        controller: _description,
                        maxLines: 2,
                        decoration: const InputDecoration(
                          labelText: 'Description (optional)',
                          hintText: 'A short note about the route',
                        ),
                      ),
                      const SizedBox(height: 27),
                      _SectionHeading(
                        title: 'Choose activities',
                        subtitle:
                            'Select activities from the NeoQuest collection.',
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _search,
                        onChanged: (_) => setState(() {}),
                        decoration: const InputDecoration(
                          prefixIcon: Icon(Icons.search_rounded),
                          hintText: 'Search activities',
                        ),
                      ),
                      const SizedBox(height: 10),
                      if (activities.isEmpty)
                        const _HintCard(
                          text: 'No activities match that search.',
                        )
                      else
                        ...activities.map((activity) {
                          final selected = _containsActivity(activity.id);
                          return Card(
                            margin: const EdgeInsets.only(bottom: 8),
                            child: CheckboxListTile(
                              value: selected,
                              onChanged: (_) => _toggleActivity(activity),
                              controlAffinity: ListTileControlAffinity.trailing,
                              secondary: CircleAvatar(
                                backgroundColor: NeoColors.lilac,
                                child: Text(activity.emoji),
                              ),
                              title: Text(
                                activity.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              subtitle: Text(activity.location),
                            ),
                          );
                        }),
                      const SizedBox(height: 12),
                      OutlinedButton.icon(
                        onPressed: _addCustomPlace,
                        icon: const Icon(Icons.add_location_alt_outlined),
                        label: const Text('Add a custom place on the map'),
                      ),
                      const SizedBox(height: 28),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Expanded(
                            child: _SectionHeading(
                              title: 'Your route',
                              subtitle: 'Drag stops to change their order.',
                            ),
                          ),
                          Text(
                            '${_stops.length} stops',
                            style: const TextStyle(
                              color: NeoColors.muted,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      if (_stops.isEmpty)
                        const _HintCard(
                          text: 'Your selected activities and places will appear here.',
                        )
                      else
                        ReorderableListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          buildDefaultDragHandles: false,
                          itemCount: _stops.length,
                          onReorderItem: _reorder,
                          itemBuilder: (context, index) {
                            final stop = _stops[index];
                            return Card(
                              key: ValueKey(stop.id),
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
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                subtitle: Text(
                                  stop.kind == SideQuestStopKind.customPlace
                                      ? 'Custom place · ${stop.location}'
                                      : stop.location,
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      tooltip: 'Remove stop',
                                      onPressed: () => setState(
                                        () => _stops.removeAt(index),
                                      ),
                                      icon: const Icon(Icons.close_rounded),
                                    ),
                                    ReorderableDragStartListener(
                                      index: index,
                                      child: const Padding(
                                        padding: EdgeInsets.all(8),
                                        child: Icon(Icons.drag_handle_rounded),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      const SizedBox(height: 20),
                      Align(
                        alignment: Alignment.centerRight,
                        child: FilledButton.icon(
                          onPressed: _saving ? null : _save,
                          icon: _saving
                              ? const SizedBox.square(
                                  dimension: 17,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Icon(Icons.route_rounded),
                          label: Text(
                            _isEditing ? 'Save changes' : 'Save side quest',
                          ),
                          style: FilledButton.styleFrom(
                            backgroundColor: NeoColors.violet,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 18,
                              vertical: 15,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _SectionHeading extends StatelessWidget {
  const _SectionHeading({required this.title, required this.subtitle});
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        title,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w800,
          color: NeoColors.ink,
        ),
      ),
      const SizedBox(height: 4),
      Text(subtitle, style: const TextStyle(color: NeoColors.muted)),
    ],
  );
}

class _HintCard extends StatelessWidget {
  const _HintCard({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: NeoColors.line),
    ),
    child: Text(text, style: const TextStyle(color: NeoColors.muted)),
  );
}

class _CustomPlacePickerDialog extends StatefulWidget {
  const _CustomPlacePickerDialog();

  @override
  State<_CustomPlacePickerDialog> createState() =>
      _CustomPlacePickerDialogState();
}

class _CustomPlacePickerDialogState extends State<_CustomPlacePickerDialog> {
  final _name = TextEditingController();
  LatLng? _point;

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  void _save() {
    final point = _point;
    final name = _name.text.trim();
    if (name.isEmpty || point == null) return;
    Navigator.pop(
      context,
      SideQuestStop(
        id: 'place-${DateTime.now().microsecondsSinceEpoch}',
        kind: SideQuestStopKind.customPlace,
        name: name,
        location: name,
        latitude: point.latitude,
        longitude: point.longitude,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screen = MediaQuery.sizeOf(context);
    return Dialog(
      insetPadding: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      child: SizedBox(
        width: screen.width > 720 ? 650 : screen.width - 32,
        height: screen.height > 780 ? 620 : screen.height - 40,
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Add a custom place',
                style: TextStyle(
                  fontSize: 21,
                  fontWeight: FontWeight.w800,
                  color: NeoColors.ink,
                ),
              ),
              const SizedBox(height: 5),
              const Text(
                'Name the place and tap its position on the map.',
                style: TextStyle(color: NeoColors.muted),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _name,
                decoration: const InputDecoration(
                  labelText: 'Place name',
                  prefixIcon: Icon(Icons.place_outlined),
                ),
                textInputAction: TextInputAction.done,
                onChanged: (_) => setState(() {}),
                onSubmitted: (_) {
                  if (_point != null) _save();
                },
              ),
              const SizedBox(height: 12),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: FlutterMap(
                    options: MapOptions(
                      initialCenter: const LatLng(37.8715, -122.273),
                      initialZoom: 12,
                      onTap: (_, point) => setState(() => _point = point),
                    ),
                    children: [
                      TileLayer(
                        urlTemplate:
                            'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        userAgentPackageName: 'com.neoquest.web',
                      ),
                      if (_point != null)
                        MarkerLayer(
                          markers: [
                            Marker(
                              point: _point!,
                              width: 48,
                              height: 56,
                              child: const Icon(
                                Icons.location_on_rounded,
                                color: NeoColors.violet,
                                size: 44,
                              ),
                            ),
                          ],
                        ),
                      RichAttributionWidget(
                        attributions: [
                          TextSourceAttribution('OpenStreetMap contributors'),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 8),
                  FilledButton(
                    onPressed: _point == null || _name.text.trim().isEmpty
                        ? null
                        : _save,
                    style: FilledButton.styleFrom(
                      backgroundColor: NeoColors.violet,
                    ),
                    child: const Text('Add stop'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
