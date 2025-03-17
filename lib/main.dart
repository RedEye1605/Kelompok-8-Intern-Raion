import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:my_flutter_app/features/presentation/screens/Auth/forgot_password.dart';
import 'package:my_flutter_app/features/presentation/screens/Settings/help_report_screen.dart';
import 'package:my_flutter_app/features/presentation/screens/Home/edit_profile.dart';
import 'package:my_flutter_app/features/presentation/screens/Home/home_page.dart';
import 'package:my_flutter_app/features/presentation/screens/Home/search_page.dart';
import 'firebase_options.dart';
import 'package:provider/provider.dart';
import 'features/presentation/screens/Auth/login_screen.dart';
import 'features/presentation/screens/Auth/register_screen.dart';
import 'features/presentation/providers/auth_provider.dart';
import 'features/presentation/providers/home_provider.dart';
import 'di/injection_container.dart' as di;
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'features/presentation/screens/Settings/settings_screen.dart';
import 'features/presentation/screens/Settings/rate_us_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  di.setupDependencyInjection();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create:
              (_) => AuthProvider(
                loginUser: di.sl(),
                registerUser: di.sl(),
                loginWithGoogle: di.sl(),
              ),
        ),
        ChangeNotifierProvider(create: (_) => di.sl<HomeProvider>()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'My Flutter App',
        theme: ThemeData(primarySwatch: Colors.blue),
        home: Consumer<AuthProvider>(
          builder: (context, authProvider, _) {
            return StreamBuilder<firebase_auth.User?>(
              stream: firebase_auth.FirebaseAuth.instance.authStateChanges(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Scaffold(
                    body: Center(child: CircularProgressIndicator()),
                  );
                }
                if (snapshot.hasData) {
                  return HomePage();
                }
                return const LoginScreen();
              },
            );
          },
        ),
        routes: {
          '/login': (context) => const LoginScreen(),
          '/register': (context) => const RegisterScreen(),
          '/forgot_password': (context) => const ForgotPassword(),
          '/settings': (context) => const SettingsScreen(),
          '/help': (context) => const HelpReportScreen(),
          '/rate': (context) => const RateUsScreen(),
          '/home': (context) => const HomePage(),
          '/search': (context) => const SearchPage(),
          '/edit_profile': (context) => const EditProfile(),
        },
      ),
    );
  }
}
