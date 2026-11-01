import 'package:flutter/material.dart';

import '../models/quest_filters.dart';
import '../theme.dart';

class FiltersScreen extends StatefulWidget {
  const FiltersScreen({super.key, required this.filters});
  final QuestFilters filters;

  @override
  State<FiltersScreen> createState() => _FiltersScreenState();
}

class _FiltersScreenState extends State<FiltersScreen> {
  late QuestFilters _filters = widget.filters;

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

  void _toggle(
    List<String> selected,
    String value,
    void Function(List<String>) update,
  ) {
    final next = [...selected];
    if (!next.remove(value)) next.add(value);
    update(next);
  }

  void _showResults() => Navigator.pushNamed(
    context,
    Uri(path: '/list', queryParameters: _filters.toQuery()).toString(),
  );

  @override
  Widget build(BuildContext context) => Center(
    child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 1100),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(26, 32, 26, 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextButton.icon(
              onPressed: () => Navigator.pushNamed(context, '/home'),
              icon: const Icon(Icons.arrow_back_rounded, size: 17),
              label: const Text('Back to home'),
              style: TextButton.styleFrom(foregroundColor: NeoColors.muted),
            ),
            const SizedBox(height: 5),
            const Text(
              'Set the scene.',
              style: TextStyle(
                color: NeoColors.ink,
                fontWeight: FontWeight.w800,
                fontSize: 35,
                letterSpacing: -1.1,
              ),
            ),
            const SizedBox(height: 7),
            const Text(
              'A few details help us find the right kind of day for you.',
              style: TextStyle(color: NeoColors.muted, fontSize: 14),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: SingleChildScrollView(
                child: LayoutBuilder(
                  builder: (context, box) {
                    final left = Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _FilterCard(
                          title: 'What sounds fun?',
                          icon: Icons.auto_awesome_outlined,
                          child: Wrap(
                            spacing: 8,
                            runSpacing: 7,
                            children: _categories
                                .map(
                                  (value) => ChoiceChip(
                                    label: Text(value),
                                    selected: _filters.category == value,
                                    onSelected: (_) => setState(
                                      () => _filters = _filters.copyWith(
                                        category: value,
                                      ),
                                    ),
                                  ),
                                )
                                .toList(),
                          ),
                        ),
                        const SizedBox(height: 16),
                        _FilterCard(
                          title: 'How far?',
                          icon: Icons.near_me_outlined,
                          child: Column(
                            children: [
                              Slider(
                                value: _filters.maxDistance.clamp(0.5, 10),
                                min: .5,
                                max: 10,
                                divisions: 19,
                                label:
                                    '${_filters.maxDistance.toStringAsFixed(1)} mi',
                                onChanged: (value) => setState(
                                  () => _filters = _filters.copyWith(
                                    maxDistance: value,
                                  ),
                                ),
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'Nearby',
                                    style: TextStyle(color: NeoColors.muted),
                                  ),
                                  Text(
                                    'Up to ${_filters.maxDistance.toStringAsFixed(1)} miles',
                                    style: const TextStyle(
                                      color: NeoColors.ink,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        _FilterCard(
                          title: 'What are you spending?',
                          icon: Icons.payments_outlined,
                          child: Column(
                            children: [
                              Slider(
                                value: _filters.maxBudget.toDouble().clamp(
                                  0,
                                  100,
                                ),
                                min: 0,
                                max: 100,
                                divisions: 20,
                                label: _filters.maxBudget == 0
                                    ? 'Free'
                                    : 'Up to \$${_filters.maxBudget}',
                                onChanged: (value) => setState(
                                  () => _filters = _filters.copyWith(
                                    maxBudget: value.round(),
                                  ),
                                ),
                              ),
                              Align(
                                alignment: Alignment.centerRight,
                                child: Text(
                                  _filters.maxBudget == 0
                                      ? 'Free only'
                                      : 'Up to \$${_filters.maxBudget} per person',
                                  style: const TextStyle(
                                    color: NeoColors.ink,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );

                    final right = Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _FilterCard(
                          title: 'Who’s coming?',
                          icon: Icons.group_outlined,
                          child: Wrap(
                            spacing: 8,
                            children: [1, 2, 4, 8]
                                .map(
                                  (size) => ChoiceChip(
                                    label: Text(size == 8 ? '8+' : '$size'),
                                    selected: _filters.groupSize == size,
                                    onSelected: (_) => setState(
                                      () => _filters = _filters.copyWith(
                                        groupSize: size,
                                      ),
                                    ),
                                  ),
                                )
                                .toList(),
                          ),
                        ),
                        const SizedBox(height: 16),
                        _FilterCard(
                          title: 'How much time?',
                          icon: Icons.schedule_rounded,
                          child: Wrap(
                            spacing: 8,
                            runSpacing: 7,
                            children:
                                [
                                      (60, 'Under an hour'),
                                      (120, 'A couple hours'),
                                      (240, 'Half a day'),
                                      (600, 'No rush'),
                                    ]
                                    .map(
                                      (item) => ChoiceChip(
                                        label: Text(item.$2),
                                        selected:
                                            _filters.maxDurationMinutes ==
                                            item.$1,
                                        onSelected: (_) => setState(
                                          () => _filters = _filters.copyWith(
                                            maxDurationMinutes: item.$1,
                                          ),
                                        ),
                                      ),
                                    )
                                    .toList(),
                          ),
                        ),
                        const SizedBox(height: 16),
                        _FilterCard(
                          title: 'Minimum rating',
                          icon: Icons.star_outline_rounded,
                          child: Column(
                            children: [
                              Slider(
                                value: _filters.minRating.clamp(0, 5),
                                min: 0,
                                max: 5,
                                divisions: 5,
                                label: _filters.minRating == 0
                                    ? 'Any'
                                    : '${_filters.minRating.toStringAsFixed(1)}+',
                                onChanged: (value) => setState(
                                  () => _filters = _filters.copyWith(
                                    minRating: value,
                                  ),
                                ),
                              ),
                              Align(
                                alignment: Alignment.centerRight,
                                child: Text(
                                  _filters.minRating == 0
                                      ? 'Any rating'
                                      : '${_filters.minRating.toStringAsFixed(1)} stars and up',
                                  style: const TextStyle(
                                    color: NeoColors.ink,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        _FilterCard(
                          title: 'Getting there',
                          icon: Icons.directions_walk_outlined,
                          child: Wrap(
                            spacing: 7,
                            runSpacing: 6,
                            children: _transport
                                .map(
                                  (value) => FilterChip(
                                    label: Text(value),
                                    selected: _filters.transportation.contains(
                                      value,
                                    ),
                                    onSelected: (_) => setState(
                                      () => _toggle(
                                        _filters.transportation,
                                        value,
                                        (items) => _filters = _filters.copyWith(
                                          transportation: items,
                                        ),
                                      ),
                                    ),
                                  ),
                                )
                                .toList(),
                          ),
                        ),
                        const SizedBox(height: 16),
                        _FilterCard(
                          title: 'When works for you?',
                          icon: Icons.wb_twilight_outlined,
                          child: Wrap(
                            spacing: 7,
                            runSpacing: 6,
                            children: _availability
                                .map(
                                  (value) => FilterChip(
                                    label: Text(value),
                                    selected: _filters.availability.contains(
                                      value,
                                    ),
                                    onSelected: (_) => setState(
                                      () => _toggle(
                                        _filters.availability,
                                        value,
                                        (items) => _filters = _filters.copyWith(
                                          availability: items,
                                        ),
                                      ),
                                    ),
                                  ),
                                )
                                .toList(),
                          ),
                        ),
                      ],
                    );

                    if (box.maxWidth > 740) {
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(child: left),
                          const SizedBox(width: 17),
                          Expanded(child: right),
                        ],
                      );
                    }
                    return Column(children: [left, right]);
                  },
                ),
              ),
            ),
            const SizedBox(height: 13),
            Row(
              children: [
                TextButton(
                  onPressed: () =>
                      setState(() => _filters = const QuestFilters()),
                  child: const Text('Clear all'),
                ),
                const Spacer(),
                FilledButton.icon(
                  onPressed: _showResults,
                  icon: const Icon(Icons.arrow_forward_rounded, size: 17),
                  label: const Text('Show matching options'),
                  style: FilledButton.styleFrom(
                    backgroundColor: NeoColors.ink,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 16,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}

class _FilterCard extends StatelessWidget {
  const _FilterCard({
    required this.title,
    required this.icon,
    required this.child,
  });
  final String title;
  final IconData icon;
  final Widget child;

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(19),
    decoration: BoxDecoration(
      color: Colors.white,
      border: Border.all(color: NeoColors.line),
      borderRadius: BorderRadius.circular(20),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: NeoColors.violet, size: 18),
            const SizedBox(width: 9),
            Text(
              title,
              style: const TextStyle(
                color: NeoColors.ink,
                fontWeight: FontWeight.w800,
                fontSize: 15,
              ),
            ),
          ],
        ),
        const SizedBox(height: 13),
        child,
      ],
    ),
  );
}
