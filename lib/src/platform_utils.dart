import 'package:flutter/foundation.dart';

abstract interface class PlatformInfo {
  bool get isAndroid;
  bool get isIOS;
  bool get isMobile;
}

class DefaultPlatformInfo implements PlatformInfo {
  const DefaultPlatformInfo();

  @override
  bool get isAndroid =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.android;

  @override
  bool get isIOS => !kIsWeb && defaultTargetPlatform == TargetPlatform.iOS;

  @override
  bool get isMobile => isAndroid || isIOS;
}
