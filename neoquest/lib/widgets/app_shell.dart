import 'package:flutter/material.dart';

import '../theme.dart';

class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) => Scaffold(
    body: Column(
      children: [
        const _TopBar(),
        Expanded(child: child),
      ],
    ),
  );
}

class _TopBar extends StatelessWidget {
  const _TopBar();

  @override
  Widget build(BuildContext context) => Container(
    decoration: const BoxDecoration(
      color: NeoColors.paper,
      border: Border(bottom: BorderSide(color: NeoColors.line)),
    ),
    child: Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1200),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 17),
          child: Row(
            children: [
              InkWell(
                onTap: () => Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/',
                  (_) => false,
                ),
                borderRadius: BorderRadius.circular(10),
                child: const Row(
                  children: [
                    _BrandMark(),
                    SizedBox(width: 10),
                    Text(
                      'neoquest',
                      style: TextStyle(
                        fontSize: 21,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.8,
                        color: NeoColors.ink,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              if (MediaQuery.sizeOf(context).width > 600) ...[
                _NavLink(
                  label: 'Explore',
                  onTap: () => Navigator.pushNamed(context, '/explore'),
                ),
                const SizedBox(width: 24),
                _NavLink(
                  label: 'Map',
                  onTap: () => Navigator.pushNamed(context, '/map'),
                ),
                const SizedBox(width: 24),
                _NavLink(
                  label: 'How it works',
                  onTap: () => Navigator.pushNamed(context, '/'),
                ),
                const SizedBox(width: 22),
              ],
              OutlinedButton(
                onPressed: () => Navigator.pushNamed(context, '/signin'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: NeoColors.ink,
                  side: const BorderSide(color: NeoColors.line),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(13),
                  ),
                ),
                child: const Text(
                  'Sign in',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
              const SizedBox(width: 10),
              FilledButton.icon(
                onPressed: () => Navigator.pushNamed(context, '/signup'),
                style: FilledButton.styleFrom(
                  backgroundColor: NeoColors.ink,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 17,
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(13),
                  ),
                ),
                icon: const Icon(Icons.arrow_outward_rounded, size: 16),
                label: const Text(
                  'Get started',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

class _BrandMark extends StatelessWidget {
  const _BrandMark();
  @override
  Widget build(BuildContext context) => Container(
    width: 34,
    height: 34,
    decoration: BoxDecoration(
      color: NeoColors.violet,
      borderRadius: BorderRadius.circular(11),
    ),
    child: const Icon(Icons.explore_rounded, color: Colors.white, size: 21),
  );
}

class _NavLink extends StatelessWidget {
  const _NavLink({required this.label, required this.onTap});
  final String label;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => TextButton(
    onPressed: onTap,
    style: TextButton.styleFrom(foregroundColor: NeoColors.muted),
    child: Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
  );
}
