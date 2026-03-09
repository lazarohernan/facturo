import 'package:facturo/core/services/storage_service.dart';
import 'package:facturo/features/auth/controllers/auth_controller.dart';
import 'package:facturo/features/auth/services/user_profile_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:io';

// User profile state
enum UserProfileState { initial, loading, loaded, error }

// User profile data class
class UserProfile {
  final String? id;
  final String? fullName;
  final String? businessName;
  final String? businessNumber;
  final String? address;
  final String? tel;
  final String? website;
  final String? email;
  final String? profileImg;
  final String? signatureUrl;
  final String? businessLogoUrl;
  final UserProfileState state;
  final String? errorMessage;

  // Getters para compatibilidad
  String? get name => fullName;
  String? get phone => tel;

  UserProfile({
    this.id,
    this.fullName,
    this.businessName,
    this.businessNumber,
    this.address,
    this.tel,
    this.website,
    this.email,
    this.profileImg,
    this.signatureUrl,
    this.businessLogoUrl,
    this.state = UserProfileState.initial,
    this.errorMessage,
  });

  UserProfile copyWith({
    String? id,
    String? fullName,
    String? businessName,
    String? businessNumber,
    String? address,
    String? tel,
    String? website,
    String? email,
    String? profileImg,
    String? signatureUrl,
    String? businessLogoUrl,
    UserProfileState? state,
    String? errorMessage,
  }) {
    return UserProfile(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      businessName: businessName ?? this.businessName,
      businessNumber: businessNumber ?? this.businessNumber,
      address: address ?? this.address,
      tel: tel ?? this.tel,
      website: website ?? this.website,
      email: email ?? this.email,
      profileImg: profileImg ?? this.profileImg,
      signatureUrl: signatureUrl ?? this.signatureUrl,
      businessLogoUrl: businessLogoUrl ?? this.businessLogoUrl,
      state: state ?? this.state,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

// User profile notifier
class UserProfileNotifier extends StateNotifier<UserProfile> {
  final Ref ref;

  UserProfileNotifier(this.ref) : super(UserProfile()) {
    // Don't load profile automatically - wait for explicit call
    // This prevents loading before auth is ready
  }

  // Load user profile manually
  Future<void> loadUserProfile() async {
    try {
      state = state.copyWith(state: UserProfileState.loading);

      final authState = ref.read(authControllerProvider);
      // Permitir tanto usuarios autenticados como anónimos
      if (authState.user == null) {
        state = state.copyWith(
          state: UserProfileState.error,
          errorMessage: 'User not authenticated',
        );
        return;
      }

      final userProfileService = ref.read(userProfileServiceProvider);
      final profileData = await userProfileService.getUserProfile(
        authState.user!.id,
      );

      if (profileData != null) {
        // Resolve signed URLs for images stored as paths
        final storageService = StorageService(Supabase.instance.client);
        final resolvedProfileImg = await storageService.getSignedUrl(
          profileData['profile_img'] as String?,
        );
        final resolvedSignatureUrl = await storageService.getSignedUrl(
          profileData['signature_url'] as String?,
        );
        final resolvedBusinessLogoUrl = await storageService.getSignedUrl(
          profileData['business_logo_url'] as String?,
        );

        state = state.copyWith(
          state: UserProfileState.loaded,
          id: profileData['id'] as String?,
          fullName: profileData['full_name'] as String?,
          email: profileData['email'] as String?,
          businessName: profileData['business_name'] as String?,
          businessNumber: profileData['business_number'] as String?,
          address: profileData['address'] as String?,
          tel: profileData['tel'] as String?,
          website: profileData['website'] as String?,
          profileImg: resolvedProfileImg,
          signatureUrl: resolvedSignatureUrl,
          businessLogoUrl: resolvedBusinessLogoUrl,
        );
      } else {
        // No profile found, creating new one
        await userProfileService.createUserProfile(
          userUuid: authState.user!.id,
          fullName: '', // String vacío para usuarios anónimos (no cuenta como completado)
          email: authState.user!.email,
        );

        // Since the profile was created successfully, set a default state
        // The profile will be loaded properly on the next app restart or manual refresh
        state = state.copyWith(
          state: UserProfileState.loaded,
          id: authState.user!.id,
          fullName: null, // Mantener null en estado local para mostrar 0% en usuarios anónimos
          email: authState.user!.email,
          // Set other fields to null - they'll be loaded when the user accesses profile
        );
      }
    } catch (e) {
      state = state.copyWith(
        state: UserProfileState.error,
        errorMessage: e.toString(),
      );
    }
  }

  // Update user profile
  Future<void> updateUserProfile({
    String? fullName,
    String? businessName,
    String? businessNumber,
    String? address,
    String? tel,
    String? website,
    String? email,
    String? profileImg,
    String? signatureUrl,
    String? businessLogoUrl,
  }) async {
    try {
      state = state.copyWith(state: UserProfileState.loading);

      final authState = ref.read(authControllerProvider);
      // Permitir tanto usuarios autenticados como anónimos
      if (authState.user == null) {
        state = state.copyWith(
          state: UserProfileState.error,
          errorMessage: 'User not authenticated',
        );
        return;
      }

      final userProfileService = ref.read(userProfileServiceProvider);
      await userProfileService.updateUserProfile(
        userUuid: authState.user!.id,
        fullName: fullName,
        businessName: businessName,
        businessNumber: businessNumber,
        address: address,
        tel: tel,
        website: website,
        email: email,
        profileImg: profileImg,
        signatureUrl: signatureUrl,
        businessLogoUrl: businessLogoUrl,
      );

      // Update local state
      state = state.copyWith(
        state: UserProfileState.loaded,
        fullName: fullName ?? state.fullName,
        businessName: businessName ?? state.businessName,
        businessNumber: businessNumber ?? state.businessNumber,
        address: address ?? state.address,
        tel: tel ?? state.tel,
        website: website ?? state.website,
        email: email ?? state.email,
        profileImg: profileImg ?? state.profileImg,
        signatureUrl: signatureUrl ?? state.signatureUrl,
        businessLogoUrl: businessLogoUrl ?? state.businessLogoUrl,
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error updating user profile: $e');
      }
      state = state.copyWith(
        state: UserProfileState.error,
        errorMessage: e.toString(),
      );
    }
  }

  // Upload profile image
  Future<void> uploadProfileImage(File imageFile) async {
    try {
      state = state.copyWith(state: UserProfileState.loading);

      final authState = ref.read(authControllerProvider);
      // Permitir tanto usuarios autenticados como anónimos
      if (authState.user == null) {
        state = state.copyWith(
          state: UserProfileState.error,
          errorMessage: 'User not authenticated',
        );
        return;
      }

      final userProfileService = ref.read(userProfileServiceProvider);
      final imageUrl = await userProfileService.uploadProfileImage(
        userUuid: authState.user!.id,
        imageFile: imageFile,
      );

      if (imageUrl == null) {
        state = state.copyWith(
          state: UserProfileState.error,
          errorMessage: 'Failed to upload profile image',
        );
        return;
      }

      // Reload profile after update
      await loadUserProfile();
    } catch (e) {
      state = state.copyWith(
        state: UserProfileState.error,
        errorMessage: e.toString(),
      );
    }
  }

  // Delete profile image
  Future<void> deleteProfileImage() async {
    try {
      state = state.copyWith(state: UserProfileState.loading);

      final authState = ref.read(authControllerProvider);
      if (authState.user == null) {
        state = state.copyWith(
          state: UserProfileState.error,
          errorMessage: 'User not authenticated',
        );
        return;
      }

      final currentProfileImg = state.profileImg;
      if (currentProfileImg == null) {
        // No profile image to delete
        state = state.copyWith(state: UserProfileState.loaded);
        return;
      }

      final userProfileService = ref.read(userProfileServiceProvider);
      final success = await userProfileService.deleteProfileImage(
        userUuid: authState.user!.id,
        imageUrl: currentProfileImg,
      );

      if (!success) {
        state = state.copyWith(
          state: UserProfileState.error,
          errorMessage: 'Failed to delete profile image',
        );
        return;
      }

      // Reload profile after update
      await loadUserProfile();
    } catch (e) {
      state = state.copyWith(
        state: UserProfileState.error,
        errorMessage: e.toString(),
      );
    }
  }

  // Upload business logo
  Future<void> uploadBusinessLogo(File imageFile) async {
    try {
      state = state.copyWith(state: UserProfileState.loading);

      final authState = ref.read(authControllerProvider);
      // Permitir tanto usuarios autenticados como anónimos
      if (authState.user == null) {
        state = state.copyWith(
          state: UserProfileState.error,
          errorMessage: 'User not authenticated',
        );
        return;
      }

      final userProfileService = ref.read(userProfileServiceProvider);
      final imageUrl = await userProfileService.uploadBusinessLogo(
        userUuid: authState.user!.id,
        imageFile: imageFile,
      );

      if (imageUrl == null) {
        state = state.copyWith(
          state: UserProfileState.error,
          errorMessage: 'Failed to upload business logo',
        );
        return;
      }

      // Reload profile after update
      await loadUserProfile();
    } catch (e) {
      state = state.copyWith(
        state: UserProfileState.error,
        errorMessage: e.toString(),
      );
    }
  }

  // Delete business logo
  Future<void> deleteBusinessLogo() async {
    try {
      state = state.copyWith(state: UserProfileState.loading);

      final authState = ref.read(authControllerProvider);
      // Permitir tanto usuarios autenticados como anónimos
      if (authState.user == null) {
        state = state.copyWith(
          state: UserProfileState.error,
          errorMessage: 'User not authenticated',
        );
        return;
      }

      final currentLogoUrl = state.businessLogoUrl;
      if (currentLogoUrl == null) {
        // No business logo to delete
        state = state.copyWith(state: UserProfileState.loaded);
        return;
      }

      final userProfileService = ref.read(userProfileServiceProvider);
      final success = await userProfileService.deleteBusinessLogo(
        userUuid: authState.user!.id,
        imageUrl: currentLogoUrl,
      );

      if (!success) {
        state = state.copyWith(
          state: UserProfileState.error,
          errorMessage: 'Failed to delete business logo',
        );
        return;
      }

      // Reload profile after update
      await loadUserProfile();
    } catch (e) {
      state = state.copyWith(
        state: UserProfileState.error,
        errorMessage: e.toString(),
      );
    }
  }
}

// User profile provider
final userProfileProvider =
    StateNotifierProvider<UserProfileNotifier, UserProfile>((ref) {
  return UserProfileNotifier(ref);
});
