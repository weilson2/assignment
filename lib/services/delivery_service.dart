import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/supabase_config.dart';
import '../models/delivery_models.dart';

class DeliveryService {
  final SupabaseClient _supabase = SupabaseConfig.client;

  // Get today's delivery jobs for current user
  Future<List<DeliveryJob>> getTodayJobs() async {
    try {
      final today = DateTime.now();
      final todayString = today.toIso8601String().split('T')[0];

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
                categories (
                  name
                )
              )
            )
          ''')
          .eq('scheduled_date', todayString)
          .order('scheduled_start_time', ascending: true);

      return (response as List)
          .map((json) => DeliveryJob.fromJson(json))
          .toList();
    } catch (error) {
      throw Exception('Failed to fetch today\'s jobs: $error');
    }
  }

  // Get single delivery job by ID
  Future<DeliveryJob?> getJobById(String jobId) async {
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
                image_url
              )
            )
          ''')
          .eq('id', jobId)
          .maybeSingle();

      if (response == null) return null;

      return DeliveryJob.fromJson(response);
    } catch (error) {
      throw Exception('Failed to fetch job: $error');
    }
  }

  // Update job status
  Future<bool> updateJobStatus(String jobId, String newStatus) async {
    try {
      await _supabase
          .from('delivery_jobs')
          .update({
        'status': newStatus,
        'updated_at': DateTime.now().toIso8601String(),
        if (newStatus == 'delivered') 'delivered_at': DateTime.now().toIso8601String(),
      })
          .eq('id', jobId);

      return true;
    } catch (error) {
      throw Exception('Failed to update job status: $error');
    }
  }

  // Simulate uploading proof image (for assignment without actual storage)
  Future<String?> simulateUploadProofImage(String jobId) async {
    try {
      // Generate a fake image URL for demonstration
      final fakeImageUrl = 'https://fake-storage.com/delivery_proofs/$jobId/proof_${DateTime.now().millisecondsSinceEpoch}.jpg';

      // Update job with fake proof image URL and mark as delivered
      await _supabase
          .from('delivery_jobs')
          .update({
        'proof_image_url': fakeImageUrl,
        'status': 'delivered',
        'delivered_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      })
          .eq('id', jobId);

      return fakeImageUrl;
    } catch (error) {
      throw Exception('Failed to simulate proof upload: $error');
    }
  }

  // Get delivery jobs by status
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
                categories (
                  name
                )
              )
            )
          ''')
          .eq('status', status)
          .order('scheduled_date', ascending: false);

      return (response as List)
          .map((json) => DeliveryJob.fromJson(json))
          .toList();
    } catch (error) {
      throw Exception('Failed to fetch jobs by status: $error');
    }
  }

  // Get all delivery history
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
                categories (
                  name
                )
              )
            )
          ''')
          .order('scheduled_date', ascending: false);

      return (response as List)
          .map((json) => DeliveryJob.fromJson(json))
          .toList();
    } catch (error) {
      throw Exception('Failed to fetch delivery history: $error');
    }
  }

  // Assign job to current user (personnel)
  Future<bool> assignJobToCurrentUser(String jobId, String userId) async {
    try {
      await _supabase
          .from('delivery_jobs')
          .update({
        'assigned_personnel_id': userId,
        'status': 'picked_up',
        'updated_at': DateTime.now().toIso8601String(),
      })
          .eq('id', jobId);

      return true;
    } catch (error) {
      throw Exception('Failed to assign job: $error');
    }
  }

  // Simulate customer notification
  Future<bool> notifyCustomer(String jobId) async {
    try {
      // In a real app, this would send SMS/email to customer
      // For assignment, we'll just simulate with a delay
      await Future.delayed(const Duration(milliseconds: 500));

      return true;
    } catch (error) {
      return false;
    }
  }

  Future<DeliveryJob?> getJobWithItems(String jobId) async {
    final response = await _supabase
        .from('delivery_jobs')
        .select('''
        *,
        delivery_items (
          id,
          product_id,
          quantity,
          products (
            id,
            name
          )
        )
      ''')
        .eq('id', jobId)
        .single();



    return DeliveryJob.fromJson(response);
  }

}