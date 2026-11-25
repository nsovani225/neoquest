import 'package:flutter_test/flutter_test.dart';
import 'package:neoquest/models/multi_stop_side_quest.dart';

void main() {
  test('route round-trips ordered activity and custom-place stops', () {
    const route = MultiStopSideQuest(
      id: 'afternoon-route',
      name: 'A Berkeley afternoon',
      description: 'A walk, a snack, and the water.',
      stops: [
        SideQuestStop(
          id: 'activity-campanile',
          kind: SideQuestStopKind.activity,
          activityId: 'campanile',
          name: 'The Campanile',
          location: 'UC Berkeley',
          latitude: 37.8721,
          longitude: -122.2578,
        ),
        SideQuestStop(
          id: 'place-1',
          kind: SideQuestStopKind.customPlace,
          name: 'My favorite bench',
          location: 'My favorite bench',
          latitude: 37.8647,
          longitude: -122.3149,
        ),
      ],
    );

    final restored = MultiStopSideQuest.fromDocument('afternoon-route', {
      ...route.toMap(),
      'createdAt': DateTime.utc(2026, 11, 24),
    });

    expect(restored.name, route.name);
    expect(restored.stops.map((stop) => stop.name), [
      'The Campanile',
      'My favorite bench',
    ]);
    expect(restored.stops.first.activityId, 'campanile');
    expect(restored.stops.first.kind, SideQuestStopKind.activity);
    expect(restored.stops.last.kind, SideQuestStopKind.customPlace);
    expect(restored.stops.last.latitude, 37.8647);
    expect(restored.createdAt, DateTime.utc(2026, 11, 24));
  });
}
