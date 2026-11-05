import 'package:flutter/material.dart';

import '../models/activity.dart';
import '../theme.dart';
import 'activity_icon.dart';

class ActivityCard extends StatelessWidget {
  const ActivityCard({
    super.key,
    required this.activity,
    this.isSaved = false,
    this.onSave,
    this.onTap,
  });
  final Activity activity;
  final bool isSaved;
  final VoidCallback? onSave;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: NeoColors.surface,
      borderRadius: BorderRadius.circular(21),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 186,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  if (activity.imageUrl != null)
                    Image.network(
                      activity.imageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) =>
                          _ArtworkFallback(activity: activity),
                    )
                  else
                    _ArtworkFallback(activity: activity),
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [
                            Colors.black.withValues(alpha: .28),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 14,
                    top: 14,
                    child: _Badge(label: activity.category),
                  ),
                  if (onSave != null)
                    Positioned(
                      right: 12,
                      top: 12,
                      child: IconButton.filledTonal(
                        tooltip: isSaved ? 'Remove from saved' : 'Save quest',
                        onPressed: onSave,
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.white.withValues(alpha: .92),
                          foregroundColor: isSaved
                              ? NeoColors.coral
                              : NeoColors.ink,
                        ),
                        icon: Icon(
                          isSaved
                              ? Icons.favorite_rounded
                              : Icons.favorite_border_rounded,
                          size: 19,
                        ),
                      ),
                    ),
                  if (activity.isCommunityQuest)
                    const Positioned(
                      right: 13,
                      bottom: 13,
                      child: _Badge(label: 'COMMUNITY'),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(17, 14, 17, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          activity.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                            color: NeoColors.ink,
                          ),
                        ),
                      ),
                      const Icon(
                        Icons.star_rounded,
                        size: 17,
                        color: Color(0xFFF0A545),
                      ),
                      const SizedBox(width: 3),
                      Text(
                        activity.rating.toStringAsFixed(1),
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: NeoColors.ink,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 7),
                  Row(
                    children: [
                      const Icon(
                        Icons.place_outlined,
                        color: NeoColors.muted,
                        size: 15,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          activity.location,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 12,
                            color: NeoColors.muted,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 13),
                  Row(
                    children: [
                      _MetaPill(
                        icon: Icons.payments_outlined,
                        text: activity.price,
                      ),
                      const SizedBox(width: 7),
                      _MetaPill(
                        icon: Icons.schedule_rounded,
                        text: activity.duration,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ArtworkFallback extends StatelessWidget {
  const _ArtworkFallback({required this.activity});
  final Activity activity;
  @override
  Widget build(BuildContext context) {
    final c = activity.colors;
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color.fromARGB(255, c[0], c[1], c[2]),
            Color.fromARGB(255, c[3], c[4], c[5]),
          ],
        ),
      ),
      child: Center(
        child: Icon(
          activityIcon(activity),
          size: 70,
          color: Colors.white.withValues(alpha: .94),
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.label});
  final String label;
  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      color: Colors.white.withValues(alpha: .92),
      borderRadius: BorderRadius.circular(20),
    ),
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      child: Text(
        label.toUpperCase(),
        style: const TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.w800,
          letterSpacing: .55,
          color: NeoColors.ink,
        ),
      ),
    ),
  );
}

class _MetaPill extends StatelessWidget {
  const _MetaPill({required this.icon, required this.text});
  final IconData icon;
  final String text;
  @override
  Widget build(BuildContext context) => Flexible(
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: NeoColors.paper,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: NeoColors.muted),
          const SizedBox(width: 5),
          Flexible(
            child: Text(
              text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: NeoColors.muted,
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
