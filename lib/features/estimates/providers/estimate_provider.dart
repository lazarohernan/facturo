import 'package:facturo/features/estimates/models/estimate_model.dart';
import 'package:facturo/features/estimates/services/estimate_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Provider for the EstimateService
final estimateServiceProvider = Provider<EstimateService>((ref) {
  return EstimateService();
});

// Estimate list state
enum EstimateState { initial, loading, loaded, error }

class EstimateListData {
  final EstimateState state;
  final List<Estimate> estimates;
  final String? errorMessage;
  final String? searchQuery;

  EstimateListData({
    this.state = EstimateState.initial,
    this.estimates = const [],
    this.errorMessage,
    this.searchQuery,
  });

  EstimateListData copyWith({
    EstimateState? state,
    List<Estimate>? estimates,
    String? errorMessage,
    String? searchQuery,
  }) {
    return EstimateListData(
      state: state ?? this.state,
      estimates: estimates ?? this.estimates,
      errorMessage: errorMessage ?? this.errorMessage,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}

// Estimate list notifier
class EstimateListNotifier extends StateNotifier<EstimateListData> {
  final EstimateService _estimateService;

  EstimateListNotifier(this._estimateService) : super(EstimateListData());

  // Load all estimates
  Future<void> loadEstimates() async {
    try {
      state = state.copyWith(state: EstimateState.loading);
      final estimates = await _estimateService.getEstimates();
      state = state.copyWith(
        state: EstimateState.loaded,
        estimates: estimates,
        searchQuery: null,
      );
    } catch (e) {
      state = state.copyWith(
        state: EstimateState.error,
        errorMessage: e.toString(),
      );
    }
  }

  // Search estimates
  Future<void> searchEstimates(String query) async {
    if (query.isEmpty) {
      return loadEstimates();
    }

    try {
      state = state.copyWith(state: EstimateState.loading, searchQuery: query);
      final estimates = await _estimateService.searchEstimates(query);
      state = state.copyWith(state: EstimateState.loaded, estimates: estimates);
    } catch (e) {
      state = state.copyWith(
        state: EstimateState.error,
        errorMessage: e.toString(),
      );
    }
  }

  // Delete an estimate
  Future<void> deleteEstimate(String estimateId) async {
    try {
      await _estimateService.deleteEstimate(estimateId);
      state = state.copyWith(
        estimates:
            state.estimates
                .where((estimate) => estimate.id != estimateId)
                .toList(),
      );
    } catch (e) {
      state = state.copyWith(
        state: EstimateState.error,
        errorMessage: e.toString(),
      );
    }
  }
}

// Provider for the estimate list
final estimateListProvider =
    StateNotifierProvider<EstimateListNotifier, EstimateListData>((ref) {
      final estimateService = ref.watch(estimateServiceProvider);
      return EstimateListNotifier(estimateService);
    });

// Provider for a single estimate
final estimateProvider = FutureProvider.family<Estimate, String>((
  ref,
  estimateId,
) async {
  final estimateService = ref.watch(estimateServiceProvider);
  return estimateService.getEstimate(estimateId);
});
