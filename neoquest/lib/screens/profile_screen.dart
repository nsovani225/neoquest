import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../data/activity_api.dart';
import '../models/activity.dart';
import '../models/quest_filters.dart';
import '../theme.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key, required this.api, this.promptSetup = false});
  final ActivityApi api;
  final bool promptSetup;

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs = TabController(length: 3, vsync: this);
  late final User? _user = FirebaseAuth.instance.currentUser;
  late Future<DocumentSnapshot<Map<String, dynamic>>> _profile;
  String _questSection = 'Visited';
  int _bookmarkReload = 0;
  bool _setupPromptShown = false;
  bool _setupComplete = false;
  QuestFilters _preferences = const QuestFilters();

  DocumentReference<Map<String, dynamic>> get _doc =>
      FirebaseFirestore.instance.collection('users').doc(_user!.uid);

  @override
  void initState() {
    super.initState();
    if (_user != null) _profile = _doc.get();
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  QuestFilters _filtersFromData(dynamic value) {
    if (value is! Map) return const QuestFilters();
    final map = Map<String, dynamic>.from(value);
    return QuestFilters(
      category: map['category'] as String? ?? 'All',
      maxDistance: (map['maxDistance'] as num?)?.toDouble() ?? 10,
      maxBudget: (map['maxBudget'] as num?)?.toInt() ?? 60,
      groupSize: (map['groupSize'] as num?)?.toInt() ?? 2,
      maxDurationMinutes: (map['maxDurationMinutes'] as num?)?.toInt() ?? 240,
      minRating: (map['minRating'] as num?)?.toDouble() ?? 0,
      transportation: (map['transportation'] as List<dynamic>? ?? const [])
          .map((item) => item.toString())
          .toList(),
      availability: (map['availability'] as List<dynamic>? ?? const [])
          .map((item) => item.toString())
          .toList(),
    );
  }

  Future<void> _savePreferences(QuestFilters value) async {
    await _doc.set({
      'preferences': {
        'category': value.category,
        'maxDistance': value.maxDistance,
        'maxBudget': value.maxBudget,
        'groupSize': value.groupSize,
        'maxDurationMinutes': value.maxDurationMinutes,
        'minRating': value.minRating,
        'transportation': value.transportation,
        'availability': value.availability,
      },
    }, SetOptions(merge: true));
  }

  Future<void> _finishSetup() async {
    await _doc.set({'profileSetupComplete': true}, SetOptions(merge: true));
    if (!mounted) return;
    setState(() {
      _setupComplete = true;
      _profile = _doc.get();
    });
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Your profile is ready.')));
  }

  Future<void> _editProfileField(
    String field,
    String title,
    String current,
  ) async {
    final controller = TextEditingController(text: current);
    final value = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit $title'),
        content: TextField(
          controller: controller,
          maxLength: field == 'bio' ? 200 : 60,
          maxLines: field == 'bio' ? 4 : 1,
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: const Text('Save'),
          ),
        ],
      ),
    );
    controller.dispose();
    if (value != null) {
      await _doc.set({field: value}, SetOptions(merge: true));
      if (field == 'name') await _user!.updateDisplayName(value);
      if (mounted) setState(() => _profile = _doc.get());
    }
  }

  Future<void> _signOut() async {
    await FirebaseAuth.instance.signOut();
    if (mounted) Navigator.pushNamedAndRemoveUntil(context, '/', (_) => false);
  }

  Future<void> _promptSetupIfNeeded(Map<String, dynamic> data) async {
    if (!widget.promptSetup ||
        _setupPromptShown ||
        data['profileSetupComplete'] == true) {
      return;
    }
    _setupPromptShown = true;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      final start = await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          icon: const Icon(Icons.auto_awesome_rounded, color: NeoColors.violet),
          title: const Text('Make Neoquest yours'),
          content: const Text(
            'Add a few details and tell us what makes a great quest for you. '
            'Your progress saves as you go.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Continue later'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Set up profile'),
            ),
          ],
        ),
      );
      if (mounted && start == true) {
        _tabs.animateTo(1);
      }
    });
  }

  String _date(Timestamp? timestamp) {
    if (timestamp == null) return '';
    final date = timestamp.toDate();
    return '${date.month}/${date.day}/${date.year}';
  }

  void _openActivity(String id) =>
      Navigator.pushNamed(context, '/activity/$id');

  Widget _empty(
    String title,
    String description, {
    VoidCallback? action,
  }) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 10),
    child: Column(
      children: [
        const Icon(Icons.explore_outlined, size: 34, color: NeoColors.violet),
        const SizedBox(height: 12),
        Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
        const SizedBox(height: 5),
        Text(
          description,
          textAlign: TextAlign.center,
          style: const TextStyle(color: NeoColors.muted),
        ),
        if (action != null) ...[
          const SizedBox(height: 12),
          TextButton(onPressed: action, child: const Text('Explore quests')),
        ],
      ],
    ),
  );

  Widget _activityTile({
    required String id,
    required String name,
    required String subtitle,
    String? date,
    VoidCallback? onRemove,
  }) => Card(
    margin: const EdgeInsets.only(bottom: 10),
    elevation: 0,
    color: const Color(0xFFF8F9F5),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
      side: const BorderSide(color: NeoColors.line),
    ),
    child: ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      leading: const CircleAvatar(
        backgroundColor: NeoColors.lime,
        child: Icon(Icons.place_rounded, color: NeoColors.ink),
      ),
      title: Text(name, style: const TextStyle(fontWeight: FontWeight.w700)),
      subtitle: Text(
        [
          subtitle,
          if (date != null && date.isNotEmpty) date,
        ].where((item) => item.isNotEmpty).join(' · '),
      ),
      trailing: onRemove == null
          ? const Icon(Icons.arrow_forward_ios_rounded, size: 15)
          : IconButton(
              tooltip: 'Remove from My quests',
              onPressed: onRemove,
              icon: const Icon(Icons.undo_rounded),
            ),
      onTap: () => _openActivity(id),
    ),
  );

  Widget _visitedList() => StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
    stream: _doc
        .collection('hangouts')
        .orderBy('date', descending: true)
        .snapshots(),
    builder: (context, snap) {
      if (snap.hasError) {
        return Text('Couldn’t load visited quests: ${snap.error}');
      }
      if (!snap.hasData) {
        return const Center(child: CircularProgressIndicator());
      }
      if (snap.data!.docs.isEmpty) {
        return _empty(
          'Your quest history starts here',
          'Quests you’ve been on will appear here.',
          action: () => Navigator.pushNamed(context, '/explore'),
        );
      }
      return Column(
        children: [
          for (final doc in snap.data!.docs)
            _activityTile(
              id: doc.id,
              name: (doc.data()['activityName'] as String?) ?? 'Quest',
              subtitle: (doc.data()['category'] as String?) ?? '',
              date: _date(doc.data()['date'] as Timestamp?),
              onRemove: () async {
                try {
                  await widget.api.unmarkVisited(doc.id);
                } on FirebaseException catch (error) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          error.message ?? 'Could not update quest history.',
                        ),
                      ),
                    );
                  }
                }
              },
            ),
        ],
      );
    },
  );

  Widget _bookmarkedList() => FutureBuilder<Set<String>>(
    key: ValueKey(_bookmarkReload),
    future: widget.api.savedIds(),
    builder: (context, snap) {
      if (snap.hasError) return Text('Couldn’t load bookmarks: ${snap.error}');
      if (!snap.hasData) {
        return const Center(child: CircularProgressIndicator());
      }
      final ids = snap.data!.toList();
      if (ids.isEmpty) {
        return _empty(
          'No bookmarks yet',
          'Save quests you want to come back to.',
          action: () => Navigator.pushNamed(context, '/explore'),
        );
      }
      return FutureBuilder<List<Activity?>>(
        future: Future.wait(ids.map(widget.api.getActivity)),
        builder: (context, activities) {
          if (activities.hasError) {
            return Text('Couldn’t load bookmarks: ${activities.error}');
          }
          if (!activities.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final available = activities.data!.whereType<Activity>().toList();
          if (available.isEmpty) {
            return _empty(
              'No available quests',
              'Saved quests may have been removed.',
            );
          }
          return Column(
            children: [
              for (final quest in available)
                _activityTile(
                  id: quest.id,
                  name: quest.name,
                  subtitle: quest.category,
                ),
            ],
          );
        },
      );
    },
  );

  Widget _createdList() => StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
    stream: FirebaseFirestore.instance
        .collection('activities')
        .where('creatorId', isEqualTo: _user!.uid)
        .snapshots(),
    builder: (context, snap) {
      if (snap.hasError) {
        return Text('Couldn’t load created quests: ${snap.error}');
      }
      if (!snap.hasData) {
        return const Center(child: CircularProgressIndicator());
      }
      const sampleIds = {
        'marina',
        'tilden',
        'adventure',
        'lake-anza',
        'cheese-board',
        'campanile',
      };
      final docs =
          snap.data!.docs.where((doc) => !sampleIds.contains(doc.id)).toList()
            ..sort((a, b) {
              final aDate = a.data()['createdAt'] as Timestamp?;
              final bDate = b.data()['createdAt'] as Timestamp?;
              return (bDate?.millisecondsSinceEpoch ?? 0).compareTo(
                aDate?.millisecondsSinceEpoch ?? 0,
              );
            });
      if (docs.isEmpty) {
        return _empty(
          'No quests created yet',
          'Create a quest and it will show up here.',
          action: () => Navigator.pushNamed(context, '/explore'),
        );
      }
      return Column(
        children: [
          for (final doc in docs)
            _activityTile(
              id: doc.id,
              name: (doc.data()['name'] as String?) ?? 'Quest',
              subtitle: (doc.data()['category'] as String?) ?? 'Side quest',
              date: _date(doc.data()['createdAt'] as Timestamp?),
            ),
        ],
      );
    },
  );

  Widget _questsTab() => ListView(
    padding: const EdgeInsets.fromLTRB(4, 20, 4, 28),
    children: [
      const Text(
        'Your quests, all in one place.',
        style: TextStyle(color: NeoColors.muted),
      ),
      const SizedBox(height: 16),
      Wrap(
        spacing: 8,
        runSpacing: 8,
        children: ['Visited', 'Bookmarked', 'Created']
            .map(
              (section) => ChoiceChip(
                label: Text(section),
                selected: section == _questSection,
                onSelected: (_) => setState(() {
                  _questSection = section;
                  if (section == 'Bookmarked') _bookmarkReload++;
                }),
              ),
            )
            .toList(),
      ),
      const SizedBox(height: 16),
      if (_questSection == 'Visited') _visitedList(),
      if (_questSection == 'Bookmarked') _bookmarkedList(),
      if (_questSection == 'Created') _createdList(),
    ],
  );

  Widget _accountTab(Map<String, dynamic> data) {
    final name = (data['name'] as String?)?.trim().isNotEmpty == true
        ? (data['name'] as String).trim()
        : (_user!.displayName ?? 'Explorer');
    final email = (data['email'] as String?) ?? _user!.email ?? '';
    final bio = (data['bio'] as String?) ?? '';
    final photoUrl = _user!.photoURL;
    return ListView(
      padding: const EdgeInsets.fromLTRB(4, 20, 4, 28),
      children: [
        Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFEBF6D9), Color(0xFFF4F0FF)],
            ),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: NeoColors.line),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 34,
                backgroundColor: NeoColors.lime,
                backgroundImage: photoUrl == null
                    ? null
                    : NetworkImage(photoUrl),
                child: photoUrl == null
                    ? const Icon(Icons.person, color: NeoColors.ink, size: 32)
                    : null,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: NeoColors.ink,
                      ),
                    ),
                    Text(email, style: const TextStyle(color: NeoColors.muted)),
                  ],
                ),
              ),
              IconButton(
                tooltip: 'Preview profile',
                onPressed: () => showDialog<void>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Your profile preview'),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CircleAvatar(
                          radius: 28,
                          backgroundColor: NeoColors.lime,
                          child: const Icon(Icons.person, color: NeoColors.ink),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          name,
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 20,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          bio.isEmpty
                              ? 'Add a bio to introduce yourself.'
                              : bio,
                        ),
                      ],
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Close'),
                      ),
                    ],
                  ),
                ),
                icon: const Icon(Icons.visibility_outlined),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        if (!_setupComplete && data['profileSetupComplete'] != true)
          Card(
            color: const Color(0xFFF7F4FF),
            child: ListTile(
              leading: const Icon(
                Icons.auto_awesome_rounded,
                color: NeoColors.violet,
              ),
              title: const Text('Finish setting up your profile'),
              subtitle: const Text('Your progress saves as you go.'),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: () => _tabs.animateTo(1),
            ),
          ),
        _infoCard('Profile details', Icons.person_outline, [
          _detailRow(
            'Name',
            name,
            () => _editProfileField('name', 'name', name),
          ),
          const Divider(height: 24),
          _detailRow('Email', email, null),
          const Divider(height: 24),
          _detailRow(
            'Bio',
            bio.isEmpty ? 'Add a short bio' : bio,
            () => _editProfileField('bio', 'bio', bio),
          ),
        ]),
        const SizedBox(height: 14),
        OutlinedButton.icon(
          onPressed: _signOut,
          icon: const Icon(Icons.logout_rounded),
          label: const Text('Sign out'),
        ),
      ],
    );
  }

  Widget _detailRow(String label, String value, VoidCallback? edit) => Row(
    children: [
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(color: NeoColors.muted, fontSize: 12),
            ),
            const SizedBox(height: 3),
            Text(
              value,
              style: const TextStyle(
                color: NeoColors.ink,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
      if (edit != null)
        IconButton(
          onPressed: edit,
          icon: const Icon(Icons.edit_outlined, size: 19),
        ),
    ],
  );

  Widget _infoCard(String title, IconData icon, List<Widget> children) =>
      Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: NeoColors.line),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: NeoColors.violet),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      );

  @override
  Widget build(BuildContext context) {
    if (_user == null) {
      return Center(
        child: FilledButton(
          onPressed: () =>
              Navigator.pushNamed(context, '/signin?returnTo=/profile'),
          child: const Text('Sign in to see your profile'),
        ),
      );
    }
    return FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      future: _profile,
      builder: (context, snapshot) {
        final data = snapshot.data?.data() ?? <String, dynamic>{};
        if (snapshot.hasData) {
          _preferences = _filtersFromData(data['preferences']);
          _promptSetupIfNeeded(data);
        }
        return Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 900),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Your profile',
                    style: TextStyle(
                      fontSize: 31,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.8,
                      color: NeoColors.ink,
                    ),
                  ),
                  const SizedBox(height: 5),
                  const Text(
                    'Your quests, your kind of adventure.',
                    style: TextStyle(color: NeoColors.muted),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3F4EF),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: TabBar(
                      controller: _tabs,
                      isScrollable: false,
                      labelColor: NeoColors.ink,
                      unselectedLabelColor: NeoColors.muted,
                      indicator: BoxDecoration(
                        color: NeoColors.lime,
                        borderRadius: BorderRadius.circular(13),
                      ),
                      indicatorPadding: const EdgeInsets.all(4),
                      dividerColor: Colors.transparent,
                      tabs: const [
                        Tab(text: 'My quests'),
                        Tab(text: 'Preferences'),
                        Tab(text: 'Account'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: TabBarView(
                      controller: _tabs,
                      children: [
                        _questsTab(),
                        _PreferencesPanel(
                          key: ValueKey(snapshot.hasData),
                          initialValue: _preferences,
                          onChanged: _savePreferences,
                          onFinish: _finishSetup,
                          setupComplete:
                              _setupComplete ||
                              data['profileSetupComplete'] == true,
                        ),
                        snapshot.hasError
                            ? Center(
                                child: Text(
                                  'Couldn’t load your account: ${snapshot.error}',
                                ),
                              )
                            : _accountTab(data),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _PreferencesPanel extends StatefulWidget {
  const _PreferencesPanel({
    super.key,
    required this.initialValue,
    required this.onChanged,
    required this.onFinish,
    required this.setupComplete,
  });
  final QuestFilters initialValue;
  final Future<void> Function(QuestFilters) onChanged;
  final Future<void> Function() onFinish;
  final bool setupComplete;

  @override
  State<_PreferencesPanel> createState() => _PreferencesPanelState();
}

class _PreferencesPanelState extends State<_PreferencesPanel> {
  late QuestFilters _filters = widget.initialValue;
  Timer? _saveTimer;
  bool _saving = false;
  bool _saved = false;
  bool _saveFailed = false;
  static const _categories = [
    'All',
    'Food & drinks',
    'Outdoor',
    'Sports',
    'Adventure',
    'Arts & culture',
    'Explore',
    'Games',
    'Chill',
  ];
  static const _transport = ['Walking', 'Bike', 'Public transit', 'Car'];
  static const _availability = [
    'Daytime',
    'Sunset',
    'Lunch',
    'Dinner',
    'Anytime',
  ];

  @override
  void dispose() {
    _saveTimer?.cancel();
    super.dispose();
  }

  void _update(QuestFilters value) {
    setState(() {
      _filters = value;
      _saved = false;
      _saveFailed = false;
    });
    _saveTimer?.cancel();
    _saveTimer = Timer(const Duration(milliseconds: 450), _persist);
  }

  Future<bool> _persist() async {
    if (!mounted) return false;
    setState(() => _saving = true);
    try {
      await widget.onChanged(_filters);
      if (mounted) {
        setState(() {
          _saving = false;
          _saved = true;
          _saveFailed = false;
        });
      }
      return true;
    } catch (_) {
      if (mounted) {
        setState(() {
          _saving = false;
          _saved = false;
          _saveFailed = true;
        });
      }
      return false;
    }
  }

  void _toggle(
    List<String> values,
    String choice,
    void Function(List<String>) update,
  ) {
    final next = [...values];
    if (!next.remove(choice)) next.add(choice);
    update(next);
  }

  Widget _card(String title, IconData icon, Widget content) => Container(
    margin: const EdgeInsets.only(bottom: 14),
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: NeoColors.line),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: NeoColors.violet),
            const SizedBox(width: 9),
            Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
          ],
        ),
        const SizedBox(height: 14),
        content,
      ],
    ),
  );

  Widget _choiceChips(
    List<String> values,
    String selected,
    void Function(String) onSelected,
  ) => Wrap(
    spacing: 7,
    runSpacing: 7,
    children: values
        .map(
          (value) => ChoiceChip(
            label: Text(value),
            selected: selected == value,
            onSelected: (_) => onSelected(value),
          ),
        )
        .toList(),
  );

  Widget _multiChips(
    List<String> values,
    List<String> selected,
    void Function(List<String>) onChanged,
  ) => Wrap(
    spacing: 7,
    runSpacing: 7,
    children: values
        .map(
          (value) => FilterChip(
            label: Text(value),
            selected: selected.contains(value),
            onSelected: (_) => _toggle(selected, value, onChanged),
          ),
        )
        .toList(),
  );

  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.fromLTRB(4, 20, 4, 28),
    children: [
      const Text(
        'Tell us what a great quest looks like for you.',
        style: TextStyle(color: NeoColors.muted),
      ),
      const SizedBox(height: 16),
      _card(
        'What sounds fun?',
        Icons.auto_awesome_outlined,
        _choiceChips(
          _categories,
          _filters.category,
          (value) => _update(_filters.copyWith(category: value)),
        ),
      ),
      _card(
        'How far would you go?',
        Icons.near_me_outlined,
        Column(
          children: [
            Slider(
              value: _filters.maxDistance.clamp(.5, 10),
              min: .5,
              max: 10,
              divisions: 19,
              label: '${_filters.maxDistance.toStringAsFixed(1)} mi',
              onChanged: (value) =>
                  _update(_filters.copyWith(maxDistance: value)),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                'Up to ${_filters.maxDistance.toStringAsFixed(1)} miles',
              ),
            ),
          ],
        ),
      ),
      _card(
        'Budget per person',
        Icons.payments_outlined,
        Column(
          children: [
            Slider(
              value: _filters.maxBudget.toDouble().clamp(0, 100),
              min: 0,
              max: 100,
              divisions: 20,
              label: _filters.maxBudget == 0
                  ? 'Free'
                  : '\$${_filters.maxBudget}',
              onChanged: (value) =>
                  _update(_filters.copyWith(maxBudget: value.round())),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                _filters.maxBudget == 0
                    ? 'Free quests'
                    : 'Up to \$${_filters.maxBudget}',
              ),
            ),
          ],
        ),
      ),
      _card(
        'Who’s coming?',
        Icons.group_outlined,
        _choiceChips(
          ['1', '2', '4', '6', '8'],
          '${_filters.groupSize}',
          (value) => _update(_filters.copyWith(groupSize: int.parse(value))),
        ),
      ),
      _card(
        'How much time?',
        Icons.schedule_rounded,
        _choiceChips(
          ['1 hour', '2 hours', '4 hours', 'Any'],
          _filters.maxDurationMinutes <= 60
              ? '1 hour'
              : _filters.maxDurationMinutes <= 120
              ? '2 hours'
              : _filters.maxDurationMinutes >= 240
              ? 'Any'
              : '4 hours',
          (value) => _update(
            _filters.copyWith(
              maxDurationMinutes: switch (value) {
                '1 hour' => 60,
                '2 hours' => 120,
                '4 hours' => 180,
                _ => 240,
              },
            ),
          ),
        ),
      ),
      _card(
        'Getting around',
        Icons.directions_transit_outlined,
        _multiChips(
          _transport,
          _filters.transportation,
          (values) => _update(_filters.copyWith(transportation: values)),
        ),
      ),
      _card(
        'When are you usually free?',
        Icons.wb_sunny_outlined,
        _multiChips(
          _availability,
          _filters.availability,
          (values) => _update(_filters.copyWith(availability: values)),
        ),
      ),
      _card(
        'Minimum rating',
        Icons.star_outline_rounded,
        Column(
          children: [
            Slider(
              value: _filters.minRating.clamp(0, 5),
              min: 0,
              max: 5,
              divisions: 10,
              label: _filters.minRating == 0
                  ? 'Any'
                  : '${_filters.minRating.toStringAsFixed(1)}+',
              onChanged: (value) =>
                  _update(_filters.copyWith(minRating: value)),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                _filters.minRating == 0
                    ? 'Any rating'
                    : '${_filters.minRating.toStringAsFixed(1)} stars or higher',
              ),
            ),
          ],
        ),
      ),
      Row(
        children: [
          if (_saving)
            const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          if (_saved && !_saving)
            const Icon(
              Icons.check_circle_outline,
              color: Colors.green,
              size: 18,
            ),
          if (_saveFailed && !_saving)
            const Icon(Icons.error_outline, color: Colors.red, size: 18),
          if (_saving || _saved || _saveFailed) const SizedBox(width: 8),
          if (_saving || _saved || _saveFailed)
            Text(
              _saving
                  ? 'Saving preferences…'
                  : _saveFailed
                  ? 'Could not save. Check your connection.'
                  : 'Saved automatically',
              style: const TextStyle(color: NeoColors.muted),
            ),
          const Spacer(),
          if (!widget.setupComplete)
            FilledButton.icon(
              onPressed: () async {
                _saveTimer?.cancel();
                final saved = await _persist();
                if (saved) await widget.onFinish();
              },
              icon: const Icon(Icons.check_rounded),
              label: const Text('Finish setup'),
            ),
        ],
      ),
    ],
  );
}
