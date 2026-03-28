import 'package:flutter/material.dart';
import 'package:url_launcher_utils/url_launcher_utils.dart';

void main() {
  runApp(const UrlLauncherUtilsExampleApp());
}

class UrlLauncherUtilsExampleApp extends StatelessWidget {
  const UrlLauncherUtilsExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'URL Launcher Utils Example',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0B7285),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      home: const ExampleHomeScreen(),
    );
  }
}

class ExampleHomeScreen extends StatelessWidget {
  const ExampleHomeScreen({super.key});

  static final List<_ActionDestination> _destinations = <_ActionDestination>[
    _ActionDestination(
      id: 'call',
      title: 'Call',
      subtitle: 'Launch the dialer with a phone number.',
      icon: Icons.call_outlined,
      builder: () => const _CallScreen(),
    ),
    _ActionDestination(
      id: 'sms',
      title: 'SMS',
      subtitle: 'Open the SMS composer with an optional message.',
      icon: Icons.sms_outlined,
      builder: () => const _SmsScreen(),
    ),
    _ActionDestination(
      id: 'email',
      title: 'Email',
      subtitle: 'Compose emails with recipients, CC, BCC, subject, and body.',
      icon: Icons.mail_outline,
      builder: () => const _EmailScreen(),
    ),
    _ActionDestination(
      id: 'whatsapp',
      title: 'WhatsApp',
      subtitle: 'Open a WhatsApp chat with an optional prefilled message.',
      icon: Icons.chat_bubble_outline,
      builder: () => const _WhatsAppScreen(),
    ),
    _ActionDestination(
      id: 'telegram',
      title: 'Telegram',
      subtitle: 'Launch a chat by username or phone number.',
      icon: Icons.send_outlined,
      builder: () => const _TelegramScreen(),
    ),
    _ActionDestination(
      id: 'viber',
      title: 'Viber',
      subtitle: 'Open a Viber chat using the best-effort phone flow.',
      icon: Icons.phone_android_outlined,
      builder: () => const _ViberScreen(),
    ),
    _ActionDestination(
      id: 'maps',
      title: 'Maps',
      subtitle: 'Search places or open directions with queries or coordinates.',
      icon: Icons.map_outlined,
      builder: () => const _MapsScreen(),
    ),
    _ActionDestination(
      id: 'browser',
      title: 'Browser',
      subtitle: 'Open any valid HTTP or HTTPS URL in the browser.',
      icon: Icons.language_outlined,
      builder: () => const _BrowserScreen(),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('URL Launcher Utils'),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _destinations.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (BuildContext context, int index) {
          final destination = _destinations[index];
          return Card(
            clipBehavior: Clip.antiAlias,
            child: ListTile(
              key: ValueKey<String>('nav-${destination.id}'),
              leading: Icon(destination.icon),
              title: Text(destination.title),
              subtitle: Text(destination.subtitle),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => destination.builder(),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class _ActionDestination {
  const _ActionDestination({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.builder,
  });

  final String id;
  final String title;
  final String subtitle;
  final IconData icon;
  final Widget Function() builder;
}

mixin _LaunchRunner<T extends StatefulWidget> on State<T> {
  bool isSubmitting = false;
  LaunchResult? launchResult;
  String? launchError;

  Future<void> runLaunch(Future<LaunchResult> Function() action) async {
    setState(() {
      isSubmitting = true;
      launchResult = null;
      launchError = null;
    });

    try {
      final result = await action();
      if (!mounted) {
        return;
      }

      setState(() {
        isSubmitting = false;
        launchResult = result;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        isSubmitting = false;
        launchError = error.toString();
      });
    }
  }
}

class _ActionScreenScaffold extends StatelessWidget {
  const _ActionScreenScaffold({
    required this.title,
    required this.description,
    required this.child,
  });

  final String title;
  final String description;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: <Widget>[
            Text(
              description,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 16),
            child,
          ],
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.title,
    required this.child,
  });

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            child,
          ],
        ),
      ),
    );
  }
}

class _LaunchResultCard extends StatelessWidget {
  const _LaunchResultCard({
    required this.isSubmitting,
    required this.result,
    required this.errorMessage,
  });

  final bool isSubmitting;
  final LaunchResult? result;
  final String? errorMessage;

  @override
  Widget build(BuildContext context) {
    Widget child;

    if (isSubmitting) {
      child = const Row(
        children: <Widget>[
          SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          SizedBox(width: 12),
          Expanded(child: Text('Launching...')),
        ],
      );
    } else if (errorMessage != null) {
      child = Text(
        errorMessage!,
        style: TextStyle(
          color: Theme.of(context).colorScheme.error,
          fontWeight: FontWeight.w600,
        ),
      );
    } else if (result != null) {
      child = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text('Status: ${result!.status.name}'),
          const SizedBox(height: 8),
          SelectableText('Requested URI: ${result!.requestedUri}'),
          if (result!.fallbackUri != null) ...<Widget>[
            const SizedBox(height: 8),
            SelectableText('Fallback URI: ${result!.fallbackUri}'),
          ],
          if (result!.error != null) ...<Widget>[
            const SizedBox(height: 8),
            SelectableText('Error: ${result!.error}'),
          ],
        ],
      );
    } else {
      child = const Text(
        'Run an action to inspect the launch result returned by the package.',
      );
    }

    return _SectionCard(
      title: 'Launch result',
      child: child,
    );
  }
}

class _CallScreen extends StatefulWidget {
  const _CallScreen();

  @override
  State<_CallScreen> createState() => _CallScreenState();
}

class _CallScreenState extends State<_CallScreen>
    with _LaunchRunner<_CallScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final TextEditingController _phoneController =
      TextEditingController(text: '+213 555 12 34 56');

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    await runLaunch(
      () => UrlLauncherUtils.launchPhoneCall(
        phoneNumber: _phoneController.text,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _ActionScreenScaffold(
      title: 'Phone Call',
      description: 'Open the system dialer with a normalized phone number.',
      child: Column(
        children: <Widget>[
          _SectionCard(
            title: 'Call form',
            child: Form(
              key: _formKey,
              child: Column(
                children: <Widget>[
                  TextFormField(
                    key: const ValueKey<String>('call-phone'),
                    controller: _phoneController,
                    decoration: const InputDecoration(
                      labelText: 'Phone number',
                      hintText: '+213 555 12 34 56',
                    ),
                    keyboardType: TextInputType.phone,
                    validator: (String? value) =>
                        _requiredField(value, 'a phone number'),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      key: const ValueKey<String>('submit-call'),
                      onPressed: _submit,
                      child: const Text('Launch call'),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          _LaunchResultCard(
            isSubmitting: isSubmitting,
            result: launchResult,
            errorMessage: launchError,
          ),
        ],
      ),
    );
  }
}

class _SmsScreen extends StatefulWidget {
  const _SmsScreen();

  @override
  State<_SmsScreen> createState() => _SmsScreenState();
}

class _SmsScreenState extends State<_SmsScreen> with _LaunchRunner<_SmsScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final TextEditingController _phoneController =
      TextEditingController(text: '+213 555 12 34 56');
  late final TextEditingController _messageController =
      TextEditingController(text: 'Hello from url_launcher_utils');

  @override
  void dispose() {
    _phoneController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    await runLaunch(
      () => UrlLauncherUtils.sendSms(
        phoneNumber: _phoneController.text,
        message: _messageController.text,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _ActionScreenScaffold(
      title: 'SMS',
      description:
          'Open the SMS composer with a target phone number and an optional body.',
      child: Column(
        children: <Widget>[
          _SectionCard(
            title: 'SMS form',
            child: Form(
              key: _formKey,
              child: Column(
                children: <Widget>[
                  TextFormField(
                    key: const ValueKey<String>('sms-phone'),
                    controller: _phoneController,
                    decoration: const InputDecoration(
                      labelText: 'Phone number',
                    ),
                    keyboardType: TextInputType.phone,
                    validator: (String? value) =>
                        _requiredField(value, 'a phone number'),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    key: const ValueKey<String>('sms-message'),
                    controller: _messageController,
                    decoration: const InputDecoration(
                      labelText: 'Message body',
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      key: const ValueKey<String>('submit-sms'),
                      onPressed: _submit,
                      child: const Text('Send SMS'),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          _LaunchResultCard(
            isSubmitting: isSubmitting,
            result: launchResult,
            errorMessage: launchError,
          ),
        ],
      ),
    );
  }
}

class _EmailScreen extends StatefulWidget {
  const _EmailScreen();

  @override
  State<_EmailScreen> createState() => _EmailScreenState();
}

class _EmailScreenState extends State<_EmailScreen>
    with _LaunchRunner<_EmailScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final TextEditingController _recipientsController =
      TextEditingController(text: 'hello@example.com, support@example.com');
  late final TextEditingController _ccController =
      TextEditingController(text: 'team@example.com');
  late final TextEditingController _bccController =
      TextEditingController(text: 'audit@example.com');
  late final TextEditingController _subjectController =
      TextEditingController(text: 'Package feedback');
  late final TextEditingController _bodyController =
      TextEditingController(text: 'This package works well.');

  @override
  void dispose() {
    _recipientsController.dispose();
    _ccController.dispose();
    _bccController.dispose();
    _subjectController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    await runLaunch(
      () => UrlLauncherUtils.sendEmail(
        recipients: _splitCsv(_recipientsController.text),
        cc: _splitCsv(_ccController.text),
        bcc: _splitCsv(_bccController.text),
        subject: _subjectController.text,
        body: _bodyController.text,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _ActionScreenScaffold(
      title: 'Email',
      description:
          'Compose a mailto URI with recipients, CC, BCC, subject, and body.',
      child: Column(
        children: <Widget>[
          _SectionCard(
            title: 'Email form',
            child: Form(
              key: _formKey,
              child: Column(
                children: <Widget>[
                  TextFormField(
                    key: const ValueKey<String>('email-recipients'),
                    controller: _recipientsController,
                    decoration: const InputDecoration(
                      labelText: 'Recipients',
                      hintText: 'hello@example.com, support@example.com',
                    ),
                    validator: _validateRequiredEmailList,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    key: const ValueKey<String>('email-cc'),
                    controller: _ccController,
                    decoration: const InputDecoration(
                      labelText: 'CC',
                    ),
                    validator: _validateOptionalEmailList,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    key: const ValueKey<String>('email-bcc'),
                    controller: _bccController,
                    decoration: const InputDecoration(
                      labelText: 'BCC',
                    ),
                    validator: _validateOptionalEmailList,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    key: const ValueKey<String>('email-subject'),
                    controller: _subjectController,
                    decoration: const InputDecoration(
                      labelText: 'Subject',
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    key: const ValueKey<String>('email-body'),
                    controller: _bodyController,
                    decoration: const InputDecoration(
                      labelText: 'Body',
                    ),
                    maxLines: 4,
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      key: const ValueKey<String>('submit-email'),
                      onPressed: _submit,
                      child: const Text('Send email'),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          _LaunchResultCard(
            isSubmitting: isSubmitting,
            result: launchResult,
            errorMessage: launchError,
          ),
        ],
      ),
    );
  }
}

class _WhatsAppScreen extends StatefulWidget {
  const _WhatsAppScreen();

  @override
  State<_WhatsAppScreen> createState() => _WhatsAppScreenState();
}

class _WhatsAppScreenState extends State<_WhatsAppScreen>
    with _LaunchRunner<_WhatsAppScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final TextEditingController _phoneController =
      TextEditingController(text: '+213 555 12 34 56');
  late final TextEditingController _messageController =
      TextEditingController(text: 'Hello from WhatsApp');

  @override
  void dispose() {
    _phoneController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    await runLaunch(
      () => UrlLauncherUtils.openWhatsApp(
        phoneNumber: _phoneController.text,
        message: _messageController.text,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _ActionScreenScaffold(
      title: 'WhatsApp',
      description:
          'Open a WhatsApp chat and optionally prefill the message composer.',
      child: Column(
        children: <Widget>[
          _SectionCard(
            title: 'WhatsApp form',
            child: Form(
              key: _formKey,
              child: Column(
                children: <Widget>[
                  TextFormField(
                    key: const ValueKey<String>('whatsapp-phone'),
                    controller: _phoneController,
                    decoration: const InputDecoration(
                      labelText: 'Phone number',
                    ),
                    keyboardType: TextInputType.phone,
                    validator: (String? value) =>
                        _requiredField(value, 'a phone number'),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    key: const ValueKey<String>('whatsapp-message'),
                    controller: _messageController,
                    decoration: const InputDecoration(
                      labelText: 'Message',
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      key: const ValueKey<String>('submit-whatsapp'),
                      onPressed: _submit,
                      child: const Text('Open WhatsApp'),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          _LaunchResultCard(
            isSubmitting: isSubmitting,
            result: launchResult,
            errorMessage: launchError,
          ),
        ],
      ),
    );
  }
}

class _TelegramScreen extends StatefulWidget {
  const _TelegramScreen();

  @override
  State<_TelegramScreen> createState() => _TelegramScreenState();
}

class _TelegramScreenState extends State<_TelegramScreen>
    with _LaunchRunner<_TelegramScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final TextEditingController _usernameController =
      TextEditingController(text: '@flutterdev');
  late final TextEditingController _phoneController = TextEditingController();

  @override
  void dispose() {
    _usernameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  String? _validateUsername(String? value) {
    final username = value?.trim() ?? '';
    final phone = _phoneController.text.trim();

    if (username.isEmpty && phone.isEmpty) {
      return 'Enter a username or a phone number.';
    }

    if (username.isNotEmpty && phone.isNotEmpty) {
      return 'Use either a username or a phone number.';
    }

    return null;
  }

  String? _validatePhone(String? value) {
    final username = _usernameController.text.trim();
    final phone = value?.trim() ?? '';

    if (username.isEmpty && phone.isEmpty) {
      return 'Enter a username or a phone number.';
    }

    if (username.isNotEmpty && phone.isNotEmpty) {
      return 'Use either a username or a phone number.';
    }

    return null;
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    await runLaunch(
      () => UrlLauncherUtils.openTelegram(
        username: _usernameController.text.trim().isEmpty
            ? null
            : _usernameController.text,
        phoneNumber:
            _phoneController.text.trim().isEmpty ? null : _phoneController.text,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _ActionScreenScaffold(
      title: 'Telegram',
      description:
          'Launch a Telegram chat with either a username or a phone number.',
      child: Column(
        children: <Widget>[
          _SectionCard(
            title: 'Telegram form',
            child: Form(
              key: _formKey,
              child: Column(
                children: <Widget>[
                  TextFormField(
                    key: const ValueKey<String>('telegram-username'),
                    controller: _usernameController,
                    decoration: const InputDecoration(
                      labelText: 'Username',
                      hintText: '@flutterdev',
                    ),
                    validator: _validateUsername,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    key: const ValueKey<String>('telegram-phone'),
                    controller: _phoneController,
                    decoration: const InputDecoration(
                      labelText: 'Phone number',
                    ),
                    keyboardType: TextInputType.phone,
                    validator: _validatePhone,
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      key: const ValueKey<String>('submit-telegram'),
                      onPressed: _submit,
                      child: const Text('Open Telegram'),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          _LaunchResultCard(
            isSubmitting: isSubmitting,
            result: launchResult,
            errorMessage: launchError,
          ),
        ],
      ),
    );
  }
}

class _ViberScreen extends StatefulWidget {
  const _ViberScreen();

  @override
  State<_ViberScreen> createState() => _ViberScreenState();
}

class _ViberScreenState extends State<_ViberScreen>
    with _LaunchRunner<_ViberScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final TextEditingController _phoneController =
      TextEditingController(text: '+213 555 12 34 56');

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    await runLaunch(
      () => UrlLauncherUtils.openViber(
        phoneNumber: _phoneController.text,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _ActionScreenScaffold(
      title: 'Viber',
      description:
          'Open a Viber chat using the phone-based best-effort deep link.',
      child: Column(
        children: <Widget>[
          _SectionCard(
            title: 'Viber form',
            child: Form(
              key: _formKey,
              child: Column(
                children: <Widget>[
                  TextFormField(
                    key: const ValueKey<String>('viber-phone'),
                    controller: _phoneController,
                    decoration: const InputDecoration(
                      labelText: 'Phone number',
                    ),
                    keyboardType: TextInputType.phone,
                    validator: (String? value) =>
                        _requiredField(value, 'a phone number'),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      key: const ValueKey<String>('submit-viber'),
                      onPressed: _submit,
                      child: const Text('Open Viber'),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          _LaunchResultCard(
            isSubmitting: isSubmitting,
            result: launchResult,
            errorMessage: launchError,
          ),
        ],
      ),
    );
  }
}

enum _MapInputMode {
  query,
  coordinates,
}

class _MapsScreen extends StatefulWidget {
  const _MapsScreen();

  @override
  State<_MapsScreen> createState() => _MapsScreenState();
}

class _MapsScreenState extends State<_MapsScreen>
    with _LaunchRunner<_MapsScreen> {
  final GlobalKey<FormState> _locationFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _directionsFormKey = GlobalKey<FormState>();

  _MapInputMode _locationMode = _MapInputMode.query;
  _MapInputMode _originMode = _MapInputMode.coordinates;
  _MapInputMode _destinationMode = _MapInputMode.query;

  late final TextEditingController _locationQueryController =
      TextEditingController(text: '1 Infinite Loop, Cupertino');
  late final TextEditingController _locationLatitudeController =
      TextEditingController(text: '37.33182');
  late final TextEditingController _locationLongitudeController =
      TextEditingController(text: '-122.03118');

  late final TextEditingController _originQueryController =
      TextEditingController(text: 'Apple Park Visitor Center');
  late final TextEditingController _originLatitudeController =
      TextEditingController(text: '37.3349');
  late final TextEditingController _originLongitudeController =
      TextEditingController(text: '-122.0090');
  late final TextEditingController _destinationQueryController =
      TextEditingController(text: 'Golden Gate Bridge');
  late final TextEditingController _destinationLatitudeController =
      TextEditingController(text: '37.8199');
  late final TextEditingController _destinationLongitudeController =
      TextEditingController(text: '-122.4783');

  @override
  void dispose() {
    _locationQueryController.dispose();
    _locationLatitudeController.dispose();
    _locationLongitudeController.dispose();
    _originQueryController.dispose();
    _originLatitudeController.dispose();
    _originLongitudeController.dispose();
    _destinationQueryController.dispose();
    _destinationLatitudeController.dispose();
    _destinationLongitudeController.dispose();
    super.dispose();
  }

  String? _validateQuery(String? value, _MapInputMode mode) {
    if (mode != _MapInputMode.query) {
      return null;
    }

    return _requiredField(value, 'a location query');
  }

  String? _validateCoordinate(
    String? value, {
    required _MapInputMode mode,
    required String label,
    required double min,
    required double max,
  }) {
    if (mode != _MapInputMode.coordinates) {
      return null;
    }

    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) {
      return 'Please enter $label.';
    }

    final parsed = double.tryParse(trimmed);
    if (parsed == null) {
      return '$label must be a valid number.';
    }

    if (parsed < min || parsed > max) {
      return '$label must be between $min and $max.';
    }

    return null;
  }

  MapLocation _buildMapLocation({
    required _MapInputMode mode,
    required TextEditingController queryController,
    required TextEditingController latitudeController,
    required TextEditingController longitudeController,
  }) {
    if (mode == _MapInputMode.query) {
      return MapLocation.query(queryController.text);
    }

    return MapLocation.coordinates(
      double.parse(latitudeController.text.trim()),
      double.parse(longitudeController.text.trim()),
    );
  }

  Future<void> _openLocation() async {
    if (!_locationFormKey.currentState!.validate()) {
      return;
    }

    await runLaunch(
      () => UrlLauncherUtils.openMapLocation(
        target: _buildMapLocation(
          mode: _locationMode,
          queryController: _locationQueryController,
          latitudeController: _locationLatitudeController,
          longitudeController: _locationLongitudeController,
        ),
      ),
    );
  }

  Future<void> _openDirections() async {
    if (!_directionsFormKey.currentState!.validate()) {
      return;
    }

    await runLaunch(
      () => UrlLauncherUtils.openMapDirections(
        origin: _buildMapLocation(
          mode: _originMode,
          queryController: _originQueryController,
          latitudeController: _originLatitudeController,
          longitudeController: _originLongitudeController,
        ),
        destination: _buildMapLocation(
          mode: _destinationMode,
          queryController: _destinationQueryController,
          latitudeController: _destinationLatitudeController,
          longitudeController: _destinationLongitudeController,
        ),
      ),
    );
  }

  Widget _buildLocationFields({
    required String prefix,
    required _MapInputMode mode,
    required ValueChanged<_MapInputMode?> onChanged,
    required TextEditingController queryController,
    required TextEditingController latitudeController,
    required TextEditingController longitudeController,
  }) {
    return Column(
      children: <Widget>[
        DropdownButtonFormField<_MapInputMode>(
          key: ValueKey<String>('$prefix-mode'),
          initialValue: mode,
          decoration: const InputDecoration(
            labelText: 'Input type',
          ),
          items: const <DropdownMenuItem<_MapInputMode>>[
            DropdownMenuItem<_MapInputMode>(
              value: _MapInputMode.query,
              child: Text('Query'),
            ),
            DropdownMenuItem<_MapInputMode>(
              value: _MapInputMode.coordinates,
              child: Text('Coordinates'),
            ),
          ],
          onChanged: onChanged,
        ),
        const SizedBox(height: 16),
        if (mode == _MapInputMode.query)
          TextFormField(
            key: ValueKey<String>('$prefix-query'),
            controller: queryController,
            decoration: const InputDecoration(
              labelText: 'Query',
            ),
            validator: (String? value) => _validateQuery(value, mode),
          ),
        if (mode == _MapInputMode.coordinates) ...<Widget>[
          TextFormField(
            key: ValueKey<String>('$prefix-latitude'),
            controller: latitudeController,
            decoration: const InputDecoration(
              labelText: 'Latitude',
            ),
            keyboardType: const TextInputType.numberWithOptions(
                decimal: true, signed: true),
            validator: (String? value) => _validateCoordinate(
              value,
              mode: mode,
              label: 'Latitude',
              min: -90,
              max: 90,
            ),
          ),
          const SizedBox(height: 16),
          TextFormField(
            key: ValueKey<String>('$prefix-longitude'),
            controller: longitudeController,
            decoration: const InputDecoration(
              labelText: 'Longitude',
            ),
            keyboardType: const TextInputType.numberWithOptions(
                decimal: true, signed: true),
            validator: (String? value) => _validateCoordinate(
              value,
              mode: mode,
              label: 'Longitude',
              min: -180,
              max: 180,
            ),
          ),
        ],
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return _ActionScreenScaffold(
      title: 'Maps',
      description:
          'Search locations or open directions with Google Maps universal URLs.',
      child: Column(
        children: <Widget>[
          _SectionCard(
            title: 'Open location',
            child: Form(
              key: _locationFormKey,
              child: Column(
                children: <Widget>[
                  _buildLocationFields(
                    prefix: 'maps-location',
                    mode: _locationMode,
                    onChanged: (_MapInputMode? value) {
                      if (value == null) {
                        return;
                      }
                      setState(() {
                        _locationMode = value;
                      });
                    },
                    queryController: _locationQueryController,
                    latitudeController: _locationLatitudeController,
                    longitudeController: _locationLongitudeController,
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      key: const ValueKey<String>('submit-map-location'),
                      onPressed: _openLocation,
                      child: const Text('Open location'),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          _SectionCard(
            title: 'Open directions',
            child: Form(
              key: _directionsFormKey,
              child: Column(
                children: <Widget>[
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Origin',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildLocationFields(
                    prefix: 'maps-origin',
                    mode: _originMode,
                    onChanged: (_MapInputMode? value) {
                      if (value == null) {
                        return;
                      }
                      setState(() {
                        _originMode = value;
                      });
                    },
                    queryController: _originQueryController,
                    latitudeController: _originLatitudeController,
                    longitudeController: _originLongitudeController,
                  ),
                  const SizedBox(height: 24),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Destination',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildLocationFields(
                    prefix: 'maps-destination',
                    mode: _destinationMode,
                    onChanged: (_MapInputMode? value) {
                      if (value == null) {
                        return;
                      }
                      setState(() {
                        _destinationMode = value;
                      });
                    },
                    queryController: _destinationQueryController,
                    latitudeController: _destinationLatitudeController,
                    longitudeController: _destinationLongitudeController,
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      key: const ValueKey<String>('submit-map-directions'),
                      onPressed: _openDirections,
                      child: const Text('Open directions'),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          _LaunchResultCard(
            isSubmitting: isSubmitting,
            result: launchResult,
            errorMessage: launchError,
          ),
        ],
      ),
    );
  }
}

class _BrowserScreen extends StatefulWidget {
  const _BrowserScreen();

  @override
  State<_BrowserScreen> createState() => _BrowserScreenState();
}

class _BrowserScreenState extends State<_BrowserScreen>
    with _LaunchRunner<_BrowserScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final TextEditingController _urlController =
      TextEditingController(text: 'https://flutter.dev');

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    await runLaunch(
      () => UrlLauncherUtils.openUrl(
        url: Uri.parse(_urlController.text.trim()),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _ActionScreenScaffold(
      title: 'Browser',
      description: 'Open a valid HTTP or HTTPS URL in the external browser.',
      child: Column(
        children: <Widget>[
          _SectionCard(
            title: 'Browser form',
            child: Form(
              key: _formKey,
              child: Column(
                children: <Widget>[
                  TextFormField(
                    key: const ValueKey<String>('browser-url'),
                    controller: _urlController,
                    decoration: const InputDecoration(
                      labelText: 'URL',
                      hintText: 'https://flutter.dev',
                    ),
                    keyboardType: TextInputType.url,
                    validator: _validateBrowserUrl,
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      key: const ValueKey<String>('submit-browser'),
                      onPressed: _submit,
                      child: const Text('Open browser'),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          _LaunchResultCard(
            isSubmitting: isSubmitting,
            result: launchResult,
            errorMessage: launchError,
          ),
        ],
      ),
    );
  }
}

String? _requiredField(String? value, String label) {
  if ((value?.trim() ?? '').isEmpty) {
    return 'Please enter $label.';
  }

  return null;
}

final RegExp _emailPattern = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');

String? _validateRequiredEmailList(String? value) {
  final emails = _splitCsv(value ?? '');
  if (emails.isEmpty) {
    return 'Please enter at least one recipient.';
  }

  return _validateEmails(emails);
}

String? _validateOptionalEmailList(String? value) {
  final emails = _splitCsv(value ?? '');
  if (emails.isEmpty) {
    return null;
  }

  return _validateEmails(emails);
}

String? _validateEmails(List<String> emails) {
  for (final String email in emails) {
    if (!_emailPattern.hasMatch(email)) {
      return 'Invalid email address: $email';
    }
  }

  return null;
}

List<String> _splitCsv(String value) {
  return value
      .split(',')
      .map((String item) => item.trim())
      .where((String item) => item.isNotEmpty)
      .toList(growable: false);
}

String? _validateBrowserUrl(String? value) {
  final trimmed = value?.trim() ?? '';
  if (trimmed.isEmpty) {
    return 'Please enter a URL.';
  }

  final uri = Uri.tryParse(trimmed);
  if (uri == null ||
      !uri.hasScheme ||
      uri.host.isEmpty ||
      (uri.scheme != 'http' && uri.scheme != 'https')) {
    return 'Enter a valid http or https URL.';
  }

  return null;
}
