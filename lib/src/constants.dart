import 'package:url_launcher/url_launcher.dart';

enum ExternalMessagingApp {
  whatsApp,
  telegram,
  viber,
}

class AppFallbackInfo {
  const AppFallbackInfo({
    required this.androidStoreUrl,
    required this.iosStoreUrl,
  });

  final String androidStoreUrl;
  final String iosStoreUrl;
}

const LaunchMode kBrowserLaunchMode = LaunchMode.externalApplication;
const LaunchMode kFallbackLaunchMode = LaunchMode.externalApplication;

const Map<ExternalMessagingApp, AppFallbackInfo> kAppFallbacks =
    <ExternalMessagingApp, AppFallbackInfo>{
  ExternalMessagingApp.whatsApp: AppFallbackInfo(
    androidStoreUrl:
        'https://play.google.com/store/apps/details?id=com.whatsapp',
    iosStoreUrl: 'https://apps.apple.com/us/app/whatsapp-messenger/id310633997',
  ),
  ExternalMessagingApp.telegram: AppFallbackInfo(
    androidStoreUrl:
        'https://play.google.com/store/apps/details?id=org.telegram.messenger',
    iosStoreUrl: 'https://apps.apple.com/us/app/telegram-messenger/id686449807',
  ),
  ExternalMessagingApp.viber: AppFallbackInfo(
    androidStoreUrl:
        'https://play.google.com/store/apps/details?id=com.viber.voip',
    iosStoreUrl:
        'https://apps.apple.com/us/app/rakuten-viber-messenger/id382617920',
  ),
};
