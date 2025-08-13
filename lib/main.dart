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
import 'screens/splash_screen.dart' show AnimatedSplashScreen;
import 'screens/post_found_item_screen.dart';
import 'screens/report_lost_item_screen.dart';
import 'services/item_service.dart';

final GoRouter _router = GoRouter(
  routes: <RouteBase>[
    // Initial route (Splash Screen)
    GoRoute(
      path: '/',
      builder: (BuildContext context, GoRouterState state) {
        return const AnimatedSplashScreen();
      },
    ),
    // Authentication Screens
    GoRoute(
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
    // Main App Screens
    GoRoute(
      path: '/home',
      builder: (BuildContext context, GoRouterState state) {
        return  HomeScreen();
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
      path: '/items/:itemId',
      builder: (BuildContext context, GoRouterState state) {
        return ItemDetailScreen(itemId: state.pathParameters['itemId']!);
      },
    ),
  ],
  redirect: (BuildContext context, GoRouterState state) {
    final bool isLoggedIn = FirebaseAuth.instance.currentUser != null;
    final String currentLocation = state.matchedLocation;
    final bool isAuthPage = currentLocation == '/login' || currentLocation == '/signup' || currentLocation == '/';

    // If user is not logged in and not on an auth page, redirect to login
    if (!isLoggedIn && !isAuthPage) {
      return '/login';
    }

    // If user is logged in and on an auth page, redirect to home
    if (isLoggedIn && isAuthPage && currentLocation != '/') {
      return '/home';
    }

    // No redirect needed
    return null;
  },
);

Future<void> main() async {
  // Ensure that Flutter is initialized.
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  runApp(
    MultiProvider(
      providers: [
        // Stream for authentication state
        StreamProvider<User?>(
          initialData: null,
          create: (context) => FirebaseAuth.instance.authStateChanges(),
        ),
        // Theme provider
        ChangeNotifierProvider(
          create: (context) => ThemeProvider(),
        ),
        // ItemService provider
        ChangeNotifierProvider<ItemService>(
          create: (context) => ItemService(),
        ),
      ],
      child: const MyApp(),
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
