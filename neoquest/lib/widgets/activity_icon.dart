import 'package:flutter/material.dart';

import '../models/activity.dart';

IconData activityIcon(Activity activity) {
  if (activity.isCommunityQuest) return Icons.auto_awesome_rounded;
  return switch (activity.id) {
    'marina' => Icons.directions_boat_filled_rounded,
    'tilden' => Icons.forest_rounded,
    'adventure' => Icons.toys_rounded,
    'lake-anza' => Icons.water_rounded,
    'cheese-board' => Icons.local_pizza_rounded,
    'campanile' => Icons.account_balance_rounded,
    _ => Icons.explore_rounded,
  };
}
