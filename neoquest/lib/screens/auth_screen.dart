import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../data/activity_api.dart';

import '../theme.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({
    super.key,
    required this.isSignUp,
    this.returnTo = '/profile',
  });
  final bool isSignUp;
  final String returnTo;

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _form = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _name = TextEditingController();
  bool _showPassword = false;
  bool _busy = false;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    _name.dispose();
    super.dispose();
  }

  Future<void> _authenticate() async {
    if (!_form.currentState!.validate()) return;
    setState(() => _busy = true);
    try {
      final auth = FirebaseAuth.instance;
      if (widget.isSignUp) {
        final result = await auth.createUserWithEmailAndPassword(
          email: _email.text.trim(),
          password: _password.text,
        );
        await result.user?.updateDisplayName(_name.text.trim());
      } else {
        await auth.signInWithEmailAndPassword(
          email: _email.text.trim(),
          password: _password.text,
        );
      }
      await FirestoreActivityApi().seedMissingSamples();
      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(
          context,
          widget.returnTo,
          (_) => false,
        );
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message ?? 'Could not complete sign-in.')),
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _googleSignIn() async {
    setState(() => _busy = true);
    try {
      await FirebaseAuth.instance.signInWithPopup(GoogleAuthProvider());
      await FirestoreActivityApi().seedMissingSamples();
      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(
          context,
          widget.returnTo,
          (_) => false,
        );
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message ?? 'Google sign-in failed.')),
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _resetPassword() async {
    final email = _email.text.trim();
    if (!email.contains('@')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter your email above first.')),
      );
      return;
    }
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Password reset link sent to $email.')),
        );
      }
    } on FirebaseAuthException catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error.message ?? 'Could not send a reset link.'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 38),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1060),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(28),
                border: Border.all(color: NeoColors.line),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x08000000),
                    blurRadius: 30,
                    offset: Offset(0, 12),
                  ),
                ],
              ),
              clipBehavior: Clip.antiAlias,
              child: LayoutBuilder(
                builder: (context, box) {
                  final wide = box.maxWidth > 700;
                  final form = Padding(
                    padding: EdgeInsets.all(wide ? 43 : 27),
                    child: Form(
                      key: _form,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.isSignUp ? 'MAKE IT YOURS' : 'WELCOME BACK',
                            style: const TextStyle(
                              fontSize: 10,
                              letterSpacing: 1.4,
                              fontWeight: FontWeight.w800,
                              color: NeoColors.violet,
                            ),
                          ),
                          const SizedBox(height: 13),
                          Text(
                            widget.isSignUp
                                ? 'Start your next story.'
                                : 'Welcome back.',
                            style: const TextStyle(
                              fontSize: 30,
                              letterSpacing: -.8,
                              fontWeight: FontWeight.w800,
                              color: NeoColors.ink,
                            ),
                          ),
                          const SizedBox(height: 9),
                          Text(
                            widget.isSignUp
                                ? 'Save your favorite places and make a little adventure list.'
                                : 'Sign in to pick up where the adventure left off.',
                            style: const TextStyle(
                              fontSize: 13,
                              height: 1.5,
                              color: NeoColors.muted,
                            ),
                          ),
                          const SizedBox(height: 27),
                          if (widget.isSignUp) ...[
                            TextFormField(
                              controller: _name,
                              decoration: const InputDecoration(
                                labelText: 'Your name',
                                prefixIcon: Icon(Icons.person_outline_rounded),
                              ),
                              validator: (v) => v == null || v.trim().isEmpty
                                  ? 'Please enter your name.'
                                  : null,
                            ),
                            const SizedBox(height: 13),
                          ],
                          TextFormField(
                            controller: _email,
                            keyboardType: TextInputType.emailAddress,
                            decoration: const InputDecoration(
                              labelText: 'Email address',
                              prefixIcon: Icon(Icons.mail_outline_rounded),
                            ),
                            validator: (v) => v == null || !v.contains('@')
                                ? 'Enter a valid email address.'
                                : null,
                          ),
                          const SizedBox(height: 13),
                          TextFormField(
                            controller: _password,
                            obscureText: !_showPassword,
                            decoration: InputDecoration(
                              labelText: 'Password',
                              helperText: widget.isSignUp
                                  ? 'At least 8 characters, with a number'
                                  : null,
                              prefixIcon: const Icon(
                                Icons.lock_outline_rounded,
                              ),
                              suffixIcon: IconButton(
                                onPressed: () => setState(
                                  () => _showPassword = !_showPassword,
                                ),
                                icon: Icon(
                                  _showPassword
                                      ? Icons.visibility_off_outlined
                                      : Icons.visibility_outlined,
                                ),
                              ),
                            ),
                            validator: (v) =>
                                v == null ||
                                    (widget.isSignUp
                                        ? v.length < 8 ||
                                              !RegExp(r'\d').hasMatch(v)
                                        : v.length < 6)
                                ? (widget.isSignUp
                                      ? 'Use 8+ characters and include a number.'
                                      : 'Enter your password.')
                                : null,
                          ),
                          if (!widget.isSignUp)
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                onPressed: _busy ? null : _resetPassword,
                                child: const Text('Forgot password?'),
                              ),
                            ),
                          const SizedBox(height: 13),
                          Row(
                            children: const [
                              Expanded(child: Divider(color: NeoColors.line)),
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 11),
                                child: Text(
                                  'OR',
                                  style: TextStyle(
                                    color: NeoColors.muted,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                              Expanded(child: Divider(color: NeoColors.line)),
                            ],
                          ),
                          const SizedBox(height: 13),
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              onPressed: _busy ? null : _googleSignIn,
                              icon: const Icon(
                                Icons.g_mobiledata_rounded,
                                size: 25,
                              ),
                              label: const Text('Continue with Google'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: NeoColors.ink,
                                side: const BorderSide(color: NeoColors.line),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 15,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(13),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 18),
                          SizedBox(
                            width: double.infinity,
                            child: FilledButton(
                              onPressed: _busy ? null : _authenticate,
                              style: FilledButton.styleFrom(
                                backgroundColor: NeoColors.violet,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(13),
                                ),
                              ),
                              child: Text(
                                widget.isSignUp ? 'Create account' : 'Sign in',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          Center(
                            child: Wrap(
                              alignment: WrapAlignment.center,
                              children: [
                                Text(
                                  widget.isSignUp
                                      ? 'Already have an account? '
                                      : 'New around here? ',
                                  style: const TextStyle(
                                    color: NeoColors.muted,
                                    fontSize: 12,
                                  ),
                                ),
                                InkWell(
                                  onTap: () => Navigator.pushReplacementNamed(
                                    context,
                                    Uri(
                                      path: widget.isSignUp
                                          ? '/signin'
                                          : '/signup',
                                      queryParameters: {
                                        'returnTo': widget.returnTo,
                                      },
                                    ).toString(),
                                  ),
                                  child: Text(
                                    widget.isSignUp
                                        ? 'Sign in'
                                        : 'Create an account',
                                    style: const TextStyle(
                                      color: NeoColors.violet,
                                      fontWeight: FontWeight.w800,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                  final art = _AuthArtwork(
                    wide: wide,
                    isSignUp: widget.isSignUp,
                  );
                  return wide
                      ? Row(
                          children: [
                            SizedBox(width: 385, child: art),
                            Expanded(child: form),
                          ],
                        )
                      : Column(children: [art, form]);
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AuthArtwork extends StatelessWidget {
  const _AuthArtwork({required this.wide, required this.isSignUp});
  final bool wide;
  final bool isSignUp;

  @override
  Widget build(BuildContext context) => SizedBox(
    height: wide ? 630 : 184,
    width: double.infinity,
    child: Stack(
      fit: StackFit.expand,
      children: [
        Image.network(
          'https://images.unsplash.com/photo-1500375592092-40eb2168fd21?auto=format&fit=crop&w=1200&q=88',
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF17221B), Color(0xFF365C43)],
              ),
            ),
          ),
        ),
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0x22101A13), Color(0xDD101A13)],
            ),
          ),
        ),
        Positioned(
          left: wide ? 28 : 19,
          top: wide ? 28 : 16,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: .28),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: Colors.white.withValues(alpha: .28)),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.explore_outlined, color: NeoColors.lime, size: 15),
                SizedBox(width: 7),
                Text(
                  'NEOQUEST  ·  BERKELEY',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 9,
                    letterSpacing: 1,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ),
        Positioned(
          left: wide ? 32 : 20,
          right: wide ? 32 : 20,
          bottom: wide ? 37 : 17,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isSignUp
                    ? Icons.auto_awesome_rounded
                    : Icons.wb_twilight_rounded,
                color: NeoColors.lime,
                size: wide ? 27 : 20,
              ),
              SizedBox(height: wide ? 18 : 7),
              Text(
                isSignUp
                    ? 'Make room for\na little wonder.'
                    : 'Your city is full\nof small wonders.',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: wide ? 39 : 24,
                  height: 1.03,
                  letterSpacing: wide ? -1.3 : -.5,
                  fontWeight: FontWeight.w800,
                ),
              ),
              if (wide) ...[
                const SizedBox(height: 14),
                const Text(
                  'Small plans. Good stories. Right around the corner.',
                  style: TextStyle(
                    color: Color(0xFFE0E8DF),
                    fontSize: 13,
                    height: 1.5,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    ),
  );
}
