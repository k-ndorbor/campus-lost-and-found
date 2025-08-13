import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:provider/provider.dart';

import 'firebase_options.dart';
import 'screens/home_screen.dart';
import 'screens/lost_items_screen.dart';
import 'screens/found_items_screen.dart';
import 'screens/item_detail_screen.dart';
import 'screens/login_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/splash_screen.dart';
import 'screens/post_found_item_screen.dart';
import 'screens/report_lost_item_screen.dart';

final GoRouter _router = GoRouter(
  routes: <RouteBase>[
    GoRoute(
      path: '/',
      builder: (BuildContext context, GoRouterState state) {
        return const SplashScreen();
      },
    ),
    GoRoute(
        return const HomeScreen();
      },
    ),
    GoRoute(
      path: '/lost-items',
      builder: (BuildContext context, GoRouterState state) {
        return const LostItemsScreen();
      },
    ),
    GoRoute(
      path: '/found-items',
      builder: (BuildContext context, GoRouterState state) {
        return const FoundItemsScreen();
      },
    ),
    GoRoute(
      path: '/post-found-item',
      builder: (BuildContext context, GoRouterState state) {
        return const PostFoundItemScreen();
      },
    ),
    GoRoute(
      path: '/report-lost-item',
      builder: (BuildContext context, GoRouterState state) {
        return const ReportLostItemScreen();
      },
    ),
    GoRoute(
      path: '/splash',
      builder: (BuildContext context, GoRouterState state) {
        return const SplashScreen();
      },
    ),
      path: '/login',
      builder: (BuildContext context, GoRouterState state) {
        return const LoginScreen();
      },
    ),
    GoRoute(
      path: '/signup',
      builder: (BuildContext context, GoRouterState state) {
        return const SignupScreen();
      },
    ),
    GoRoute(
      path: '/items/:itemId',
      builder: (BuildContext context, GoRouterState state) {
        return ItemDetailScreen(itemId: state.pathParameters['itemId']!);
      },
    ),
  ],
  redirect: (BuildContext context, GoRouterState state) {
    final bool loggedIn = FirebaseAuth.instance.currentUser != null;
    final String location = state.matchedLocation ?? '/';
    final bool isAuthPage = location == '/login' || location == '/signup';

    if (!loggedIn && !isAuthPage) {
      return '/login';
    }

    if (loggedIn && isAuthPage) {
      return '/';
    }

    return null; // No redirect
  },
);

Future<void> main() async {
  // Ensure that Flutter is initialized.
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(
    StreamProvider<User?>.value(
      value: FirebaseAuth.instance.authStateChanges(),
      initialData: null,
      child: ChangeNotifierProvider(
        create: (context) =>
            ThemeProvider(), // Assuming you have a ThemeProvider
        child: const MyApp(),
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Campus Lost and Found System',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        textTheme: GoogleFonts.nunitoTextTheme(
          Theme.of(context).textTheme,
        ),
        useMaterial3: true,
      ),
      routerConfig: _router,
    );
  }
}

// Placeholder ThemeProvider - Replace with your actual theme management logic
class ThemeProvider with ChangeNotifier {
  final ThemeData _themeData = ThemeData(
    primarySwatch: Colors.blue,
    visualDensity: VisualDensity.adaptivePlatformDensity,
    textTheme: GoogleFonts.nunitoTextTheme(),
    useMaterial3: true,
  );

  ThemeData get themeData => _themeData;

  // Add methods to change theme if needed
  void setTheme(ThemeData theme) {}
}
