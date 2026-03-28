import 'package:url_launcher/url_launcher.dart';

import 'src/constants.dart';
import 'src/launcher_service.dart';
import 'src/models.dart';
import 'src/uri_builders.dart';

export 'src/exceptions.dart';
export 'src/models.dart';

final LauncherService _launcherService = LauncherService();

/// Developer-friendly helpers around Flutter's `url_launcher` package.
///
/// The API is intentionally static so it can be used from any layer of an
/// application without additional setup.
class UrlLauncherUtils {
  UrlLauncherUtils._();

  /// Opens the platform dialer with [phoneNumber].
  ///
  /// The phone number may contain spaces, parentheses, dashes, and an optional
  /// leading `+`. It is normalized before launch.
  ///
  /// Example:
  /// ```dart
  /// await UrlLauncherUtils.launchPhoneCall(phoneNumber: '+1 555 123 4567');
  /// ```
  static Future<LaunchResult> launchPhoneCall({
    required String phoneNumber,
  }) {
    final uri = UriBuilders.phoneCall(phoneNumber);
    return _launcherService.launch(
      uri,
      mode: LaunchMode.externalNonBrowserApplication,
    );
  }

  /// Opens the SMS composer for [phoneNumber].
  ///
  /// When [message] is provided, it is prefilled in the SMS body.
  static Future<LaunchResult> sendSms({
    required String phoneNumber,
    String? message,
  }) {
    final uri = UriBuilders.sms(phoneNumber, message: message);
    return _launcherService.launch(
      uri,
      mode: LaunchMode.externalNonBrowserApplication,
    );
  }

  /// Opens the default email client using a `mailto:` URI.
  ///
  /// [recipients] must not be empty. Optional [cc], [bcc], [subject], and
  /// [body] values are encoded safely for `mailto:`.
  static Future<LaunchResult> sendEmail({
    required List<String> recipients,
    List<String> cc = const [],
    List<String> bcc = const [],
    String? subject,
    String? body,
  }) {
    final uri = UriBuilders.email(
      recipients: recipients,
      cc: cc,
      bcc: bcc,
      subject: subject,
      body: body,
    );
    return _launcherService.launch(
      uri,
      mode: LaunchMode.externalNonBrowserApplication,
    );
  }

  /// Opens a WhatsApp chat using a normalized international [phoneNumber].
  ///
  /// If [message] is provided, it is prefilled in the chat composer.
  ///
  /// When the primary launch fails on Android or iOS, the helper attempts to
  /// open the WhatsApp store page.
  static Future<LaunchResult> openWhatsApp({
    required String phoneNumber,
    String? message,
  }) {
    final uri = UriBuilders.whatsApp(phoneNumber, message: message);
    return _launcherService.launch(
      uri,
      mode: LaunchMode.externalNonBrowserApplication,
      fallbackApp: ExternalMessagingApp.whatsApp,
    );
  }

  /// Opens a Telegram chat using either [username] or [phoneNumber].
  ///
  /// Exactly one of [username] or [phoneNumber] must be provided.
  ///
  /// When the primary launch fails on Android or iOS, the helper attempts to
  /// open the Telegram store page.
  static Future<LaunchResult> openTelegram({
    String? username,
    String? phoneNumber,
  }) {
    final uri = UriBuilders.telegram(
      username: username,
      phoneNumber: phoneNumber,
    );
    return _launcherService.launch(
      uri,
      mode: LaunchMode.externalNonBrowserApplication,
      fallbackApp: ExternalMessagingApp.telegram,
    );
  }

  /// Opens a Viber chat using a best-effort consumer deep link.
  ///
  /// Viber deep linking for consumer chats is less standardized than WhatsApp
  /// and Telegram. When the primary launch fails on Android or iOS, the helper
  /// attempts to open the Viber store page.
  static Future<LaunchResult> openViber({
    required String phoneNumber,
  }) {
    final uri = UriBuilders.viber(phoneNumber);
    return _launcherService.launch(
      uri,
      mode: LaunchMode.externalNonBrowserApplication,
      fallbackApp: ExternalMessagingApp.viber,
    );
  }

  /// Opens a map location using Google Maps universal URLs.
  ///
  /// Use [MapLocation.query] for text-based destinations or
  /// [MapLocation.coordinates] for latitude/longitude.
  static Future<LaunchResult> openMapLocation({
    required MapLocation target,
  }) {
    final uri = UriBuilders.mapLocation(target);
    return _launcherService.launch(
      uri,
      mode: LaunchMode.externalApplication,
    );
  }

  /// Opens map directions from [origin] to [destination].
  ///
  /// Both arguments can be query-based or coordinate-based.
  static Future<LaunchResult> openMapDirections({
    required MapLocation origin,
    required MapLocation destination,
  }) {
    final uri = UriBuilders.mapDirections(
      origin: origin,
      destination: destination,
    );
    return _launcherService.launch(
      uri,
      mode: LaunchMode.externalApplication,
    );
  }

  /// Opens an HTTP or HTTPS URL in the external browser.
  static Future<LaunchResult> openUrl({
    required Uri url,
  }) {
    final uri = UriBuilders.web(url);
    return _launcherService.launch(
      uri,
      mode: kBrowserLaunchMode,
    );
  }
}
