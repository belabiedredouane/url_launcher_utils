import 'package:flutter_test/flutter_test.dart';
import 'package:url_launcher_utils/src/exceptions.dart';
import 'package:url_launcher_utils/src/models.dart';
import 'package:url_launcher_utils/src/uri_builders.dart';

void main() {
  group('UriBuilders', () {
    test('builds a tel URI with normalized digits', () {
      final uri = UriBuilders.phoneCall('+213 (555) 12-34-56');

      expect(uri.toString(), 'tel:+213555123456');
    });

    test('builds an sms URI with an encoded body', () {
      final uri = UriBuilders.sms(
        '+213 555 12 34 56',
        message: 'Hello from Flutter',
      );

      expect(
        uri.toString(),
        'sms:+213555123456?body=Hello+from+Flutter',
      );
    });

    test('builds a mailto URI with recipients and optional fields', () {
      final uri = UriBuilders.email(
        recipients: const <String>['hello@example.com'],
        cc: const <String>['team@example.com'],
        bcc: const <String>['hidden@example.com'],
        subject: 'Package feedback',
        body: 'This package works well.',
      );

      expect(
        uri.toString(),
        'mailto:hello@example.com?cc=team%40example.com&bcc=hidden%40example.com&subject=Package+feedback&body=This+package+works+well.',
      );
    });

    test('builds a WhatsApp URI with a normalized international number', () {
      final uri = UriBuilders.whatsApp(
        '+213 555 12 34 56',
        message: 'Hello',
      );

      expect(uri.toString(), 'https://wa.me/213555123456?text=Hello');
    });

    test('builds a Telegram URI from a username', () {
      final uri = UriBuilders.telegram(username: '@flutterdev');

      expect(uri.toString(), 'https://t.me/flutterdev');
    });

    test('builds a Telegram URI from a phone number', () {
      final uri = UriBuilders.telegram(phoneNumber: '+213 555 12 34 56');

      expect(uri.toString(), 'https://t.me/+213555123456');
    });

    test('builds a Viber URI with an encoded number', () {
      final uri = UriBuilders.viber('+213 555 12 34 56');

      expect(uri.toString(), 'viber://contact?number=%2B213555123456');
    });

    test('builds a Google Maps search URI from a query', () {
      final uri = UriBuilders.mapLocation(
        MapLocation.query('1600 Amphitheatre Parkway, Mountain View'),
      );

      expect(
        uri.toString(),
        'https://www.google.com/maps/search/?api=1&query=1600+Amphitheatre+Parkway%2C+Mountain+View',
      );
    });

    test('builds a Google Maps directions URI from mixed location types', () {
      final uri = UriBuilders.mapDirections(
        origin: MapLocation.coordinates(37.33182, -122.03118),
        destination: MapLocation.query('Golden Gate Bridge'),
      );

      expect(
        uri.toString(),
        'https://www.google.com/maps/dir/?api=1&origin=37.33182%2C-122.03118&destination=Golden+Gate+Bridge',
      );
    });

    test('returns absolute browser URLs unchanged', () {
      final uri = UriBuilders.web(Uri.parse('https://flutter.dev'));

      expect(uri.toString(), 'https://flutter.dev');
    });

    test('throws for empty recipients', () {
      expect(
        () => UriBuilders.email(recipients: const <String>[]),
        throwsA(isA<UrlLauncherValidationException>()),
      );
    });

    test('throws for invalid map coordinates', () {
      expect(
        () => MapLocation.coordinates(100, 2),
        throwsA(isA<UrlLauncherValidationException>()),
      );
    });

    test('throws for invalid browser schemes', () {
      expect(
        () => UriBuilders.web(Uri.parse('ftp://example.com')),
        throwsA(isA<UrlLauncherValidationException>()),
      );
    });

    test('throws when Telegram target is missing', () {
      expect(
        () => UriBuilders.telegram(),
        throwsA(isA<UrlLauncherValidationException>()),
      );
    });

    test('throws for malformed phone numbers', () {
      expect(
        () => UriBuilders.phoneCall('+213-ABC-123'),
        throwsA(isA<UrlLauncherValidationException>()),
      );
    });
  });
}
