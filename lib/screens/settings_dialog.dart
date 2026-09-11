import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/zego_config.dart';
import '../widgets/gradient_button.dart';

class SettingsDialog extends StatefulWidget {
  const SettingsDialog({super.key});

  @override
  State<SettingsDialog> createState() => _SettingsDialogState();
}

class _SettingsDialogState extends State<SettingsDialog> {
  late TextEditingController _appIdController;
  late TextEditingController _appSignController;
  final _formKey = GlobalKey<FormState>();
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _appIdController = TextEditingController(text: ZegoConfig.appId.toString());
    _appSignController = TextEditingController(text: ZegoConfig.appSign);
  }

  @override
  void dispose() {
    _appIdController.dispose();
    _appSignController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);
    final appId = int.parse(_appIdController.text.trim());
    final appSign = _appSignController.text.trim();

    await ZegoConfig.saveCredentials(appId, appSign);

    if (!mounted) return;
    setState(() => _isSaving = false);
    Navigator.of(context).pop(true);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        backgroundColor: AppColors.callGreen,
        content: Text('ZEGOCLOUD credentials updated successfully!'),
      ),
    );
  }

  Future<void> _handleReset() async {
    await ZegoConfig.resetToDefault();
    setState(() {
      _appIdController.text = ZegoConfig.defaultAppID.toString();
      _appSignController.text = ZegoConfig.defaultAppSign;
    });

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        backgroundColor: AppColors.surfaceElevated,
        content: Text('Reset to demo placeholder credentials.'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isCustom = ZegoConfig.isCustomConfigured;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 440),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.surfaceBorder, width: 1.2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.5),
              blurRadius: 32,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(22),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Dialog Header
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.cyan.withValues(alpha: 0.12),
                      ),
                      child: const Icon(
                        Icons.settings_suggest_rounded,
                        color: AppColors.cyan,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'ZEGOCLOUD Settings',
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Configure AppID & AppSign',
                            style: TextStyle(
                              color: AppColors.textMuted,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, color: AppColors.textMuted),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Status Banner
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isCustom
                        ? AppColors.callGreen.withValues(alpha: 0.12)
                        : AppColors.warning.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isCustom
                          ? AppColors.callGreen.withValues(alpha: 0.4)
                          : AppColors.warning.withValues(alpha: 0.4),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        isCustom
                            ? Icons.verified_rounded
                            : Icons.info_outline_rounded,
                        color: isCustom ? AppColors.callGreen : AppColors.warning,
                        size: 20,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          isCustom
                              ? 'Active: Custom ZEGOCLOUD credentials set.'
                              : 'Notice: Using demo placeholders. Get live keys at console.zegocloud.com',
                          style: TextStyle(
                            color: isCustom ? AppColors.callGreen : AppColors.warning,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // AppID Field
                const Text(
                  'ZEGOCLOUD AppID (Integer)',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _appIdController,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontFamily: 'monospace',
                  ),
                  decoration: InputDecoration(
                    hintText: 'e.g. 192837465',
                    hintStyle: const TextStyle(color: AppColors.textMuted),
                    filled: true,
                    fillColor: AppColors.backgroundAlt,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.surfaceBorder),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.surfaceBorder),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.cyan),
                    ),
                  ),
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return 'AppID is required';
                    }
                    if (int.tryParse(val.trim()) == null) {
                      return 'AppID must be a valid number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // AppSign Field
                const Text(
                  'ZEGOCLOUD AppSign (64-char Hex String)',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _appSignController,
                  maxLines: 2,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 12,
                    fontFamily: 'monospace',
                  ),
                  decoration: InputDecoration(
                    hintText: 'Paste 64-character AppSign from Zego Console',
                    hintStyle: const TextStyle(color: AppColors.textMuted),
                    filled: true,
                    fillColor: AppColors.backgroundAlt,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.surfaceBorder),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.surfaceBorder),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.violet),
                    ),
                  ),
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return 'AppSign is required';
                    }
                    if (val.trim().length < 32) {
                      return 'AppSign is usually 64 hex characters';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),

                // Actions
                GradientButton(
                  onPressed: _handleSave,
                  isLoading: _isSaving,
                  text: 'Save Credentials',
                  icon: Icons.check_circle_outline_rounded,
                ),
                const SizedBox(height: 10),
                Center(
                  child: TextButton.icon(
                    onPressed: _handleReset,
                    icon: const Icon(Icons.refresh_rounded, size: 16, color: AppColors.textMuted),
                    label: const Text(
                      'Reset to Demo Placeholder',
                      style: TextStyle(color: AppColors.textMuted, fontSize: 13),
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
