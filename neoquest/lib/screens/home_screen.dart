import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../data/activity_api.dart';
import '../data/weather_api.dart';
import '../models/activity.dart';
import '../theme.dart';
import '../widgets/activity_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.api});
  final ActivityApi api;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<Activity>> _activities;
  late Future<CurrentWeather> _weather;
  Set<String> _saved = {};

  @override
  void initState() {
    super.initState();
    _activities = widget.api.listActivities();
    _weather = WeatherApi().forBerkeley();
    _loadSaved();
  }

  Future<void> _loadSaved() async {
    final ids = await widget.api.savedIds();
    if (mounted) setState(() => _saved = ids);
  }

  Future<void> _toggleSaved(String id) async {
    try {
      await widget.api.toggleSaved(id);
      await _loadSaved();
    } on FirebaseException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message ?? 'Sign in to save this quest.')),
        );
      }
      if (mounted && e.code == 'unauthenticated') {
        Navigator.pushNamed(context, '/signin');
      }
    }
  }

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    child: Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1200),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(28, 35, 28, 74),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Hero(
                weather: _weather,
                onExplore: () => Navigator.pushNamed(context, '/explore'),
              ),
              const SizedBox(height: 64),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _Eyebrow('A LITTLE INSPIRATION'),
                        SizedBox(height: 10),
                        Text(
                          'Your next side quest',
                          style: TextStyle(
                            fontSize: 31,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -.8,
                            color: NeoColors.ink,
                          ),
                        ),
                        SizedBox(height: 6),
                        Text(
                          'Good things to do, right around Berkeley.',
                          style: TextStyle(
                            color: NeoColors.muted,
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () => Navigator.pushNamed(context, '/explore'),
                    icon: const Icon(Icons.arrow_forward_rounded, size: 17),
                    label: const Text('See all'),
                  ),
                ],
              ),
              const SizedBox(height: 22),
              FutureBuilder<List<Activity>>(
                future: _activities,
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return const _LoadMessage(
                      icon: Icons.cloud_off_outlined,
                      text: 'The demo activity service could not load. Try refreshing.',
                    );
                  }
                  if (!snapshot.hasData) {
                    return const SizedBox(
                      height: 248,
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }
                  final items = snapshot.data!.take(3).toList();
                  return LayoutBuilder(
                    builder: (context, box) {
                      final columns = box.maxWidth > 780
                          ? 3
                          : box.maxWidth > 500
                          ? 2
                          : 1;
                      return GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: items.length,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: columns,
                          mainAxisExtent: 319,
                          crossAxisSpacing: 17,
                          mainAxisSpacing: 17,
                        ),
                        itemBuilder: (context, i) => ActivityCard(
                          activity: items[i],
                          isSaved: _saved.contains(items[i].id),
                          onSave: () => _toggleSaved(items[i].id),
                          onTap: () => Navigator.pushNamed(
                            context,
                            '/activity/${items[i].id}',
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
              const SizedBox(height: 67),
              const _HowItWorks(),
            ],
          ),
        ),
      ),
    ),
  );
}

class _Hero extends StatelessWidget {
  const _Hero({required this.onExplore, required this.weather});
  final VoidCallback onExplore;
  final Future<CurrentWeather> weather;
  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.sizeOf(context).width > 760;
    return Container(
      constraints: const BoxConstraints(minHeight: 400),
      decoration: BoxDecoration(
        color: NeoColors.ink,
        borderRadius: BorderRadius.circular(30),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF252949), Color(0xFF3D397A)],
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          const Positioned(
            right: -20,
            top: -140,
            child: _Orb(size: 390, color: Color(0x386D64E9)),
          ),
          const Positioned(
            right: 170,
            bottom: -185,
            child: _Orb(size: 330, color: Color(0x26D8EF86)),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(
              wide ? 63 : 32,
              47,
              wide ? 40 : 32,
              42,
            ),
            child: Row(
              children: [
                Expanded(
                  flex: 6,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: .11),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.wb_sunny_outlined,
                              size: 14,
                              color: NeoColors.lime,
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'BERKELEY, CA',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                letterSpacing: .75,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(width: 7),
                            Container(
                              width: 3,
                              height: 3,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: NeoColors.lime,
                              ),
                            ),
                            const SizedBox(width: 7),
                            FutureBuilder<CurrentWeather>(
                              future: weather,
                              builder: (context, snapshot) => Text(
                                snapshot.hasData
                                    ? '${snapshot.data!.temperatureF.round()}°  ·  ${snapshot.data!.summary.toUpperCase()}'
                                    : 'LOCAL SIDE QUESTS',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  letterSpacing: .5,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 28),
                      Text.rich(
                        TextSpan(
                          children: [
                            const TextSpan(text: 'Make room\nfor a little '),
                            TextSpan(
                              text: 'wonder.',
                              style: TextStyle(
                                color: NeoColors.lime,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ],
                        ),
                        style: TextStyle(
                          fontSize: wide ? 57 : 43,
                          height: 1.02,
                          letterSpacing: -2.2,
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 18),
                      const Text(
                        'Find something fun nearby, gather your people, and let the afternoon surprise you.',
                        style: TextStyle(
                          fontSize: 16,
                          height: 1.55,
                          color: Color(0xFFD6D8E6),
                        ),
                      ),
                      const SizedBox(height: 26),
                      FilledButton.icon(
                        onPressed: onExplore,
                        style: FilledButton.styleFrom(
                          backgroundColor: NeoColors.lime,
                          foregroundColor: NeoColors.ink,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 22,
                            vertical: 17,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        icon: const Icon(Icons.explore_outlined, size: 18),
                        label: const Text(
                          'Find a side quest',
                          style: TextStyle(fontWeight: FontWeight.w800),
                        ),
                      ),
                      const SizedBox(height: 15),
                      const Text(
                        'No elaborate plans required.',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFFB9BBD0),
                        ),
                      ),
                      if (!wide) ...[
                        const SizedBox(height: 22),
                        const _QuestIllustration(compact: true),
                      ],
                    ],
                  ),
                ),
                if (wide) const Expanded(flex: 5, child: _QuestIllustration()),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _QuestIllustration extends StatelessWidget {
  const _QuestIllustration({this.compact = false});
  final bool compact;
  @override
  Widget build(BuildContext context) => Container(
    height: compact ? 180 : 320,
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(24),
      border: Border.all(color: Colors.white.withValues(alpha: .23)),
      boxShadow: const [
        BoxShadow(
          color: Color(0x330E1024),
          blurRadius: 32,
          offset: Offset(0, 18),
        ),
      ],
    ),
    clipBehavior: Clip.antiAlias,
    child: Stack(
      fit: StackFit.expand,
      children: [
        Image.network(
          'https://images.unsplash.com/photo-1448375240586-882707db888b?auto=format&fit=crop&w=1100&q=90',
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) => const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF72988A), Color(0xFF273D56)],
              ),
            ),
          ),
        ),
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0x160A1020), Color(0xA8101425)],
              stops: [0.35, 1],
            ),
          ),
        ),
        const Positioned(
          top: 17,
          left: 17,
          child: _FloatTag(icon: Icons.near_me_rounded, text: 'Close to home'),
        ),
        Positioned(
          left: 22,
          right: 22,
          bottom: 20,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'TILDEN REGIONAL PARK',
                      style: TextStyle(
                        color: NeoColors.lime,
                        fontSize: 10,
                        letterSpacing: 1,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 7),
                    Text(
                      'Take the scenic route.',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: compact ? 16 : 21,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -.4,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: NeoColors.lime,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.arrow_outward_rounded,
                  color: NeoColors.ink,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class _FloatTag extends StatelessWidget {
  const _FloatTag({required this.icon, required this.text});
  final IconData icon;
  final String text;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
    decoration: BoxDecoration(
      color: Colors.white.withValues(alpha: .94),
      borderRadius: BorderRadius.circular(13),
      boxShadow: const [
        BoxShadow(
          color: Color(0x22000000),
          blurRadius: 20,
          offset: Offset(0, 7),
        ),
      ],
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: NeoColors.violet),
        const SizedBox(width: 6),
        Text(
          text,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: NeoColors.ink,
          ),
        ),
      ],
    ),
  );
}

class _Orb extends StatelessWidget {
  const _Orb({required this.size, required this.color});
  final double size;
  final Color color;
  @override
  Widget build(BuildContext context) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(shape: BoxShape.circle, color: color),
  );
}

class _HowItWorks extends StatelessWidget {
  const _HowItWorks();
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const _Eyebrow('THE SIMPLE VERSION'),
      const SizedBox(height: 10),
      const Text(
        'Less planning. More doing.',
        style: TextStyle(
          fontSize: 30,
          fontWeight: FontWeight.w800,
          letterSpacing: -.8,
          color: NeoColors.ink,
        ),
      ),
      const SizedBox(height: 22),
      LayoutBuilder(
        builder: (context, box) {
          final columns = box.maxWidth > 700 ? 3 : 1;
          const items = [
            (
              '01',
              Icons.tune_rounded,
              'Pick your vibe',
              'Choose a mood, a budget, and how far you feel like going.',
            ),
            (
              '02',
              Icons.auto_awesome_outlined,
              'Find your match',
              'Browse nearby ideas that fit the plan you actually have.',
            ),
            (
              '03',
              Icons.rocket_launch_outlined,
              'Go make a story',
              'Pick one, invite your people, and get out there.',
            ),
          ];
          return GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: items.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: columns,
              mainAxisExtent: 168,
              crossAxisSpacing: 18,
              mainAxisSpacing: 12,
            ),
            itemBuilder: (context, i) {
              final item = items[i];
              return Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: NeoColors.line),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: NeoColors.lilac,
                            borderRadius: BorderRadius.circular(13),
                          ),
                          child: Icon(item.$2, color: NeoColors.violet),
                        ),
                        const Spacer(),
                        Text(
                          item.$1,
                          style: const TextStyle(
                            color: NeoColors.violet,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),
                    Text(
                      item.$3,
                      style: const TextStyle(
                        fontSize: 12,
                        color: NeoColors.muted,
                        height: 1.45,
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    ],
  );
}

class _Eyebrow extends StatelessWidget {
  const _Eyebrow(this.text);
  final String text;
  @override
  Widget build(BuildContext context) => Text(
    text,
    style: const TextStyle(
      fontSize: 10,
      letterSpacing: 1.5,
      fontWeight: FontWeight.w800,
      color: NeoColors.violet,
    ),
  );
}

class _LoadMessage extends StatelessWidget {
  const _LoadMessage({required this.icon, required this.text});
  final IconData icon;
  final String text;
  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(40),
      child: Column(
        children: [
          Icon(icon, color: NeoColors.muted),
          Text(text),
        ],
      ),
    ),
  );
}
