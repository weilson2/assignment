import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/supabase_config.dart';
import '../models/user_model.dart';

class AuthService {
  final SupabaseClient _supabase = SupabaseConfig.client;

  // Get current user
  User? get currentUser => _supabase.auth.currentUser;

  // Check if user is logged in
  bool get isLoggedIn => currentUser != null;

  // Helper function to ensure fake emails work with Supabase
  String _ensureFakeEmailWorks(String email) {
    String cleanEmail = email.toLowerCase().trim();

    // If it already looks like a valid email format, use it
    if (RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$').hasMatch(cleanEmail)) {
      return cleanEmail;
    }

    // If it's not a valid format, make it valid
    String username = cleanEmail.split('@')[0];
    if (username.isEmpty) {
      username = 'user${DateTime.now().millisecondsSinceEpoch}';
    }

    return '$username@example.com';
  }

  // Sign up new user - FAKE DATA FRIENDLY VERSION
  Future<AuthResponse> signUp({
    required String email,
    required String password,
    required String fullName,
    required String phoneNumber,
  }) async {
    try {
      // Process email to ensure it works with Supabase (for fake data)
      String processedEmail = _ensureFakeEmailWorks(email);

      final AuthResponse response = await _supabase.auth.signUp(
        email: processedEmail,
        password: password,
        data: {
          'full_name': fullName,
          'phone_number': phoneNumber,
          'original_email': email, // Store the original email user entered
        },
      );

      // Try to create profile if user was created
      if (response.user != null) {
        try {
          await _supabase.from('profiles').insert({
            'id': response.user!.id,
            'full_name': fullName,
            'email': email, // Store original email in profiles table
            'phone_number': phoneNumber,
            'created_at': DateTime.now().toIso8601String(),
          });
        } catch (profileError) {
          print('Profile creation error: $profileError');
        }
      }

      return response;
    } on AuthException catch (error) {
      String message = error.message;

      if (message.toLowerCase().contains('already')) {
        throw Exception('This email is already registered. Try signing in instead.');
      } else if (message.toLowerCase().contains('weak')) {
        throw Exception('Password is too weak. Please use a stronger password.');
      } else {
        throw Exception('Registration failed: $message');
      }
    } catch (error) {
      throw Exception('Registration failed: $error');
    }
  }

  // Sign in user - HANDLES FAKE EMAIL MAPPING
  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    try {
      // Use the same email processing as sign-up to ensure consistency
      String processedEmail = _ensureFakeEmailWorks(email);

      final AuthResponse response = await _supabase.auth.signInWithPassword(
        email: processedEmail,
        password: password,
      );

      return response;
    } on AuthException catch (error) {
      String message = error.message;


      if (message.toLowerCase().contains('invalid')) {
        throw Exception('Invalid email or password. Please check your credentials.');
      } else if (message.toLowerCase().contains('not confirmed')) {
        throw Exception('Please verify your email before signing in.');
      } else {
        throw Exception('Sign in failed: $message');
      }
    } catch (error) {
      throw Exception('Sign in failed: $error');
    }
  }

  // Sign out user
  Future<void> signOut() async {
    try {
      await _supabase.auth.signOut();
    } catch (error) {
      rethrow;
    }
  }

  // Reset password
  Future<void> resetPassword(String email) async {
    try {
      String processedEmail = _ensureFakeEmailWorks(email);
      await _supabase.auth.resetPasswordForEmail(processedEmail);
    } on AuthException catch (error) {
      throw Exception('Password reset failed: ${error.message}');
    } catch (error) {
      throw Exception('Password reset failed: $error');
    }
  }

  // Get user profile
  Future<UserModel?> getUserProfile() async {
    try {
      if (currentUser == null) return null;

      // Try to get from profiles table first
      try {
        final response = await _supabase
            .from('profiles')
            .select()
            .eq('id', currentUser!.id)
            .single();

        return UserModel.fromJson(response);
      } catch (e) {
        // If profiles table fails, create from auth metadata
        return UserModel(
          id: currentUser!.id,
          fullName: currentUser!.userMetadata?['full_name'] ?? 'User',
          email: currentUser!.userMetadata?['original_email'] ?? currentUser!.email ?? 'user@example.com',
          phoneNumber: currentUser!.userMetadata?['phone_number'] ?? '012-3456789',
          createdAt: DateTime.parse(currentUser!.createdAt),
        );
      }
    } catch (error) {
      return null;
    }
  }

  // Update user profile
  Future<bool> updateUserProfile({
    required String fullName,
    required String phoneNumber,
  }) async {
    try {
      if (currentUser == null) return false;

      // Try updating profiles table first
      try {
        await _supabase.from('profiles').update({
          'full_name': fullName,
          'phone_number': phoneNumber,
          'updated_at': DateTime.now().toIso8601String(),
        }).eq('id', currentUser!.id);
      } catch (e) {
        // If profiles table fails, update auth metadata
        await _supabase.auth.updateUser(
          UserAttributes(
            data: {
              'full_name': fullName,
              'phone_number': phoneNumber,
            },
          ),
        );
      }

      return true;
    } catch (error) {
      return false;
    }
  }

  // Listen to auth state changes
  Stream<AuthState> get authStateStream => _supabase.auth.onAuthStateChange;
}