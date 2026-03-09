import 'package:facturo/features/estimates/models/estimate_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class EstimateService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Get all estimates for the current user
  Future<List<Estimate>> getEstimates() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      final response = await _supabase
          .from('estimates')
          .select()
          .eq('user_id', userId)
          .eq('status', true)
          .order('document_date', ascending: false);

      // Convert response to Estimate objects
      final estimates =
          response.map<Estimate>((json) => Estimate.fromJson(json)).toList();

      // Load details for each estimate
      for (var i = 0; i < estimates.length; i++) {
        final details = await getEstimateDetails(estimates[i].id);
        estimates[i] = estimates[i].copyWith(details: details);
      }

      return estimates;
    } catch (e) {
      throw Exception('Failed to get estimates: $e');
    }
  }

  // Get estimate details
  Future<List<EstimateDetail>> getEstimateDetails(String estimateId) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      final response = await _supabase
          .from('estimate_detail')
          .select()
          .eq('estimate_id', estimateId)
          .eq('user_id', userId);

      return response
          .map<EstimateDetail>((json) => EstimateDetail.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to get estimate details: $e');
    }
  }

  // Get a single estimate with its details
  Future<Estimate> getEstimate(String estimateId) async {
    try {
      final estimateResponse =
          await _supabase
              .from('estimates')
              .select()
              .eq('id', estimateId)
              .single();

      final estimate = Estimate.fromJson(estimateResponse);

      // Get estimate details
      final details = await getEstimateDetails(estimateId);

      return estimate.copyWith(details: details);
    } catch (e) {
      throw Exception('Failed to get estimate: $e');
    }
  }

  // Create a new estimate
  Future<Estimate> createEstimate(Estimate estimate) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      // Create estimate
      final estimateData = estimate.toJson();
      estimateData['user_id'] = userId;

      final response =
          await _supabase
              .from('estimates')
              .insert(estimateData)
              .select()
              .single();

      final createdEstimate = Estimate.fromJson(response);

      // Create estimate details if available
      if (estimate.details != null && estimate.details!.isNotEmpty) {
        for (var detail in estimate.details!) {
          final detailData = detail.toJson();
          detailData['estimate_id'] = createdEstimate.id;
          detailData['user_id'] = userId;

          await _supabase.from('estimate_detail').insert(detailData);
        }
      }

      return createdEstimate;
    } catch (e) {
      throw Exception('Failed to create estimate: $e');
    }
  }

  // Update an existing estimate
  Future<Estimate> updateEstimate(Estimate estimate) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      // Update estimate
      final estimateData = estimate.toJson();
      estimateData['user_id'] = userId; // Ensure user_id is included

      final response =
          await _supabase
              .from('estimates')
              .update(estimateData)
              .eq('id', estimate.id)
              .eq('user_id', userId) // Add user_id to the where clause
              .select()
              .single();

      final updatedEstimate = Estimate.fromJson(response);

      // Handle estimate details
      if (estimate.details != null) {
        // First, delete existing details
        await _supabase
            .from('estimate_detail')
            .delete()
            .eq('estimate_id', estimate.id)
            .eq('user_id', userId); // Add user_id to the where clause

        // Then, insert new details
        for (var detail in estimate.details!) {
          final detailData = detail.toJson();
          detailData['estimate_id'] = updatedEstimate.id;
          detailData['user_id'] = userId;

          await _supabase.from('estimate_detail').insert(detailData);
        }
      }

      return updatedEstimate;
    } catch (e) {
      throw Exception('Failed to update estimate: $e');
    }
  }

  // Delete an estimate (soft delete by setting status to false)
  Future<void> deleteEstimate(String estimateId) async {
    try {
      await _supabase
          .from('estimates')
          .update({'status': false})
          .eq('id', estimateId);
    } catch (e) {
      throw Exception('Failed to delete estimate: $e');
    }
  }

  // Search estimates
  Future<List<Estimate>> searchEstimates(String query) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      final response = await _supabase
          .from('estimates')
          .select()
          .eq('user_id', userId)
          .eq('status', true)
          .or(
            'document_number.ilike.%$query%,notes.ilike.%$query%,po_number.ilike.%$query%',
          )
          .order('document_date', ascending: false);

      // Convert response to Estimate objects
      final estimates =
          response.map<Estimate>((json) => Estimate.fromJson(json)).toList();

      // Load details for each estimate
      for (var i = 0; i < estimates.length; i++) {
        final details = await getEstimateDetails(estimates[i].id);
        estimates[i] = estimates[i].copyWith(details: details);
      }

      return estimates;
    } catch (e) {
      throw Exception('Failed to search estimates: $e');
    }
  }

  // Helper method to create an EstimateDetail with the current user's ID
  EstimateDetail createEstimateDetailWithUserId({
    required String estimateId,
    String? description,
    double? unitCost,
    double? quantity,
    String? discountType,
    double? discountAmount,
    bool? taxable,
    String? additionalDetails,
  }) {
    final userId = _supabase.auth.currentUser?.id;

    return EstimateDetail(
      estimateId: estimateId,
      description: description,
      unitCost: unitCost,
      quantity: quantity,
      discountType: discountType,
      discountAmount: discountAmount,
      taxable: taxable,
      additionalDetails: additionalDetails,
      userId: userId,
    );
  }
}
