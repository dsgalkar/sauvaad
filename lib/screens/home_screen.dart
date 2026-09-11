import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import '../constants/app_colors.dart';
import '../constants/zego_config.dart';
import '../models/user_model.dart';
import '../widgets/glass_card.dart';
import '../widgets/gradient_button.dart';
import 'call_screen.dart';
import 'login_screen.dart';
import 'settings_dialog.dart';

class HomeScreen extends StatefulWidget {
  final UserModel user;

  const HomeScreen({super.key, required this.user});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _callIdController = TextEditingController();
  bool _isVideoCall = true;
  bool _isGroupCall = false;
  bool _isJoining = false;

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
    _generateRandomCallId();
  }

  void _generateRandomCallId() {
    final random = Random();
    final number = 1000 + random.nextInt(9000);
    setState(() {
      _callIdController.text = 'room_$number';
    });
  }

  @override
  void dispose() {
    _callIdController.dispose();
    super.dispose();
  }

  Future<void> _pasteFromClipboard() async {
    final data = await Clipboard.getData('text/plain');
    if (data?.text != null && data!.text!.trim().isNotEmpty) {
      setState(() {
        _callIdController.text = data.text!.trim().replaceAll(RegExp(r'[^a-zA-Z0-9_]'), '');
      });
    }
  }

  Future<void> _startOrJoinCall() async {
    final callId = _callIdController.text.trim();
    if (callId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: AppColors.callRed,
          content: Text('Please enter or generate a Call ID'),
        ),
      );
      return;
    }

    setState(() => _isJoining = true);

    // Request necessary runtime permissions
    final micStatus = await Permission.microphone.request();
    if (_isVideoCall) {
      final cameraStatus = await Permission.camera.request();
      if (cameraStatus.isPermanentlyDenied || micStatus.isPermanentlyDenied) {
        setState(() => _isJoining = false);
        _showPermissionDialog();
        return;
      }
    } else {
      if (micStatus.isPermanentlyDenied) {
        setState(() => _isJoining = false);
        _showPermissionDialog();
        return;
      }
    }

    setState(() => _isJoining = false);

    if (!mounted) return;

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CallScreen(
          callID: callId,
          userID: widget.user.id,
          userName: widget.user.name,
          isVideoCall: _isVideoCall,
          isGroupCall: _isGroupCall,
        ),
      ),
    );
  }

  void _showPermissionDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Permissions Required', style: TextStyle(color: Colors.white)),
        content: const Text(
          'Microphone and Camera permissions are needed to start calls. Please enable them in app settings.',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: AppColors.textMuted)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.cyan),
            onPressed: () {
              Navigator.pop(ctx);
              openAppSettings();
            },
            child: const Text('Open Settings', style: TextStyle(color: Colors.black)),
          ),
        ],
      ),
    );
  }

  Future<void> _openSettings() async {
    await showDialog(
      context: context,
      builder: (_) => const SettingsDialog(),
    );
    setState(() {}); // Refresh credential state
  }

  Future<void> _handleLogout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Switch User', style: TextStyle(color: Colors.white)),
        content: const Text(
          'Do you want to log out and change caller profile?',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel', style: TextStyle(color: AppColors.textMuted)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.callRed),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Log Out', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await UserModel.clear();
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isCustomConfig = ZegoConfig.isCustomConfigured;
    final avatarIcon = _avatars[
      widget.user.avatarIndex.clamp(0, _avatars.length - 1)
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Top Bar
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Brand Logo & Title
                  Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppColors.cyan.withValues(alpha: 0.5),
                            width: 1.2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.cyan.withValues(alpha: 0.2),
                              blurRadius: 10,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.asset(
                            'assets/images/logo.png',
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Sauvaad',
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 19,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.4,
                            ),
                          ),
                          Text(
                            'Audio & Video Calling',
                            style: TextStyle(
                              color: AppColors.cyan.withValues(alpha: 0.85),
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  // Actions: Settings & Profile
                  Row(
                    children: [
                      // Settings Button with Config indicator
                      IconButton(
                        onPressed: _openSettings,
                        tooltip: 'ZEGOCLOUD Settings',
                        icon: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppColors.surfaceElevated,
                                border: Border.all(
                                  color: AppColors.surfaceBorder,
                                ),
                              ),
                              child: const Icon(
                                Icons.tune_rounded,
                                color: AppColors.textSecondary,
                                size: 20,
                              ),
                            ),
                            Positioned(
                              top: -2,
                              right: -2,
                              child: Container(
                                width: 10,
                                height: 10,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: isCustomConfig
                                      ? AppColors.callGreen
                                      : AppColors.warning,
                                  border: Border.all(
                                    color: AppColors.background,
                                    width: 1.5,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 6),
                      // User profile button
                      GestureDetector(
                        onTap: _handleLogout,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceElevated,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: AppColors.surfaceBorder,
                            ),
                          ),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 12,
                                backgroundColor: AppColors.cyan.withValues(alpha: 0.2),
                                child: Icon(
                                  avatarIcon,
                                  size: 14,
                                  color: AppColors.cyan,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                widget.user.name,
                                style: const TextStyle(
                                  color: AppColors.textPrimary,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // ZegoCloud Notice banner (if default keys are active)
              if (!isCustomConfig)
                Container(
                  margin: const EdgeInsets.only(bottom: 20),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceElevated.withValues(alpha: 0.8),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppColors.cyan.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.cyan.withValues(alpha: 0.12),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.info_outline_rounded,
                          color: AppColors.cyan,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Live Calling Setup',
                              style: TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Running with demo keys. Set your free AppID & AppSign from ZEGOCLOUD Console to connect real devices.',
                              style: TextStyle(
                                color: AppColors.textSecondary.withValues(alpha: 0.85),
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                      TextButton(
                        onPressed: _openSettings,
                        child: const Text(
                          'Configure',
                          style: TextStyle(
                            color: AppColors.cyan,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              // Main Call Configuration Card
              GlassCard(
                hasGlow: true,
                padding: const EdgeInsets.all(22),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header inside card
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Enter Call Room',
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Row(
                          children: [
                            IconButton(
                              onPressed: _pasteFromClipboard,
                              tooltip: 'Paste Call ID',
                              icon: const Icon(
                                Icons.content_paste_rounded,
                                color: AppColors.cyan,
                                size: 18,
                              ),
                              constraints: const BoxConstraints(),
                              padding: const EdgeInsets.all(6),
                            ),
                            const SizedBox(width: 6),
                            IconButton(
                              onPressed: _generateRandomCallId,
                              tooltip: 'Generate Random ID',
                              icon: const Icon(
                                Icons.refresh_rounded,
                                color: AppColors.violet,
                                size: 18,
                              ),
                              constraints: const BoxConstraints(),
                              padding: const EdgeInsets.all(6),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    // Call ID Text Input
                    TextFormField(
                      controller: _callIdController,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 16,
                        fontFamily: 'monospace',
                        fontWeight: FontWeight.w600,
                      ),
                      decoration: InputDecoration(
                        hintText: 'e.g. room_1234',
                        hintStyle: const TextStyle(color: AppColors.textMuted),
                        prefixIcon: const Icon(
                          Icons.meeting_room_rounded,
                          color: AppColors.cyan,
                        ),
                        suffixIcon: IconButton(
                          icon: const Icon(
                            Icons.copy_rounded,
                            color: AppColors.textMuted,
                            size: 18,
                          ),
                          onPressed: () {
                            if (_callIdController.text.isNotEmpty) {
                              Clipboard.setData(
                                ClipboardData(text: _callIdController.text),
                              );
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  duration: Duration(seconds: 1),
                                  backgroundColor: AppColors.surfaceElevated,
                                  content: Text('Call ID copied to clipboard!'),
                                ),
                              );
                            }
                          },
                        ),
                        filled: true,
                        fillColor: AppColors.backgroundAlt,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(color: AppColors.surfaceBorder),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(color: AppColors.surfaceBorder),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(
                            color: AppColors.cyan,
                            width: 1.5,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 22),

                    // Call Mode Selector (Video Call vs Audio-only)
                    const Text(
                      'Select Call Mode',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        // Video Call Option
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => _isVideoCall = true),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(14),
                                gradient: _isVideoCall
                                    ? AppColors.accentGradient
                                    : null,
                                color: _isVideoCall
                                    ? null
                                    : AppColors.surfaceElevated,
                                border: Border.all(
                                  color: _isVideoCall
                                      ? Colors.transparent
                                      : AppColors.surfaceBorder,
                                ),
                                boxShadow: _isVideoCall
                                    ? [
                                        BoxShadow(
                                          color: AppColors.cyan.withValues(alpha: 0.3),
                                          blurRadius: 14,
                                          offset: const Offset(0, 4),
                                        ),
                                      ]
                                    : null,
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.videocam_rounded,
                                    color: _isVideoCall
                                        ? Colors.white
                                        : AppColors.textMuted,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Video Call',
                                    style: TextStyle(
                                      color: _isVideoCall
                                          ? Colors.white
                                          : AppColors.textSecondary,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        // Voice / Audio Call Option
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => _isVideoCall = false),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(14),
                                gradient: !_isVideoCall
                                    ? AppColors.primaryGradient
                                    : null,
                                color: !_isVideoCall
                                    ? null
                                    : AppColors.surfaceElevated,
                                border: Border.all(
                                  color: !_isVideoCall
                                      ? Colors.transparent
                                      : AppColors.surfaceBorder,
                                ),
                                boxShadow: !_isVideoCall
                                    ? [
                                        BoxShadow(
                                          color: AppColors.purple.withValues(alpha: 0.3),
                                          blurRadius: 14,
                                          offset: const Offset(0, 4),
                                        ),
                                      ]
                                    : null,
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.mic_rounded,
                                    color: !_isVideoCall
                                        ? Colors.white
                                        : AppColors.textMuted,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Voice Call',
                                    style: TextStyle(
                                      color: !_isVideoCall
                                          ? Colors.white
                                          : AppColors.textSecondary,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),

                    // Call Type: 1-on-1 vs Group Call Switch
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Call Layout',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Row(
                          children: [
                            ChoiceChip(
                              label: const Text('1-on-1'),
                              selected: !_isGroupCall,
                              onSelected: (val) => setState(() => _isGroupCall = false),
                              backgroundColor: AppColors.surfaceElevated,
                              selectedColor: AppColors.cyan.withValues(alpha: 0.25),
                              labelStyle: TextStyle(
                                color: !_isGroupCall
                                    ? AppColors.cyan
                                    : AppColors.textMuted,
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
                              ),
                              side: BorderSide(
                                color: !_isGroupCall
                                    ? AppColors.cyan
                                    : AppColors.surfaceBorder,
                              ),
                            ),
                            const SizedBox(width: 8),
                            ChoiceChip(
                              label: const Text('Group'),
                              selected: _isGroupCall,
                              onSelected: (val) => setState(() => _isGroupCall = true),
                              backgroundColor: AppColors.surfaceElevated,
                              selectedColor: AppColors.violet.withValues(alpha: 0.25),
                              labelStyle: TextStyle(
                                color: _isGroupCall
                                    ? AppColors.violet
                                    : AppColors.textMuted,
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
                              ),
                              side: BorderSide(
                                color: _isGroupCall
                                    ? AppColors.violet
                                    : AppColors.surfaceBorder,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Start/Join Call Button
                    GradientButton(
                      onPressed: _startOrJoinCall,
                      isLoading: _isJoining,
                      text: _isVideoCall ? 'Start Video Call' : 'Start Voice Call',
                      icon: _isVideoCall
                          ? Icons.videocam_rounded
                          : Icons.call_rounded,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Quick Feature Highlights
              const Text(
                'Key Features',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: _buildFeatureCard(
                      icon: Icons.high_quality_rounded,
                      title: 'Crystal Clear',
                      subtitle: 'Ultra-HD audio & 1080p video',
                      color: AppColors.cyan,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildFeatureCard(
                      icon: Icons.security_rounded,
                      title: 'Secure & Private',
                      subtitle: 'Encrypted WebRTC channels',
                      color: AppColors.violet,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildFeatureCard(
                      icon: Icons.groups_rounded,
                      title: 'Group Calling',
                      subtitle: 'Multi-party rooms supported',
                      color: AppColors.indigo,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildFeatureCard(
                      icon: Icons.picture_in_picture_alt_rounded,
                      title: 'PiP Overlay',
                      subtitle: 'Multitask while talking',
                      color: AppColors.magenta,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 28),

              // Caller ID info pill
              Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.surfaceBorder),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.fingerprint_rounded,
                        color: AppColors.cyan,
                        size: 16,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Your Caller ID: ${widget.user.id}',
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
  }) {
    return GlassCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 10),
          Text(
            title,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: const TextStyle(
              color: AppColors.textMuted,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}
