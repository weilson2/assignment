import 'package:flutter/cupertino.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/supabase_config.dart';
import '../models/delivery_models.dart';
import 'dart:io';

class DeliveryService {
  final SupabaseClient _supabase = SupabaseConfig.client;

  //get today's delivery jobs
  Future<List<DeliveryJob>> getTodayJobs() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
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
          .or('status.eq.pending,assigned_personnel_id.eq.$userId')
          .order('scheduled_start_time', ascending: true);

      return (response as List)
          .map((json) => DeliveryJob.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception("Failed to fetch today's jobs: $e");
    }
  }

  //get job by ID
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

  //update job status
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

  //assign job to current user
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

  //upload proof image upload
  Future<String?> uploadProofImage(String jobId, File file) async {
    try {
      final fileExt = file.path.split('.').last;
      final fileName = 'proof_$jobId.${DateTime.now().millisecondsSinceEpoch}.$fileExt';

      final storage = Supabase.instance.client.storage.from('proofs'); // ✅ make sure you have a "proofs" bucket in Supabase
      await storage.upload(fileName, file);

      final publicUrl = storage.getPublicUrl(fileName);

      //update job with proof URL
      await Supabase.instance.client
          .from('delivery_jobs')
          .update({
        'status': 'delivered',
        'proof_image_url': publicUrl,
        'delivered_at': DateTime.now().toIso8601String(),
      })
          .eq('id', jobId);

      return publicUrl;
    } catch (e) {
      debugPrint("uploadProofImage error: $e");
      return null;
    }
  }

  //get jobs by status
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

  //get delivery history
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

  //simulate customer notification
  Future<bool> notifyCustomer(String jobId) async {
    try {
      await Future.delayed(const Duration(milliseconds: 500));
      return true;
    } catch (_) {
      return false;
    }
  }
}
