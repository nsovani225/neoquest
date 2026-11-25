import 'package:flutter/material.dart';

import '../data/adventure_packages.dart';
import '../data/side_quest_api.dart';
import '../models/multi_stop_side_quest.dart';
import '../theme.dart';

class PackagesScreen extends StatefulWidget {
  const PackagesScreen({super.key, required this.sideQuestApi});
  final SideQuestApi sideQuestApi;

  @override
  State<PackagesScreen> createState() => _PackagesScreenState();
}

class _PackagesScreenState extends State<PackagesScreen> {
  late Future<List<MultiStopSideQuest>> _routes;

  @override
  void initState() {
    super.initState();
    _routes = widget.sideQuestApi.listRoutes();
  }

  Future<void> _openBuilder() async {
    await Navigator.pushNamed(context, '/sidequests/new');
    if (mounted) setState(() => _routes = widget.sideQuestApi.listRoutes());
  }

  Future<void> _openRoute(String id) async {
    await Navigator.pushNamed(
      context,
      '/sidequests/${Uri.encodeComponent(id)}',
    );
    if (mounted) setState(() => _routes = widget.sideQuestApi.listRoutes());
  }

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    child: Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1000),
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              LayoutBuilder(
                builder: (context, box) {
                  final heading = const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Adventure Packages',
                        style: TextStyle(
                          fontSize: 34,
                          fontWeight: FontWeight.w800,
                          color: NeoColors.ink,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Multiple SideQuests, one adventure.',
                        style: TextStyle(color: NeoColors.muted),
                      ),
                    ],
                  );
                  final button = FilledButton.icon(
                    onPressed: _openBuilder,
                    icon: const Icon(Icons.add_rounded),
                    label: const Text('Build a side quest'),
                    style: FilledButton.styleFrom(
                      backgroundColor: NeoColors.ink,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 17,
                        vertical: 15,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(13),
                      ),
                    ),
                  );
                  return box.maxWidth > 650
                      ? Row(
                          children: [
                            Expanded(child: heading),
                            const SizedBox(width: 14),
                            button,
                          ],
                        )
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            heading,
                            const SizedBox(height: 16),
                            button,
                          ],
                        );
                },
              ),
              const SizedBox(height: 30),
              const _SectionTitle('Your side quests'),
              const SizedBox(height: 12),
              FutureBuilder<List<MultiStopSideQuest>>(
                future: _routes,
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return _MessageCard(
                      text: 'Your side quests could not load.',
                      actionLabel: 'Try again',
                      onAction: () => setState(
                        () => _routes = widget.sideQuestApi.listRoutes(),
                      ),
                    );
                  }
                  if (!snapshot.hasData) {
                    return const Padding(
                      padding: EdgeInsets.all(24),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }
                  final routes = snapshot.data!;
                  if (routes.isEmpty) {
                    return const _MessageCard(
                      text: 'Your saved routes will show up here. Start one with a few stops.',
                    );
                  }
                  return Column(
                    children: routes.map((route) {
                      return Card(
                        margin: const EdgeInsets.only(bottom: 10),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 10,
                          ),
                          leading: const CircleAvatar(
                            backgroundColor: NeoColors.lilac,
                            child: Icon(
                              Icons.route_rounded,
                              color: NeoColors.violet,
                            ),
                          ),
                          title: Text(
                            route.name,
                            style: const TextStyle(fontWeight: FontWeight.w800),
                          ),
                          subtitle: Text(
                            '${route.stops.length} stops${route.description.isEmpty ? '' : ' · ${route.description}'}',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          trailing: const Icon(Icons.arrow_forward_ios_rounded),
                          onTap: () => _openRoute(route.id),
                        ),
                      );
                    }).toList(),
                  );
                },
              ),
              const SizedBox(height: 28),
              const _SectionTitle('Curated packages'),
              const SizedBox(height: 12),
              ...adventurePackages.map(
                (package) => Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(20),
                    leading: const Icon(
                      Icons.route_rounded,
                      color: NeoColors.violet,
                      size: 32,
                    ),
                    title: Text(
                      package.name,
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                    subtitle: Text(
                      '${package.description}\n${package.activityIds.length} SideQuests',
                    ),
                    isThreeLine: true,
                    trailing: const Icon(Icons.arrow_forward_ios_rounded),
                    onTap: () =>
                        Navigator.pushNamed(context, '/packages/${package.id}'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Text(
    text,
    style: const TextStyle(
      color: NeoColors.ink,
      fontSize: 21,
      fontWeight: FontWeight.w800,
    ),
  );
}

class _MessageCard extends StatelessWidget {
  const _MessageCard({required this.text, this.actionLabel, this.onAction});
  final String text;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(19),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(17),
      border: Border.all(color: NeoColors.line),
    ),
    child: Row(
      children: [
        Expanded(
          child: Text(text, style: const TextStyle(color: NeoColors.muted)),
        ),
        if (actionLabel != null)
          TextButton(onPressed: onAction, child: Text(actionLabel!)),
      ],
    ),
  );
}
