import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher_utils/src/constants.dart';
import 'package:url_launcher_utils/src/launcher_service.dart';
import 'package:url_launcher_utils/src/models.dart';
import 'package:url_launcher_utils/src/platform_utils.dart';

void main() {
  final primaryUri = Uri.parse('https://wa.me/213555123456');
  final fallbackUri = Uri.parse(
    'https://play.google.com/store/apps/details?id=com.whatsapp',
  );

  group('LauncherService', () {
    test('returns launchedPrimary when the first launch succeeds', () async {
      final adapter = FakeUrlLauncherAdapter(
        handler: (_, __) async => true,
      );
      final service = LauncherService(
        adapter: adapter,
        platformInfo: const FakePlatformInfo(),
      );

      final result = await service.launch(primaryUri);

      expect(result.status, LaunchStatus.launchedPrimary);
      expect(result.requestedUri, primaryUri);
      expect(result.fallbackUri, isNull);
      expect(adapter.calls, hasLength(1));
      expect(adapter.calls.single.url, primaryUri);
    });

    test('falls back to the Android store when launchUrl returns false',
        () async {
      final adapter = FakeUrlLauncherAdapter(
        handler: (Uri url, LaunchMode mode) async => url == fallbackUri,
      );
      final service = LauncherService(
        adapter: adapter,
        platformInfo: const FakePlatformInfo(isAndroid: true),
      );

      final result = await service.launch(
        primaryUri,
        fallbackApp: ExternalMessagingApp.whatsApp,
      );

      expect(result.status, LaunchStatus.launchedFallback);
      expect(result.requestedUri, primaryUri);
      expect(result.fallbackUri, fallbackUri);
      expect(adapter.calls, hasLength(2));
      expect(adapter.calls.first.url, primaryUri);
      expect(adapter.calls.last.url, fallbackUri);
      expect(adapter.calls.last.mode, LaunchMode.externalApplication);
    });

    test('falls back after a PlatformException on iOS', () async {
      final adapter = FakeUrlLauncherAdapter(
        handler: (Uri url, LaunchMode mode) async {
          if (url == primaryUri) {
            throw PlatformException(code: 'unavailable');
          }
          return true;
        },
      );
      final service = LauncherService(
        adapter: adapter,
        platformInfo: const FakePlatformInfo(isIOS: true),
      );

      final result = await service.launch(
        primaryUri,
        fallbackApp: ExternalMessagingApp.whatsApp,
      );

      expect(result.status, LaunchStatus.launchedFallback);
      expect(result.requestedUri, primaryUri);
      expect(
        result.fallbackUri,
        Uri.parse(
            'https://apps.apple.com/us/app/whatsapp-messenger/id310633997'),
      );
      expect(result.error, isA<PlatformException>());
      expect(adapter.calls, hasLength(2));
    });

    test('returns failed for unexpected exceptions without fallback', () async {
      final adapter = FakeUrlLauncherAdapter(
        handler: (_, __) async => throw StateError('boom'),
      );
      final service = LauncherService(
        adapter: adapter,
        platformInfo: const FakePlatformInfo(),
      );

      final result = await service.launch(primaryUri);

      expect(result.status, LaunchStatus.failed);
      expect(result.fallbackUri, isNull);
      expect(result.error, isA<StateError>());
      expect(adapter.calls, hasLength(1));
    });

    test('returns failed when the fallback store page cannot be opened',
        () async {
      final adapter = FakeUrlLauncherAdapter(
        handler: (_, __) async => false,
      );
      final service = LauncherService(
        adapter: adapter,
        platformInfo: const FakePlatformInfo(isAndroid: true),
      );

      final result = await service.launch(
        primaryUri,
        fallbackApp: ExternalMessagingApp.whatsApp,
      );

      expect(result.status, LaunchStatus.failed);
      expect(result.requestedUri, primaryUri);
      expect(result.fallbackUri, fallbackUri);
      expect(adapter.calls, hasLength(2));
    });
  });
}

class FakeUrlLauncherAdapter implements UrlLauncherAdapter {
  FakeUrlLauncherAdapter({
    required this.handler,
  });

  final Future<bool> Function(Uri url, LaunchMode mode) handler;
  final List<LaunchCall> calls = <LaunchCall>[];

  @override
  Future<bool> launch(
    Uri url, {
    required LaunchMode mode,
  }) {
    calls.add(LaunchCall(url: url, mode: mode));
    return handler(url, mode);
  }
}

class LaunchCall {
  const LaunchCall({
    required this.url,
    required this.mode,
  });

  final Uri url;
  final LaunchMode mode;
}

class FakePlatformInfo implements PlatformInfo {
  const FakePlatformInfo({
    this.isAndroid = false,
    this.isIOS = false,
  });

  @override
  final bool isAndroid;

  @override
  final bool isIOS;

  @override
  bool get isMobile => isAndroid || isIOS;
}
