import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/supabase_config.dart';
import '../models/delivery_models.dart';

class DeliveryService {
  final SupabaseClient _supabase = SupabaseConfig.client;

  /// Get today's delivery jobs
  Future<List<DeliveryJob>> getTodayJobs() async {
    try {
      final today = DateTime.now().toIso8601String().split('T')[0];

      final response = await _supabase
          .from('delivery_jobs')
          .select('''
            *,
            delivery_items (
              *,
              products (
                id,
                name,
                price,
                image_url,
                categories (name)
              )
            )
          ''')
          .eq('scheduled_date', today)
          .order('scheduled_start_time', ascending: true);

      return (response as List)
          .map((json) => DeliveryJob.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception("Failed to fetch today's jobs: $e");
    }
  }

  /// Get job by ID
  Future<DeliveryJob?> getJobById(String jobId) async {
    try {
      final response = await _supabase
          .from('delivery_jobs')
          .select('''
            *,
            delivery_items (
              *,
              products (id, name, image_url)
            )
          ''')
          .eq('id', jobId)
          .maybeSingle();

      if (response == null) return null;
      return DeliveryJob.fromJson(response);
    } catch (e) {
      throw Exception("Failed to fetch job: $e");
    }
  }

  /// Update job status
  Future<bool> updateJobStatus(String jobId, String newStatus) async {
    try {
      await _supabase.from('delivery_jobs').update({
        'status': newStatus,
        'updated_at': DateTime.now().toIso8601String(),
        if (newStatus == 'delivered')
          'delivered_at': DateTime.now().toIso8601String(),
      }).eq('id', jobId);

      return true;
    } catch (e) {
      throw Exception("Failed to update status: $e");
    }
  }

  /// Assign job to current user
  Future<bool> assignJobToCurrentUser(String jobId, String userId) async {
    try {
      await _supabase.from('delivery_jobs').update({
        'assigned_personnel_id': userId,
        'status': 'picked_up',
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', jobId);

      return true;
    } catch (e) {
      throw Exception("Failed to assign job: $e");
    }
  }

  /// Simulate proof image upload
  Future<String?> simulateUploadProofImage(String jobId) async {
    try {
      final fakeUrl =
          "https://fake-storage.com/proofs/$jobId/${DateTime.now().millisecondsSinceEpoch}.jpg";

      await _supabase.from('delivery_jobs').update({
        'proof_image_url': fakeUrl,
        'status': 'delivered',
        'delivered_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', jobId);

      return fakeUrl;
    } catch (e) {
      throw Exception("Failed to simulate proof upload: $e");
    }
  }

  /// Get jobs by status
  Future<List<DeliveryJob>> getJobsByStatus(String status) async {
    try {
      final response = await _supabase
          .from('delivery_jobs')
          .select('''
            *,
            delivery_items (
              *,
              products (
                id,
                name,
                price,
                image_url,
                categories (name)
              )
            )
          ''')
          .eq('status', status)
          .order('scheduled_date', ascending: false);

      return (response as List)
          .map((json) => DeliveryJob.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception("Failed to fetch jobs by status: $e");
    }
  }

  /// Get delivery history
  Future<List<DeliveryJob>> getDeliveryHistory() async {
    try {
      final response = await _supabase
          .from('delivery_jobs')
          .select('''
            *,
            delivery_items (
              *,
              products (
                id,
                name,
                price,
                image_url,
                categories (name)
              )
            )
          ''')
          .order('scheduled_date', ascending: false);

      return (response as List)
          .map((json) => DeliveryJob.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception("Failed to fetch delivery history: $e");
    }
  }

  /// Simulate customer notification
  Future<bool> notifyCustomer(String jobId) async {
    try {
      await Future.delayed(const Duration(milliseconds: 500));
      return true;
    } catch (_) {
      return false;
    }
  }
}
