import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../data/activity_api.dart';
import '../models/activity.dart';
import '../models/quest_filters.dart';
import '../theme.dart';
import '../widgets/activity_card.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({
    super.key,
    required this.api,
    required this.initialFilters,
  });
  final ActivityApi api;
  final QuestFilters initialFilters;

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  final _search = TextEditingController();
  late Future<List<Activity>> _items;
  String _category = 'All';
  late QuestFilters _filters;
  Set<String> _saved = {};
  bool _onlySaved = false;

  static const _categories = [
    'All',
    'Outdoors',
    'Nature',
    'Food & drink',
    'Play',
    'Explore',
    'Community',
  ];

  @override
  void initState() {
    super.initState();
    _filters = widget.initialFilters;
    _category = _filters.category;
    _items = widget.api.listActivities(filters: _filters);
    _loadSaved();
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  void _refresh() {
    setState(() {
      _items = widget.api.listActivities(
        query: _search.text,
        category: _category == 'Community' ? 'All' : _category,
        filters: _filters.copyWith(
          category: _category == 'Community' ? 'All' : _category,
        ),
      );
    });
  }

  Future<void> _openActivity(String id) async {
    await Navigator.pushNamed(context, '/activity/$id');
    if (mounted) _refresh();
  }

  Future<void> _loadSaved() async {
    final ids = await widget.api.savedIds();
    if (mounted) setState(() => _saved = ids);
  }

  Future<void> _toggleSaved(String id) async {
    if (FirebaseAuth.instance.currentUser == null) {
      Navigator.pushNamed(context, '/signin?returnTo=/list');
      return;
    }
    try {
      await widget.api.toggleSaved(id);
      await _loadSaved();
    } on FirebaseException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message ?? 'Sign in to save this quest.')),
        );
      }
      if (mounted && e.code == 'unauthenticated') {
        Navigator.pushNamed(context, '/signin');
      }
    }
  }

  Future<void> _createQuest() async {
    if (FirebaseAuth.instance.currentUser == null) {
      Navigator.pushNamed(context, '/signin?returnTo=/list');
      return;
    }
    final activity = await showDialog<Activity>(
      context: context,
      builder: (_) => const _CreateQuestDialog(),
    );
    if (activity == null) return;
    try {
      await widget.api.createActivity(activity);
    } on FirebaseException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.message ?? 'Sign in and set up Firestore to publish.',
          ),
        ),
      );
      if (e.code == 'unauthenticated') Navigator.pushNamed(context, '/signin');
      return;
    }
    if (!mounted) return;
    setState(() {
      _category = 'All';
      _filters = const QuestFilters();
      _search.clear();
      _onlySaved = false;
      _items = widget.api.listActivities();
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Your side quest is live in this browser.')),
    );
  }

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    child: Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1200),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(28, 42, 28, 72),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              LayoutBuilder(
                builder: (context, box) {
                  final intro = const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'THE BERKELEY EDITION',
                        style: TextStyle(
                          fontSize: 10,
                          letterSpacing: 1.5,
                          color: NeoColors.violet,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      SizedBox(height: 11),
                      Text(
                        'Find your kind of fun.',
                        style: TextStyle(
                          fontSize: 37,
                          letterSpacing: -1.3,
                          fontWeight: FontWeight.w800,
                          color: NeoColors.ink,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'A few good ideas, close enough to make today interesting.',
                        style: TextStyle(fontSize: 15, color: NeoColors.muted),
                      ),
                    ],
                  );
                  final actions = Wrap(
                    spacing: 9,
                    runSpacing: 8,
                    children: [
                      FilledButton.icon(
                        onPressed: _createQuest,
                        icon: const Icon(Icons.add_rounded),
                        label: const Text('Add a side quest'),
                        style: FilledButton.styleFrom(
                          backgroundColor: NeoColors.ink,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 17,
                            vertical: 16,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(13),
                          ),
                        ),
                      ),
                      OutlinedButton.icon(
                        onPressed: () => Navigator.pushNamed(
                          context,
                          Uri(
                            path: '/filters',
                            queryParameters: _filters.toQuery(),
                          ).toString(),
                        ),
                        icon: const Icon(Icons.tune_rounded, size: 17),
                        label: const Text('Filters'),
                      ),
                    ],
                  );
                  return box.maxWidth > 760
                      ? Row(
                          children: [
                            Expanded(child: intro),
                            const SizedBox(width: 16),
                            actions,
                          ],
                        )
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            intro,
                            const SizedBox(height: 15),
                            actions,
                          ],
                        );
                },
              ),
              const SizedBox(height: 27),
              Container(
                padding: const EdgeInsets.all(14),
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
                        Expanded(
                          child: TextField(
                            controller: _search,
                            onChanged: (_) => _refresh(),
                            decoration: const InputDecoration(
                              hintText: 'Search places, moods, neighborhoods…',
                              prefixIcon: Icon(Icons.search_rounded),
                              border: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              filled: true,
                            ),
                          ),
                        ),
                        const SizedBox(width: 9),
                        OutlinedButton.icon(
                          onPressed: () {
                            if (FirebaseAuth.instance.currentUser == null) {
                              Navigator.pushNamed(
                                context,
                                '/signin?returnTo=/list',
                              );
                              return;
                            }
                            setState(() => _onlySaved = !_onlySaved);
                          },
                          icon: Icon(
                            _onlySaved
                                ? Icons.favorite_rounded
                                : Icons.favorite_border_rounded,
                            color: _onlySaved ? NeoColors.coral : NeoColors.ink,
                            size: 18,
                          ),
                          label: const Text('Saved'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: NeoColors.ink,
                            side: const BorderSide(color: NeoColors.line),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 15,
                              vertical: 16,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(13),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 13),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _categories
                          .map(
                            (category) => ChoiceChip(
                              label: Text(category),
                              selected: _category == category,
                              onSelected: (_) => setState(() {
                                _category = category;
                                _filters = _filters.copyWith(
                                  category: category,
                                );
                                _items = widget.api.listActivities(
                                  query: _search.text,
                                  category: category == 'Community'
                                      ? 'All'
                                      : category,
                                  filters: _filters,
                                );
                              }),
                              selectedColor: NeoColors.lilac,
                              backgroundColor: NeoColors.paper,
                              side: BorderSide(
                                color: _category == category
                                    ? NeoColors.lilac
                                    : NeoColors.line,
                              ),
                              labelStyle: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: _category == category
                                    ? NeoColors.violetDark
                                    : NeoColors.muted,
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 26),
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Little adventures, big payoff',
                      style: TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.w800,
                        color: NeoColors.ink,
                      ),
                    ),
                  ),
                  FutureBuilder<List<Activity>>(
                    future: _items,
                    builder: (_, snapshot) => Text(
                      '${_onlySaved ? (snapshot.data?.where((a) => _saved.contains(a.id)).length ?? 0) : (snapshot.data?.length ?? 0)} ideas',
                      style: const TextStyle(
                        fontSize: 12,
                        color: NeoColors.muted,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 17),
              FutureBuilder<List<Activity>>(
                future: _items,
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return const _EmptyState(
                      title: 'Could not load ideas',
                      subtitle: 'The local demo API had a hiccup. Refresh and try again.',
                    );
                  }
                  if (!snapshot.hasData) {
                    return const SizedBox(
                      height: 280,
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }
                  final items = snapshot.data!.where((a) {
                    if (_category == 'Community' && !a.isCommunityQuest) {
                      return false;
                    }
                    if (_onlySaved && !_saved.contains(a.id)) {
                      return false;
                    }
                    return true;
                  }).toList();
                  if (items.isEmpty) {
                    return _EmptyState(
                      title: _onlySaved
                          ? 'Nothing saved just yet'
                          : 'No side quests found',
                      subtitle: _onlySaved
                          ? 'Tap the heart on an idea you want to keep.'
                          : 'Try a different filter or add the first idea.',
                    );
                  }
                  return LayoutBuilder(
                    builder: (context, box) {
                      final columns = box.maxWidth > 900
                          ? 3
                          : box.maxWidth > 620
                          ? 2
                          : 1;
                      return GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: items.length,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: columns,
                          mainAxisExtent: 319,
                          crossAxisSpacing: 17,
                          mainAxisSpacing: 17,
                        ),
                        itemBuilder: (context, i) {
                          final item = items[i];
                          return ActivityCard(
                            activity: item,
                            isSaved: _saved.contains(item.id),
                            onSave: () => _toggleSaved(item.id),
                            onTap: () => _openActivity(item.id),
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

class _CreateQuestDialog extends StatefulWidget {
  const _CreateQuestDialog();
  @override
  State<_CreateQuestDialog> createState() => _CreateQuestDialogState();
}

class _CreateQuestDialogState extends State<_CreateQuestDialog> {
  final _form = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _description = TextEditingController();
  final _location = TextEditingController(text: 'Berkeley, CA');
  final _latitude = TextEditingController(text: '37.8715');
  final _longitude = TextEditingController(text: '-122.2730');
  String _category = 'Community';
  String _price = 'Free';

  @override
  void dispose() {
    _name.dispose();
    _description.dispose();
    _location.dispose();
    _latitude.dispose();
    _longitude.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    backgroundColor: NeoColors.paper,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
    title: const Text(
      'Add a side quest',
      style: TextStyle(fontWeight: FontWeight.w800, color: NeoColors.ink),
    ),
    content: SizedBox(
      width: 460,
      child: Form(
        key: _form,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Have a local idea worth sharing? Add it to the community collection.',
                  style: TextStyle(color: NeoColors.muted, height: 1.4),
                ),
              ),
              const SizedBox(height: 18),
              TextFormField(
                controller: _name,
                decoration: const InputDecoration(
                  labelText: 'Quest name',
                  hintText: 'Sunset at the marina',
                ),
                validator: (v) => v == null || v.trim().isEmpty
                    ? 'Give your quest a name.'
                    : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _description,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'A little about it',
                  hintText: 'What makes it fun?',
                ),
                validator: (v) => v == null || v.trim().isEmpty
                    ? 'Add a short description.'
                    : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _location,
                decoration: const InputDecoration(
                  labelText: 'Where',
                  prefixIcon: Icon(Icons.place_outlined),
                ),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Add a location.' : null,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _latitude,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                        signed: true,
                      ),
                      decoration: const InputDecoration(labelText: 'Latitude'),
                      validator: (value) => double.tryParse(value ?? '') == null
                          ? 'Enter a latitude.'
                          : null,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextFormField(
                      controller: _longitude,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                        signed: true,
                      ),
                      decoration: const InputDecoration(labelText: 'Longitude'),
                      validator: (value) => double.tryParse(value ?? '') == null
                          ? 'Enter a longitude.'
                          : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      initialValue: _category,
                      decoration: const InputDecoration(labelText: 'Category'),
                      items:
                          [
                                'Community',
                                'Outdoors',
                                'Food & drink',
                                'Play',
                                'Explore',
                              ]
                              .map(
                                (x) =>
                                    DropdownMenuItem(value: x, child: Text(x)),
                              )
                              .toList(),
                      onChanged: (v) =>
                          setState(() => _category = v ?? 'Community'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      initialValue: _price,
                      decoration: const InputDecoration(labelText: 'Budget'),
                      items: ['Free', r'$', r'$$']
                          .map(
                            (x) => DropdownMenuItem(value: x, child: Text(x)),
                          )
                          .toList(),
                      onChanged: (v) => setState(() => _price = v ?? 'Free'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('Cancel'),
      ),
      FilledButton(
        onPressed: () {
          if (!_form.currentState!.validate()) return;
          final now = DateTime.now().microsecondsSinceEpoch.toString();
          Navigator.pop(
            context,
            Activity(
              id: 'quest-$now',
              name: _name.text.trim(),
              category: _category,
              description: _description.text.trim(),
              location: _location.text.trim(),
              price: _price,
              latitude: double.parse(_latitude.text.trim()),
              longitude: double.parse(_longitude.text.trim()),
              budgetAmount: _price == 'Free'
                  ? 0
                  : _price == r'$'
                  ? 12
                  : 25,
              duration: 'Around 1 hour',
              rating: 5.0,
              emoji: '✨',
              colors: const [99, 91, 219, 234, 232, 255],
              isCommunityQuest: true,
            ),
          );
        },
        style: FilledButton.styleFrom(backgroundColor: NeoColors.violet),
        child: const Text('Publish idea'),
      ),
    ],
  );
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.title, required this.subtitle});
  final String title;
  final String subtitle;
  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(45),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: NeoColors.line),
    ),
    child: Column(
      children: [
        const Icon(
          Icons.travel_explore_rounded,
          size: 33,
          color: NeoColors.violet,
        ),
        const SizedBox(height: 12),
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: NeoColors.ink,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          subtitle,
          textAlign: TextAlign.center,
          style: const TextStyle(color: NeoColors.muted),
        ),
      ],
    ),
  );
}
