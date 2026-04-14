import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'fcm_service.dart';
import 'firebase_options.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  debugPrint('Background message: ${message.messageId}');
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'FCM Activity 14',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FCMService _fcmService = FCMService();
  String _statusText = 'Waiting for a cloud message';
  String _imagePath = 'assets/images/default.webp';
  String _lastAction = 'none';
  String _tokenText = 'Fetching token...';

  @override
  void initState() {
    super.initState();
    _initializeMessaging();
  }

  Future<void> _initializeMessaging() async {
    await _fcmService.initialize(
      onData: (RemoteMessage message) {
        final assetName = (message.data['asset'] as String?) ?? 'default';
        final action = (message.data['action'] as String?) ?? 'none';

        debugPrint('Message notification title: ${message.notification?.title}');
        debugPrint('Message data payload: ${message.data}');

        if (!mounted) {
          return;
        }

        setState(() {
          _statusText = message.notification?.title ?? 'Payload received';
          _imagePath = 'assets/images/$assetName.webp';
          _lastAction = action;
        });
      },
    );

    final token = await _fcmService.getToken();
    debugPrint('FCM token: $token');
    if (!mounted) {
      return;
    }
    setState(() {
      _tokenText = token ?? 'Token unavailable';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('FCM Activity 14')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text(
              _statusText,
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.asset(
                  _imagePath,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.grey.shade200,
                      alignment: Alignment.center,
                      child: const Text(
                        'Image not found.\nAdd default.webp and promo.webp in assets/images.',
                        textAlign: TextAlign.center,
                      ),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 16),
            SelectableText('FCM token: $_tokenText'),
            const SizedBox(height: 8),
            Text('Last action: $_lastAction'),
          ],
        ),
      ),
    );
  }
}