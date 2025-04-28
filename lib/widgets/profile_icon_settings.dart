import 'dart:io';
import 'package:flutter/material.dart';
import 'package:software_development/screens/home/profile_screen.dart';
import 'package:software_development/screens/main_navigation.dart';

class ProfileIconSettings extends StatefulWidget {
  final File? profileImage;
  final String userName;

  const ProfileIconSettings({
    super.key,
    required this.profileImage,
    required this.userName,
  });

  @override
  State<ProfileIconSettings> createState() => _ProfileIconSettingsState();
}

class _ProfileIconSettingsState extends State<ProfileIconSettings> {
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;

  void _toggleOverlay() {
    if (_overlayEntry != null) {
      _overlayEntry!.remove();
      _overlayEntry = null;
    } else {
      _overlayEntry = _createOverlay();
      Overlay.of(context)!.insert(_overlayEntry!);
    }
  }

  OverlayEntry _createOverlay() {
    const bubbleWidth = 160.0;
    const bubbleRadius = 8.0;
    const arrowSize = Size(16, 8);
    const verticalSpacing = 8.0; // gap between icon and bubble

    return OverlayEntry(
      builder: (context) => CompositedTransformFollower(
        link: _layerLink,
        showWhenUnlinked: false,
        targetAnchor: Alignment.bottomRight,
        followerAnchor: Alignment.topRight,
        offset: const Offset(0, verticalSpacing),
        child: Material(
          color: Colors.transparent,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // little triangle
              CustomPaint(
                size: arrowSize,
                painter: _TrianglePainter(color: Colors.white),
              ),

              // bubble itself
              Container(
                width: bubbleWidth,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(bubbleRadius),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 6,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextButton.icon(
                      onPressed: () {
                        _toggleOverlay();                        // 1) close the popup
                        MainNavigationScreen.goToProfileTab();   // 2) switch to Profile in the bottom nav
                      },
                      icon: const Icon(Icons.person, color: Colors.black87),
                      label: const Text('My Profile'),
                      style: TextButton.styleFrom(
                        alignment: Alignment.centerLeft,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                      ),
                    ),
                    const Divider(height: 1),
                    TextButton.icon(
                      onPressed: () {
                        // your logout logic
                        ProfileScreen();
                      },
                      icon: const Icon(Icons.logout, color: Colors.black87),
                      label: const Text('Log out'),
                      style: TextButton.styleFrom(
                        alignment: Alignment.centerLeft,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: GestureDetector(
        onTap: _toggleOverlay,
        child: CircleAvatar(
          radius: 24,
          backgroundColor: Colors.grey[300],
          backgroundImage: widget.profileImage != null
              ? FileImage(widget.profileImage!)
              : null,
          child: widget.profileImage == null
              ? const Icon(Icons.person, size: 28, color: Colors.white)
              : null,
        ),
      ),
    );
  }
}

/// Draws a little downward-pointing triangle
class _TrianglePainter extends CustomPainter {
  final Color color;
  const _TrianglePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width / 2, size.height)
      ..lineTo(size.width, 0)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_TrianglePainter oldDelegate) => false;
}
