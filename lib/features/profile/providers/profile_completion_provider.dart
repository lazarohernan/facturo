import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'user_profile_provider.dart';

/// Modelo para representar el estado de completado del perfil
class ProfileCompletion {
  final int percentage;
  final bool isComplete;
  final List<String> missingFields;
  final bool step1Complete;
  final bool step2Complete;
  final bool step3Complete;

  const ProfileCompletion({
    this.percentage = 0,
    this.isComplete = false,
    this.missingFields = const [],
    this.step1Complete = false,
    this.step2Complete = false,
    this.step3Complete = false,
  });
}

/// Provider que calcula el porcentaje de completado del perfil
final profileCompletionProvider = Provider<ProfileCompletion>((ref) {
  final profile = ref.watch(userProfileProvider);

  // Verificar campos individuales de forma segura
  final hasFullName = profile.fullName != null && profile.fullName!.trim().isNotEmpty;
  final hasEmail = profile.email != null && profile.email!.trim().isNotEmpty;
  final hasBusinessName = profile.businessName != null && profile.businessName!.trim().isNotEmpty;
  final hasTel = profile.tel != null && profile.tel!.trim().isNotEmpty;
  final hasAddress = profile.address != null && profile.address!.trim().isNotEmpty;
  final hasBusinessNumber = profile.businessNumber != null && profile.businessNumber!.trim().isNotEmpty;

  // Contar campos completados (5 campos principales)
  int completedCount = 0;
  List<String> missing = [];

  if (hasFullName) {
    completedCount++;
  } else {
    missing.add('fullName');
  }
  if (hasEmail) {
    completedCount++;
  } else {
    missing.add('email');
  }
  if (hasBusinessName) {
    completedCount++;
  } else {
    missing.add('businessName');
  }
  if (hasTel) {
    completedCount++;
  } else {
    missing.add('tel');
  }
  if (hasAddress) {
    completedCount++;
  } else {
    missing.add('address');
  }

  // Calcular porcentaje
  final percentage = completedCount > 0 ? ((completedCount / 5) * 100).round() : 0;

  // Calcular qué pasos están completados
  final step1Complete = hasFullName && hasEmail;
  final step2Complete = hasBusinessName && hasTel && hasAddress;
  final step3Complete = hasBusinessNumber;

  return ProfileCompletion(
    percentage: percentage,
    isComplete: percentage >= 100,
    missingFields: missing,
    step1Complete: step1Complete,
    step2Complete: step2Complete,
    step3Complete: step3Complete,
  );
});
