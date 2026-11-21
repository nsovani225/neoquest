
import 'package:flutter/material.dart';

import '../data/adventure_packages.dart';
import '../theme.dart';

class PackagesScreen extends StatelessWidget {
  const PackagesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1000),
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Adventure Packages',
                  style: TextStyle(
                    fontSize: 34,
                    fontWeight: FontWeight.w800,
                    color: NeoColors.ink,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Multiple SideQuests, one adventure.',
                  style: TextStyle(
                    color: NeoColors.muted,
                  ),
                ),
                const SizedBox(height: 28),
                ...adventurePackages.map(
                  (package) => Card(
                    margin: const EdgeInsets.only(bottom: 16),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(20),
                      leading: const Icon(
                        Icons.route_rounded,
                        color: NeoColors.violet,
                        size: 32,
                      ),
                      title: Text(
                        package.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      subtitle: Text(
                        '${package.description}\n'
                        '${package.activityIds.length} SideQuests',
                      ),
                      isThreeLine: true,
                      trailing: const Icon(
                        Icons.arrow_forward_ios_rounded,
                      ),
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          '/packages/${package.id}',
                        );
                      },
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
}