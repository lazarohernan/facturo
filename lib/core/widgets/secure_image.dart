import 'package:facturo/core/services/storage_service.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// A widget that displays images from Supabase Storage using signed URLs.
/// Handles both legacy public URLs and new storage paths transparently.
class SecureImage extends StatefulWidget {
  final String? storedValue;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Widget Function(BuildContext, Object, StackTrace?)? errorBuilder;
  final Widget Function(BuildContext, Widget, ImageChunkEvent?)? loadingBuilder;
  final int? cacheWidth;
  final int? cacheHeight;

  const SecureImage({
    super.key,
    required this.storedValue,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.errorBuilder,
    this.loadingBuilder,
    this.cacheWidth,
    this.cacheHeight,
  });

  @override
  State<SecureImage> createState() => _SecureImageState();
}

class _SecureImageState extends State<SecureImage> {
  String? _signedUrl;
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _resolveUrl();
  }

  @override
  void didUpdateWidget(SecureImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.storedValue != widget.storedValue) {
      _resolveUrl();
    }
  }

  Future<void> _resolveUrl() async {
    if (widget.storedValue == null || widget.storedValue!.isEmpty) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _hasError = true;
        });
      }
      return;
    }

    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      final storageService = StorageService(Supabase.instance.client);
      final url = await storageService.getSignedUrl(widget.storedValue);

      if (mounted) {
        setState(() {
          _signedUrl = url;
          _isLoading = false;
          _hasError = url == null;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _hasError = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return SizedBox(
        width: widget.width,
        height: widget.height,
        child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
      );
    }

    if (_hasError || _signedUrl == null) {
      if (widget.errorBuilder != null) {
        return widget.errorBuilder!(context, Exception('Failed to load'), null);
      }
      return SizedBox(
        width: widget.width,
        height: widget.height,
        child: const Center(child: Icon(Icons.broken_image, color: Colors.grey)),
      );
    }

    return Image.network(
      _signedUrl!,
      width: widget.width,
      height: widget.height,
      fit: widget.fit,
      cacheWidth: widget.cacheWidth,
      cacheHeight: widget.cacheHeight,
      errorBuilder: widget.errorBuilder,
      loadingBuilder: widget.loadingBuilder,
    );
  }
}
