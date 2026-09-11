import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../models/user_model.dart';
import '../services/call_invitation_service.dart';
import '../widgets/glass_card.dart';
import '../widgets/gradient_button.dart';
import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _idController = TextEditingController();
  int _selectedAvatar = 0;
  bool _isLoading = false;

  final List<IconData> _avatars = const [
    Icons.person_rounded,
    Icons.face_rounded,
    Icons.sentiment_very_satisfied_rounded,
    Icons.rocket_launch_rounded,
    Icons.headphones_rounded,
  ];

  @override
  void initState() {
    super.initState();
    _generateRandomUserId();
  }

  void _generateRandomUserId() {
    setState(() {
      _idController.text = UserModel.generateRandomUserId();
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _idController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final user = UserModel(
      id: _idController.text.trim(),
      name: _nameController.text.trim(),
      avatarIndex: _selectedAvatar,
    );

    await user.save();

    // Connect to ZEGOCLOUD Call Invitation service for this user ID
    await CallInvitationService.instance.initCallInvitation(user);

    if (!mounted) return;
    setState(() => _isLoading = false);

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => HomeScreen(user: user)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Logo thumbnail & App Name
                  Center(
                    child: Container(
                      width: 90,
                      height: 90,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(22),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.cyan.withValues(alpha: 0.25),
                            blurRadius: 24,
                            offset: const Offset(0, 8),
                          ),
                          BoxShadow(
                            color: AppColors.purple.withValues(alpha: 0.25),
                            blurRadius: 28,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(22),
                        child: Image.asset(
                          'assets/images/logo.png',
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Welcome to Sauvaad',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.3,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'More than a call. A closer you.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.cyan.withValues(alpha: 0.9),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 28),

                  // Profile Card
                  GlassCard(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Choose Your Avatar',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 12),
                        // Avatar selection row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: List.generate(_avatars.length, (index) {
                            final isSelected = _selectedAvatar == index;
                            return GestureDetector(
                              onTap: () => setState(() => _selectedAvatar = index),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: isSelected
                                      ? AppColors.primaryGradient
                                      : null,
                                  color: isSelected
                                      ? null
                                      : AppColors.surfaceElevated,
                                  border: Border.all(
                                    color: isSelected
                                        ? AppColors.cyan
                                        : AppColors.surfaceBorder,
                                    width: isSelected ? 2.0 : 1.0,
                                  ),
                                  boxShadow: isSelected
                                      ? [
                                          BoxShadow(
                                            color: AppColors.purple.withValues(alpha: 0.4),
                                            blurRadius: 10,
                                            offset: const Offset(0, 4),
                                          )
                                        ]
                                      : null,
                                ),
                                child: Icon(
                                  _avatars[index],
                                  color: isSelected
                                      ? Colors.white
                                      : AppColors.textMuted,
                                  size: 24,
                                ),
                              ),
                            );
                          }),
                        ),
                        const SizedBox(height: 22),

                        // Display Name Input
                        const Text(
                          'Your Display Name',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _nameController,
                          style: const TextStyle(color: AppColors.textPrimary),
                          decoration: InputDecoration(
                            hintText: 'e.g. Alex Rivera',
                            hintStyle: const TextStyle(color: AppColors.textMuted),
                            prefixIcon: const Icon(
                              Icons.badge_outlined,
                              color: AppColors.cyan,
                              size: 20,
                            ),
                            filled: true,
                            fillColor: AppColors.backgroundAlt,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: const BorderSide(
                                color: AppColors.surfaceBorder,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: const BorderSide(
                                color: AppColors.surfaceBorder,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: const BorderSide(
                                color: AppColors.cyan,
                                width: 1.5,
                              ),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter your name';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 18),

                        // User ID Input
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'User ID (Unique caller identifier)',
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.5,
                              ),
                            ),
                            GestureDetector(
                              onTap: _generateRandomUserId,
                              child: Row(
                                children: const [
                                  Icon(
                                    Icons.refresh_rounded,
                                    color: AppColors.cyan,
                                    size: 16,
                                  ),
                                  SizedBox(width: 4),
                                  Text(
                                    'Random',
                                    style: TextStyle(
                                      color: AppColors.cyan,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _idController,
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontFamily: 'monospace',
                          ),
                          decoration: InputDecoration(
                            hintText: 'user_1234',
                            hintStyle: const TextStyle(color: AppColors.textMuted),
                            prefixIcon: const Icon(
                              Icons.tag_rounded,
                              color: AppColors.violet,
                              size: 20,
                            ),
                            filled: true,
                            fillColor: AppColors.backgroundAlt,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: const BorderSide(
                                color: AppColors.surfaceBorder,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: const BorderSide(
                                color: AppColors.surfaceBorder,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: const BorderSide(
                                color: AppColors.violet,
                                width: 1.5,
                              ),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter a user ID';
                            }
                            if (RegExp(r'[^a-zA-Z0-9_]').hasMatch(value)) {
                              return 'Only letters, numbers, and _ are allowed';
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 28),

                  // Submit Button
                  GradientButton(
                    onPressed: _handleLogin,
                    isLoading: _isLoading,
                    text: 'Get Started',
                    icon: Icons.arrow_forward_rounded,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
