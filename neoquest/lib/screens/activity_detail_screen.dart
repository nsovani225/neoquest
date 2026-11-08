import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../data/activity_api.dart';
import '../models/activity.dart';
import '../theme.dart';
import '../widgets/activity_icon.dart';

class ActivityDetailScreen extends StatefulWidget {
  const ActivityDetailScreen({
    super.key,
    required this.api,
    required this.activityId,
  });
  final ActivityApi api;
  final String activityId;

  @override
  State<ActivityDetailScreen> createState() => _ActivityDetailScreenState();
}

class _ActivityDetailScreenState extends State<ActivityDetailScreen> {
  late Future<Activity?> _activity;
  bool _saved = false;

  @override
  void initState() {
    super.initState();
    _activity = widget.api.getActivity(widget.activityId);
    _loadSaved();
  }

  Future<void> _loadSaved() async {
    final ids = await widget.api.savedIds();
    if (mounted) setState(() => _saved = ids.contains(widget.activityId));
  }

  @override
  Widget build(BuildContext context) => FutureBuilder<Activity?>(
    future: _activity,
    builder: (context, snapshot) {
      if (!snapshot.hasData && !snapshot.hasError) {
        return const Center(child: CircularProgressIndicator());
      }
      final activity = snapshot.data;
      if (activity == null) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(30),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.search_off_rounded,
                  size: 40,
                  color: NeoColors.muted,
                ),
                const SizedBox(height: 12),
                const Text(
                  'That side quest wandered off.',
                  style: TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.w800,
                    color: NeoColors.ink,
                  ),
                ),
                const SizedBox(height: 12),
                FilledButton(
                  onPressed: () => Navigator.pushNamed(context, '/explore'),
                  child: const Text('Back to explore'),
                ),
              ],
            ),
          ),
        );
      }
      return SingleChildScrollView(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1080),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(28, 34, 28, 70),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextButton.icon(
                    onPressed: () => Navigator.pushNamed(context, '/explore'),
                    icon: const Icon(Icons.arrow_back_rounded, size: 17),
                    label: const Text('Back to explore'),
                    style: TextButton.styleFrom(
                      foregroundColor: NeoColors.muted,
                    ),
                  ),
                  const SizedBox(height: 15),
                  LayoutBuilder(
                    builder: (context, box) {
                      final wide = box.maxWidth > 720;
                      final colors = activity.colors;
                      final art = Container(
                        height: wide ? 410 : 265,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(25),
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Color.fromARGB(
                                255,
                                colors[0],
                                colors[1],
                                colors[2],
                              ),
                              Color.fromARGB(
                                255,
                                colors[3],
                                colors[4],
                                colors[5],
                              ),
                            ],
                          ),
                        ),
                        child: Center(
                          child: activity.imageUrl == null
                              ? Icon(
                                  activityIcon(activity),
                                  size: 120,
                                  color: Colors.white.withValues(alpha: .94),
                                )
                              : Image.network(
                                  activity.imageUrl!,
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                  errorBuilder: (_, _, _) => Icon(
                                    activityIcon(activity),
                                    size: 120,
                                    color: Colors.white.withValues(alpha: .94),
                                  ),
                                ),
                        ),
                      );
                      final info = Padding(
                        padding: EdgeInsets.fromLTRB(
                          wide ? 32 : 4,
                          wide ? 18 : 26,
                          4,
                          0,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _Tag(
                              text: activity.isCommunityQuest
                                  ? 'COMMUNITY QUEST'
                                  : activity.category.toUpperCase(),
                            ),
                            const SizedBox(height: 18),
                            Text(
                              activity.name,
                              style: TextStyle(
                                fontSize: wide ? 39 : 31,
                                height: 1.1,
                                letterSpacing: -1,
                                fontWeight: FontWeight.w800,
                                color: NeoColors.ink,
                              ),
                            ),
                            const SizedBox(height: 14),
                            Row(
                              children: [
                                const Icon(
                                  Icons.place_outlined,
                                  color: NeoColors.muted,
                                  size: 18,
                                ),
                                const SizedBox(width: 5),
                                Expanded(
                                  child: Text(
                                    activity.location,
                                    style: const TextStyle(
                                      color: NeoColors.muted,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 18),
                            Row(
                              children: [
                                const Icon(
                                  Icons.star_rounded,
                                  color: Color(0xFFF0A545),
                                  size: 19,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  activity.rating.toStringAsFixed(1),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w800,
                                    color: NeoColors.ink,
                                  ),
                                ),
                                const Text(
                                  '  ·  Loved by local explorers',
                                  style: TextStyle(
                                    color: NeoColors.muted,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 22),
                            Text(
                              activity.description,
                              style: const TextStyle(
                                fontSize: 16,
                                height: 1.6,
                                color: NeoColors.ink,
                              ),
                            ),
                            const SizedBox(height: 22),
                            Row(
                              children: [
                                _DetailPill(
                                  icon: Icons.payments_outlined,
                                  title: 'Budget',
                                  value: activity.price,
                                ),
                                const SizedBox(width: 10),
                                _DetailPill(
                                  icon: Icons.schedule_rounded,
                                  title: 'Time',
                                  value: activity.duration,
                                ),
                              ],
                            ),
                            const SizedBox(height: 26),
                            SizedBox(
                              width: double.infinity,
                              child: FilledButton.icon(
                                onPressed: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Directions will be connected when Maps is configured.',
                                      ),
                                    ),
                                  );
                                },
                                icon: const Icon(Icons.directions_rounded),
                                label: const Text('Get directions'),
                                style: FilledButton.styleFrom(
                                  backgroundColor: NeoColors.violet,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 17,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(13),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            SizedBox(
                              width: double.infinity,
                              child: OutlinedButton.icon(
                                onPressed: () async {
                                  if (FirebaseAuth.instance.currentUser ==
                                      null) {
                                    Navigator.pushNamed(
                                      context,
                                      '/signin?returnTo=/activity/${activity.id}',
                                    );
                                    return;
                                  }
                                  try {
                                    await widget.api.toggleSaved(activity.id);
                                    await _loadSaved();
                                  } on FirebaseException catch (e) {
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            e.message ??
                                                'Sign in to save this quest.',
                                          ),
                                        ),
                                      );
                                    }
                                    if (context.mounted &&
                                        e.code == 'unauthenticated') {
                                      Navigator.pushNamed(context, '/signin');
                                    }
                                  }
                                },
                                icon: Icon(
                                  _saved
                                      ? Icons.favorite_rounded
                                      : Icons.favorite_border_rounded,
                                  color: _saved
                                      ? NeoColors.coral
                                      : NeoColors.ink,
                                ),
                                label: Text(
                                  _saved
                                      ? 'Saved for later'
                                      : 'Save this quest',
                                ),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: NeoColors.ink,
                                  side: const BorderSide(color: NeoColors.line),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(13),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                      return wide
                          ? Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(flex: 11, child: art),
                                Expanded(flex: 10, child: info),
                              ],
                            )
                          : Column(children: [art, info]);
                    },
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

class _Tag extends StatelessWidget {
  const _Tag({required this.text});
  final String text;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
    decoration: BoxDecoration(
      color: NeoColors.lilac,
      borderRadius: BorderRadius.circular(30),
    ),
    child: Text(
      text,
      style: const TextStyle(
        fontSize: 10,
        letterSpacing: .7,
        fontWeight: FontWeight.w800,
        color: NeoColors.violetDark,
      ),
    ),
  );
}

class _DetailPill extends StatelessWidget {
  const _DetailPill({
    required this.icon,
    required this.title,
    required this.value,
  });
  final IconData icon;
  final String title;
  final String value;
  @override
  Widget build(BuildContext context) => Expanded(
    child: Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: NeoColors.line),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(icon, color: NeoColors.violet, size: 18),
          const SizedBox(width: 9),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(fontSize: 10, color: NeoColors.muted),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  color: NeoColors.ink,
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}
