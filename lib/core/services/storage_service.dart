import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Centralized service for Supabase Storage operations.
/// Stores file paths instead of public URLs for security.
/// Generates signed URLs on-the-fly for displaying images.
class StorageService {
  static const String _bucketName = 'facturo_bucket';

  /// Default signed URL expiry: 1 hour (3600 seconds)
  static const int _defaultExpirySeconds = 3600;

  /// Long expiry for shared content (PDFs, etc.): 30 days
  static const int _shareExpirySeconds = 30 * 24 * 3600;

  final SupabaseClient _client;

  StorageService(this._client);

  /// Upload a file and return the storage path (NOT a public URL)
  Future<String> uploadFile({
    required String filePath,
    required File file,
    FileOptions? fileOptions,
  }) async {
    await _client.storage.from(_bucketName).upload(
          filePath,
          file,
          fileOptions: fileOptions ??
              const FileOptions(cacheControl: '3600', upsert: false),
        );
    debugPrint('📤 File uploaded to: $filePath');
    return filePath;
  }

  /// Upload binary data and return the storage path (NOT a public URL)
  Future<String> uploadBinary({
    required String filePath,
    required Uint8List data,
    FileOptions? fileOptions,
  }) async {
    await _client.storage.from(_bucketName).uploadBinary(
          filePath,
          data,
          fileOptions: fileOptions ??
              const FileOptions(cacheControl: '3600', upsert: false),
        );
    debugPrint('📤 Binary uploaded to: $filePath');
    return filePath;
  }

  /// Generate a signed URL from a stored path or legacy public URL.
  /// Returns null if the input is null or empty.
  Future<String?> getSignedUrl(
    String? storedValue, {
    int expiresIn = _defaultExpirySeconds,
  }) async {
    if (storedValue == null || storedValue.isEmpty) return null;

    try {
      final filePath = extractPath(storedValue);
      if (filePath.isEmpty) return null;

      final signedUrl = await _client.storage
          .from(_bucketName)
          .createSignedUrl(filePath, expiresIn);

      return signedUrl;
    } catch (e) {
      debugPrint('❌ Error generating signed URL for "$storedValue": $e');
      return null;
    }
  }

  /// Generate a signed URL with long expiry for sharing (PDFs, etc.)
  Future<String?> getShareUrl(String? storedValue) async {
    return getSignedUrl(storedValue, expiresIn: _shareExpirySeconds);
  }

  /// Delete a file from storage using a stored path or legacy URL
  Future<bool> deleteFile(String? storedValue) async {
    if (storedValue == null || storedValue.isEmpty) return false;

    try {
      final filePath = extractPath(storedValue);
      if (filePath.isEmpty) return false;

      await _client.storage.from(_bucketName).remove([filePath]);
      debugPrint('🗑️ File deleted: $filePath');
      return true;
    } catch (e) {
      debugPrint('❌ Error deleting file "$storedValue": $e');
      return false;
    }
  }

  /// Extract the file path from either:
  /// - A storage path (e.g., 'ocr/userId_123.jpg') — returned as-is
  /// - A legacy public URL (e.g., 'https://xxx.supabase.co/storage/v1/object/public/facturo_bucket/ocr/file.jpg')
  /// - A signed URL (e.g., 'https://xxx.supabase.co/storage/v1/object/sign/facturo_bucket/ocr/file.jpg?token=xxx')
  static String extractPath(String storedValue) {
    // If it doesn't look like a URL, assume it's already a path
    if (!storedValue.startsWith('http')) {
      return storedValue;
    }

    try {
      final uri = Uri.parse(storedValue);
      final segments = uri.pathSegments;

      // Find 'facturo_bucket' in the path segments
      final bucketIndex = segments.indexOf(_bucketName);
      if (bucketIndex >= 0 && bucketIndex < segments.length - 1) {
        return segments.sublist(bucketIndex + 1).join('/');
      }

      // Fallback: try to find the path after /object/public/ or /object/sign/
      for (int i = 0; i < segments.length - 2; i++) {
        if (segments[i] == 'object' &&
            (segments[i + 1] == 'public' || segments[i + 1] == 'sign')) {
          // Skip 'object', 'public'/'sign', and bucket name
          if (i + 3 < segments.length) {
            return segments.sublist(i + 3).join('/');
          }
        }
      }
    } catch (e) {
      debugPrint('⚠️ Could not parse URL: $storedValue');
    }

    return '';
  }
}
