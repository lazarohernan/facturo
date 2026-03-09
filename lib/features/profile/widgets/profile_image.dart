import 'dart:io';
import 'package:facturo/features/profile/providers/user_profile_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:facturo/generated/l10n/app_localizations.dart';
import 'package:facturo/core/services/snackbar_service.dart';

class ProfileImage extends ConsumerStatefulWidget {
  final bool isEditing;

  const ProfileImage({super.key, required this.isEditing});

  @override
  ConsumerState<ProfileImage> createState() => _ProfileImageState();
}

class _ProfileImageState extends ConsumerState<ProfileImage> {
  File? _imageFile;
  final _imagePicker = ImagePicker();

  Future<void> _pickImage(ImageSource source) async {
    try {
      final pickedFile = await _imagePicker.pickImage(
        source: source,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        setState(() {
          _imageFile = File(pickedFile.path);
        });

        // Upload the image
        await ref
            .read(userProfileProvider.notifier)
            .uploadProfileImage(_imageFile!);
      }
    } catch (e) {
      if (!mounted) return;
      SnackbarService.showGenericError(
        context,
        error: '${AppLocalizations.of(context).errorPickingImage}: $e',
      );
    }
  }

  Future<void> _showImageSourceDialog() async {
    await showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(AppLocalizations.of(context).selectImageSource),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.camera_alt),
                  title: Text(AppLocalizations.of(context).camera),
                  onTap: () {
                    Navigator.of(context).pop();
                    _pickImage(ImageSource.camera);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.photo_library),
                  title: Text(AppLocalizations.of(context).gallery),
                  onTap: () {
                    Navigator.of(context).pop();
                    _pickImage(ImageSource.gallery);
                  },
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(AppLocalizations.of(context).cancel),
              ),
            ],
          ),
    );
  }

  Future<void> _deleteProfileImage() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(AppLocalizations.of(context).deleteProfileImage),
            content: Text(
              AppLocalizations.of(context).deleteProfileImageConfirmation,
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text(AppLocalizations.of(context).cancel),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: Text(AppLocalizations.of(context).delete),
              ),
            ],
          ),
    );

    if (confirmed == true) {
      await ref.read(userProfileProvider.notifier).deleteProfileImage();
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileData = ref.watch(userProfileProvider);
    final profileImgUrl = profileData.profileImg;
    final isLoading = profileData.state == UserProfileState.loading;

    return Column(
      children: [
        Stack(
          alignment: Alignment.bottomRight,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                shape: BoxShape.circle,
                border: Border.all(
                  color: Theme.of(context).primaryColor,
                  width: 2,
                ),
              ),
              child:
                  isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : ClipOval(
                        child:
                            _imageFile != null
                                ? Image.file(
                                  _imageFile!,
                                  fit: BoxFit.cover,
                                  width: 120,
                                  height: 120,
                                )
                                : profileImgUrl != null
                                ? Image.network(
                                  profileImgUrl,
                                  width: 120,
                                  height: 120,
                                  fit: BoxFit.cover,
                                  cacheWidth: 240,
                                  cacheHeight: 240,
                                  loadingBuilder: (context, child, loadingProgress) {
                                    if (loadingProgress == null) return child;
                                    return const Center(
                                      child: CircularProgressIndicator(),
                                    );
                                  },
                                  errorBuilder: (context, url, error) => Icon(
                                    Icons.person,
                                    size: 60,
                                    color: Theme.of(context).primaryColor,
                                  ),
                                  frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
                                    if (wasSynchronouslyLoaded) return child;
                                    return AnimatedOpacity(
                                      opacity: frame == null ? 0 : 1,
                                      duration: const Duration(milliseconds: 200),
                                      child: child,
                                    );
                                  },
                                )
                                : Icon(
                                  Icons.person,
                                  size: 60,
                                  color: Theme.of(context).primaryColor,
                                ),
                      ),
            ),
            if (widget.isEditing)
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
                    onPressed: _showImageSourceDialog,
                    tooltip: AppLocalizations.of(context).changeProfilePicture,
                    // Minimum 44x44 touch target per Apple HIG
                    constraints: const BoxConstraints.tightFor(
                      width: 44,
                      height: 44,
                    ),
                    padding: EdgeInsets.zero,
                  ),
                ),
              ),
          ],
        ),
        if (widget.isEditing && profileImgUrl != null)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: TextButton.icon(
              onPressed: _deleteProfileImage,
              icon: const Icon(Icons.delete, size: 18),
              label: Text(AppLocalizations.of(context).removePhoto),
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
                textStyle: const TextStyle(fontSize: 14),
              ),
            ),
          ),
      ],
    );
  }
}
