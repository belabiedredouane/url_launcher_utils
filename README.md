# url_launcher_utils

`url_launcher_utils` is a Flutter package that wraps
[`url_launcher`](https://pub.dev/packages/url_launcher) with a focused API for
common URL-based actions:

- Phone calls
- SMS
- Email
- WhatsApp
- Telegram
- Viber
- Maps search and directions
- Browser URLs

The package is mobile-first for Android and iOS. Generic web URLs and email
links may also work on desktop and web, but third-party messaging integrations
are primarily intended for mobile devices.

## Features

- Static, easy-to-call API through `UrlLauncherUtils`
- Strong input validation with package-specific exceptions
- `Uri`-first builders for cleaner and safer launch requests
- Typed `LaunchResult` for caller-side status inspection
- Automatic Play Store/App Store fallback for WhatsApp, Telegram, and Viber
- Example app with dedicated screens for each use case
- Unit and widget tests

## Installation

Add the package to `pubspec.yaml`:

```yaml
dependencies:
  url_launcher_utils: ^0.1.0
```

Then run:

```bash
flutter pub get
```

## Usage

### Phone call

```dart
await UrlLauncherUtils.launchPhoneCall(
  phoneNumber: '+1 555 123 4567',
);
```

### SMS

```dart
await UrlLauncherUtils.sendSms(
  phoneNumber: '+1 555 123 4567',
  message: 'Hello from Flutter',
);
```

### Email

```dart
await UrlLauncherUtils.sendEmail(
  recipients: const ['hello@example.com'],
  cc: const ['team@example.com'],
  subject: 'Feedback',
  body: 'This package works well.',
);
```

### WhatsApp

```dart
await UrlLauncherUtils.openWhatsApp(
  phoneNumber: '+213555123456',
  message: 'Hello',
);
```

### Telegram

```dart
await UrlLauncherUtils.openTelegram(username: '@flutterdev');
await UrlLauncherUtils.openTelegram(phoneNumber: '+213555123456');
```

### Viber

```dart
await UrlLauncherUtils.openViber(phoneNumber: '+213555123456');
```

### Maps

```dart
await UrlLauncherUtils.openMapLocation(
  target: MapLocation.query('1 Infinite Loop, Cupertino'),
);

await UrlLauncherUtils.openMapDirections(
  origin: MapLocation.coordinates(37.33182, -122.03118),
  destination: MapLocation.query('Golden Gate Bridge'),
);
```

### Browser

```dart
await UrlLauncherUtils.openUrl(
  url: Uri.parse('https://flutter.dev'),
);
```

## Error handling

Every launcher method returns a `LaunchResult`:

- `LaunchStatus.launchedPrimary`
- `LaunchStatus.launchedFallback`
- `LaunchStatus.failed`

Validation problems throw `UrlLauncherValidationException`.

If launching WhatsApp, Telegram, or Viber fails because the app is unavailable,
the package attempts to redirect to the appropriate store page on Android or
iOS. In debug mode, failed launches print `Could not launch <url>`.

## Notes

- Google Maps universal URLs are used for map search and directions.
- Telegram requires exactly one of `username` or `phoneNumber`.
- Viber consumer-chat support is best-effort because official Viber deep-link
  documentation focuses on bot and public-account flows.

See the runnable sample inside [`example/`](example).
