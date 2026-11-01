import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../theme.dart';

class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.child, this.showAuthActions = true});
  final Widget child;
  final bool showAuthActions;

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: NeoColors.paper,
    body: Column(
      children: [
        _TopBar(showAuthActions: showAuthActions),
        Expanded(child: child),
      ],
    ),
  );
}

class _TopBar extends StatelessWidget {
  const _TopBar({required this.showAuthActions});
  final bool showAuthActions;

  Future<void> _signOut(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    if (context.mounted) {
      Navigator.pushNamedAndRemoveUntil(context, '/', (_) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final signedIn = FirebaseAuth.instance.currentUser != null;
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: NeoColors.line)),
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1240),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 14),
            child: Row(
              children: [
                InkWell(
                  onTap: () => Navigator.pushNamedAndRemoveUntil(
                    context,
                    signedIn ? '/home' : '/',
                    (_) => false,
                  ),
                  borderRadius: BorderRadius.circular(10),
                  child: const Row(
                    children: [
                      _BrandMark(),
                      SizedBox(width: 9),
                      Text(
                        'neoquest',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -.8,
                          color: NeoColors.ink,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                if (signedIn && MediaQuery.sizeOf(context).width > 590) ...[
                  _NavLink(
                    label: 'Home',
                    active: ModalRoute.of(context)?.settings.name == '/home',
                    onTap: () => Navigator.pushNamed(context, '/home'),
                  ),
                  const SizedBox(width: 18),
                  _NavLink(
                    label: 'Explore',
                    onTap: () => Navigator.pushNamed(context, '/list'),
                  ),
                  const SizedBox(width: 18),
                  _NavLink(
                    label: 'Map',
                    onTap: () => Navigator.pushNamed(context, '/map'),
                  ),
                  const SizedBox(width: 18),
                ],
                if (signedIn)
                  PopupMenuButton<String>(
                    tooltip: 'Account menu',
                    onSelected: (value) => value == 'signout'
                        ? _signOut(context)
                        : Navigator.pushNamed(context, '/home'),
                    itemBuilder: (_) => const [
                      PopupMenuItem(value: 'account', child: Text('Account')),
                      PopupMenuItem(value: 'signout', child: Text('Sign out')),
                    ],
                    child: CircleAvatar(
                      radius: 18,
                      backgroundColor: NeoColors.lilac,
                      child: Text(
                        (FirebaseAuth
                                        .instance
                                        .currentUser
                                        ?.displayName
                                        ?.isNotEmpty ==
                                    true
                                ? FirebaseAuth
                                      .instance
                                      .currentUser!
                                      .displayName![0]
                                : FirebaseAuth.instance.currentUser?.email
                                          ?.substring(0, 1) ??
                                      'Q')
                            .toUpperCase(),
                        style: const TextStyle(
                          color: NeoColors.violetDark,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  )
                else if (showAuthActions) ...[
                  OutlinedButton(
                    onPressed: () => Navigator.pushNamed(context, '/signin'),
                    child: const Text('Sign in'),
                  ),
                  const SizedBox(width: 9),
                  FilledButton(
                    onPressed: () => Navigator.pushNamed(context, '/signup'),
                    style: FilledButton.styleFrom(
                      backgroundColor: NeoColors.ink,
                    ),
                    child: const Text('Get started'),
                  ),
                ] else
                  TextButton.icon(
                    onPressed: () => Navigator.pushNamedAndRemoveUntil(
                      context,
                      '/',
                      (_) => false,
                    ),
                    icon: const Icon(Icons.arrow_back_rounded, size: 16),
                    label: const Text('Back to site'),
                    style: TextButton.styleFrom(
                      foregroundColor: NeoColors.muted,
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

class _BrandMark extends StatelessWidget {
  const _BrandMark();
  @override
  Widget build(BuildContext context) => Container(
    width: 32,
    height: 32,
    decoration: BoxDecoration(
      color: NeoColors.violet,
      borderRadius: BorderRadius.circular(10),
    ),
    child: const Icon(Icons.explore_rounded, color: Colors.white, size: 20),
  );
}

class _NavLink extends StatelessWidget {
  const _NavLink({
    required this.label,
    required this.onTap,
    this.active = false,
  });
  final String label;
  final VoidCallback onTap;
  final bool active;
  @override
  Widget build(BuildContext context) => TextButton(
    onPressed: onTap,
    child: Text(
      label,
      style: TextStyle(
        color: active ? NeoColors.violet : NeoColors.muted,
        fontWeight: active ? FontWeight.w800 : FontWeight.w600,
      ),
    ),
  );
}
