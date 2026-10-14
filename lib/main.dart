import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mech_go/Admin/Admin_Authentication/admin_bloc.dart';
import 'package:mech_go/Admin/Admin_Authentication/admin_repo.dart';
import 'package:mech_go/OTP/auth_bloc.dart';
import 'package:mech_go/OTP/auth_repo.dart';
import 'package:mech_go/Services/theme_controller.dart';
import 'package:mech_go/firebase_options.dart';
import 'package:mech_go/splash_screen.dart';




Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await ThemeController.instance.loadTheme();

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => AuthBloc(
            authRepository: AuthRepository(),
          ),
        ),

        BlocProvider(
          create: (context) => AdminBloc(
            adminRepository: AdminRepository()
          ),
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
    return ValueListenableBuilder<ThemeMode>(
  valueListenable:
      ThemeController.instance.themeMode,
  builder: (context, themeMode, child) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      themeMode: themeMode,

      theme: ThemeData(
        brightness: Brightness.light,
        scaffoldBackgroundColor: Colors.white,

        colorScheme: ColorScheme.fromSeed(
          seedColor:
              const Color.fromARGB(
            255,
            198,
            24,
            11,
          ),
          brightness: Brightness.light,
        ),

        appBarTheme: const AppBarTheme(
          backgroundColor:
              Color.fromARGB(255, 198, 24, 11),
          foregroundColor: Colors.white,
        ),

        bottomNavigationBarTheme:
            const BottomNavigationBarThemeData(
          backgroundColor:
              Color.fromARGB(255, 198, 24, 11),
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.white70,
        ),
      ),

      darkTheme: ThemeData(
        brightness: Brightness.dark,

        scaffoldBackgroundColor:
            Colors.black,

        colorScheme: ColorScheme.fromSeed(
          seedColor:
              const Color.fromARGB(
            255,
            198,
            24,
            11,
          ),
          brightness: Brightness.dark,
        ),

        // KEEP APP BAR RED
        appBarTheme: const AppBarTheme(
          backgroundColor:
              Color.fromARGB(255, 198, 24, 11),
          foregroundColor: Colors.white,
        ),

        // KEEP BOTTOM NAV RED
        bottomNavigationBarTheme:
            const BottomNavigationBarThemeData(
          backgroundColor:
              Color.fromARGB(255, 198, 24, 11),
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.white70,
        ),

        // Cards become dark
        cardTheme: const CardThemeData(
          color: Color(0xFF151515),
        ),

        // Input fields
        inputDecorationTheme:
            const InputDecorationTheme(
          filled: true,
          fillColor: Color(0xFF151515),
        ),

        // Main text
        textTheme: const TextTheme(
          bodyLarge: TextStyle(
            color: Colors.white,
          ),
          bodyMedium: TextStyle(
            color: Colors.white,
          ),
          bodySmall: TextStyle(
            color: Colors.white70,
          ),
        ),
      ),

      home: SplashScreen(),
    );
  },
);
  }
}