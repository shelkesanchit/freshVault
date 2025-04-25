// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/add_item_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/categories_screen.dart';
import 'screens/language_screen.dart';
import 'screens/template_screen.dart';
import 'screens/stats_screen.dart';
import 'screens/data_management_screen.dart';
import 'screens/shopping_list_screen.dart';
import 'screens/barcode_scanner_screen.dart';
import 'screens/calendar_screen.dart';
import 'screens/bulk_operations_screen.dart';
import 'providers/item_provider.dart';
import 'providers/category_provider.dart';
import 'providers/theme_provider.dart';
import 'providers/language_provider.dart';
import 'providers/user_provider.dart';
import 'providers/auth_provider.dart';
import 'providers/notification_provider.dart';
import 'utils/notification_service.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService().initNotification();
  final prefs = await SharedPreferences.getInstance();
  final isDarkMode = prefs.getBool('isDarkMode') ?? false;
  
  // Initialize user information with the latest timestamp
  final currentDateTime = DateTime.parse('2025-04-18 03:14:35');
  const currentUserLogin = 'shelkesanchit632003';
  
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  
  runApp(MyApp(
    isDarkMode: isDarkMode,
    currentDateTime: currentDateTime,
    currentUserLogin: currentUserLogin,
  ));
}

class MyApp extends StatelessWidget {
  final bool isDarkMode;
  final DateTime currentDateTime;
  final String currentUserLogin;
  
  const MyApp({
    Key? key, 
    required this.isDarkMode,
    required this.currentDateTime,
    required this.currentUserLogin,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (ctx) => ItemProvider()),
        ChangeNotifierProvider(create: (ctx) => CategoryProvider()),
        ChangeNotifierProvider(create: (ctx) => ThemeProvider(isDarkMode)),
        ChangeNotifierProvider(create: (ctx) => LanguageProvider()),
        ChangeNotifierProvider(create: (ctx) => AuthProvider()),
        ChangeNotifierProvider(create: (ctx) => NotificationProvider()),
        ChangeNotifierProvider(create: (ctx) => UserProvider(
          currentDateTime: currentDateTime,
          currentUserLogin: currentUserLogin,
        )),
      ],
      child: Consumer2<ThemeProvider, LanguageProvider>(
        builder: (ctx, themeProvider, languageProvider, _) => MaterialApp(
          title: 'Expiry Tracker',
          debugShowCheckedModeBanner: false,
          locale: languageProvider.currentLocale,
          supportedLocales: languageProvider.supportedLanguages
              .map((lang) => Locale(lang['code'] ?? 'en', ''))
              .toList(),
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          theme: ThemeData(
            primarySwatch: Colors.teal,
            colorScheme: ColorScheme.light(
              primary: Colors.teal,
              secondary: Colors.tealAccent,
            ),
            cardTheme: CardTheme(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            appBarTheme: const AppBarTheme(
              elevation: 2,
              backgroundColor: Colors.teal,
              foregroundColor: Colors.white,
            ),
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            inputDecorationTheme: InputDecorationTheme(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
            ),
          ),
          darkTheme: ThemeData(
            brightness: Brightness.dark,
            primarySwatch: Colors.teal,
            colorScheme: ColorScheme.dark(
              primary: Colors.teal,
              secondary: Colors.tealAccent,
              background: const Color(0xFF121212),
            ),
            cardTheme: CardTheme(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            appBarTheme: const AppBarTheme(
              elevation: 2,
              backgroundColor: Color(0xFF1E1E1E),
            ),
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            inputDecorationTheme: InputDecorationTheme(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
            ),
          ),
          themeMode: themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
          home: const SplashScreen(),
          routes: {
            SplashScreen.routeName: (ctx) => const SplashScreen(),
            LoginScreen.routeName: (ctx) => const LoginScreen(),
            HomeScreen.routeName: (ctx) => const HomeScreen(),
            AddItemScreen.routeName: (ctx) => const AddItemScreen(),
            SettingsScreen.routeName: (ctx) => const SettingsScreen(),
            CategoriesScreen.routeName: (ctx) => const CategoriesScreen(),
            LanguageScreen.routeName: (ctx) => const LanguageScreen(),
            TemplateScreen.routeName: (ctx) => const TemplateScreen(),
            StatsScreen.routeName: (ctx) => const StatsScreen(),
            DataManagementScreen.routeName: (ctx) => const DataManagementScreen(),
            ShoppingListScreen.routeName: (ctx) => const ShoppingListScreen(),
            BarcodeScannerScreen.routeName: (ctx) => const BarcodeScannerScreen(),
            CalendarScreen.routeName: (ctx) => const CalendarScreen(),
            BulkOperationsScreen.routeName: (ctx) => const BulkOperationsScreen(),
          },
        ),
      ),
    );
  }
}