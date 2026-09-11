import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// ignore: depend_on_referenced_packages
import 'package:zego_uikit/zego_uikit.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';
import '../constants/app_colors.dart';
import '../models/user_model.dart';
import '../services/call_invitation_service.dart';
import '../widgets/glass_card.dart';
import 'login_screen.dart';

class HomeScreen extends StatefulWidget {
  final UserModel user;

  const HomeScreen({super.key, required this.user});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  final _targetUserIdController = TextEditingController();
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

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
    _targetUserIdController.addListener(() {
      setState(() {});
    });

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.85, end: 1.25).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _targetUserIdController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _pasteTargetUserId() async {
    final data = await Clipboard.getData('text/plain');
    if (data?.text != null && data!.text!.trim().isNotEmpty) {
      final sanitized = data.text!.trim().replaceAll(RegExp(r'[^a-zA-Z0-9_]'), '');
      setState(() {
        _targetUserIdController.text = sanitized;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppColors.surfaceElevated,
            duration: const Duration(seconds: 1),
            content: Text('Pasted User ID: $sanitized'),
          ),
        );
      }
    }
  }

  void _copyOwnUserId() {
    Clipboard.setData(ClipboardData(text: widget.user.id));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppColors.surfaceElevated,
        duration: const Duration(seconds: 2),
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: AppColors.callGreen, size: 18),
            const SizedBox(width: 8),
            Text('Copied your ID (${widget.user.id}) to clipboard!'),
          ],
        ),
      ),
    );
  }

  Future<bool> _validateCall(bool isVideo) async {
    final targetId = _targetUserIdController.text.trim();
    if (targetId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: AppColors.callRed,
          content: Text('Please enter the target User ID to call.'),
        ),
      );
      return false;
    }

    if (targetId == widget.user.id) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: AppColors.callRed,
          content: Text('You cannot call your own User ID.'),
        ),
      );
      return false;
    }

    return true;
  }

  void _onCallResult(String code, String message, List<String> errorInvitees) {
    if (errorInvitees.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors.callRed,
          content: Text('User ${errorInvitees.join(", ")} is currently unavailable.'),
        ),
      );
    }
  }

  Future<void> _handleLogout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Switch Caller Profile', style: TextStyle(color: Colors.white)),
        content: const Text(
          'Do you want to sign out of this device?',
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
            child: const Text('Sign Out', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await CallInvitationService.instance.uninitCallInvitation();
      await UserModel.clear();
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final avatarIcon = _avatars[
      widget.user.avatarIndex.clamp(0, _avatars.length - 1)
    ];
    final targetId = _targetUserIdController.text.trim();
    final inviteesList = targetId.isNotEmpty
        ? [ZegoUIKitUser(id: targetId, name: targetId)]
        : <ZegoUIKitUser>[];

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Top Bar: Branding & Profile with Dynamic Character Adaptation
              LayoutBuilder(
                builder: (context, constraints) {
                  final totalWidth = constraints.maxWidth;
                  // Dynamically allocate characters based on available container width:
                  final int maxNameChars = totalWidth <= 300
                      ? 4
                      : (totalWidth <= 340
                          ? 6
                          : (totalWidth <= 380
                              ? 9
                              : (totalWidth <= 420 ? 12 : 16)));

                  final displayName = widget.user.name.length > maxNameChars
                      ? '${widget.user.name.substring(0, maxNameChars)}…'
                      : widget.user.name;

                  return Row(
                    children: [
                      // App Branding
                      Expanded(
                        child: Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
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
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Text(
                                    'Sauvaad',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: AppColors.textPrimary,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 0.3,
                                    ),
                                  ),
                                  Text(
                                    'Audio & Video Calls',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: AppColors.cyan.withValues(alpha: 0.85),
                                      fontSize: 11,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(width: 8),

                      // User Profile Pill (Tap to switch user / logout) with auto-scaling
                      GestureDetector(
                        onTap: _handleLogout,
                        child: Container(
                          constraints: BoxConstraints(
                            maxWidth: totalWidth * 0.44,
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceElevated,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: AppColors.surfaceBorder),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              CircleAvatar(
                                radius: 11,
                                backgroundColor: AppColors.cyan.withValues(alpha: 0.2),
                                child: Icon(avatarIcon, size: 13, color: AppColors.cyan),
                              ),
                              const SizedBox(width: 5),
                              Flexible(
                                child: Text(
                                  displayName,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  softWrap: false,
                                  style: const TextStyle(
                                    color: AppColors.textPrimary,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 4),
                              const Icon(Icons.logout_rounded, size: 13, color: AppColors.textMuted),
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),

              const SizedBox(height: 20),

              // "Your Caller ID" Identity Card
              GlassCard(
                hasGlow: true,
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              ScaleTransition(
                                scale: _pulseAnimation,
                                child: Container(
                                  width: 9,
                                  height: 9,
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: AppColors.callGreen,
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppColors.callGreen,
                                        blurRadius: 8,
                                        spreadRadius: 1,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Flexible(
                                child: Text(
                                  'Online • Ready to Call',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: AppColors.callGreen,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.3,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        InkWell(
                          onTap: _copyOwnUserId,
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.cyan.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: AppColors.cyan.withValues(alpha: 0.4),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.copy_rounded, color: AppColors.cyan, size: 13),
                                const SizedBox(width: 4),
                                Text(
                                  MediaQuery.sizeOf(context).width <= 340 ? 'Copy' : 'Copy ID',
                                  style: const TextStyle(
                                    color: AppColors.cyan,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Your Caller ID',
                      style: TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: AppColors.backgroundAlt,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.surfaceBorder),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              widget.user.id,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: AppColors.textPrimary,
                                fontFamily: 'monospace',
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.8,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Icon(
                            Icons.fingerprint_rounded,
                            color: AppColors.cyan,
                            size: 20,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Share this ID with friends so they can call you directly from their device.',
                      style: TextStyle(
                        color: AppColors.textSecondary.withValues(alpha: 0.85),
                        fontSize: 11.5,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // "Call a Contact" Calling Action Card
              GlassCard(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Make a Call',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Enter the target User ID to send an instant ringing call request.',
                      style: TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Target User ID Input
                    TextFormField(
                      controller: _targetUserIdController,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontFamily: 'monospace',
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                      decoration: InputDecoration(
                        hintText: 'e.g. user_5432',
                        hintStyle: const TextStyle(color: AppColors.textMuted),
                        prefixIcon: const Icon(
                          Icons.perm_identity_rounded,
                          color: AppColors.cyan,
                        ),
                        suffixIcon: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (_targetUserIdController.text.isNotEmpty)
                              IconButton(
                                icon: const Icon(Icons.clear_rounded, color: AppColors.textMuted, size: 18),
                                onPressed: () => setState(() => _targetUserIdController.clear()),
                              ),
                            IconButton(
                              icon: const Icon(Icons.paste_rounded, color: AppColors.cyan, size: 18),
                              tooltip: 'Paste from clipboard',
                              onPressed: _pasteTargetUserId,
                            ),
                          ],
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
                          borderSide: const BorderSide(color: AppColors.cyan, width: 1.5),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Call Invitation Buttons (Video & Voice)
                    const Text(
                      'Select Call Type',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 10),

                    Row(
                      children: [
                        // Video Call Button
                        Expanded(
                          child: Container(
                            height: 62,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(14),
                              gradient: AppColors.accentGradient,
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.cyan.withValues(alpha: 0.3),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: ZegoSendCallInvitationButton(
                              isVideoCall: true,
                              resourceID: 'sauvaad_call',
                              invitees: inviteesList,
                              icon: ButtonIcon(
                                icon: const Icon(Icons.videocam_rounded, color: Colors.black, size: 20),
                              ),
                              text: MediaQuery.sizeOf(context).width <= 330 ? 'Video' : 'Video Call',
                              textStyle: const TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                              iconSize: const Size(20, 20),
                              buttonSize: const Size(double.infinity, 62),
                              borderRadius: 14,
                              clickableBackgroundColor: Colors.transparent,
                              unclickableBackgroundColor: Colors.transparent,
                              onWillPressed: () => _validateCall(true),
                              onPressed: _onCallResult,
                            ),
                          ),
                        ),

                        const SizedBox(width: 12),

                        // Voice Call Button
                        Expanded(
                          child: Container(
                            height: 62,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(14),
                              gradient: AppColors.primaryGradient,
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.purple.withValues(alpha: 0.35),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: ZegoSendCallInvitationButton(
                              isVideoCall: false,
                              resourceID: 'sauvaad_call',
                              invitees: inviteesList,
                              icon: ButtonIcon(
                                icon: const Icon(Icons.call_rounded, color: Colors.white, size: 20),
                              ),
                              text: MediaQuery.sizeOf(context).width <= 330 ? 'Voice' : 'Voice Call',
                              textStyle: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                              iconSize: const Size(20, 20),
                              buttonSize: const Size(double.infinity, 62),
                              borderRadius: 14,
                              clickableBackgroundColor: Colors.transparent,
                              unclickableBackgroundColor: Colors.transparent,
                              onWillPressed: () => _validateCall(false),
                              onPressed: _onCallResult,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Calling Features Guide
              const Text(
                'How It Works',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.4,
                ),
              ),
              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: _buildInfoCard(
                      icon: Icons.notifications_active_rounded,
                      title: 'Instant Ringing',
                      subtitle: 'Incoming call dialog alerts the user directly',
                      color: AppColors.cyan,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildInfoCard(
                      icon: Icons.lock_rounded,
                      title: 'Direct & Private',
                      subtitle: 'Encrypted 1-to-1 WebRTC connection',
                      color: AppColors.violet,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildInfoCard(
                      icon: Icons.high_quality_rounded,
                      title: 'HD Quality',
                      subtitle: '1080p video with low-latency audio',
                      color: AppColors.indigo,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildInfoCard(
                      icon: Icons.picture_in_picture_alt_rounded,
                      title: 'Background PiP',
                      subtitle: 'Multitask smoothly while in a call',
                      color: AppColors.magenta,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard({
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
              color: color.withValues(alpha: 0.15),
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
