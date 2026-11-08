import 'package:flutter_test/flutter_test.dart';
import 'package:neoquest/data/activity_api.dart';
import 'package:neoquest/models/activity.dart';

void main() {
  const marina = Activity(
    id: 'marina',
    name: 'Berkeley Marina',
    category: 'Outdoors',
    description: 'A walk by the water.',
    location: 'Berkeley Marina',
    price: 'Free',
    duration: '1 hour',
    rating: 4.8,
    emoji: '⛵',
    colors: [44, 124, 155, 174, 222, 221],
  );
  const marinaPicnic = Activity(
    id: 'marina-picnic',
    name: 'Picnic at the Marina',
    category: 'Outdoors',
    description: 'Bring lunch to the water.',
    location: 'Berkeley Marina',
    price: 'Free',
    duration: '1 hour',
    rating: 4.6,
    emoji: '🧺',
    colors: [44, 124, 155, 174, 222, 221],
  );

  test('guest history leaves every quest visible', () {
    expect(filterUnvisitedActivities([marina, marinaPicnic], const {}), [
      marina,
      marinaPicnic,
    ]);
  });

  test('visited quest is hidden by ID, not by venue name', () {
    expect(filterUnvisitedActivities([marina, marinaPicnic], {'marina'}), [
      marinaPicnic,
    ]);
  });

  test('undoing a visit makes the quest visible again', () {
    expect(filterUnvisitedActivities([marina], const {}), [marina]);
  });
}
