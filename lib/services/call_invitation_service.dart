import 'package:flutter/material.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';
import 'package:zego_uikit_signaling_plugin/zego_uikit_signaling_plugin.dart';
import '../constants/zego_config.dart';
import '../models/user_model.dart';

class CallInvitationService {
  static final CallInvitationService instance = CallInvitationService._internal();
  CallInvitationService._internal();

  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  /// Initialize ZEGOCLOUD Call Invitation Service for the logged in user
  Future<void> initCallInvitation(UserModel user) async {
    if (_isInitialized) {
      await uninitCallInvitation();
    }

    await ZegoUIKitPrebuiltCallInvitationService().init(
      appID: ZegoConfig.appId,
      appSign: ZegoConfig.appSign,
      userID: user.id,
      userName: user.name,
      plugins: [ZegoUIKitSignalingPlugin()],
      config: ZegoCallInvitationConfig(
        requiredInviter: ZegoCallRequiredInviterConfig(
          enabledOnOneOnOneCall: false,
          enabledOnGroupCall: false,
        ),
      ),
      events: ZegoUIKitPrebuiltCallEvents(
        onCallEnd: (ZegoCallEndEvent event, VoidCallback defaultAction) {
          debugPrint('Sauvaad call end event reason: ${event.reason}');
          // If the SDK triggered auto-abandon (e.g. inviter detection timeout), ignore it so the call stays connected!
          if (event.reason == ZegoCallEndReason.abandoned) {
            debugPrint('Prevented premature auto-abandon disconnect; keeping call connected.');
            return;
          }
          defaultAction.call();
        },
      ),
      requireConfig: (ZegoCallInvitationData data) {
        final config = (data.invitees.length > 1)
            ? (data.type == ZegoCallInvitationType.videoCall
                ? ZegoUIKitPrebuiltCallConfig.groupVideoCall()
                : ZegoUIKitPrebuiltCallConfig.groupVoiceCall())
            : (data.type == ZegoCallInvitationType.videoCall
                ? ZegoUIKitPrebuiltCallConfig.oneOnOneVideoCall()
                : ZegoUIKitPrebuiltCallConfig.oneOnOneVoiceCall());

        config.duration.isVisible = true;
        config.topMenuBar.isVisible = true;
        config.topMenuBar.buttons = [
          ZegoCallMenuBarButtonName.minimizingButton,
          ZegoCallMenuBarButtonName.showMemberListButton,
        ];

        // Disable automatic leave/abandon timeouts so the call STAYS connected until a user actually hangs up
        config.user.requiredUsers.enabled = false;
        config.noResponseEnd.enabled = false;

        return config;
      },
    );

    _isInitialized = true;
  }

  /// Uninitialize on logout
  Future<void> uninitCallInvitation() async {
    if (!_isInitialized) return;
    await ZegoUIKitPrebuiltCallInvitationService().uninit();
    _isInitialized = false;
  }
}
