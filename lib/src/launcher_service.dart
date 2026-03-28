import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import 'constants.dart';
import 'models.dart';
import 'platform_utils.dart';

abstract interface class UrlLauncherAdapter {
  Future<bool> launch(
    Uri url, {
    required LaunchMode mode,
  });
}

class UrlLauncherPluginAdapter implements UrlLauncherAdapter {
  const UrlLauncherPluginAdapter();

  @override
  Future<bool> launch(
    Uri url, {
    required LaunchMode mode,
  }) {
    return launchUrl(url, mode: mode);
  }
}

class LauncherService {
  LauncherService({
    UrlLauncherAdapter? adapter,
    PlatformInfo? platformInfo,
  })  : _adapter = adapter ?? const UrlLauncherPluginAdapter(),
        _platformInfo = platformInfo ?? const DefaultPlatformInfo();

  final UrlLauncherAdapter _adapter;
  final PlatformInfo _platformInfo;

  Future<LaunchResult> launch(
    Uri uri, {
    LaunchMode mode = LaunchMode.platformDefault,
    ExternalMessagingApp? fallbackApp,
  }) async {
    try {
      final launched = await _adapter.launch(uri, mode: mode);
      if (launched) {
        return LaunchResult.launchedPrimary(requestedUri: uri);
      }

      _debugCouldNotLaunch(uri);
      return _launchFallback(
        requestedUri: uri,
        fallbackApp: fallbackApp,
      );
    } on PlatformException catch (error) {
      _debugCouldNotLaunch(uri);
      return _launchFallback(
        requestedUri: uri,
        fallbackApp: fallbackApp,
        error: error,
      );
    } catch (error, stackTrace) {
      if (kDebugMode) {
        debugPrint('Unexpected error launching $uri: $error');
        debugPrintStack(stackTrace: stackTrace);
      }

      return LaunchResult.failed(
        requestedUri: uri,
        error: error,
      );
    }
  }

  Future<LaunchResult> _launchFallback({
    required Uri requestedUri,
    required ExternalMessagingApp? fallbackApp,
    Object? error,
  }) async {
    final fallbackUri = _storeUriFor(fallbackApp);
    if (fallbackUri == null) {
      return LaunchResult.failed(
        requestedUri: requestedUri,
        error: error,
      );
    }

    try {
      final launchedFallback = await _adapter.launch(
        fallbackUri,
        mode: kFallbackLaunchMode,
      );

      if (launchedFallback) {
        return LaunchResult.launchedFallback(
          requestedUri: requestedUri,
          fallbackUri: fallbackUri,
          error: error,
        );
      }

      if (kDebugMode) {
        debugPrint('Could not launch $fallbackUri');
      }
    } on PlatformException catch (fallbackError) {
      if (kDebugMode) {
        debugPrint('Could not launch $fallbackUri');
      }

      return LaunchResult.failed(
        requestedUri: requestedUri,
        fallbackUri: fallbackUri,
        error: error ?? fallbackError,
      );
    } catch (fallbackError, stackTrace) {
      if (kDebugMode) {
        debugPrint('Unexpected error launching $fallbackUri: $fallbackError');
        debugPrintStack(stackTrace: stackTrace);
      }

      return LaunchResult.failed(
        requestedUri: requestedUri,
        fallbackUri: fallbackUri,
        error: error ?? fallbackError,
      );
    }

    return LaunchResult.failed(
      requestedUri: requestedUri,
      fallbackUri: fallbackUri,
      error: error,
    );
  }

  Uri? _storeUriFor(ExternalMessagingApp? fallbackApp) {
    if (fallbackApp == null || !_platformInfo.isMobile) {
      return null;
    }

    final fallbackInfo = kAppFallbacks[fallbackApp];
    if (fallbackInfo == null) {
      return null;
    }

    if (_platformInfo.isAndroid) {
      return Uri.parse(fallbackInfo.androidStoreUrl);
    }

    if (_platformInfo.isIOS) {
      return Uri.parse(fallbackInfo.iosStoreUrl);
    }

    return null;
  }

  void _debugCouldNotLaunch(Uri uri) {
    if (kDebugMode) {
      debugPrint('Could not launch $uri');
    }
  }
}
