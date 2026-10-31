// NeoQuest – Flutter Web
// Routes: /  /signin  /signup  /map  /list  /filters
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';

// ───────────────────────── Theme tokens ─────────────────────────
class C {
  static const navy = Color(0xFF070B16);
  static const navy2 = Color(0xFF0F1526);
  static const teal = Color(0xFF7FE3D0);
  static const purple = Color(0xFF8B7CF6);
  static const lime = Color(0xFFC8F560);
  static const cream = Color(0xFFF6F5EE);
  static const ink = Color(0xFF111111);
  static const line = Color(0xFFE2E0D6);
  static const link = Color(0xFF2563EB);
}

// ───────────────────────── Data + state ─────────────────────────
class Activity {
  final String id, name, category, blurb;
  final double miles, rating;
  final int price; // 0 = free
  final LatLng pos;
  const Activity(this.id, this.name, this.category, this.blurb, this.miles,
      this.rating, this.price, this.pos);
}

const activities = <Activity>[
  Activity('marina', 'Berkeley Marina', 'Outdoors',
      'Waterfront paths, kite flying and sunset views over the bay.', 2.1, 4.7, 0,
      LatLng(37.8697, -122.3151)),
  Activity('anza', 'Lake Anza', 'Water',
      'Swimming beach and picnic lawns tucked into Tilden.', 3.4, 4.6, 6,
      LatLng(37.8892, -122.2425)),
  Activity('playground', 'Adventure Playground', 'Family',
      'Build-it-yourself playground on the shoreline.', 2.3, 4.5, 0,
      LatLng(37.8725, -122.3165)),
  Activity('tilden', 'Tilden Regional Park', 'Hiking',
      'Ridge trails, a botanic garden and a carousel.', 4.8, 4.9, 0,
      LatLng(37.8970, -122.2440)),
  Activity('sather', 'Sather Tower', 'Culture',
      'Ride the campanile to the top for a 360° view of campus.', 0.4, 4.8, 4,
      LatLng(37.8721, -122.2578)),
  Activity('rose', 'Berkeley Rose Garden', 'Garden',
      'Terraced garden with 3,000 rose bushes and bay views.', 1.7, 4.7, 0,
      LatLng(37.8806, -122.2689)),
];

const categories = ['Outdoors', 'Water', 'Family', 'Hiking', 'Culture', 'Garden'];

class AppState extends ChangeNotifier {
  String? userName;
  final Set<String> selected = {};
  double maxMiles = 10;
  bool freeOnly = false;
  String query = '';
  String? selectedId;

  bool get signedIn => userName != null;

  List<Activity> get results => activities.where((a) {
        if (selected.isNotEmpty && !selected.contains(a.category)) return false;
        if (a.miles > maxMiles) return false;
        if (freeOnly && a.price > 0) return false;
        if (query.isNotEmpty &&
            !('${a.name} ${a.category}'.toLowerCase())
                .contains(query.toLowerCase())) return false;
        return true;
      }).toList();

  void toggleCategory(String c) {
    selected.contains(c) ? selected.remove(c) : selected.add(c);
    notifyListeners();
  }

  void update({double? miles, bool? free, String? q, String? sel, bool clearSel = false}) {
    if (miles != null) maxMiles = miles;
    if (free != null) freeOnly = free;
    if (q != null) query = q;
    if (sel != null) selectedId = sel;
    if (clearSel) selectedId = null;
    notifyListeners();
  }

  void reset() {
    selected.clear();
    maxMiles = 10;
    freeOnly = false;
    query = '';
    selectedId = null;
    notifyListeners();
  }

  void signIn(String name) {
    userName = name;
    notifyListeners();
  }

  void signOut() {
    userName = null;
    notifyListeners();
  }
}

final app = AppState();

// ───────────────────────── Router ─────────────────────────
final router = GoRouter(
  routes: [
    GoRoute(path: '/', builder: (_, __) => const HomePage()),
    GoRoute(path: '/signin', builder: (_, __) => const AuthPage(signUp: false)),
    GoRoute(path: '/signup', builder: (_, __) => const AuthPage(signUp: true)),
    GoRoute(path: '/map', builder: (_, __) => const MapPage()),
    GoRoute(path: '/list', builder: (_, __) => const ListPage()),
    GoRoute(path: '/filters', builder: (_, __) => const FiltersPage()),
  ],
);

void main() => runApp(const NeoQuestApp());

class NeoQuestApp extends StatelessWidget {
  const NeoQuestApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp.router(
        title: 'NeoQuest',
        debugShowCheckedModeBanner: false,
        routerConfig: router,
        theme: ThemeData(
          useMaterial3: true,
          fontFamily: 'Inter',
          colorScheme: ColorScheme.fromSeed(seedColor: C.purple),
          scaffoldBackgroundColor: C.cream,
        ),
      );
}

// ───────────────────────── Shared widgets ─────────────────────────
bool isNarrow(BuildContext c) => MediaQuery.sizeOf(c).width < 800;

class NeoHeader extends StatelessWidget implements PreferredSizeWidget {
  final bool dark;
  final List<Widget> extraLinks;
  const NeoHeader({super.key, this.dark = false, this.extraLinks = const []});
  @override
  Size get preferredSize => const Size.fromHeight(64);

  @override
  Widget build(BuildContext context) {
    final fg = dark ? Colors.white : C.ink;
    final narrow = isNarrow(context);
    return ListenableBuilder(
      listenable: app,
      builder: (_, __) => Container(
        height: 64,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        decoration: BoxDecoration(
          color: dark ? C.navy : C.cream,
          border: Border(bottom: BorderSide(color: dark ? Colors.white12 : C.line)),
        ),
        child: Row(children: [
          InkWell(
            onTap: () => context.go('/'),
            child: Row(children: [
              Container(
                  width: 10,
                  height: 10,
                  decoration: const BoxDecoration(color: C.lime, shape: BoxShape.circle)),
              const SizedBox(width: 8),
              Text('neoquest',
                  style: TextStyle(color: fg, fontWeight: FontWeight.w800, fontSize: 16)),
            ]),
          ),
          const Spacer(),
          if (!narrow) ...[
            ...extraLinks,
            for (final l in const [['Map', '/map'], ['List', '/list'], ['Filters', '/filters']])
              TextButton(
                  onPressed: () => context.go(l[1]),
                  child: Text(l[0], style: TextStyle(color: fg.withOpacity(.8)))),
            const SizedBox(width: 12),
          ] else
            PopupMenuButton<String>(
              icon: Icon(Icons.menu, color: fg),
              onSelected: context.go,
              itemBuilder: (_) => const [
                PopupMenuItem(value: '/map', child: Text('Map')),
                PopupMenuItem(value: '/list', child: Text('List')),
                PopupMenuItem(value: '/filters', child: Text('Filters')),
              ],
            ),
          if (app.signedIn)
            PopupMenuButton<String>(
              onSelected: (_) {
                app.signOut();
                context.go('/');
              },
              itemBuilder: (_) => const [PopupMenuItem(value: 'out', child: Text('Sign out'))],
              child: Chip(
                avatar: const CircleAvatar(
                    backgroundColor: C.lime,
                    child: Icon(Icons.person, size: 14, color: C.ink)),
                label: Text(app.userName!),
              ),
            )
          else
            FilledButton(
              onPressed: () => context.go('/signin'),
              style: FilledButton.styleFrom(
                  backgroundColor: dark ? C.teal : C.ink,
                  foregroundColor: dark ? C.navy : Colors.white),
              child: const Text('Sign in'),
            ),
        ]),
      ),
    );
  }
}

/// The "Search Input" component from the canvas.
class SearchInput extends StatefulWidget {
  const SearchInput({super.key});
  @override
  State<SearchInput> createState() => _SearchInputState();
}

class _SearchInputState extends State<SearchInput> {
  final _c = TextEditingController(text: app.query);
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => TextField(
        controller: _c,
        onChanged: (v) {
          _debounce?.cancel();
          _debounce = Timer(const Duration(milliseconds: 200), () => app.update(q: v));
        },
        decoration: InputDecoration(
          hintText: 'Search quests…',
          prefixIcon: const Icon(Icons.search, size: 20),
          suffixIcon: _c.text.isEmpty
              ? null
              : IconButton(
                  icon: const Icon(Icons.close, size: 18),
                  onPressed: () {
                    _c.clear();
                    app.update(q: '');
                    setState(() {});
                  }),
          filled: true,
          fillColor: Colors.white,
          isDense: true,
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: C.line)),
        ),
      );
}

class CategoryChips extends StatelessWidget {
  const CategoryChips({super.key});
  @override
  Widget build(BuildContext context) => ListenableBuilder(
        listenable: app,
        builder: (_, __) => Wrap(spacing: 8, runSpacing: 8, children: [
          for (final c in categories)
            FilterChip(
              label: Text(c),
              selected: app.selected.contains(c),
              selectedColor: C.lime,
              checkmarkColor: C.ink,
              onSelected: (_) => app.toggleCategory(c),
            ),
        ]),
      );
}

class DistanceSlider extends StatelessWidget {
  const DistanceSlider({super.key});
  @override
  Widget build(BuildContext context) => ListenableBuilder(
        listenable: app,
        builder: (_, __) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Within ${app.maxMiles.round()} mi',
              style: const TextStyle(fontWeight: FontWeight.w600)),
          Slider(
            value: app.maxMiles,
            min: 1,
            max: 15,
            divisions: 14,
            activeColor: C.ink,
            onChanged: (v) => app.update(miles: v),
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Free only'),
            value: app.freeOnly,
            activeColor: C.ink,
            onChanged: (v) => app.update(free: v),
          ),
        ]),
      );
}

class ActivityMap extends StatelessWidget {
  const ActivityMap({super.key});
  @override
  Widget build(BuildContext context) => ListenableBuilder(
        listenable: app,
        builder: (_, __) => ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: FlutterMap(
            options: const MapOptions(
                initialCenter: LatLng(37.8800, -122.2700), initialZoom: 12),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.neoquest',
              ),
              MarkerLayer(markers: [
                for (final a in app.results)
                  Marker(
                    point: a.pos,
                    width: 40,
                    height: 40,
                    child: GestureDetector(
                      onTap: () => app.update(sel: a.id),
                      child: Icon(Icons.location_on,
                          size: app.selectedId == a.id ? 40 : 30,
                          color: app.selectedId == a.id ? C.purple : C.ink),
                    ),
                  ),
              ]),
            ],
          ),
        ),
      );
}

class ActivityCard extends StatelessWidget {
  final Activity a;
  const ActivityCard(this.a, {super.key});

  @override
  Widget build(BuildContext context) {
    final sel = app.selectedId == a.id;
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () => app.update(sel: a.id),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: sel ? C.ink : C.line, width: sel ? 2 : 1),
        ),
        child: Row(children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
                color: C.line, borderRadius: BorderRadius.circular(8)),
            child: const Icon(Icons.image_outlined, color: Colors.black38),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(a.category.toUpperCase(),
                  style: const TextStyle(fontSize: 10, letterSpacing: 1, color: Colors.black54)),
              Text(a.name, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
              const SizedBox(height: 4),
              Text('${a.miles} mi · ★ ${a.rating} · ${a.price == 0 ? 'Free' : '\$${a.price}'}',
                  style: const TextStyle(fontSize: 12, color: Colors.black54)),
            ]),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: C.ink),
            onPressed: () => showActivityDialog(context, a),
            child: const Text('View options'),
          ),
        ]),
      ),
    );
  }
}

void showActivityDialog(BuildContext context, Activity a) {
  showDialog(
    context: context,
    builder: (_) => AlertDialog(
      title: Text(a.name),
      content: Text('${a.blurb}\n\n${a.miles} mi away · ★ ${a.rating} · '
          '${a.price == 0 ? 'Free' : '\$${a.price}'}'),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
        FilledButton(
          style: FilledButton.styleFrom(backgroundColor: C.ink),
          onPressed: () {
            Navigator.pop(context);
            if (!app.signedIn) {
              context.go('/signin');
              return;
            }
            ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Quest started: ${a.name}')));
          },
          child: const Text('Start quest'),
        ),
      ],
    ),
  );
}

class ResultsList extends StatelessWidget {
  const ResultsList({super.key});
  @override
  Widget build(BuildContext context) => ListenableBuilder(
        listenable: app,
        builder: (_, __) {
          final r = app.results;
          if (r.isEmpty) {
            return Center(
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                const Text('No quests match these filters.'),
                TextButton(onPressed: app.reset, child: const Text('Clear filters')),
              ]),
            );
          }
          return ListView(children: [for (final a in r) ActivityCard(a)]);
        },
      );
}

// ───────────────────────── Home ─────────────────────────
class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _how = GlobalKey(), _contact = GlobalKey();

  void _scrollTo(GlobalKey k) => Scrollable.ensureVisible(k.currentContext!,
      duration: const Duration(milliseconds: 500), curve: Curves.easeInOut);

  @override
  Widget build(BuildContext context) {
    final narrow = isNarrow(context);
    return Scaffold(
      backgroundColor: C.navy,
      appBar: NeoHeader(dark: true, extraLinks: [
        TextButton(
            onPressed: () => _scrollTo(_how),
            child: const Text('How it works', style: TextStyle(color: Colors.white70))),
        TextButton(
            onPressed: () => _scrollTo(_contact),
            child: const Text('Contact', style: TextStyle(color: Colors.white70))),
      ]),
      body: SingleChildScrollView(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1100),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(children: [
                const SizedBox(height: 40),
                const Text('NeoQuest',
                    style: TextStyle(color: Colors.white, fontSize: 56, fontWeight: FontWeight.w600)),
                Container(height: 2, width: 220, color: C.teal),
                const SizedBox(height: 48),
                _hero(narrow),
                const SizedBox(height: 80),
                _cta(),
                const SizedBox(height: 80),
                _steps(narrow),
                const SizedBox(height: 80),
                _contactSection(),
                const SizedBox(height: 60),
              ]),
            ),
          ),
        ),
      ),
    );
  }

  Widget _hero(bool narrow) {
    final text = Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      RichText(
        text: const TextSpan(
          style: TextStyle(fontSize: 40, fontWeight: FontWeight.w700, color: Colors.white, height: 1.15),
          children: [
            TextSpan(text: 'Discover the '),
            TextSpan(text: 'story\n', style: TextStyle(color: C.purple)),
            TextSpan(text: 'around '),
            TextSpan(text: 'every corner.'),
          ],
        ),
      ),
      const SizedBox(height: 16),
      const Text(
          'Your next great adventure is just seconds away. Connect with friends, '
          'explore exciting new activities, and fill your days with endless possibilities.',
          style: TextStyle(color: Colors.white60, height: 1.5)),
      const SizedBox(height: 28),
      Wrap(spacing: 32, runSpacing: 12, children: const [
        _Stat('11,513', 'campus quests'),
        _Stat('5,512', 'active explorers'),
        _Stat('4.9★', 'average rating'),
      ]),
    ]);
    final visual = Container(
      height: 280,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(colors: [C.purple, C.teal]),
      ),
      // Swap for Image.asset('assets/hero.jpg', fit: BoxFit.cover)
      child: const Center(child: Icon(Icons.explore, size: 72, color: Colors.white)),
    );
    return narrow
        ? Column(children: [text, const SizedBox(height: 24), visual])
        : Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
            Expanded(child: text),
            const SizedBox(width: 40),
            Expanded(child: visual),
          ]);
  }

  Widget _cta() => Column(children: [
        RichText(
          textAlign: TextAlign.center,
          text: const TextSpan(
            style: TextStyle(fontSize: 32, fontWeight: FontWeight.w700, color: Colors.white),
            children: [
              TextSpan(text: 'your next '),
              TextSpan(text: 'adventure\n', style: TextStyle(color: C.teal)),
              TextSpan(text: 'is closer '),
              TextSpan(text: 'than you think.'),
            ],
          ),
        ),
        const SizedBox(height: 20),
        FilledButton(
          style: FilledButton.styleFrom(backgroundColor: C.lime, foregroundColor: C.ink),
          onPressed: () => context.go('/map'),
          child: const Text('Explore the Map'),
        ),
      ]);

  Widget _steps(bool narrow) {
    const items = [
      ['01', 'Get Started', 'Browse nearby activities and hidden gems curated by students.'],
      ['02', 'Choose & Configure', 'Set your filters, group size, budget and distance.'],
      ['03', 'Enter Your Quest', 'Show up, check in and make the memory.'],
    ];
    return Column(key: _how, crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        RichText(
          text: const TextSpan(
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: Colors.white),
            children: [
              TextSpan(text: 'Find ', style: TextStyle(color: C.teal)),
              TextSpan(text: 'your next '),
              TextSpan(text: 'quest', style: TextStyle(color: C.purple)),
            ],
          ),
        ),
        const Spacer(),
        FilledButton(
          style: FilledButton.styleFrom(backgroundColor: C.lime, foregroundColor: C.ink),
          onPressed: () => context.go('/filters'),
          child: const Text('Explore activities'),
        ),
      ]),
      const Divider(color: Colors.white24, height: 32),
      Flex(
        direction: narrow ? Axis.vertical : Axis.horizontal,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final i in items)
            Flexible(
              child: Padding(
                padding: const EdgeInsets.only(right: 24, bottom: 20),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(i[0], style: const TextStyle(color: Colors.white, fontSize: 24)),
                  const SizedBox(height: 8),
                  Text(i[1], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  Text(i[2], style: const TextStyle(color: Colors.white54, fontSize: 13)),
                ]),
              ),
            ),
        ],
      ),
    ]);
  }

  Widget _contactSection() => Column(key: _contact, children: [
        const Divider(color: Colors.white24),
        const SizedBox(height: 24),
        const Text('Contact Us',
            style: TextStyle(color: C.teal, fontSize: 22, fontWeight: FontWeight.w700)),
        const SizedBox(height: 8),
        const Text('Have a question or idea for a new quest? We’d love to hear from you.',
            style: TextStyle(color: Colors.white54)),
        const SizedBox(height: 20),
        FilledButton(
          style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFB9C4F5),
              foregroundColor: C.navy,
              minimumSize: const Size(260, 44)),
          onPressed: _contactDialog,
          child: const Text('Get in Touch'),
        ),
      ]);

  void _contactDialog() {
    final email = TextEditingController(), msg = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Get in touch'),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          TextField(controller: email, decoration: const InputDecoration(labelText: 'Email')),
          TextField(
              controller: msg,
              maxLines: 3,
              decoration: const InputDecoration(labelText: 'Message')),
        ]),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context)
                  .showSnackBar(const SnackBar(content: Text('Thanks! We’ll be in touch.')));
            },
            child: const Text('Send'),
          ),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final String n, label;
  const _Stat(this.n, this.label);
  @override
  Widget build(BuildContext context) => RichText(
        text: TextSpan(children: [
          TextSpan(text: '$n ', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
          TextSpan(text: label, style: const TextStyle(color: C.teal)),
        ]),
      );
}

// ───────────────────────── Sign in / Sign up ─────────────────────────
class AuthPage extends StatefulWidget {
  final bool signUp;
  const AuthPage({super.key, required this.signUp});
  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  final _form = GlobalKey<FormState>();
  final _name = TextEditingController(),
      _email = TextEditingController(),
      _pass = TextEditingController();
  bool _hide = true, _busy = false;

  String? _emailV(String? v) =>
      (v == null || !RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(v.trim()))
          ? 'Enter a valid email'
          : null;

  String? _passV(String? v) {
    if (v == null || v.isEmpty) return 'Enter a password';
    if (widget.signUp && (v.length < 8 || !RegExp(r'\d').hasMatch(v))) {
      return 'At least 8 characters, with a number';
    }
    return null;
  }

  Future<void> _submit() async {
    if (!_form.currentState!.validate()) return;
    setState(() => _busy = true);
    await Future.delayed(const Duration(milliseconds: 600)); // TODO: call your backend
    app.signIn(widget.signUp ? _name.text.trim() : _email.text.split('@').first);
    if (mounted) context.go('/filters');
  }

  @override
  Widget build(BuildContext context) {
    final su = widget.signUp;
    return Scaffold(
      appBar: const NeoHeader(),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Container(
            width: 380,
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: C.line)),
            child: Form(
              key: _form,
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(su ? 'Create your account!' : 'Welcome Back!',
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
                const SizedBox(height: 4),
                Text(su ? 'Start in less than a minute' : 'Sign in to continue to your account',
                    style: const TextStyle(color: Colors.black54)),
                const SizedBox(height: 20),
                if (su) ...[
                  TextFormField(
                      controller: _name,
                      decoration: const InputDecoration(labelText: 'Full name'),
                      validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter your name' : null),
                  const SizedBox(height: 12),
                ],
                TextFormField(
                    controller: _email,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(labelText: 'Email'),
                    validator: _emailV),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _pass,
                  obscureText: _hide,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    helperText: su ? 'At least 8 characters, with a number' : null,
                    suffixIcon: IconButton(
                      icon: Icon(_hide ? Icons.visibility_off : Icons.visibility, size: 18),
                      onPressed: () => setState(() => _hide = !_hide),
                    ),
                  ),
                  validator: _passV,
                  onFieldSubmitted: (_) => _submit(),
                ),
                if (!su)
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Password reset link sent (demo).'))),
                      child: const Text('Forgot password?'),
                    ),
                  ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    style: FilledButton.styleFrom(
                        backgroundColor: C.ink, padding: const EdgeInsets.symmetric(vertical: 16)),
                    onPressed: _busy ? null : _submit,
                    child: _busy
                        ? const SizedBox(
                            width: 18, height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : Text(su ? 'Create Account' : 'Sign In'),
                  ),
                ),
                const SizedBox(height: 16),
                Center(
                  child: Wrap(crossAxisAlignment: WrapCrossAlignment.center, children: [
                    Text(su ? 'Already have an account? ' : 'Don’t have an account? ',
                        style: const TextStyle(fontSize: 12)),
                    InkWell(
                      onTap: () => context.go(su ? '/signin' : '/signup'),
                      child: Text(su ? 'Sign in' : 'Sign up',
                          style: const TextStyle(
                              fontSize: 12, color: C.link, decoration: TextDecoration.underline)),
                    ),
                  ]),
                ),
              ]),
            ),
          ),
        ),
      ),
    );
  }
}

// ───────────────────────── /map ─────────────────────────
class MapPage extends StatelessWidget {
  const MapPage({super.key});
  @override
  Widget build(BuildContext context) {
    final side = Container(
      width: isNarrow(context) ? double.infinity : 340,
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Your kind of nearby',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
        const SizedBox(height: 4),
        const Text('Pins update as you change filters.', style: TextStyle(color: Colors.black54)),
        const SizedBox(height: 16),
        const SearchInput(),
        const SizedBox(height: 12),
        const CategoryChips(),
        const SizedBox(height: 8),
        const DistanceSlider(),
        if (!isNarrow(context)) const Expanded(child: ResultsList()),
      ]),
    );
    return Scaffold(
      appBar: const NeoHeader(),
      body: isNarrow(context)
          ? Column(children: [
              SizedBox(height: 300, child: SingleChildScrollView(child: side)),
              const Expanded(child: Padding(padding: EdgeInsets.all(12), child: ActivityMap())),
            ])
          : Row(children: [
              side,
              const Expanded(child: Padding(padding: EdgeInsets.all(12), child: ActivityMap())),
            ]),
    );
  }
}

// ───────────────────────── /list ─────────────────────────
class ListPage extends StatelessWidget {
  const ListPage({super.key});
  @override
  Widget build(BuildContext context) {
    final list = Padding(
      padding: const EdgeInsets.all(24),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          IconButton(onPressed: () => context.go('/filters'), icon: const Icon(Icons.arrow_back)),
          const Text('Activity Options',
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800)),
        ]),
        const Padding(
          padding: EdgeInsets.only(left: 48, bottom: 16),
          child: Text('Matches based on your filters.', style: TextStyle(color: Colors.black54)),
        ),
        const SearchInput(),
        const SizedBox(height: 12),
        ListenableBuilder(
            listenable: app,
            builder: (_, __) => Text('${app.results.length} results',
                style: const TextStyle(fontSize: 12, color: Colors.black54))),
        const SizedBox(height: 8),
        const Expanded(child: ResultsList()),
      ]),
    );
    return Scaffold(
      appBar: const NeoHeader(),
      body: isNarrow(context)
          ? list
          : Row(children: [
              Expanded(flex: 3, child: list),
              const Expanded(
                  flex: 2,
                  child: Padding(padding: EdgeInsets.fromLTRB(0, 24, 24, 24), child: ActivityMap())),
            ]),
    );
  }
}

// ───────────────────────── /filters ─────────────────────────
class FiltersPage extends StatefulWidget {
  const FiltersPage({super.key});
  @override
  State<FiltersPage> createState() => _FiltersPageState();
}

class _FiltersPageState extends State<FiltersPage> {
  int step = 0;
  static const steps = [
    ['Activity', 'What kind of quest are you after?'],
    ['Distance', 'How far are you willing to go?'],
    ['Budget', 'Pick your price range.'],
  ];

  @override
  Widget build(BuildContext context) {
    final body = Padding(
      padding: const EdgeInsets.all(24),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(steps[step][0], style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
        const SizedBox(height: 4),
        Text(steps[step][1], style: const TextStyle(color: Colors.black54)),
        const SizedBox(height: 20),
        if (step == 0) const CategoryChips(),
        if (step == 1) const DistanceSlider(),
        if (step == 2)
          ListenableBuilder(
            listenable: app,
            builder: (_, __) => SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Free activities only'),
              value: app.freeOnly,
              activeColor: C.ink,
              onChanged: (v) => app.update(free: v),
            ),
          ),
        const Spacer(),
        Row(children: [
          TextButton(onPressed: app.reset, child: const Text('Reset')),
          const Spacer(),
          if (step > 0)
            TextButton(onPressed: () => setState(() => step--), child: const Text('Back')),
          const SizedBox(width: 8),
          if (step < steps.length - 1)
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: C.ink),
              onPressed: () => setState(() => step++),
              child: const Text('Next'),
            )
          else
            ListenableBuilder(
              listenable: app,
              builder: (_, __) => FilledButton(
                style: FilledButton.styleFrom(backgroundColor: C.ink),
                onPressed: () => context.go('/list'),
                child: Text('Show matching options (${app.results.length})'),
              ),
            ),
        ]),
      ]),
    );

    final rail = Container(
      width: isNarrow(context) ? double.infinity : 240,
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Build Your nEoQuest',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
        const SizedBox(height: 16),
        for (var i = 0; i < steps.length; i++)
          ListTile(
            dense: true,
            selected: i == step,
            selectedTileColor: C.lime.withOpacity(.4),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            leading: CircleAvatar(
              radius: 12,
              backgroundColor: i <= step ? C.lime : C.line,
              child: Text('${i + 1}', style: const TextStyle(fontSize: 11, color: C.ink)),
            ),
            title: Text(steps[i][0]),
            onTap: () => setState(() => step = i),
          ),
      ]),
    );

    return Scaffold(
      appBar: const NeoHeader(),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 960),
          child: Container(
            margin: const EdgeInsets.all(24),
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: C.line)),
            child: isNarrow(context)
                ? Column(children: [rail, Expanded(child: body)])
                : Row(children: [rail, const VerticalDivider(width: 1), Expanded(child: body)]),
          ),
        ),
      ),
    );
  }
}