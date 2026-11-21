import '../models/adventure_package.dart';

const adventurePackages = <AdventurePackage>[
  AdventurePackage(
    id: 'berkeley-explorer',
    name: 'Berkeley Explorer',
    description:
        'Discover Berkeley through food, campus views, and the waterfront.',
    activityIds: [
      'campanile',
      'cheese-board',
      'marina',
    ],
    category: 'Exploration',
  ),

  AdventurePackage(
    id: 'nature-escape',
    name: 'Nature Escape',
    description:
        'Spend a relaxing day exploring the outdoors.',
    activityIds: [
      'tilden',
      'lake-anza',
    ],
    category: 'Outdoors',
  ),

  AdventurePackage(
    id: 'marina-adventure',
    name: 'Marina Adventure',
    description:
        'Enjoy two fun activities near the Berkeley waterfront.',
    activityIds: [
      'adventure',
      'marina',
    ],
    category: 'Adventure',
  ),
];