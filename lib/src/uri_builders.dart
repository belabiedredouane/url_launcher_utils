import 'exceptions.dart';
import 'models.dart';

class UriBuilders {
  UriBuilders._();

  static final RegExp _allowedPhonePattern = RegExp(r'^[+\d\s().-]+$');
  static final RegExp _emailPattern = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
  static final RegExp _telegramUsernamePattern = RegExp(
    r'^[a-zA-Z][a-zA-Z0-9_]{4,31}$',
  );

  static Uri phoneCall(String phoneNumber) {
    final normalized = _normalizePhone(
      phoneNumber,
      fieldName: 'phoneNumber',
      keepLeadingPlus: true,
      minimumDigits: 3,
    );
    return Uri.parse('tel:$normalized');
  }

  static Uri sms(String phoneNumber, {String? message}) {
    final normalized = _normalizePhone(
      phoneNumber,
      fieldName: 'phoneNumber',
      keepLeadingPlus: true,
      minimumDigits: 3,
    );
    final query = _encodeQueryParameters(<String, String>{
      if (_hasText(message)) 'body': message!.trim(),
    });

    return Uri.parse(
      query.isEmpty ? 'sms:$normalized' : 'sms:$normalized?$query',
    );
  }

  static Uri email({
    required List<String> recipients,
    List<String> cc = const <String>[],
    List<String> bcc = const <String>[],
    String? subject,
    String? body,
  }) {
    final normalizedRecipients = _normalizeEmails(
      recipients,
      fieldName: 'recipients',
      requireAtLeastOne: true,
    );
    final normalizedCc = _normalizeEmails(cc, fieldName: 'cc');
    final normalizedBcc = _normalizeEmails(bcc, fieldName: 'bcc');

    final query = _encodeQueryParameters(<String, String>{
      if (normalizedCc.isNotEmpty) 'cc': normalizedCc.join(','),
      if (normalizedBcc.isNotEmpty) 'bcc': normalizedBcc.join(','),
      if (_hasText(subject)) 'subject': subject!.trim(),
      if (_hasText(body)) 'body': body!.trim(),
    });

    final recipientPath = normalizedRecipients.join(',');
    return Uri.parse(
      query.isEmpty ? 'mailto:$recipientPath' : 'mailto:$recipientPath?$query',
    );
  }

  static Uri whatsApp(String phoneNumber, {String? message}) {
    final normalized = _normalizePhone(
      phoneNumber,
      fieldName: 'phoneNumber',
      keepLeadingPlus: false,
      minimumDigits: 6,
    );
    return Uri.https(
      'wa.me',
      '/$normalized',
      <String, String>{
        if (_hasText(message)) 'text': message!.trim(),
      },
    );
  }

  static Uri telegram({
    String? username,
    String? phoneNumber,
  }) {
    final hasUsername = _hasText(username);
    final hasPhoneNumber = _hasText(phoneNumber);

    if (hasUsername == hasPhoneNumber) {
      throw const UrlLauncherValidationException(
        'Provide exactly one of username or phoneNumber for Telegram.',
      );
    }

    if (hasUsername) {
      final normalizedUsername = _normalizeTelegramUsername(username!);
      return Uri.https('t.me', '/$normalizedUsername');
    }

    final normalizedPhoneNumber = _normalizePhone(
      phoneNumber!,
      fieldName: 'phoneNumber',
      keepLeadingPlus: false,
      minimumDigits: 6,
    );
    return Uri.parse('https://t.me/+$normalizedPhoneNumber');
  }

  static Uri viber(String phoneNumber) {
    final normalized = _normalizePhone(
      phoneNumber,
      fieldName: 'phoneNumber',
      keepLeadingPlus: true,
      minimumDigits: 6,
    );
    final query = _encodeQueryParameters(<String, String>{
      'number': normalized,
    });
    return Uri.parse('viber://contact?$query');
  }

  static Uri mapLocation(MapLocation target) {
    return Uri.https(
      'www.google.com',
      '/maps/search/',
      <String, String>{
        'api': '1',
        'query': target.toMapsValue(),
      },
    );
  }

  static Uri mapDirections({
    required MapLocation origin,
    required MapLocation destination,
  }) {
    return Uri.https(
      'www.google.com',
      '/maps/dir/',
      <String, String>{
        'api': '1',
        'origin': origin.toMapsValue(),
        'destination': destination.toMapsValue(),
      },
    );
  }

  static Uri web(Uri url) {
    final scheme = url.scheme.toLowerCase();
    if ((scheme != 'http' && scheme != 'https') || url.host.isEmpty) {
      throw const UrlLauncherValidationException(
        'Only absolute HTTP and HTTPS URLs can be opened in the browser.',
      );
    }

    return url;
  }

  static String _normalizePhone(
    String rawPhone, {
    required String fieldName,
    required bool keepLeadingPlus,
    required int minimumDigits,
  }) {
    final trimmed = rawPhone.trim();
    if (trimmed.isEmpty) {
      throw UrlLauncherValidationException('$fieldName cannot be empty.');
    }

    if (!_allowedPhonePattern.hasMatch(trimmed)) {
      throw UrlLauncherValidationException(
        '$fieldName contains unsupported characters.',
      );
    }

    final plusMatches = RegExp(r'\+').allMatches(trimmed).length;
    if (plusMatches > 1 || (plusMatches == 1 && !trimmed.startsWith('+'))) {
      throw UrlLauncherValidationException(
        '$fieldName can only contain a leading + sign.',
      );
    }

    final digitsOnly = trimmed.replaceAll(RegExp(r'\D'), '');
    if (digitsOnly.length < minimumDigits) {
      throw UrlLauncherValidationException(
        '$fieldName must contain at least $minimumDigits digits.',
      );
    }

    final hasLeadingPlus = trimmed.startsWith('+');
    if (keepLeadingPlus && hasLeadingPlus) {
      return '+$digitsOnly';
    }

    return digitsOnly;
  }

  static List<String> _normalizeEmails(
    List<String> emails, {
    required String fieldName,
    bool requireAtLeastOne = false,
  }) {
    final normalizedEmails = emails
        .map((String email) => email.trim())
        .where((String email) => email.isNotEmpty)
        .toList(growable: false);

    if (requireAtLeastOne && normalizedEmails.isEmpty) {
      throw UrlLauncherValidationException('$fieldName cannot be empty.');
    }

    for (final String email in normalizedEmails) {
      if (!_emailPattern.hasMatch(email)) {
        throw UrlLauncherValidationException(
          'Invalid email address in $fieldName: $email',
        );
      }
    }

    return normalizedEmails;
  }

  static String _normalizeTelegramUsername(String username) {
    final trimmed = username.trim();
    if (trimmed.isEmpty) {
      throw const UrlLauncherValidationException(
        'Telegram username cannot be empty.',
      );
    }

    final normalized = trimmed.startsWith('@') ? trimmed.substring(1) : trimmed;
    if (!_telegramUsernamePattern.hasMatch(normalized)) {
      throw const UrlLauncherValidationException(
        'Telegram username must start with a letter and contain 5 to 32 letters, digits, or underscores.',
      );
    }

    return normalized;
  }

  static String _encodeQueryParameters(Map<String, String> parameters) {
    return parameters.entries
        .map(
          (MapEntry<String, String> entry) =>
              '${Uri.encodeQueryComponent(entry.key)}=${Uri.encodeQueryComponent(entry.value)}',
        )
        .join('&');
  }

  static bool _hasText(String? value) =>
      value != null && value.trim().isNotEmpty;
}
