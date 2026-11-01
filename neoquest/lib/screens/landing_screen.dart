import 'package:flutter/material.dart';

import '../theme.dart';

class LandingScreen extends StatelessWidget {
  const LandingScreen({super.key});
  static final _stepsKey = GlobalKey();

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: const Color(0xFF101815),
    body: SafeArea(
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: _LandingHeader()),
          SliverToBoxAdapter(child: _Hero()),
          SliverToBoxAdapter(child: _ExploreSection(key: _stepsKey)),
          SliverToBoxAdapter(child: _LandingFooter()),
        ],
      ),
    ),
  );
}

class _LandingHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Center(
    child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 1260),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: MediaQuery.sizeOf(context).width < 500 ? 16 : 30,
          vertical: 24,
        ),
        child: Row(
          children: [
            const _Wordmark(),
            const Spacer(),
            if (MediaQuery.sizeOf(context).width > 650) ...[
              TextButton(
                onPressed: () {
                  final target = LandingScreen._stepsKey.currentContext;
                  if (target != null) {
                    Scrollable.ensureVisible(
                      target,
                      duration: const Duration(milliseconds: 420),
                      curve: Curves.easeOutCubic,
                    );
                  }
                },
                child: const Text(
                  'The idea',
                  style: TextStyle(color: Colors.white70),
                ),
              ),
              const SizedBox(width: 14),
              TextButton(
                onPressed: () {
                  final target = LandingScreen._stepsKey.currentContext;
                  if (target != null) {
                    Scrollable.ensureVisible(
                      target,
                      duration: const Duration(milliseconds: 420),
                      curve: Curves.easeOutCubic,
                    );
                  }
                },
                child: const Text(
                  'How it works',
                  style: TextStyle(color: Colors.white70),
                ),
              ),
              const SizedBox(width: 22),
            ],
            if (MediaQuery.sizeOf(context).width > 390) ...[
              OutlinedButton(
                onPressed: () => Navigator.pushNamed(context, '/signin'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: BorderSide(color: Colors.white.withValues(alpha: .28)),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 17,
                    vertical: 15,
                  ),
                ),
                child: const Text('Sign in'),
              ),
              const SizedBox(width: 10),
            ],
            FilledButton(
              onPressed: () => Navigator.pushNamed(context, '/signup'),
              style: FilledButton.styleFrom(
                backgroundColor: NeoColors.lime,
                foregroundColor: const Color(0xFF121910),
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 16,
                ),
              ),
              child: const Text(
                'Get started',
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class _Hero extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Center(
    child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 1260),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(30, 62, 30, 84),
        child: LayoutBuilder(
          builder: (context, box) {
            final wide = box.maxWidth > 850;
            final copy = Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const _Kicker('A DIFFERENT KIND OF LOCAL GUIDE'),
                const SizedBox(height: 22),
                Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: wide
                            ? 'Discover the story\naround every '
                            : box.maxWidth < 430
                            ? 'Find the story\naround\nevery '
                            : 'Find the story\naround every ',
                      ),
                      TextSpan(
                        text: 'corner.',
                        style: TextStyle(
                          color: NeoColors.lime,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                  style: TextStyle(
                    fontSize: wide
                        ? 66
                        : box.maxWidth < 430
                        ? 38
                        : 48,
                    height: 1.02,
                    letterSpacing: -2.1,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 21),
                const Text(
                  'A tiny adventure, a new favorite spot, a reason to take the long way home. Your next side quest is closer than you think.',
                  style: TextStyle(
                    color: Color(0xFFB5C0B8),
                    height: 1.7,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 30),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    FilledButton.icon(
                      onPressed: () => Navigator.pushNamed(context, '/signup'),
                      icon: const Icon(Icons.arrow_outward_rounded, size: 17),
                      label: const Text('Find your next quest'),
                      style: FilledButton.styleFrom(
                        backgroundColor: NeoColors.lime,
                        foregroundColor: const Color(0xFF121910),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 18,
                        ),
                      ),
                    ),
                    TextButton.icon(
                      onPressed: () => Navigator.pushNamed(context, '/signin'),
                      icon: const Icon(
                        Icons.play_circle_outline_rounded,
                        color: Colors.white70,
                      ),
                      label: const Text(
                        'I already have an account',
                        style: TextStyle(color: Colors.white70),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 35),
                const Wrap(
                  spacing: 19,
                  runSpacing: 10,
                  children: [
                    _Promise(
                      icon: Icons.tune_rounded,
                      text: 'Made for your mood',
                    ),
                    _Promise(
                      icon: Icons.near_me_outlined,
                      text: 'Close to home',
                    ),
                    _Promise(
                      icon: Icons.savings_outlined,
                      text: 'Fits your budget',
                    ),
                  ],
                ),
              ],
            );
            final visual = const _QuestVisual();
            return wide
                ? Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(flex: 6, child: copy),
                      const SizedBox(width: 40),
                      Expanded(flex: 5, child: visual),
                    ],
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      copy,
                      const SizedBox(height: 52),
                      SizedBox(height: 390, child: visual),
                    ],
                  );
          },
        ),
      ),
    ),
  );
}

class _QuestVisual extends StatelessWidget {
  const _QuestVisual();
  @override
  Widget build(BuildContext context) => AspectRatio(
    aspectRatio: .92,
    child: Stack(
      clipBehavior: Clip.none,
      children: [
        Positioned.fill(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(34),
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.network(
                  'https://images.unsplash.com/photo-1448375240586-882707db888b?auto=format&fit=crop&w=1200&q=90',
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      const DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [Color(0xFF314D38), Color(0xFF17221B)],
                          ),
                        ),
                      ),
                ),
                const DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Color(0x22101815),
                        Color(0x99101815),
                        Color(0xEE101815),
                      ],
                      stops: [0, .52, 1],
                    ),
                  ),
                ),
                Positioned(
                  top: 24,
                  left: 24,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 9,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xCC101815),
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: .2),
                      ),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.explore_outlined,
                          color: NeoColors.lime,
                          size: 15,
                        ),
                        SizedBox(width: 7),
                        Text(
                          'YOUR NEXT SIDE QUEST',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            letterSpacing: 1,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  right: 23,
                  top: 23,
                  child: Container(
                    padding: const EdgeInsets.all(11),
                    decoration: BoxDecoration(
                      color: NeoColors.lime,
                      borderRadius: BorderRadius.circular(17),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 20,
                          offset: Offset(0, 7),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.near_me_rounded,
                      color: Color(0xFF182017),
                      size: 20,
                    ),
                  ),
                ),
                Positioned(
                  left: 27,
                  right: 27,
                  bottom: 145,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'BERKELEY, CALIFORNIA',
                        style: TextStyle(
                          color: NeoColors.lime,
                          letterSpacing: 1.8,
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 9),
                      Text(
                        'Take the\nscenic route.',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: MediaQuery.sizeOf(context).width < 500
                              ? 35
                              : 48,
                          height: .99,
                          letterSpacing: -1.8,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        Positioned(
          left: 18,
          bottom: 18,
          right: 18,
          child: Container(
            padding: const EdgeInsets.all(13),
            decoration: BoxDecoration(
              color: const Color(0xFFFBF8F0),
              borderRadius: BorderRadius.circular(22),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 25,
                  offset: Offset(0, 9),
                ),
              ],
            ),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: Image.network(
                    'https://images.unsplash.com/photo-1500375592092-40eb2168fd21?auto=format&fit=crop&w=240&q=80',
                    width: 56,
                    height: 56,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      width: 56,
                      height: 56,
                      color: const Color(0xFFDCE7D8),
                      child: const Icon(
                        Icons.wb_twilight_rounded,
                        color: Color(0xFF456A48),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'A slower kind of evening',
                        style: TextStyle(
                          color: Color(0xFF1D2820),
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      SizedBox(height: 5),
                      Text(
                        'Sunset by the water  ·  easy  ·  free',
                        style: TextStyle(
                          color: Color(0xFF66736A),
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.arrow_outward_rounded,
                  color: Color(0xFF1D2820),
                  size: 18,
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}

class _ExploreSection extends StatelessWidget {
  const _ExploreSection({super.key});

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    color: const Color(0xFF16211A),
    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 72),
    child: Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1180),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _Kicker('HOW NEOQUEST WORKS'),
            const SizedBox(height: 14),
            const Text(
              'Good plans start with\na little curiosity.',
              style: TextStyle(
                color: Colors.white,
                fontSize: 38,
                height: 1.12,
                letterSpacing: -1.4,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 34),
            LayoutBuilder(
              builder: (context, box) {
                final columns = box.maxWidth > 760 ? 3 : 1;
                final cards = const [
                  _StepCard(
                    number: '01',
                    icon: Icons.tune_rounded,
                    title: 'Pick your vibe',
                    body: 'Choose what sounds good, how far you want to go, and what feels right to spend.',
                  ),
                  _StepCard(
                    number: '02',
                    icon: Icons.map_outlined,
                    title: 'See what’s nearby',
                    body: 'Explore local ideas on a map or scan a short list of options that fit.',
                  ),
                  _StepCard(
                    number: '03',
                    icon: Icons.bookmark_border_rounded,
                    title: 'Make it yours',
                    body: 'Save the ideas you love and share a side quest with the community.',
                  ),
                ];
                return Wrap(
                  spacing: 17,
                  runSpacing: 17,
                  children: cards
                      .map(
                        (card) => SizedBox(
                          width: (box.maxWidth - (columns - 1) * 17) / columns,
                          child: card,
                        ),
                      )
                      .toList(),
                );
              },
            ),
            const SizedBox(height: 30),
            FilledButton(
              onPressed: () => Navigator.pushNamed(context, '/signup'),
              style: FilledButton.styleFrom(
                backgroundColor: NeoColors.lime,
                foregroundColor: const Color(0xFF121910),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 17,
                ),
              ),
              child: const Text(
                'Start exploring',
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class _StepCard extends StatelessWidget {
  const _StepCard({
    required this.number,
    required this.icon,
    required this.title,
    required this.body,
  });
  final String number, title, body;
  final IconData icon;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(23),
    decoration: BoxDecoration(
      color: const Color(0xFF202D23),
      borderRadius: BorderRadius.circular(24),
      border: Border.all(color: Colors.white.withValues(alpha: .07)),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: NeoColors.lime),
            const Spacer(),
            Text(
              number,
              style: const TextStyle(
                color: Color(0xFF809080),
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 29),
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 19,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          body,
          style: const TextStyle(color: Color(0xFFB4C0B5), height: 1.6),
        ),
      ],
    ),
  );
}

class _LandingFooter extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Center(
    child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 1200),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: MediaQuery.sizeOf(context).width < 500 ? 20 : 30,
          vertical: 25,
        ),
        child: LayoutBuilder(
          builder: (context, box) => box.maxWidth > 460
              ? const Row(
                  children: [
                    _Wordmark(),
                    Spacer(),
                    Text(
                      'Make today a little less ordinary.',
                      style: TextStyle(color: Color(0xFF86948A), fontSize: 12),
                    ),
                  ],
                )
              : const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _Wordmark(),
                    SizedBox(height: 14),
                    Text(
                      'Make today a little less ordinary.',
                      style: TextStyle(color: Color(0xFF86948A), fontSize: 12),
                    ),
                  ],
                ),
        ),
      ),
    ),
  );
}

class _Wordmark extends StatelessWidget {
  const _Wordmark();
  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: NeoColors.lime,
          borderRadius: BorderRadius.circular(11),
        ),
        child: const Icon(
          Icons.explore_rounded,
          color: Color(0xFF182017),
          size: 21,
        ),
      ),
      const SizedBox(width: 10),
      const Text(
        'neoquest',
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w800,
          fontSize: 20,
          letterSpacing: -.7,
        ),
      ),
    ],
  );
}

class _Kicker extends StatelessWidget {
  const _Kicker(this.text);
  final String text;
  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Container(width: 22, height: 2, color: NeoColors.lime),
      const SizedBox(width: 9),
      Text(
        text,
        style: const TextStyle(
          color: NeoColors.lime,
          fontSize: 10,
          letterSpacing: 1.4,
          fontWeight: FontWeight.w800,
        ),
      ),
    ],
  );
}

class _Promise extends StatelessWidget {
  const _Promise({required this.icon, required this.text});
  final IconData icon;
  final String text;
  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(icon, color: NeoColors.lime, size: 16),
      const SizedBox(width: 7),
      Text(
        text,
        style: const TextStyle(
          color: Color(0xFFD1D8D1),
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    ],
  );
}
