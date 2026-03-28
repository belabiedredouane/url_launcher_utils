import 'package:example/main.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('home screen lists all launcher actions',
      (WidgetTester tester) async {
    await tester.pumpWidget(const UrlLauncherUtilsExampleApp());

    for (final String actionId in <String>[
      'call',
      'sms',
      'email',
      'whatsapp',
      'telegram',
      'viber',
      'maps',
      'browser',
    ]) {
      final finder = find.byKey(ValueKey<String>('nav-$actionId'));
      await _scrollIntoView(tester, finder);
      expect(finder, findsOneWidget);
    }
  });

  testWidgets('call screen validates required phone number',
      (WidgetTester tester) async {
    await tester.pumpWidget(const UrlLauncherUtilsExampleApp());
    await _openAction(tester, 'call');

    await tester.enterText(
        find.byKey(const ValueKey<String>('call-phone')), '');
    await _tapVisible(
      tester,
      find.byKey(const ValueKey<String>('submit-call')),
    );
    await tester.pump();

    expect(find.text('Please enter a phone number.'), findsOneWidget);
  });

  testWidgets('sms screen validates required phone number',
      (WidgetTester tester) async {
    await tester.pumpWidget(const UrlLauncherUtilsExampleApp());
    await _openAction(tester, 'sms');

    await tester.enterText(find.byKey(const ValueKey<String>('sms-phone')), '');
    await _tapVisible(
      tester,
      find.byKey(const ValueKey<String>('submit-sms')),
    );
    await tester.pump();

    expect(find.text('Please enter a phone number.'), findsOneWidget);
  });

  testWidgets('email screen validates recipients', (WidgetTester tester) async {
    await tester.pumpWidget(const UrlLauncherUtilsExampleApp());
    await _openAction(tester, 'email');

    await tester.enterText(
      find.byKey(const ValueKey<String>('email-recipients')),
      '',
    );
    await _tapVisible(
      tester,
      find.byKey(const ValueKey<String>('submit-email')),
    );
    await tester.pump();

    expect(find.text('Please enter at least one recipient.'), findsOneWidget);
  });

  testWidgets('whatsapp screen validates required phone number',
      (WidgetTester tester) async {
    await tester.pumpWidget(const UrlLauncherUtilsExampleApp());
    await _openAction(tester, 'whatsapp');

    await tester.enterText(
      find.byKey(const ValueKey<String>('whatsapp-phone')),
      '',
    );
    await _tapVisible(
      tester,
      find.byKey(const ValueKey<String>('submit-whatsapp')),
    );
    await tester.pump();

    expect(find.text('Please enter a phone number.'), findsOneWidget);
  });

  testWidgets('telegram screen enforces a single launch target',
      (WidgetTester tester) async {
    await tester.pumpWidget(const UrlLauncherUtilsExampleApp());
    await _openAction(tester, 'telegram');

    await tester.enterText(
      find.byKey(const ValueKey<String>('telegram-username')),
      '@flutterdev',
    );
    await tester.enterText(
      find.byKey(const ValueKey<String>('telegram-phone')),
      '+213555123456',
    );
    await _tapVisible(
      tester,
      find.byKey(const ValueKey<String>('submit-telegram')),
    );
    await tester.pump();

    expect(find.text('Use either a username or a phone number.'),
        findsNWidgets(2));
  });

  testWidgets('viber screen validates required phone number',
      (WidgetTester tester) async {
    await tester.pumpWidget(const UrlLauncherUtilsExampleApp());
    await _openAction(tester, 'viber');

    await tester.enterText(
        find.byKey(const ValueKey<String>('viber-phone')), '');
    await _tapVisible(
      tester,
      find.byKey(const ValueKey<String>('submit-viber')),
    );
    await tester.pump();

    expect(find.text('Please enter a phone number.'), findsOneWidget);
  });

  testWidgets('maps location form validates the query input',
      (WidgetTester tester) async {
    await tester.pumpWidget(const UrlLauncherUtilsExampleApp());
    await _openAction(tester, 'maps');

    await tester.enterText(
      find.byKey(const ValueKey<String>('maps-location-query')),
      '',
    );
    await _tapVisible(
      tester,
      find.byKey(const ValueKey<String>('submit-map-location')),
    );
    await tester.pump();

    expect(find.text('Please enter a location query.'), findsOneWidget);
  });

  testWidgets('browser screen validates URL scheme',
      (WidgetTester tester) async {
    await tester.pumpWidget(const UrlLauncherUtilsExampleApp());
    await _openAction(tester, 'browser');

    await tester.enterText(
      find.byKey(const ValueKey<String>('browser-url')),
      'ftp://example.com',
    );
    await _tapVisible(
      tester,
      find.byKey(const ValueKey<String>('submit-browser')),
    );
    await tester.pump();

    expect(find.text('Enter a valid http or https URL.'), findsOneWidget);
  });
}

Future<void> _openAction(WidgetTester tester, String actionId) async {
  final finder = find.byKey(ValueKey<String>('nav-$actionId'));
  await _scrollIntoView(tester, finder);
  await tester.tap(finder, warnIfMissed: false);
  await tester.pumpAndSettle();
}

Future<void> _scrollIntoView(WidgetTester tester, Finder finder) async {
  await tester.scrollUntilVisible(
    finder,
    200,
    scrollable: find.byType(Scrollable).first,
  );
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
}

Future<void> _tapVisible(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
  await tester.tap(finder, warnIfMissed: false);
}
