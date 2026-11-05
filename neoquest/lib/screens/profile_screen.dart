// lib/screens/profile_screen.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../theme.dart';

/// Saves a hangout for the signed-in user. Call this when a quest is started.
Future<void> recordHangout({
  required String activityId,
  required String activityName,
  String category = '',
}) async {
  final u = FirebaseAuth.instance.currentUser;
  if (u == null) return;
  await FirebaseFirestore.instance
      .collection('users')
      .doc(u.uid)
      .collection('hangouts')
      .add({
    'activityId': activityId,
    'activityName': activityName,
    'category': category,
    'date': FieldValue.serverTimestamp(),
  });
}

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return Center(
        child: FilledButton(
          onPressed: () => Navigator.pushNamed(context, '/signin?returnTo=/profile'),
          child: const Text('Sign in to see your profile'),
        ),
      );
    }
    return _ProfileBody(user: user);
  }
}

class _ProfileBody extends StatelessWidget {
  const _ProfileBody({required this.user});
  final User user;

  DocumentReference<Map<String, dynamic>> get _doc =>
      FirebaseFirestore.instance.collection('users').doc(user.uid);

  Widget _card(Widget child) => Container(
        margin: const EdgeInsets.only(bottom: 20),
        padding: const EdgeInsets.all(24),
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: NeoColors.line),
        ),
        child: child,
      );

  String _fmt(Timestamp? t) {
    if (t == null) return '';
    final d = t.toDate();
    return '${d.month}/${d.day}/${d.year}';
  }

  Future<void> _editBio(BuildContext context, String current) async {
    final c = TextEditingController(text: current);
    final save = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Edit bio'),
        content: TextField(controller: c, maxLines: 4, maxLength: 200),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: NeoColors.violet),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Save'),
          ),
        ],
      ),
    );
    if (save == true) {
      await _doc.set({'bio': c.text.trim()}, SetOptions(merge: true));
    }
  }

  Future<void> _signOut(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    if (context.mounted) {
      Navigator.pushNamedAndRemoveUntil(context, '/', (_) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 760),
        child: ListView(padding: const EdgeInsets.all(24), children: [
          // ── Account details ──
          _card(StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
            stream: _doc.snapshots(),
            builder: (context, snap) {
              final d = snap.data?.data() ?? {};
              final storedName = (d['name'] as String?) ?? '';
              final name = storedName.isNotEmpty
                  ? storedName
                  : (user.displayName ?? 'Explorer');
              final email = (d['email'] as String?) ?? user.email ?? '';
              final bio = (d['bio'] as String?) ?? '';
              return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  CircleAvatar(
                    radius: 32,
                    backgroundColor: NeoColors.lime,
                    backgroundImage: user.photoURL != null
                        ? NetworkImage(user.photoURL!)
                        : null,
                    child: user.photoURL == null
                        ? const Icon(Icons.person, size: 32, color: NeoColors.ink)
                        : null,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(name,
                          style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w800,
                              color: NeoColors.ink)),
                      Text(email,
                          style: const TextStyle(color: NeoColors.muted)),
                    ]),
                  ),
                  OutlinedButton(
                    onPressed: () => _signOut(context),
                    child: const Text('Sign out'),
                  ),
                ]),
                const SizedBox(height: 22),
                Row(children: [
                  const Text('Bio',
                      style: TextStyle(fontWeight: FontWeight.w800)),
                  const Spacer(),
                  TextButton(
                      onPressed: () => _editBio(context, bio),
                      child: const Text('Edit')),
                ]),
                Text(bio.isEmpty ? 'No bio yet.' : bio,
                    style: TextStyle(
                        color: bio.isEmpty ? NeoColors.muted : NeoColors.ink)),
              ]);
            },
          )),

          // ── Past hangouts ──
          _card(Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Past hangouts',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
            const SizedBox(height: 12),
            StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: _doc
                  .collection('hangouts')
                  .orderBy('date', descending: true)
                  .snapshots(),
              builder: (context, snap) {
                if (snap.hasError) {
                  return Text('Couldn’t load hangouts: ${snap.error}');
                }
                if (!snap.hasData) {
                  return const Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                final docs = snap.data!.docs;
                if (docs.isEmpty) {
                  return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    const Text('No hangouts yet. Start a quest to see it here.',
                        style: TextStyle(color: NeoColors.muted)),
                    TextButton(
                        onPressed: () => Navigator.pushNamed(context, '/explore'),
                        child: const Text('Explore quests')),
                  ]);
                }
                return Column(children: [
                  for (final h in docs)
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const CircleAvatar(
                          backgroundColor: NeoColors.lime,
                          child: Icon(Icons.place, color: NeoColors.ink, size: 18)),
                      title: Text((h.data()['activityName'] as String?) ?? 'Quest'),
                      subtitle: Text((h.data()['category'] as String?) ?? ''),
                      trailing: Text(_fmt(h.data()['date'] as Timestamp?),
                          style: const TextStyle(
                              color: NeoColors.muted, fontSize: 12)),
                    ),
                ]);
              },
            ),
          ])),
        ]),
      ),
    );
  }
}