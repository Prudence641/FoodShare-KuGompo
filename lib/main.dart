// FoodShare KuGompo - main application screens.
// Required image assets (registered in pubspec.yaml):
// assets/images/welcome_bg.jpeg
// assets/images/donor_bg.jpeg
// assets/images/recipient_bg.jpeg
// assets/images/admin_bg.jpeg (used by lib/admin/admin_dashboard.dart)
// AdminDashboard is maintained in lib/admin/admin_dashboard.dart.


import 'dart:math';
import 'dart:typed_data';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';

import 'firebase_options.dart';
import 'services/auth_service.dart';
import 'admin/admin_dashboard.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const FoodShareApp());
}

class AppColors {
  static const green = Color(0xFF176B45);
  static const lightGreen = Color(0xFFE8F5EC);
  static const lime = Color(0xFFB7E4C7);
  static const dark = Color(0xFF18352A);
  static const grey = Color(0xFF718078);
  static const background = Color(0xFFF7FAF7);
}

final FirebaseFirestore _db = FirebaseFirestore.instance;

String _formatQuantity(num value) {
  if (value == value.roundToDouble()) {
    return value.toInt().toString();
  }
  return value.toString();
}

String _errorMessage(Object error) {
  if (error is FirebaseException) {
    return error.message ?? error.code;
  }
  return error.toString().replaceFirst('Exception: ', '');
}

void _showMessage(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(message)),
  );
}

// -----------------------------------------------------------------------------
// APP
// -----------------------------------------------------------------------------

class FoodShareApp extends StatelessWidget {
  const FoodShareApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FoodShare KuGompo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: AppColors.background,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.green,
          primary: AppColors.green,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFFE3EBE5)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(
              color: AppColors.green,
              width: 1.5,
            ),
          ),
        ),
      ),
      home: const WelcomeScreen(),
    );
  }
}

// -----------------------------------------------------------------------------
// WELCOME
// -----------------------------------------------------------------------------

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/welcome_bg.jpeg'),
            fit: BoxFit.cover,
          ),
        ),
        child: Container(
          color: const Color.fromRGBO(0, 0, 0, 0.53),
          child: SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  padding: const EdgeInsets.all(25),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight - 50,
                    ),
                    child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            height: 112,
                            width: 112,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.94),
                              borderRadius: BorderRadius.circular(32),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.18),
                                  blurRadius: 22,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.volunteer_activism_rounded,
                              color: AppColors.green,
                              size: 64,
                            ),
                          ),
                          const SizedBox(height: 23),
                          const Text(
                            'FoodShare',
                            style: TextStyle(
                              fontSize: 38,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const Text(
                            'KuGompo',
                            style: TextStyle(
                              fontSize: 22,
                              color: Colors.lightGreenAccent,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 2,
                            ),
                          ),
                          const SizedBox(height: 19),
                          const Text(
                            'Sharing food. Fighting hunger.\nBuilding a stronger community.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 16,
                              height: 1.6,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 42),
                          SizedBox(
                            width: double.infinity,
                            height: 56,
                            child: ElevatedButton.icon(
                              icon: const Icon(Icons.person_add_alt_1),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.green,
                                foregroundColor: Colors.white,
                                elevation: 3,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              onPressed: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const RegisterScreen(),
                                ),
                              ),
                              label: const Text(
                                'Create Account',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 14),
                          SizedBox(
                            width: double.infinity,
                            height: 56,
                            child: OutlinedButton.icon(
                              icon: const Icon(Icons.login_rounded),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.white,
                                side: const BorderSide(
                                  color: Colors.white,
                                  width: 1.5,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              onPressed: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const LoginScreen(),
                                ),
                              ),
                              label: const Text(
                                'Sign In',
                                style: TextStyle(fontSize: 16),
                              ),
                            ),
                          ),
                          const SizedBox(height: 30),
                          const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.location_on,
                                color: Colors.lightGreenAccent,
                                size: 18,
                              ),
                              SizedBox(width: 5),
                              Text(
                                'Serving the KuGompo community',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}


// -----------------------------------------------------------------------------
// LOGIN
// -----------------------------------------------------------------------------

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final AuthService _authService = AuthService();

  bool _isLoading = false;
  bool _hidePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Send a password reset link to the email entered on this screen.
  // The user must have access to that email inbox.
  Future<void> _resetPassword() async {
    final email = _emailController.text.trim();

    if (email.isEmpty ||
        !RegExp(r'^[^@]+@[^@]+\.[^@]+$').hasMatch(email)) {
      _showMessage(
        context,
        'Enter your registered email address first.',
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      if (!mounted) return;
      _showMessage(
        context,
        'Password reset email sent. Check your inbox.',
      );
    } on FirebaseAuthException catch (error) {
      if (!mounted) return;
      _showMessage(
        context,
        error.message ?? 'Could not send the password reset email.',
      );
    } catch (error) {
      if (mounted) {
        _showMessage(context, 'Password reset failed: ${_errorMessage(error)}');
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      final credential = await _authService.loginUser(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      final user = credential.user;
      if (user == null) {
        throw Exception('Unable to retrieve your account.');
      }

      // Admin access is determined by the trusted Firebase custom claim,
      // never by the editable Firestore role field alone.
      final isAdmin = await _authService.hasAdminAccess(user);
      if (!mounted) return;

      if (isAdmin) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => const AdminDashboard(),
          ),
        );
        return;
      }

      final profile = await _authService.getUserProfile(user.uid);
      if (!mounted) return;

      if (profile == null) {
        await _authService.logout();
        throw Exception('User profile not found. Please contact support.');
      }

      final role = profile['role']?.toString().trim();

      // Donors must be approved by an administrator before entering.
      if (role == 'Donor' && profile['isVerified'] != true) {
        final approvalStatus =
            profile['approvalStatus']?.toString().toLowerCase();
        await _authService.logout();
        if (approvalStatus == 'rejected') {
          throw Exception(
            'Your donor application was not approved. Please contact support.',
          );
        }
        throw Exception(
          'Your donor account is awaiting administrator approval.',
        );
      }

      if (role == 'Donor') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const DonorDashboard()),
        );
      } else if (role == 'Recipient') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const RecipientDashboard()),
        );
      } else if (role == 'Admin') {
        await _authService.logout();
        throw Exception(
          'This profile is marked Admin, but the Firebase admin permission was not found. ' +
          'Check that set_admin.js was run against the same Firebase project used by this app.',
        );
      } else {
        await _authService.logout();
        throw Exception('Your account has an invalid role.');
      }
    } on FirebaseAuthException catch (error) {
      var message = 'Login failed. Please try again.';
      if (error.code == 'user-not-found' ||
          error.code == 'wrong-password' ||
          error.code == 'invalid-credential') {
        message = 'Incorrect email or password.';
      } else if (error.code == 'invalid-email') {
        message = 'Please enter a valid email address.';
      } else if (error.code == 'too-many-requests') {
        message = 'Too many attempts. Please try again later.';
      }
      if (mounted) _showMessage(context, message);
    } catch (error) {
      if (mounted) _showMessage(context, _errorMessage(error));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Sign In'),
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.dark,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(25),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    height: 82,
                    width: 82,
                    decoration: BoxDecoration(
                      color: AppColors.lightGreen,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: const Icon(
                      Icons.volunteer_activism_rounded,
                      color: AppColors.green,
                      size: 45,
                    ),
                  ),
                ),
                const SizedBox(height: 22),
                const Text(
                  'Welcome back!',
                  style: TextStyle(
                    fontSize: 29,
                    fontWeight: FontWeight.bold,
                    color: AppColors.dark,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Sign in to continue sharing and discovering food.',
                  style: TextStyle(color: AppColors.grey),
                ),
                const SizedBox(height: 32),
                const Text('Email address'),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    hintText: 'Enter your email',
                    prefixIcon: Icon(Icons.email_outlined),
                  ),
                  validator: (value) {
                    if (value == null ||
                        !RegExp(r'^[^@]+@[^@]+\.[^@]+$')
                            .hasMatch(value.trim())) {
                      return 'Enter a valid email address';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                const Text('Password'),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _passwordController,
                  obscureText: _hidePassword,
                  decoration: InputDecoration(
                    hintText: 'Enter your password',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _hidePassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                      ),
                      onPressed: () {
                        setState(() => _hidePassword = !_hidePassword);
                      },
                    ),
                  ),
                  validator: (value) => value == null || value.length < 6
                      ? 'Password must contain at least 6 characters'
                      : null,
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: _isLoading ? null : _resetPassword,
                    child: const Text(
                      'Forgot password?',
                      style: TextStyle(
                        color: AppColors.green,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.green,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: _isLoading ? null : _login,
                    child: _isLoading
                        ? const SizedBox(
                            height: 22,
                            width: 22,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text(
                            'Sign In',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                  ),
                ),
                const SizedBox(height: 20),
                Center(
                  child: TextButton(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const RegisterScreen(),
                      ),
                    ),
                    child: const Text(
                      "Don't have an account? Register",
                      style: TextStyle(color: AppColors.green),
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


class DonorDashboard extends StatelessWidget {
  const DonorDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final rawName = user?.displayName?.trim() ?? '';
    final name = rawName.isNotEmpty ? rawName.split(' ').first : 'Donor';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'FoodShare Donor',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.green,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            tooltip: 'Sign out',
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              if (context.mounted) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const WelcomeScreen()),
                  (_) => false,
                );
              }
            },
            icon: const Icon(Icons.logout_rounded),
          ),
        ],
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/donor_bg.jpeg',
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) =>
                  Container(color: AppColors.background),
            ),
          ),
          Positioned.fill(
            child: Container(color: Colors.white.withValues(alpha: 0.90)),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(23),
                    child: SizedBox(
                      height: 190,
                      width: double.infinity,
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          Image.asset(
                            'assets/images/donor_bg.jpeg',
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) =>
                                Container(color: AppColors.green),
                          ),
                          Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.black.withValues(alpha: 0.72),
                                  Colors.black.withValues(alpha: 0.12),
                                ],
                                begin: Alignment.bottomLeft,
                                end: Alignment.topRight,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                const Icon(
                                  Icons.volunteer_activism_rounded,
                                  color: Colors.white,
                                  size: 33,
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  'Welcome back, $name!',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 25,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                const Text(
                                  'Your generosity helps feed our community.',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 22),
                  const Text(
                    'Your contribution',
                    style: TextStyle(
                      color: AppColors.dark,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (user != null)
                    Row(
                      children: [
                        Expanded(
                          child: StreamBuilder<
                              QuerySnapshot<Map<String, dynamic>>>(
                            stream: _db
                                .collection('food_donations')
                                .where('donorUid', isEqualTo: user.uid)
                                .snapshots(),
                            builder: (context, snapshot) {
                              return _DonorMetricCard(
                                title: 'My donations',
                                value: '${snapshot.data?.docs.length ?? 0}',
                                icon: Icons.inventory_2_rounded,
                                color: AppColors.green,
                              );
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: StreamBuilder<
                              QuerySnapshot<Map<String, dynamic>>>(
                            stream: _db
                                .collection('claims')
                                .where('donorUid', isEqualTo: user.uid)
                                .snapshots(),
                            builder: (context, snapshot) {
                              return _DonorMetricCard(
                                title: 'Food requests',
                                value: '${snapshot.data?.docs.length ?? 0}',
                                icon: Icons.assignment_rounded,
                                color: Colors.orange.shade700,
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  const SizedBox(height: 24),
                  const Text(
                    'Manage your activity',
                    style: TextStyle(
                      color: AppColors.dark,
                      fontSize: 19,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _DonorActionCard(
                    icon: Icons.add_a_photo_rounded,
                    title: 'Add Food Donation',
                    subtitle: 'Share surplus food with people who need it.',
                    action: 'Add donation',
                    color: AppColors.green,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const AddFoodScreen(),
                      ),
                    ),
                  ),
                  _DonorActionCard(
                    icon: Icons.inventory_2_rounded,
                    title: 'My Donations',
                    subtitle: 'View food listings and manage available stock.',
                    action: 'View donations',
                    color: Colors.teal.shade700,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const MyDonationsScreen(),
                      ),
                    ),
                  ),
                  _DonorActionCard(
                    icon: Icons.assignment_turned_in_rounded,
                    title: 'Manage Claims',
                    subtitle: 'Review requests and confirm collections.',
                    action: 'Manage requests',
                    color: Colors.orange.shade800,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const ManageClaimsScreen(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(17),
                    decoration: BoxDecoration(
                      color: AppColors.lightGreen,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: AppColors.lime),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.favorite_rounded,
                            color: AppColors.green, size: 27),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Every donation makes a difference. Thank you for fighting hunger!',
                            style: TextStyle(
                              color: AppColors.dark,
                              fontWeight: FontWeight.w600,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DonorMetricCard extends StatelessWidget {
  const _DonorMetricCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String title;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(17),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            height: 42,
            width: 42,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppColors.dark,
                  ),
                ),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.grey,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DonorActionCard extends StatelessWidget {
  const _DonorActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.action,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String action;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(19),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.045),
            blurRadius: 11,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(19),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 55,
                height: 55,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.11),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(icon, color: color, size: 29),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: AppColors.dark,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: AppColors.grey,
                        fontSize: 12,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      action,
                      style: TextStyle(
                        color: color,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios_rounded,
                  color: color, size: 17),
            ],
          ),
        ),
      ),
    );
  }
}


// -----------------------------------------------------------------------------
// RECIPIENT DASHBOARD - GPS, DISTANCE AND DIRECTIONS
// -----------------------------------------------------------------------------

class RecipientDashboard extends StatefulWidget {
  const RecipientDashboard({super.key});

  @override
  State<RecipientDashboard> createState() =>
      _RecipientDashboardState();
}

class _RecipientDashboardState extends State<RecipientDashboard> {
  Position? _recipientPosition;
  bool _locationLoading = false;

  @override
  void initState() {
    super.initState();
    _loadRecipientLocation();
  }

  Future<void> _loadRecipientLocation() async {
    if (mounted) {
      setState(() => _locationLoading = true);
    }

    try {
      final serviceEnabled =
          await Geolocator.isLocationServiceEnabled();

      if (!serviceEnabled) {
        if (mounted) {
          _showMessage(context, 'Please enable your device location.');
        }
        return;
      }

      LocationPermission permission =
          await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        if (mounted) {
          _showMessage(context, 'Location permission was not granted.');
        }
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      if (!mounted) return;

      setState(() {
        _recipientPosition = position;
      });
    } catch (error) {
      debugPrint('Recipient GPS error: $error');
      if (mounted) {
        _showMessage(context, 'Could not get your location.');
      }
    } finally {
      if (mounted) {
        setState(() => _locationLoading = false);
      }
    }
  }

  String _getDonationDistance(Map<String, dynamic> donation) {
    final latitude = donation['pickupLatitude'];
    final longitude = donation['pickupLongitude'];

    if (_recipientPosition == null ||
        latitude is! num ||
        longitude is! num) {
      return 'Distance unavailable';
    }

    final distance = Geolocator.distanceBetween(
      _recipientPosition!.latitude,
      _recipientPosition!.longitude,
      latitude.toDouble(),
      longitude.toDouble(),
    );

    return '${(distance / 1000).toStringAsFixed(1)} km away';
  }

  Future<void> _openDirections(
    Map<String, dynamic> donation,
  ) async {
    final latitude = donation['pickupLatitude'];
    final longitude = donation['pickupLongitude'];

    if (latitude is! num || longitude is! num) {
      _showMessage(
        context,
        'Directions are unavailable for this older donation.',
      );
      return;
    }

    final uri = Uri.https(
      'www.google.com',
      '/maps/dir/',
      {
        'api': '1',
        'destination':
            '${latitude.toDouble()},${longitude.toDouble()}',
        'travelmode': 'driving',
      },
    );

    try {
      final opened = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );

      if (!opened && mounted) {
        _showMessage(context, 'Could not open Google Maps.');
      }
    } catch (error) {
      if (mounted) {
        _showMessage(
          context,
          'Directions error: ${_errorMessage(error)}',
        );
      }
    }
  }

  Future<void> _requestFood(
    BuildContext context,
    String donationId,
    Map<String, dynamic> donation,
  ) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final available = donation['availableQuantity'];
    final unit = (donation['quantityUnit'] ?? '').toString();

    if (available is! num || unit.isEmpty) {
      _showMessage(
        context,
        'This is an older listing. The donor must publish it again '
        'using the new quantity fields before it can be requested.',
      );
      return;
    }

    final requested = await showDialog<double>(
      context: context,
      builder: (dialogContext) => _RequestFoodDialog(
        foodName: (donation['foodName'] ?? 'food').toString(),
        available: available.toDouble(),
        unit: unit,
      ),
    );

    if (requested == null || !context.mounted) return;

    try {
      final donationRef =
          _db.collection('food_donations').doc(donationId);
      final claimRef = _db.collection('claims').doc();

      await _db.runTransaction((transaction) async {
        final donationSnapshot = await transaction.get(donationRef);

        if (!donationSnapshot.exists) {
          throw Exception('This donation no longer exists.');
        }

        final current = donationSnapshot.data()!;
        final currentAvailable = current['availableQuantity'];
        final currentUnit =
            (current['quantityUnit'] ?? '').toString();

        if (current['status'] != 'available' ||
            currentAvailable is! num ||
            currentUnit != unit) {
          throw Exception('This donation is no longer available.');
        }

        if (requested > currentAvailable.toDouble()) {
          throw Exception(
            'Only ${_formatQuantity(currentAvailable)} $unit remain. '
            'Please request a smaller amount.',
          );
        }

        transaction.set(claimRef, {
          'donationId': donationId,
          'recipientUid': user.uid,
          'recipientName':
              user.displayName ?? user.email ?? 'Food recipient',
          'donorUid': current['donorUid'],
          'donorName': current['donorName'] ?? 'Food donor',
          'foodName': current['foodName'] ?? 'Food donation',
          'description': current['description'] ?? '',
          'requestedQuantity': requested,
          'quantityUnit': unit,
          'quantity': '${_formatQuantity(requested)} $unit',
          'pickupLocation': current['pickupLocation'] ?? '',
          'expiryDate': current['expiryDate'],
          'status': 'pending',
          'createdAt': FieldValue.serverTimestamp(),
        });
      });

      if (!context.mounted) return;

      _showMessage(
        context,
        'Request submitted! The donor must approve it before '
        'the food quantity is reserved.',
      );
    } catch (error) {
      if (!context.mounted) return;

      _showMessage(
        context,
        'Request failed: ${_errorMessage(error)}',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final rawName = user?.displayName?.trim() ?? '';
    final name = rawName.isNotEmpty ? rawName.split(' ').first : 'Friend';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'FoodShare KuGompo',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.green,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            tooltip: 'Sign out',
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              if (context.mounted) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const WelcomeScreen()),
                  (_) => false,
                );
              }
            },
            icon: const Icon(Icons.logout_rounded),
          ),
        ],
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/recipient_bg.jpeg',
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) =>
                  Container(color: AppColors.background),
            ),
          ),
          Positioned.fill(
            child: Container(color: Colors.white.withValues(alpha: 0.91)),
          ),
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(17, 16, 17, 10),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(23),
                    child: SizedBox(
                      width: double.infinity,
                      height: 160,
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          Image.asset(
                            'assets/images/recipient_bg.jpeg',
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) =>
                                Container(color: AppColors.green),
                          ),
                          Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.black.withValues(alpha: 0.72),
                                  Colors.black.withValues(alpha: 0.12),
                                ],
                                begin: Alignment.bottomLeft,
                                end: Alignment.topRight,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(18),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                const Icon(
                                  Icons.favorite_rounded,
                                  color: Colors.white,
                                  size: 29,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Welcome, $name!',
                                  style: const TextStyle(
                                    fontSize: 23,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 5),
                                const Text(
                                  'Discover food shared by your community.',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 17),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 7,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: const Color(0xFFE3EBE5),
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.location_on_rounded,
                              color: AppColors.green,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _locationLoading
                                    ? 'Finding your location...'
                                    : _recipientPosition == null
                                        ? 'Location not available'
                                        : 'Your location is ready',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.dark,
                                ),
                              ),
                            ),
                            TextButton(
                              onPressed: _locationLoading
                                  ? null
                                  : _loadRecipientLocation,
                              child: const Text('Refresh'),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 9),
                      Card(
                        elevation: 1,
                        color: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: ListTile(
                          leading: Container(
                            height: 43,
                            width: 43,
                            decoration: BoxDecoration(
                              color: AppColors.lightGreen,
                              borderRadius: BorderRadius.circular(13),
                            ),
                            child: const Icon(
                              Icons.receipt_long_rounded,
                              color: AppColors.green,
                            ),
                          ),
                          title: const Text(
                            'My Food Requests',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppColors.dark,
                            ),
                          ),
                          subtitle: const Text(
                            'Check request status and pickup PINs',
                            style: TextStyle(fontSize: 11),
                          ),
                          trailing: const Icon(
                            Icons.arrow_forward_ios_rounded,
                            size: 17,
                            color: AppColors.green,
                          ),
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const MyClaimsScreen(),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.fromLTRB(19, 16, 19, 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Available Food',
                        style: TextStyle(
                          fontSize: 21,
                          fontWeight: FontWeight.bold,
                          color: AppColors.dark,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Discover donations shared near your community.',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: StreamBuilder<
                      QuerySnapshot<Map<String, dynamic>>>(
                    stream: _db
                        .collection('food_donations')
                        .where('status', isEqualTo: 'available')
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return Center(
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Text(
                              'Unable to load donations: ${snapshot.error}',
                              textAlign: TextAlign.center,
                            ),
                          ),
                        );
                      }

                      if (snapshot.connectionState ==
                          ConnectionState.waiting) {
                        return const Center(
                          child: CircularProgressIndicator(
                            color: AppColors.green,
                          ),
                        );
                      }

                      final donations = snapshot.data?.docs ?? [];

                      if (donations.isEmpty) {
                        return Center(
                          child: Container(
                            margin: const EdgeInsets.all(20),
                            padding: const EdgeInsets.all(25),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.restaurant_menu_rounded,
                                  color: AppColors.green,
                                  size: 48,
                                ),
                                SizedBox(height: 12),
                                Text(
                                  'No food available right now',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: AppColors.dark,
                                  ),
                                ),
                                SizedBox(height: 7),
                                Text(
                                  'Please check again later for new donations.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: AppColors.grey,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }

                      return ListView.builder(
                        padding: const EdgeInsets.fromLTRB(15, 2, 15, 22),
                        itemCount: donations.length,
                        itemBuilder: (context, index) {
                          final doc = donations[index];
                          final donation = doc.data();
                          final stock = donation['availableQuantity'];
                          final unit =
                              (donation['quantityUnit'] ?? '').toString();
                          final supportsNewClaims =
                              stock is num && unit.isNotEmpty;
                          final expiry = donation['expiryDate'] is Timestamp
                              ? (donation['expiryDate'] as Timestamp).toDate()
                              : null;
                          final expiryText = expiry == null
                              ? 'Not specified'
                              : '${expiry.day}/${expiry.month}/${expiry.year}';
                          final latitude = donation['pickupLatitude'];
                          final longitude = donation['pickupLongitude'];
                          final hasCoordinates =
                              latitude is num && longitude is num;

                          return Container(
                            margin: const EdgeInsets.only(bottom: 16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.045),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(14),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(15),
                                    child: _donationImage(
                                      donation['imageUrl']?.toString(),
                                      height: 175,
                                    ),
                                  ),
                                  const SizedBox(height: 13),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          donation['foodName'] ??
                                              'Food donation',
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.dark,
                                          ),
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 9,
                                          vertical: 6,
                                        ),
                                        decoration: BoxDecoration(
                                          color: AppColors.lightGreen,
                                          borderRadius:
                                              BorderRadius.circular(20),
                                        ),
                                        child: const Text(
                                          'AVAILABLE',
                                          style: TextStyle(
                                            color: AppColors.green,
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    donation['description'] ?? '',
                                    style: const TextStyle(
                                      color: AppColors.grey,
                                      height: 1.4,
                                      fontSize: 13,
                                    ),
                                  ),
                                  const Divider(height: 24),
                                  _InfoLine(
                                    icon: Icons.inventory_2_outlined,
                                    label: 'Available quantity',
                                    value: supportsNewClaims
                                        ? '${_formatQuantity(stock)} $unit'
                                        : (donation['quantity']?.toString() ??
                                            'Older listing'),
                                  ),
                                  _InfoLine(
                                    icon: Icons.location_on_outlined,
                                    label: 'Pickup location',
                                    value: donation['pickupLocation'] ??
                                        'Not specified',
                                  ),
                                  _InfoLine(
                                    icon: Icons.near_me_outlined,
                                    label: 'Distance',
                                    value: _getDonationDistance(donation),
                                  ),
                                  _InfoLine(
                                    icon: Icons.calendar_today_outlined,
                                    label: 'Expiry date',
                                    value: expiryText,
                                  ),
                                  _InfoLine(
                                    icon: Icons.person_outline,
                                    label: 'Donor',
                                    value: donation['donorName'] ?? 'Food donor',
                                  ),
                                  const SizedBox(height: 12),
                                  SizedBox(
                                    width: double.infinity,
                                    child: OutlinedButton.icon(
                                      onPressed: hasCoordinates
                                          ? () => _openDirections(donation)
                                          : null,
                                      icon: const Icon(
                                        Icons.directions_rounded,
                                      ),
                                      label: const Text('Get Directions'),
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: AppColors.green,
                                        side: const BorderSide(
                                          color: AppColors.green,
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 12,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton.icon(
                                      onPressed: supportsNewClaims
                                          ? () => _requestFood(
                                                context,
                                                doc.id,
                                                donation,
                                              )
                                          : null,
                                      icon: const Icon(
                                        Icons.volunteer_activism_rounded,
                                      ),
                                      label: Text(
                                        supportsNewClaims
                                            ? 'Request Food'
                                            : 'Donor must update this listing',
                                      ),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppColors.green,
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 14,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(13),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

}

// -----------------------------------------------------------------------------
// RECIPIENT QUANTITY REQUEST DIALOG
// -----------------------------------------------------------------------------

class _RequestFoodDialog extends StatefulWidget {
  final String foodName;
  final double available;
  final String unit;

  const _RequestFoodDialog({
    required this.foodName,
    required this.available,
    required this.unit,
  });

  @override
  State<_RequestFoodDialog> createState() =>
      _RequestFoodDialogState();
}

class _RequestFoodDialogState extends State<_RequestFoodDialog> {
  final TextEditingController _quantityController =
      TextEditingController();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _quantityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Request ${widget.foodName}'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Available: ${_formatQuantity(widget.available)} '
                '${widget.unit}',
                style: const TextStyle(
                  color: AppColors.green,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 15),
              TextFormField(
                controller: _quantityController,
                autofocus: true,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: 'Quantity you need (${widget.unit})',
                  hintText: 'Enter an amount',
                ),
                validator: (value) {
                  final amount = double.tryParse((value ?? '').trim());

                  if (amount == null ||
                      !amount.isFinite ||
                      amount <= 0) {
                    return 'Enter a valid amount greater than zero';
                  }

                  if (amount > widget.available) {
                    return 'You cannot request more than the available amount';
                  }

                  return null;
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              Navigator.pop(
                context,
                double.parse(_quantityController.text.trim()),
              );
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.green,
            foregroundColor: Colors.white,
          ),
          child: const Text('Submit request'),
        ),
      ],
    );
  }
}

// -----------------------------------------------------------------------------
// ADD FOOD DONATION - DONOR GPS
// -----------------------------------------------------------------------------

class AddFoodScreen extends StatefulWidget {
  const AddFoodScreen({super.key});

  @override
  State<AddFoodScreen> createState() => _AddFoodScreenState();
}

class _AddFoodScreenState extends State<AddFoodScreen> {
  final _formKey = GlobalKey<FormState>();
  final _foodNameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _quantityController = TextEditingController();
  final _unitController = TextEditingController();
  final _locationController = TextEditingController();

  DateTime? _expiryDate;
  XFile? _selectedImage;
  bool _isLoading = false;

  Position? _pickupPosition;
  bool _isGettingLocation = false;

  final ImagePicker _imagePicker = ImagePicker();

  @override
  void dispose() {
    _foodNameController.dispose();
    _descriptionController.dispose();
    _quantityController.dispose();
    _unitController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _selectExpiryDate() async {
    final now = DateTime.now();

    final selectedDate = await showDatePicker(
      context: context,
      initialDate: now.add(const Duration(days: 1)),
      firstDate: DateTime(now.year, now.month, now.day),
      lastDate: now.add(const Duration(days: 365)),
    );

    if (selectedDate != null) {
      setState(() => _expiryDate = selectedDate);
    }
  }

  Future<void> _pickImage() async {
    try {
      final image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
        maxWidth: 1600,
      );

      if (image != null && mounted) {
        setState(() => _selectedImage = image);
      }
    } catch (error) {
      if (mounted) {
        _showMessage(
          context,
          'Could not select image: ${_errorMessage(error)}',
        );
      }
    }
  }

  Future<String?> _uploadDonationImage(
    String uid,
    String donationId,
  ) async {
    if (_selectedImage == null) return null;

    final bytes = await _selectedImage!.readAsBytes();
    final extension =
        _selectedImage!.name.split('.').last.toLowerCase();

    final contentType =
        extension == 'png' ? 'image/png' : 'image/jpeg';

    final imageRef = FirebaseStorage.instance
        .ref()
        .child('food_donations')
        .child(uid)
        .child('$donationId.$extension');

    await imageRef.putData(
      bytes,
      SettableMetadata(contentType: contentType),
    );

    return imageRef.getDownloadURL();
  }

  Future<void> _capturePickupLocation() async {
    setState(() => _isGettingLocation = true);

    try {
      final serviceEnabled =
          await Geolocator.isLocationServiceEnabled();

      if (!serviceEnabled) {
        throw Exception('Please enable location services.');
      }

      LocationPermission permission =
          await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        throw Exception('Location permission is required.');
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      if (!mounted) return;

      setState(() => _pickupPosition = position);

      _showMessage(context, 'Pickup GPS location captured!');
    } catch (error) {
      if (mounted) {
        _showMessage(
          context,
          'Location error: ${_errorMessage(error)}',
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isGettingLocation = false);
      }
    }
  }

  Future<void> _saveDonation() async {
    if (!_formKey.currentState!.validate()) return;

    if (_expiryDate == null) {
      _showMessage(context, 'Please select an expiry date.');
      return;
    }

    if (_pickupPosition == null) {
      _showMessage(
        context,
        'Please capture the pickup GPS location before publishing.',
      );
      return;
    }

    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      _showMessage(context, 'Please sign in first.');
      return;
    }

    final total = double.parse(_quantityController.text.trim());
    final unit = _unitController.text.trim();

    setState(() => _isLoading = true);

    try {
      final donationRef = _db.collection('food_donations').doc();

      final imageUrl = await _uploadDonationImage(
        user.uid,
        donationRef.id,
      );

      await donationRef.set({
        'foodName': _foodNameController.text.trim(),
        'description': _descriptionController.text.trim(),
        'totalQuantity': total,
        'availableQuantity': total,
        'reservedQuantity': 0,
        'collectedQuantity': 0,
        'quantityUnit': unit,
        'quantity': '${_formatQuantity(total)} $unit',
        'pickupLocation': _locationController.text.trim(),

        // DONOR GPS COORDINATES
        'pickupLatitude': _pickupPosition!.latitude,
        'pickupLongitude': _pickupPosition!.longitude,

        'imageUrl': imageUrl,
        'expiryDate': Timestamp.fromDate(_expiryDate!),
        'donorUid': user.uid,
        'donorName': user.displayName ?? user.email ?? 'Food donor',
        'status': 'available',
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;

      _showMessage(context, 'Food donation published successfully!');
      Navigator.pop(context);
    } catch (error) {
      if (mounted) {
        _showMessage(
          context,
          'Could not save donation: ${_errorMessage(error)}',
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Food Donation'),
        backgroundColor: AppColors.green,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(22),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Share food with your community',
                style: TextStyle(
                  fontSize: 23,
                  fontWeight: FontWeight.bold,
                  color: AppColors.dark,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Enter the total amount and the unit recipients should request.',
                style: TextStyle(color: AppColors.grey),
              ),
              const SizedBox(height: 20),
              const Text(
                'Food photo (optional)',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                height: 190,
                decoration: BoxDecoration(
                  color: AppColors.lightGreen,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.lime),
                ),
                clipBehavior: Clip.antiAlias,
                child: _selectedImage == null
                    ? const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.add_a_photo_outlined,
                            size: 42,
                            color: AppColors.green,
                          ),
                          SizedBox(height: 8),
                          Text('Add a clear photo of the food'),
                        ],
                      )
                    : FutureBuilder<Uint8List>(
                        future: _selectedImage!.readAsBytes(),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }

                          if (snapshot.hasError) {
                            return const Center(
                              child: Text('Unable to preview image'),
                            );
                          }

                          return Image.memory(
                            snapshot.data!,
                            width: double.infinity,
                            height: 190,
                            fit: BoxFit.cover,
                          );
                        },
                      ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _isLoading ? null : _pickImage,
                      icon: const Icon(Icons.photo_library_outlined),
                      label: Text(
                        _selectedImage == null
                            ? 'Choose photo'
                            : 'Change photo',
                      ),
                    ),
                  ),
                  if (_selectedImage != null) ...[
                    const SizedBox(width: 8),
                    IconButton(
                      tooltip: 'Remove photo',
                      onPressed: _isLoading
                          ? null
                          : () => setState(() => _selectedImage = null),
                      icon: const Icon(
                        Icons.delete_outline,
                        color: Colors.red,
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 20),
              const Text('Food name'),
              const SizedBox(height: 8),
              TextFormField(
                controller: _foodNameController,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  hintText: 'e.g. Fresh vegetables',
                  prefixIcon: Icon(Icons.restaurant),
                ),
                validator: (value) =>
                    value == null || value.trim().isEmpty
                        ? 'Enter the food name'
                        : null,
              ),
              const SizedBox(height: 18),
              const Text('Description'),
              const SizedBox(height: 8),
              TextFormField(
                controller: _descriptionController,
                maxLines: 3,
                decoration: const InputDecoration(
                  hintText: 'Describe the food and its condition',
                  prefixIcon: Icon(Icons.description_outlined),
                ),
                validator: (value) =>
                    value == null || value.trim().isEmpty
                        ? 'Enter a description'
                        : null,
              ),
              const SizedBox(height: 18),
              const Text('Total quantity available'),
              const SizedBox(height: 8),
              TextFormField(
                controller: _quantityController,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  hintText: 'e.g. 20 or 2.5',
                  prefixIcon: Icon(Icons.numbers),
                ),
                validator: (value) {
                  final amount =
                      double.tryParse((value ?? '').trim());

                  if (amount == null ||
                      !amount.isFinite ||
                      amount <= 0) {
                    return 'Enter a valid quantity greater than zero';
                  }

                  return null;
                },
              ),
              const SizedBox(height: 18),
              const Text('Quantity unit'),
              const SizedBox(height: 8),
              TextFormField(
                controller: _unitController,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  hintText: 'e.g. plates, kg, packets, boxes, litres',
                  prefixIcon: Icon(Icons.straighten),
                  helperText: 'You define the unit recipients will use.',
                ),
                validator: (value) =>
                    value == null || value.trim().isEmpty
                        ? 'Enter a quantity unit'
                        : null,
              ),
              const SizedBox(height: 18),
              const Text('Pickup location'),
              const SizedBox(height: 8),
              TextFormField(
                controller: _locationController,
                decoration: const InputDecoration(
                  hintText: 'Enter the collection address or area',
                  prefixIcon: Icon(Icons.location_on_outlined),
                ),
                validator: (value) =>
                    value == null || value.trim().isEmpty
                        ? 'Enter the pickup location'
                        : null,
              ),

              const SizedBox(height: 10),

              // DONOR GPS BUTTON
              OutlinedButton.icon(
                onPressed: _isGettingLocation || _isLoading
                    ? null
                    : _capturePickupLocation,
                icon: const Icon(Icons.my_location),
                label: Text(
                  _isGettingLocation
                      ? 'Capturing location...'
                      : 'Use my current location',
                ),
              ),

              if (_pickupPosition != null) ...[
                const SizedBox(height: 8),
                Text(
                  'GPS captured: '
                  '${_pickupPosition!.latitude.toStringAsFixed(6)}, '
                  '${_pickupPosition!.longitude.toStringAsFixed(6)}',
                  style: const TextStyle(color: AppColors.green),
                ),
              ],

              const SizedBox(height: 18),
              const Text('Expiry date'),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _selectExpiryDate,
                  icon: const Icon(Icons.calendar_month),
                  label: Text(
                    _expiryDate == null
                        ? 'Choose expiry date'
                        : '${_expiryDate!.day}/${_expiryDate!.month}/${_expiryDate!.year}',
                  ),
                ),
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveDonation,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.green,
                    foregroundColor: Colors.white,
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(
                          color: Colors.white,
                        )
                      : const Text('Publish Donation'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// DONATION IMAGE
// -----------------------------------------------------------------------------

Widget _donationImage(String? imageUrl, {double height = 190}) {
  if (imageUrl == null || imageUrl.trim().isEmpty) {
    return Container(
      height: height,
      width: double.infinity,
      color: AppColors.lightGreen,
      alignment: Alignment.center,
      child: const Icon(
        Icons.restaurant,
        size: 48,
        color: AppColors.green,
      ),
    );
  }

  return ClipRRect(
    borderRadius: BorderRadius.circular(12),
    child: Image.network(
      imageUrl,
      height: height,
      width: double.infinity,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) => Container(
        height: height,
        color: AppColors.lightGreen,
        alignment: Alignment.center,
        child: const Icon(
          Icons.broken_image_outlined,
          size: 42,
          color: AppColors.grey,
        ),
      ),
    ),
  );
}

// -----------------------------------------------------------------------------
// MY DONATIONS
// -----------------------------------------------------------------------------

class MyDonationsScreen extends StatelessWidget {
  const MyDonationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Scaffold(
        body: Center(child: Text('Please sign in again.')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Donations'),
        backgroundColor: AppColors.green,
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: _db
            .collection('food_donations')
            .where('donorUid', isEqualTo: user.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Unable to load donations: ${snapshot.error}',
              ),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final donations = snapshot.data?.docs ?? [];

          if (donations.isEmpty) {
            return const Center(
              child: Text('You have not added donations yet.'),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: donations.length,
            itemBuilder: (context, index) {
              final donation = donations[index].data();

              final total = donation['totalQuantity'];
              final available = donation['availableQuantity'];
              final reserved = donation['reservedQuantity'];
              final collected = donation['collectedQuantity'];
              final unit = donation['quantityUnit'] ?? '';

              final isNewFormat = total is num &&
                  available is num &&
                  reserved is num &&
                  collected is num;

              return Card(
                margin: const EdgeInsets.only(bottom: 15),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _donationImage(
                        donation['imageUrl']?.toString(),
                        height: 170,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        donation['foodName'] ?? 'Food donation',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.dark,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        donation['description'] ?? '',
                        style: const TextStyle(color: AppColors.grey),
                      ),
                      const Divider(height: 24),
                      if (isNewFormat) ...[
                        _InfoLine(
                          icon: Icons.inventory_2_outlined,
                          label: 'Total',
                          value: '${_formatQuantity(total)} $unit',
                        ),
                        _InfoLine(
                          icon: Icons.check_circle_outline,
                          label: 'Available',
                          value: '${_formatQuantity(available)} $unit',
                        ),
                        _InfoLine(
                          icon: Icons.lock_outline,
                          label: 'Reserved for approved claims',
                          value: '${_formatQuantity(reserved)} $unit',
                        ),
                        _InfoLine(
                          icon: Icons.shopping_bag_outlined,
                          label: 'Collected',
                          value: '${_formatQuantity(collected)} $unit',
                        ),
                      ] else
                        Text(
                          'Quantity: ${donation['quantity'] ?? 'N/A'}',
                        ),
                      _InfoLine(
                        icon: Icons.location_on_outlined,
                        label: 'Pickup location',
                        value: donation['pickupLocation'] ?? 'N/A',
                      ),
                      const SizedBox(height: 8),
                      Chip(
                        label: Text(
                          (donation['status'] ?? 'available')
                              .toString()
                              .toUpperCase(),
                        ),
                      ),
                      if (!isNewFormat)
                        const Text(
                          'Legacy listing: edit/repost this donation with a numeric quantity and unit before accepting requests.',
                          style: TextStyle(color: Colors.orange),
                        ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// MY CLAIMS
// -----------------------------------------------------------------------------

class MyClaimsScreen extends StatelessWidget {
  const MyClaimsScreen({super.key});

  Color _statusColor(String status) {
    switch (status) {
      case 'approved':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      case 'collected':
        return Colors.blue;
      default:
        return Colors.orange;
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Scaffold(
        body: Center(child: Text('Please sign in to view your requests.')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Claims'),
        backgroundColor: AppColors.green,
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: _db
            .collection('claims')
            .where('recipientUid', isEqualTo: user.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Unable to load your claims: ${snapshot.error}',
              ),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final claims = snapshot.data?.docs ?? [];

          if (claims.isEmpty) {
            return const Center(
              child: Text('You have not requested food yet.'),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: claims.length,
            itemBuilder: (context, index) {
              final claim = claims[index].data();

              final status =
                  (claim['status'] ?? 'pending').toString();

              final pin = (claim['pickupCode'] ?? '').toString();
              final color = _statusColor(status);

              return Card(
                margin: const EdgeInsets.only(bottom: 15),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        claim['foodName'] ?? 'Food donation',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Divider(height: 24),
                      Text(claim['description'] ?? ''),
                      const SizedBox(height: 10),
                      _InfoLine(
                        icon: Icons.inventory_2_outlined,
                        label: 'Requested quantity',
                        value: claim['quantity'] ??
                            '${claim['requestedQuantity'] ?? ''} '
                                '${claim['quantityUnit'] ?? ''}',
                      ),
                      _InfoLine(
                        icon: Icons.location_on_outlined,
                        label: 'Pickup location',
                        value: claim['pickupLocation'] ?? 'Not specified',
                      ),
                      const SizedBox(height: 10),
                      Chip(
                        label: Text(status.toUpperCase()),
                        backgroundColor: color.withValues(alpha: 0.12),
                        labelStyle: TextStyle(
                          color: color,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (status == 'pending')
                        const Text(
                          'Your request is waiting for donor approval. '
                          'The food quantity is not reserved yet.',
                          style: TextStyle(color: Colors.orange),
                        ),
                      if (status == 'approved' && pin.isNotEmpty) ...[
                        const SizedBox(height: 15),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: AppColors.lightGreen,
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(color: AppColors.green),
                          ),
                          child: Column(
                            children: [
                              const Icon(
                                Icons.verified_user,
                                color: AppColors.green,
                                size: 35,
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'YOUR PICKUP PIN',
                                style: TextStyle(
                                  color: AppColors.dark,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              SelectableText(
                                pin,
                                style: const TextStyle(
                                  color: AppColors.green,
                                  fontSize: 34,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 6,
                                ),
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'Show this PIN to the donor when collecting your food.',
                                textAlign: TextAlign.center,
                                style: TextStyle(fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                      ],
                      if (status == 'rejected')
                        const Text(
                          'This request was rejected. The donation itself may still be available to other recipients.',
                          style: TextStyle(color: Colors.red),
                        ),
                      if (status == 'collected')
                        const Text(
                          'Collection completed. Thank you for using FoodShare!',
                          style: TextStyle(color: Colors.blue),
                        ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// REGISTRATION
// -----------------------------------------------------------------------------

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final AuthService _authService = AuthService();

  String _selectedRole = 'Recipient';
  bool _isLoading = false;
  bool _acceptedTerms = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _show(String message) => _showMessage(context, message);

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    if (!_acceptedTerms) {
      _show('Please accept the terms and conditions.');
      return;
    }

    setState(() => _isLoading = true);

    try {
      await _authService.registerUser(
        fullName: _nameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
        role: _selectedRole,
      );

      if (!mounted) return;

      await showDialog<void>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Text('Account created!'),
          content: const Text(
            'Welcome to FoodShare KuGompo. Your account was created successfully.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
              child: const Text('Continue'),
            ),
          ],
        ),
      );
    } on FirebaseAuthException catch (error) {
      if (!mounted) return;

      var message = error.message ?? 'Registration failed.';

      switch (error.code) {
        case 'email-already-in-use':
          message = 'This email is already registered.';
          break;
        case 'weak-password':
          message = 'Please choose a stronger password.';
          break;
        case 'invalid-email':
          message = 'Please enter a valid email address.';
          break;
        case 'network-request-failed':
          message = 'Check your internet connection.';
          break;
      }

      _show(message);
    } catch (error) {
      if (mounted) {
        _show('Registration failed: ${_errorMessage(error)}');
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          color: AppColors.dark,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Account'),
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.dark,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 15,
          ),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    height: 85,
                    width: 85,
                    decoration: BoxDecoration(
                      color: AppColors.lightGreen,
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: const Icon(
                      Icons.volunteer_activism_rounded,
                      size: 48,
                      color: AppColors.green,
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                const Center(
                  child: Text(
                    'Join FoodShare!',
                    style: TextStyle(
                      fontSize: 27,
                      fontWeight: FontWeight.bold,
                      color: AppColors.dark,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                const Center(
                  child: Text(
                    'Create an account and help reduce food waste\nin the KuGompo community.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppColors.grey, height: 1.5),
                  ),
                ),
                const SizedBox(height: 30),
                _sectionTitle('Full name'),
                TextFormField(
                  controller: _nameController,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(
                    hintText: 'Enter your full name',
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                  validator: (value) =>
                      value == null || value.trim().length < 3
                          ? 'Please enter your full name'
                          : null,
                ),
                const SizedBox(height: 20),
                _sectionTitle('Email address'),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    hintText: 'Enter your email',
                    prefixIcon: Icon(Icons.email_outlined),
                  ),
                  validator: (value) {
                    if (value == null ||
                        !RegExp(r'^[^@]+@[^@]+\.[^@]+$')
                            .hasMatch(value.trim())) {
                      return 'Enter a valid email address';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                _sectionTitle('Account type'),
                DropdownButtonFormField<String>(
                  initialValue: _selectedRole,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.people_outline),
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: 'Recipient',
                      child: Text('Food recipient / Student'),
                    ),
                    DropdownMenuItem(
                      value: 'Donor',
                      child: Text('Food donor / Business'),
                    ),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _selectedRole = value);
                    }
                  },
                ),
                const SizedBox(height: 20),
                _sectionTitle('Password'),
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    hintText: 'Create a password',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                      ),
                      onPressed: () => setState(
                        () => _obscurePassword = !_obscurePassword,
                      ),
                    ),
                  ),
                  validator: (value) => value == null || value.length < 6
                      ? 'Password must contain at least 6 characters'
                      : null,
                ),
                const SizedBox(height: 20),
                _sectionTitle('Confirm password'),
                TextFormField(
                  controller: _confirmPasswordController,
                  obscureText: _obscureConfirmPassword,
                  decoration: InputDecoration(
                    hintText: 'Enter your password again',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureConfirmPassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                      ),
                      onPressed: () => setState(
                        () => _obscureConfirmPassword =
                            !_obscureConfirmPassword,
                      ),
                    ),
                  ),
                  validator: (value) =>
                      value != _passwordController.text
                          ? 'Passwords do not match'
                          : null,
                ),
                const SizedBox(height: 15),
                CheckboxListTile(
                  value: _acceptedTerms,
                  onChanged: (value) {
                    setState(() => _acceptedTerms = value ?? false);
                  },
                  controlAffinity: ListTileControlAffinity.leading,
                  contentPadding: EdgeInsets.zero,
                  activeColor: AppColors.green,
                  title: const Text(
                    'I agree to the terms and conditions.',
                    style: TextStyle(fontSize: 13),
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _register,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.green,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(
                            color: Colors.white,
                          )
                        : const Text(
                            'Create Account',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 20),
                Center(
                  child: TextButton(
                    onPressed: () => Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const LoginScreen(),
                      ),
                    ),
                    child: const Text(
                      'Already have an account? Sign In',
                      style: TextStyle(
                        color: AppColors.green,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// DONOR: MANAGE CLAIMS
// -----------------------------------------------------------------------------

class ManageClaimsScreen extends StatelessWidget {
  const ManageClaimsScreen({super.key});

  Future<void> _approveClaim(
    BuildContext context,
    String claimId,
    Map<String, dynamic> claim,
  ) async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      _showMessage(context, 'Please sign in again.');
      return;
    }

    final claimRef = _db.collection('claims').doc(claimId);
    final donationId = (claim['donationId'] ?? '').toString();

    if (donationId.isEmpty) {
      _showMessage(context, 'This claim has no donation reference.');
      return;
    }

    final donationRef =
        _db.collection('food_donations').doc(donationId);

    try {
      final random = Random.secure();
      final pickupPin =
          (100000 + random.nextInt(900000)).toString();

      await _db.runTransaction((transaction) async {
        final claimSnapshot = await transaction.get(claimRef);
        final donationSnapshot = await transaction.get(donationRef);

        if (!claimSnapshot.exists) {
          throw Exception('This request no longer exists.');
        }

        if (!donationSnapshot.exists) {
          throw Exception('The food donation no longer exists.');
        }

        final currentClaim = claimSnapshot.data()!;
        final donation = donationSnapshot.data()!;

        // CHECK 1: The signed-in donor must own this claim.
        if (currentClaim['donorUid'] != user.uid) {
          throw Exception(
            'You are not authorised to approve this request.',
          );
        }

        // CHECK 2: The signed-in donor must also own the donation.
        if (donation['donorUid'] != user.uid) {
          throw Exception(
            'You are not authorised to update this donation.',
          );
        }

        // CHECK 3: The claim must reference the donation being updated.
        if (currentClaim['donationId'] != donationId) {
          throw Exception(
            'The claim is linked to a different donation.',
          );
        }

        if (currentClaim['status'] != 'pending') {
          throw Exception('This request has already been processed.');
        }

        final requested = currentClaim['requestedQuantity'];
        final available = donation['availableQuantity'];
        final reserved = donation['reservedQuantity'];

        if (requested is! num ||
            available is! num ||
            reserved is! num) {
          throw Exception(
            'The donation has invalid quantity information.',
          );
        }

        if (donation['status'] != 'available') {
          throw Exception('This donation is no longer available.');
        }

        if (requested <= 0 || requested > available) {
          throw Exception(
            'Not enough food remains. Available: '
            '${_formatQuantity(available)} '
            '${donation['quantityUnit'] ?? ''}.',
          );
        }

        final newAvailable = available - requested;
        final newReserved = reserved + requested;

        transaction.update(donationRef, {
          'availableQuantity': newAvailable,
          'reservedQuantity': newReserved,
          'status': newAvailable > 0 ? 'available' : 'sold_out',
          'lastUpdatedClaimId': claimId,
          'updatedAt': FieldValue.serverTimestamp(),
        });

        transaction.update(claimRef, {
          'status': 'approved',
          'pickupCode': pickupPin,
          'reviewedAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      });

      if (!context.mounted) return;

      _showMessage(
        context,
        'Request approved. A six-digit pickup PIN has been generated.',
      );
    } catch (error, stackTrace) {
      // Print the full error in the VS Code terminal so we can identify
      // which Firestore security rule is rejecting the transaction.
      debugPrint('========== FOODSHARE APPROVAL ERROR ==========');
      debugPrint('Error: $error');
      debugPrintStack(stackTrace: stackTrace);

      if (error is FirebaseException) {
        debugPrint('Firebase error code: ${error.code}');
        debugPrint('Firebase error message: ${error.message}');
      }

      debugPrint('==============================================');

      if (!context.mounted) return;

      if (error is FirebaseException) {
        _showMessage(
          context,
          'Approval failed (${error.code}): ${error.message ?? error.code}',
        );
      } else {
        _showMessage(
          context,
          'Approval failed: ${_errorMessage(error)}',
        );
      }
    }
  }

  Future<void> _rejectClaim(
    BuildContext context,
    String claimId,
  ) async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      _showMessage(context, 'Please sign in again.');
      return;
    }

    final claimRef = _db.collection('claims').doc(claimId);

    try {
      await _db.runTransaction((transaction) async {
        final snapshot = await transaction.get(claimRef);

        if (!snapshot.exists) {
          throw Exception('This request no longer exists.');
        }

        final claim = snapshot.data()!;

        if (claim['donorUid'] != user.uid) {
          throw Exception(
            'You are not authorised to reject this request.',
          );
        }

        if (claim['status'] != 'pending') {
          throw Exception('This request has already been processed.');
        }

        transaction.update(claimRef, {
          'status': 'rejected',
          'reviewedAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      });

      if (!context.mounted) return;

      _showMessage(
        context,
        'Request rejected. Donation stock is unchanged.',
      );
    } catch (error) {
      if (!context.mounted) return;

      _showMessage(
        context,
        'Could not reject request: ${_errorMessage(error)}',
      );
    }
  }

  Future<void> _confirmCollection(
    BuildContext context,
    String claimId,
    String enteredPin,
  ) async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      _showMessage(context, 'Please sign in again.');
      return;
    }

    final claimRef = _db.collection('claims').doc(claimId);

    try {
      await _db.runTransaction((transaction) async {
        final claimSnapshot = await transaction.get(claimRef);

        if (!claimSnapshot.exists) {
          throw Exception('This claim no longer exists.');
        }

        final claim = claimSnapshot.data()!;

        if (claim['donorUid'] != user.uid) {
          throw Exception(
            'You are not authorised to confirm this collection.',
          );
        }

        if (claim['status'] != 'approved') {
          throw Exception('Only approved claims can be collected.');
        }

        final savedPin = (claim['pickupCode'] ?? '').toString();

        if (savedPin != enteredPin.trim()) {
          throw Exception('Incorrect pickup PIN. Please try again.');
        }

        final donationId = (claim['donationId'] ?? '').toString();

        if (donationId.isEmpty) {
          throw Exception('The donation reference is missing.');
        }

        final donationRef =
            _db.collection('food_donations').doc(donationId);

        final donationSnapshot = await transaction.get(donationRef);

        if (!donationSnapshot.exists) {
          throw Exception('The original donation no longer exists.');
        }

        final donation = donationSnapshot.data()!;

        final requested = claim['requestedQuantity'];
        final reserved = donation['reservedQuantity'];
        final collected = donation['collectedQuantity'];
        final available = donation['availableQuantity'];

        if (requested is! num ||
            reserved is! num ||
            collected is! num ||
            available is! num) {
          throw Exception('Invalid donation stock information.');
        }

        if (requested > reserved) {
          throw Exception('The reserved quantity is incorrect.');
        }

        final newReserved = reserved - requested;
        final newCollected = collected + requested;

        String newStatus;

        if (available > 0) {
          newStatus = 'available';
        } else if (newReserved > 0) {
          newStatus = 'sold_out';
        } else {
          newStatus = 'collected';
        }

        transaction.update(donationRef, {
          'reservedQuantity': newReserved,
          'collectedQuantity': newCollected,
          'status': newStatus,
          'lastUpdatedClaimId': claimId,
          'updatedAt': FieldValue.serverTimestamp(),
        });

        transaction.update(claimRef, {
          'status': 'collected',
          'collectedAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      });

      if (!context.mounted) return;

      _showMessage(context, 'Collection confirmed successfully!');
    } catch (error) {
      if (!context.mounted) return;

      _showMessage(
        context,
        'Collection failed: ${_errorMessage(error)}',
      );
    }
  }

  Future<void> _showPickupDialog(
    BuildContext context,
    String claimId,
  ) async {
    final enteredPin = await showDialog<String>(
      context: context,
      builder: (_) => const _PickupPinDialog(),
    );

    if (enteredPin == null || !context.mounted) return;

    await _confirmCollection(context, claimId, enteredPin);
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Scaffold(
        body: Center(child: Text('Please sign in again.')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Claims'),
        backgroundColor: AppColors.green,
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: _db
            .collection('claims')
            .where('donorUid', isEqualTo: user.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Unable to load requests: ${snapshot.error}',
              ),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final claims = snapshot.data?.docs ?? [];

          if (claims.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(25),
                child: Text(
                  'You have no recipient requests yet.',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          final sortedClaims = [...claims];

          sortedClaims.sort((a, b) {
            final aStatus = a.data()['status'] ?? 'pending';
            final bStatus = b.data()['status'] ?? 'pending';

            const priority = {
              'pending': 0,
              'approved': 1,
              'collected': 2,
              'rejected': 3,
            };

            return (priority[aStatus] ?? 4)
                .compareTo(priority[bStatus] ?? 4);
          });

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: sortedClaims.length,
            itemBuilder: (context, index) {
              final doc = sortedClaims[index];
              final claim = doc.data();

              final status =
                  (claim['status'] ?? 'pending').toString();

              final quantity =
                  (claim['quantity'] ?? 'Not specified').toString();

              final pin =
                  (claim['pickupCode'] ?? '').toString();

              Color statusColor;

              switch (status) {
                case 'approved':
                  statusColor = Colors.green;
                  break;
                case 'rejected':
                  statusColor = Colors.red;
                  break;
                case 'collected':
                  statusColor = Colors.blue;
                  break;
                default:
                  statusColor = Colors.orange;
              }

              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const CircleAvatar(
                            backgroundColor: AppColors.lightGreen,
                            child: Icon(
                              Icons.restaurant,
                              color: AppColors.green,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              (claim['foodName'] ?? 'Food donation')
                                  .toString(),
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppColors.dark,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 25),
                      _InfoLine(
                        icon: Icons.person_outline,
                        label: 'Recipient',
                        value: (claim['recipientName'] ?? 'Recipient')
                            .toString(),
                      ),
                      _InfoLine(
                        icon: Icons.inventory_2_outlined,
                        label: 'Requested quantity',
                        value: quantity,
                      ),
                      _InfoLine(
                        icon: Icons.location_on_outlined,
                        label: 'Collection location',
                        value: (claim['pickupLocation'] ?? 'Not specified')
                            .toString(),
                      ),
                      const SizedBox(height: 10),
                      Chip(
                        label: Text(status.toUpperCase()),
                        backgroundColor:
                            statusColor.withValues(alpha: 0.12),
                        labelStyle: TextStyle(
                          color: statusColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (status == 'pending') ...[
                        const Text(
                          'This request is waiting for your decision. '
                          'Food stock will only be reserved after approval.',
                          style: TextStyle(color: AppColors.grey),
                        ),
                        const SizedBox(height: 15),
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () => _approveClaim(
                                  context,
                                  doc.id,
                                  claim,
                                ),
                                icon: const Icon(Icons.check),
                                label: const Text('Approve'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.green,
                                  foregroundColor: Colors.white,
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () => _rejectClaim(
                                  context,
                                  doc.id,
                                ),
                                icon: const Icon(Icons.close),
                                label: const Text('Reject'),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: Colors.red,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                      if (status == 'approved') ...[
                        const SizedBox(height: 10),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(15),
                          decoration: BoxDecoration(
                            color: AppColors.lightGreen,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            children: [
                              const Text(
                                'PICKUP PIN',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.dark,
                                ),
                              ),
                              const SizedBox(height: 8),
                              SelectableText(
                                pin,
                                style: const TextStyle(
                                  fontSize: 30,
                                  letterSpacing: 5,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.green,
                                ),
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'Ask the recipient to provide this PIN '
                                'when collecting the food.',
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 15),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () => _showPickupDialog(
                              context,
                              doc.id,
                            ),
                            icon: const Icon(Icons.verified),
                            label: const Text('Confirm Food Collection'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.green,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ),
                      ],
                      if (status == 'rejected')
                        const Text(
                          'This request was rejected. No food stock was reserved.',
                          style: TextStyle(color: Colors.red),
                        ),
                      if (status == 'collected')
                        const Text(
                          'Food collection has been completed.',
                          style: TextStyle(color: Colors.blue),
                        ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// PICKUP PIN DIALOG
// -----------------------------------------------------------------------------

class _PickupPinDialog extends StatefulWidget {
  const _PickupPinDialog();

  @override
  State<_PickupPinDialog> createState() => _PickupPinDialogState();
}

class _PickupPinDialogState extends State<_PickupPinDialog> {
  final TextEditingController _pinController =
      TextEditingController();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _pinController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Confirm Food Collection'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Ask the recipient for their six-digit pickup PIN.',
            ),
            const SizedBox(height: 15),
            TextFormField(
              controller: _pinController,
              keyboardType: TextInputType.number,
              maxLength: 6,
              decoration: const InputDecoration(
                labelText: 'Enter pickup PIN',
                prefixIcon: Icon(Icons.lock_outline),
              ),
              validator: (value) {
                if (value == null ||
                    !RegExp(r'^\d{6}$').hasMatch(value.trim())) {
                  return 'Enter a valid six-digit PIN';
                }
                return null;
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              Navigator.pop(
                context,
                _pinController.text.trim(),
              );
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.green,
            foregroundColor: Colors.white,
          ),
          child: const Text('Verify PIN'),
        ),
      ],
    );
  }
}

// -----------------------------------------------------------------------------
// REUSABLE INFORMATION ROW
// -----------------------------------------------------------------------------

class _InfoLine extends StatelessWidget {
  const _InfoLine({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 9),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 19,
            color: AppColors.green,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              '$label: $value',
              style: const TextStyle(color: AppColors.dark),
            ),
          ),
        ],
      ),
    );
  }
}
