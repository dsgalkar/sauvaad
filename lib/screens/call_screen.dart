import 'package:flutter/material.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';
import '../constants/app_colors.dart';
import '../constants/zego_config.dart';

class CallScreen extends StatelessWidget {
  final String callID;
  final String userID;
  final String userName;
  final bool isVideoCall;
  final bool isGroupCall;

  const CallScreen({
    super.key,
    required this.callID,
    required this.userID,
    required this.userName,
    this.isVideoCall = true,
    this.isGroupCall = false,
  });

  ZegoUIKitPrebuiltCallConfig _getCallConfig() {
    late ZegoUIKitPrebuiltCallConfig config;

    if (isGroupCall) {
      config = isVideoCall
          ? ZegoUIKitPrebuiltCallConfig.groupVideoCall()
          : ZegoUIKitPrebuiltCallConfig.groupVoiceCall();
    } else {
      config = isVideoCall
          ? ZegoUIKitPrebuiltCallConfig.oneOnOneVideoCall()
          : ZegoUIKitPrebuiltCallConfig.oneOnOneVoiceCall();
    }

    // Configure duration timer
    config.duration.isVisible = true;

    // Configure top menu bar
    config.topMenuBar.isVisible = true;
    config.topMenuBar.buttons = [
      ZegoCallMenuBarButtonName.minimizingButton,
      ZegoCallMenuBarButtonName.showMemberListButton,
    ];

    return config;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: ZegoUIKitPrebuiltCall(
          appID: ZegoConfig.appId,
          appSign: ZegoConfig.appSign,
          userID: userID,
          userName: userName,
          callID: callID,
          config: _getCallConfig(),
          events: ZegoUIKitPrebuiltCallEvents(
            onCallEnd: (event, defaultAction) {
              defaultAction.call();
              Navigator.of(context).pop();
            },
          ),
        ),
      ),
    );
  }
}
