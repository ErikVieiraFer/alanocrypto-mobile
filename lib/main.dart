import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'theme/app_theme.dart';
import 'features/auth/screens/landing_screen.dart';
import 'features/auth/screens/login_screen.dart';
import 'features/auth/screens/signup_screen.dart';
import 'features/legal/screens/privacy_policy_screen.dart';
import 'features/legal/screens/terms_of_use_screen.dart';
// import 'features/auth/screens/email_verification_screen.dart'; // DESABILITADO - Fluxo direto sem verificação
import 'features/auth/screens/pending_approval_screen.dart';
import 'features/dashboard/screen/dashboard_screen.dart';
import 'features/placeholder/under_development_screen.dart';
import 'services/auth_service.dart';
import 'services/user_service.dart';
import 'services/fcm_service.dart';
import 'services/notification_preferences_service.dart';
import 'widgets/loading_screen.dart';
import 'package:alanocrypto/firebase_options.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'utils/web_notifications.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  debugPrint('📬 Notificação FCM recebida em background');

  // Se tem campo 'notification', o Firebase já mostrou automaticamente
  if (message.notification != null) {
    debugPrint('Título: ${message.notification?.title}');
    debugPrint('Corpo: ${message.notification?.body}');
  }

  // Se é mensagem data-only, o Firebase NÃO mostra automaticamente
  // Então precisamos mostrar manualmente (mas não aqui no background handler,
  // o sistema operacional já mostra baseado nos dados)
  if (message.data.isNotEmpty) {
    debugPrint('Data: ${message.data}');
  }
}

// Chave global de navegação
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void setupNotificationNavigation() {
  if (kIsWeb) {
    try {
      setupWebNotificationListener((data) {
        debugPrint('📱 Mensagem do SW recebida: ${data['notifType']}');
        _navigateFromNotification(data);
      });
      debugPrint('✅ Listener de navegação configurado');
    } catch (e) {
      debugPrint('❌ Erro ao configurar listener: $e');
    }
  }
}

void _navigateFromNotification(Map data) {
  debugPrint('🎯 Navegando da notificação: $data');

  final notifType = data['notifType']?.toString();

  if (notifType == null) {
    debugPrint('⚠️ notifType é null');
    return;
  }

  Future.delayed(const Duration(milliseconds: 500), () {
    final context = navigatorKey.currentContext;
    if (context == null) {
      debugPrint('❌ Context não disponível para navegação');
      return;
    }

    debugPrint('✅ Navegando para tipo: $notifType');

    switch (notifType) {
      case 'alano_post':
      case 'post':
        debugPrint('📝 Navegando para Posts do Alano');
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (context) => const DashboardScreen(initialIndex: 2),
          ),
          (route) => false,
        );
        break;

      case 'mention':
        debugPrint('💬 Navegando para Chat');
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (context) => const DashboardScreen(initialIndex: 1),
          ),
          (route) => false,
        );
        break;

      case 'signal':
        debugPrint('📊 Navegando para Sinais');
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (context) => const DashboardScreen(initialIndex: 3),
          ),
          (route) => false,
        );
        break;

      default:
        debugPrint('⚠️ Tipo de notificação não mapeado: $notifType');
    }
  });
}

void main() {
  FlutterError.onError = (FlutterErrorDetails details) {
    final error = details.exception.toString();
    if (error.contains('JavaScriptObject') ||
        error.contains('_testException') ||
        error.contains('ArgumentError')) {
      debugPrint(
        'Suprimindo erro conhecido do FlutterFire: ${details.exception}',
      );
      return;
    }
    FlutterError.presentError(details);
  };

  runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();

      // Carregar variáveis de ambiente
      try {
        await dotenv.load(fileName: ".env");
        debugPrint('✅ .env carregado com sucesso');
        debugPrint('📋 ADMIN_UID do .env: "${dotenv.env['ADMIN_UID']}"');
      } catch (e) {
        debugPrint('❌ Erro ao carregar .env: $e');
      }

      try {
        await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        );

        FirebaseFirestore.instance.settings = const Settings(
          persistenceEnabled: true,
          cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
        );
        debugPrint('✅ Firestore cache habilitado');

        if (!kIsWeb) {
          try {
            await FirebaseAppCheck.instance.activate(
              androidProvider: AndroidProvider.debug,
              appleProvider: AppleProvider.debug,
            );
            debugPrint('✅ Firebase App Check ativado');
          } catch (e) {
            debugPrint('⚠️ Firebase App Check não ativado (modo debug): $e');
          }
        }

        if (!kIsWeb) {
          FirebaseMessaging.onBackgroundMessage(
            _firebaseMessagingBackgroundHandler,
          );
        }
      } catch (e) {
        if (!e.toString().contains('duplicate-app')) {
          rethrow;
        }
      }

      timeago.setLocaleMessages('pt_BR', timeago.PtBrMessages());

      // Configurar navegação de notificações
      if (kIsWeb) {
        setupNotificationNavigation();
      }

      runApp(const MyApp());
    },
    (error, stack) {
      if (error.toString().contains('JavaScriptObject') ||
          error.toString().contains('_testException') ||
          error.toString().contains('ArgumentError')) {
        debugPrint(
          'Suprimindo erro assíncrono conhecido do FlutterFire: $error',
        );
        return;
      }
      debugPrint('Erro não tratado: $error');
      debugPrint('Stack trace: $stack');
    },
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
        systemNavigationBarColor: Color(0xFF0f0f0f),
        systemNavigationBarIconBrightness: Brightness.light,
      ),
    );

    return MaterialApp(
      title: 'AlanoCryptoFX',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
      themeMode: ThemeMode.dark,
      navigatorKey: navigatorKey,
      home: const AuthWrapper(),
      routes: {
        '/landing': (context) => const LandingScreen(),
        '/login': (context) => const LoginScreen(),
        '/signup': (context) => const SignupScreen(),
        // '/email-verification': (context) {
        //   final args = ModalRoute.of(context)!.settings.arguments as Map;
        //   return EmailVerificationScreen(
        //     email: args['email'],
        //     displayName: args['displayName'],
        //   );
        // }, // DESABILITADO - Fluxo direto sem verificação
        '/pending-approval': (context) => const PendingApprovalScreen(),
        '/dashboard': (context) => const DashboardScreen(),
        '/alano-posts': (context) => const DashboardScreen(initialIndex: 2),
        '/chat': (context) => const DashboardScreen(initialIndex: 1),
        '/signals': (context) => const DashboardScreen(initialIndex: 3),
        '/under-development': (context) {
          final pageName =
              ModalRoute.of(context)?.settings.arguments as String? ?? 'Página';
          return UnderDevelopmentScreen(pageName: pageName);
        },
        '/privacidade': (context) => const PrivacyPolicyScreen(),
        '/termos': (context) => const TermsOfUseScreen(),
      },
    );
  }
}

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  bool _fcmInitialized = false;
  bool _lastAccessUpdated = false;

  Future<void> _initializeFcm() async {
    if (!_fcmInitialized) {
      try {
        await FcmService().initialize();
        await NotificationPreferencesService().initializeDefaultPreferences();
        _fcmInitialized = true;
        debugPrint('✅ FCM Service e preferências inicializados no AuthWrapper');
      } catch (e) {
        debugPrint('❌ Erro ao inicializar FCM Service: $e');
      }
    }
  }

  Future<void> _updateLastAccess() async {
    if (!_lastAccessUpdated) {
      try {
        final user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .update({'lastAccess': FieldValue.serverTimestamp()});
          _lastAccessUpdated = true;
          debugPrint('✅ lastAccess atualizado para ${user.uid}');
        }
      } catch (e) {
        debugPrint('❌ Erro ao atualizar lastAccess: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();
    final userService = UserService();

    return StreamBuilder<User?>(
      stream: authService.authStateChanges,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const LoadingScreen(message: 'Verificando autenticação...');
        }

        if (snapshot.hasError) {
          return const LandingScreen();
        }

        if (snapshot.hasData && snapshot.data != null) {
          return FutureBuilder<bool>(
            future: userService.isUserApproved(snapshot.data!.uid),
            builder: (context, approvalSnapshot) {
              if (approvalSnapshot.connectionState == ConnectionState.waiting) {
                return const LoadingScreen(message: 'Verificando permissões...');
              }

              if (approvalSnapshot.hasData && approvalSnapshot.data == true) {
                _initializeFcm();
                _updateLastAccess();
                return const DashboardScreen();
              }

              return const PendingApprovalScreen();
            },
          );
        }

        return const LandingScreen();
      },
    );
  }
}
