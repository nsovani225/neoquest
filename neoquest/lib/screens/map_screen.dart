import 'package:flutter/material.dart';

import '../data/activity_api.dart';
import '../models/activity.dart';
import '../theme.dart';
import '../widgets/activity_icon.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key, required this.api});
  final ActivityApi api;

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  late Future<List<Activity>> _activities;

  @override
  void initState() {
    super.initState();
    _activities = widget.api.listActivities();
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
      return SingleChildScrollView(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1200),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(28, 40, 28, 60),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Expanded(
                        child: Column(
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
                            SizedBox(height: 10),
                            Text(
                              'The map is your menu.',
                              style: TextStyle(
                                fontSize: 35,
                                letterSpacing: -1.1,
                                fontWeight: FontWeight.w800,
                                color: NeoColors.ink,
                              ),
                            ),
                            SizedBox(height: 7),
                            Text(
                              'Pick a pin and see where the day takes you.',
                              style: TextStyle(
                                fontSize: 14,
                                color: NeoColors.muted,
                              ),
                            ),
                          ],
                        ),
                      ),
                      OutlinedButton.icon(
                        onPressed: () =>
                            Navigator.pushNamed(context, '/explore'),
                        icon: const Icon(Icons.view_list_rounded, size: 18),
                        label: const Text('List view'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: NeoColors.ink,
                          side: const BorderSide(color: NeoColors.line),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 15,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(13),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 25),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(25),
                    child: SizedBox(
                      height: 440,
                      width: double.infinity,
                      child: Stack(
                        children: [
                          const Positioned.fill(
                            child: CustomPaint(painter: _BerkeleyMapPainter()),
                          ),
                          Positioned(
                            left: 16,
                            top: 16,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 11,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: .95),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.layers_outlined,
                                    size: 16,
                                    color: NeoColors.violet,
                                  ),
                                  SizedBox(width: 7),
                                  Text(
                                    'SIDE QUESTS NEAR YOU',
                                    style: TextStyle(
                                      fontSize: 9,
                                      letterSpacing: .7,
                                      fontWeight: FontWeight.w800,
                                      color: NeoColors.ink,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          ...List.generate(activities.length, (index) {
                            const points = [
                              Offset(.24, .37),
                              Offset(.73, .28),
                              Offset(.48, .70),
                              Offset(.82, .66),
                              Offset(.12, .70),
                              Offset(.57, .40),
                            ];
                            final point = points[index % points.length];
                            final item = activities[index];
                            return Positioned(
                              left:
                                  point.dx *
                                  MediaQuery.sizeOf(context).width *
                                  .78,
                              top: point.dy * 440,
                              child: Tooltip(
                                message: item.name,
                                child: InkWell(
                                  onTap: () => Navigator.pushNamed(
                                    context,
                                    '/activity/${item.id}',
                                  ),
                                  borderRadius: BorderRadius.circular(30),
                                  child: Container(
                                    width: 46,
                                    height: 46,
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
                                          blurRadius: 10,
                                          offset: Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    child: Icon(
                                      activityIcon(item),
                                      size: 20,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }),
                          const Positioned(
                            right: 16,
                            bottom: 16,
                            child: _MapLegend(),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 25),
                  const Text(
                    'Around you',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: NeoColors.ink,
                    ),
                  ),
                  const SizedBox(height: 13),
                  Wrap(
                    spacing: 9,
                    runSpacing: 9,
                    children: activities
                        .map(
                          (item) => ActionChip(
                            avatar: Icon(
                              activityIcon(item),
                              color: NeoColors.violet,
                              size: 17,
                            ),
                            label: Text(item.name),
                            backgroundColor: Colors.white,
                            side: const BorderSide(color: NeoColors.line),
                            onPressed: () => Navigator.pushNamed(
                              context,
                              '/activity/${item.id}',
                            ),
                          ),
                        )
                        .toList(),
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    'Illustrative map preview · connect Maps to enable live tiles and routing.',
                    style: TextStyle(fontSize: 11, color: NeoColors.muted),
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

class _MapLegend extends StatelessWidget {
  const _MapLegend();
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
    decoration: BoxDecoration(
      color: Colors.white.withValues(alpha: .95),
      borderRadius: BorderRadius.circular(12),
    ),
    child: const Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.circle, size: 9, color: NeoColors.violet),
        SizedBox(width: 7),
        Text(
          'Side quest',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: NeoColors.ink,
          ),
        ),
      ],
    ),
  );
}

class _BerkeleyMapPainter extends CustomPainter {
  const _BerkeleyMapPainter();
  @override
  void paint(Canvas canvas, Size size) {
    final base = Paint()..color = const Color(0xFFE8ECD9);
    canvas.drawRect(Offset.zero & size, base);
    final park = Paint()..color = const Color(0xFFC9DFC0);
    canvas.drawPath(
      Path()
        ..moveTo(size.width * .55, 0)
        ..lineTo(size.width, 0)
        ..lineTo(size.width, size.height)
        ..lineTo(size.width * .75, size.height * .81)
        ..lineTo(size.width * .63, size.height * .42)
        ..close(),
      park,
    );
    final water = Paint()..color = const Color(0xFFB7D9E6);
    canvas.drawPath(
      Path()
        ..moveTo(0, size.height * .70)
        ..quadraticBezierTo(
          size.width * .18,
          size.height * .61,
          size.width * .37,
          size.height * .75,
        )
        ..lineTo(size.width * .39, size.height)
        ..lineTo(0, size.height)
        ..close(),
      water,
    );
    final minor = Paint()
      ..color = const Color(0xFFF9F8EF)
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round;
    for (var row = 0; row < 8; row++) {
      final y = size.height * (row / 7);
      canvas.drawLine(Offset(0, y), Offset(size.width, y + 22), minor);
    }
    for (var col = 0; col < 12; col++) {
      final x = size.width * (col / 11);
      canvas.drawLine(Offset(x, 0), Offset(x - 90, size.height), minor);
    }
    final major = Paint()
      ..color = const Color(0xFFFFFDF5)
      ..strokeWidth = 14
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      Offset(size.width * .12, 0),
      Offset(size.width * .79, size.height),
      major,
    );
    canvas.drawLine(
      Offset(size.width * .08, size.height * .18),
      Offset(size.width, size.height * .50),
      major,
    );
    final labelPaint = TextPainter(textDirection: TextDirection.ltr);
    for (final label in const [
      (0.29, 0.2, 'DOWNTOWN'),
      (0.67, 0.14, 'BERKELEY HILLS'),
      (0.78, 0.83, 'TILDEN PARK'),
    ]) {
      labelPaint.text = TextSpan(
        text: label.$3,
        style: const TextStyle(
          fontSize: 10,
          letterSpacing: 1.2,
          fontWeight: FontWeight.w800,
          color: Color(0xFF707A6E),
        ),
      );
      labelPaint.layout();
      labelPaint.paint(
        canvas,
        Offset(size.width * label.$1, size.height * label.$2),
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
