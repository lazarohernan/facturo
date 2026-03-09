import 'package:facturo/core/providers/supabase_providers.dart';
import 'package:facturo/core/services/storage_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:io';
import 'package:path/path.dart' as path;

class UserProfileService {
  final SupabaseClient _client;

  UserProfileService(this._client);

  /// Creates a new user profile record in the users_public_info table
  Future<void> createUserProfile({
    required String userUuid,
    required String fullName,
    String? email,
    String? businessName,
    String? businessLogoUrl,
    String? businessPhone,
    String? businessAddress,
  }) async {
    try {
      debugPrint('📝 Creating user profile for: $userUuid');
      
      final Map<String, dynamic> data = {
        'user_uuid': userUuid,
        'full_name': fullName,
      };

      if (email != null) data['email'] = email;
      if (businessName != null) data['business_name'] = businessName;
      if (businessLogoUrl != null) data['business_logo_url'] = businessLogoUrl;
      if (businessPhone != null) data['tel'] = businessPhone;
      if (businessAddress != null) data['address'] = businessAddress;

      debugPrint('📝 Profile data: $data');
      
      await _client.from('users_public_info').insert(data);
      
      debugPrint('✅ User profile created successfully');
    } catch (e) {
      debugPrint('❌ Error creating user profile: $e');
      
      // If it's a RLS policy error, don't throw - just log and continue
      if (e is PostgrestException && e.code == '42501') {
        debugPrint('⚠️ RLS policy error - profile creation blocked');
        return;
      }

      // For duplicate key errors, the profile already exists
      if (e is PostgrestException && e.code == '23505') {
        debugPrint('ℹ️ Profile already exists for user');
        return;
      }

      // For foreign key constraint errors, the user doesn't exist in users table yet
      if (e is PostgrestException && e.code == '23503') {
        debugPrint('⚠️ Foreign key constraint error - user not in users table yet');
        return;
      }

      // Rethrow other errors so they can be handled
      rethrow;
    }
  }

  /// Updates an existing user profile or creates one if it doesn't exist (upsert)
  Future<void> updateUserProfile({
    required String userUuid,
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
      debugPrint('📝 Updating profile for user: $userUuid');
      
      final Map<String, dynamic> data = {
        'user_uuid': userUuid,
      };

      if (fullName != null) data['full_name'] = fullName;
      if (businessName != null) data['business_name'] = businessName;
      if (businessNumber != null) data['business_number'] = businessNumber;
      if (address != null) data['address'] = address;
      if (tel != null) data['tel'] = tel;
      if (website != null) data['website'] = website;
      if (email != null) data['email'] = email;
      if (profileImg != null) data['profile_img'] = profileImg;
      if (signatureUrl != null) data['signature_url'] = signatureUrl;
      if (businessLogoUrl != null) data['business_logo_url'] = businessLogoUrl;

      debugPrint('📝 Profile data to upsert: $data');

      // Use upsert to create or update the profile
      await _client
          .from('users_public_info')
          .upsert(data, onConflict: 'user_uuid');
      
      debugPrint('✅ Profile upserted successfully');
    } catch (e) {
      debugPrint('❌ Error updating profile: $e');
      rethrow;
    }
  }

  /// Gets a user profile by user UUID
  Future<Map<String, dynamic>?> getUserProfile(String userUuid) async {
    try {
      final response = await _client
          .from('users_public_info')
          .select()
          .eq('user_uuid', userUuid)
          .single();

      return response;
    } catch (e) {
      // If no profile is found, return null instead of throwing an error
      if (e is PostgrestException && e.code == 'PGRST116') {
        return null;
      }

      // Return null instead of throwing to prevent app crashes
      return null;
    }
  }

  /// Uploads a profile image to Supabase storage and updates the user profile
  Future<String?> uploadProfileImage({
    required String userUuid,
    required File imageFile,
  }) async {
    try {
      debugPrint('📸 Uploading profile image for user: $userUuid');
      
      // Generate a unique file name using timestamp
      final fileExt = path.extension(imageFile.path);
      final fileName =
          'profile_$userUuid${DateTime.now().millisecondsSinceEpoch}$fileExt';
      final filePath = 'profile_img/$fileName';

      debugPrint('📸 File path: $filePath');

      // Upload the file to Supabase Storage
      final storageService = StorageService(_client);
      final storedPath = await storageService.uploadFile(
        filePath: filePath,
        file: imageFile,
      );

      debugPrint('✅ Image uploaded to storage: $storedPath');

      // Update the user profile with the storage path
      await updateUserProfile(userUuid: userUuid, profileImg: storedPath);

      debugPrint('✅ Profile updated with storage path');

      return storedPath;
    } catch (e) {
      debugPrint('❌ Error uploading profile image: $e');
      return null;
    }
  }

  /// Deletes a profile image from Supabase storage
  Future<bool> deleteProfileImage({
    required String userUuid,
    required String imageUrl,
  }) async {
    try {
      debugPrint('🗑️ Deleting profile image for user: $userUuid');
      
      // Delete the file from Supabase Storage using StorageService
      final storageService = StorageService(_client);
      await storageService.deleteFile(imageUrl);
      debugPrint('✅ Image deleted from storage');

      // Always update the user profile to clear the profile image URL, regardless of storage deletion success
      debugPrint('✅ Updating profile to clear profile_img field');
      await updateUserProfile(userUuid: userUuid, profileImg: '');

      return true;
    } catch (e) {
      debugPrint('❌ Error deleting profile image: $e');
      // Even if storage deletion fails, try to clear the profile field
      try {
        await updateUserProfile(userUuid: userUuid, profileImg: '');
        debugPrint('✅ Profile cleared despite storage error');
        return true; // Consider it successful since we cleared the profile
      } catch (updateError) {
        debugPrint('❌ Failed to clear profile field: $updateError');
        return false;
      }
    }
  }

  Future<String?> uploadBusinessLogo({
    required String userUuid,
    required File imageFile,
  }) async {
    try {
      final fileExt = imageFile.path.split('.').last;
      final fileName =
          '${userUuid}_${DateTime.now().millisecondsSinceEpoch}.$fileExt';
      final filePath = 'business_logo/$fileName';

      final storageService = StorageService(_client);
      final storedPath = await storageService.uploadFile(
        filePath: filePath,
        file: imageFile,
      );

      // Update the user profile with the storage path
      await updateUserProfile(userUuid: userUuid, businessLogoUrl: storedPath);

      return storedPath;
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> deleteBusinessLogo({
    required String userUuid,
    required String imageUrl,
  }) async {
    try {
      debugPrint('🗑️ Deleting business logo for user: $userUuid');
      
      // Delete the file from Supabase Storage using StorageService
      final storageService = StorageService(_client);
      await storageService.deleteFile(imageUrl);
      debugPrint('✅ Logo deleted from storage');

      // Always update the user profile to clear the business logo URL, regardless of storage deletion success
      debugPrint('✅ Updating profile to clear business_logo_url field');
      await updateUserProfile(userUuid: userUuid, businessLogoUrl: '');

      return true;
    } catch (e) {
      debugPrint('❌ Error deleting business logo: $e');
      // Even if storage deletion fails, try to clear the profile field
      try {
        await updateUserProfile(userUuid: userUuid, businessLogoUrl: '');
        debugPrint('✅ Business logo URL cleared despite storage error');
        return true; // Consider it successful since we cleared the profile
      } catch (updateError) {
        debugPrint('❌ Failed to clear business logo URL field: $updateError');
        return false;
      }
    }
  }
}

// Provider for UserProfileService
final userProfileServiceProvider = Provider<UserProfileService>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return UserProfileService(client);
});
