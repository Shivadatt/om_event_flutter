import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Modal bottom sheet dialog rendering photo management options.
class ProfilePhotoSheet extends StatelessWidget {
  /// Whether the user has an existing avatar uploaded.
  final bool hasAvatar;

  /// Callback action to pick/upload from gallery or camera.
  /// True representing gallery, false representing camera source.
  final Function(bool isGallery) onPick;

  /// Callback action to remove the current photo.
  final VoidCallback onRemove;

  /// Creates a [ProfilePhotoSheet] widget instance.
  const ProfilePhotoSheet({
    super.key,
    required this.hasAvatar,
    required this.onPick,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Wrap(
        children: [
          ListTile(
            leading: const Icon(
              Icons.photo_library_outlined,
              color: Color(0xFFC8A26A),
            ),
            title: Text(
              'Choose from Gallery',
              style: GoogleFonts.dmSans(color: Colors.white),
            ),
            onTap: () {
              Navigator.pop(context);
              onPick(true);
            },
          ),
          ListTile(
            leading: const Icon(
              Icons.camera_alt_outlined,
              color: Color(0xFFC8A26A),
            ),
            title: Text(
              'Take a Photo',
              style: GoogleFonts.dmSans(color: Colors.white),
            ),
            onTap: () {
              Navigator.pop(context);
              onPick(false);
            },
          ),
          if (hasAvatar)
            ListTile(
              leading: const Icon(
                Icons.delete_outline_rounded,
                color: Colors.redAccent,
              ),
              title: Text(
                'Remove Current Photo',
                style: GoogleFonts.dmSans(color: Colors.redAccent),
              ),
              onTap: () {
                Navigator.pop(context);
                onRemove();
              },
            ),
        ],
      ),
    );
  }
}
