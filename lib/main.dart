import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/stock_screen.dart';
import 'screens/delivery_details_screen.dart';
import 'screens/record_screen.dart';
import 'screens/profile_screen.dart';

void main() {
  runApp(const GreenstemApp());
}

class GreenstemApp extends StatelessWidget {
  const GreenstemApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Greenstem Parts Delivery',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: const Color(0xFF2E7D32),
        colorScheme: ColorScheme.fromSwatch().copyWith(
          primary: const Color(0xFF2E7D32),
          secondary: const Color(0xFF66BB6A),
        ),
        scaffoldBackgroundColor: Colors.white,
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF2E7D32),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            minimumSize: const Size(double.infinity, 50),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFFF1F8E9),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide.none,
          ),
          labelStyle: const TextStyle(color: Colors.black87),
        ),
      ),
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginScreen(),
        '/home': (context) => const HomeScreen(),
        '/stock': (context) => const StockScreen(),
        '/delivery-details': (context) => const DeliveryDetailsScreen(),
        '/record': (context) => const RecordScreen(),
        '/profile': (context) => const ProfileScreen(),
      },
    );
  }
}
