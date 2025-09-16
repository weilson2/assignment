import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseConfig {
  static const String supabaseUrl = 'https://jwflsfbaupvwwmvrismt.supabase.co';
  static const String supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imp3ZmxzZmJhdXB2d3dtdnJpc210Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTc5OTYyNDIsImV4cCI6MjA3MzU3MjI0Mn0.0Ff8JOY947CHc2X5BdeTKwtvUjsoNR5pWM8UQy5OtKc';

  static Future<void> initialize() async {
    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
    );
  }

  static SupabaseClient get client => Supabase.instance.client;
}