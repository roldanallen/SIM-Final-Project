import 'package:flutter/material.dart';

class TaskTypeCard extends StatelessWidget {
  final String label;
  final String subtext;
  final String hexColor1;
  final String hexColor2;
  final String imagePath;
  final String? duration;
  final String? calories;
  final VoidCallback? onTap;
  final bool enabled;
  final double imageSize; // New parameter for image size

  const TaskTypeCard({
    super.key,
    required this.label,
    required this.subtext,
    required this.hexColor1,
    required this.hexColor2,
    required this.imagePath,
    this.duration,
    this.calories,
    required this.onTap,
    this.enabled = true,
    this.imageSize = 60, // Default to 60px for other pages
  });

  Color _hexToColor(String hex) {
    hex = hex.replaceAll("#", "");
    if (hex.length == 6) hex = "FF$hex";
    return Color(int.parse("0x$hex"));
  }

  @override
  Widget build(BuildContext context) {
    final color1 = _hexToColor(hexColor1);
    final color2 = _hexToColor(hexColor2);
    final screenWidth = MediaQuery.of(context).size.width;
    final scaleFactor = screenWidth < 360 ? 0.9 : 1.0; // Scaling for small screens

    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        width: double.infinity,
        margin: EdgeInsets.symmetric(vertical: 8 * scaleFactor),
        padding: EdgeInsets.all(12 * scaleFactor),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: enabled ? [color1, color2] : [Colors.grey, Colors.grey],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12 * scaleFactor),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 4 * scaleFactor,
              offset: Offset(0, 2 * scaleFactor),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 16 * scaleFactor,
                      fontWeight: FontWeight.bold,
                      color: enabled ? Colors.black54 : Colors.black38,
                    ),
                  ),
                  SizedBox(height: 4 * scaleFactor),
                  Text(
                    subtext,
                    style: TextStyle(
                      fontSize: 14 * scaleFactor,
                      color: enabled ? Colors.black87 : Colors.black38,
                    ),
                  ),
                  if (duration != null || calories != null)
                    Padding(
                      padding: EdgeInsets.only(top: 6 * scaleFactor),
                      child: Row(
                        children: [
                          if (duration != null)
                            Text(
                              duration!,
                              style: TextStyle(
                                fontSize: 12 * scaleFactor,
                                color: enabled ? Colors.grey : Colors.black38,
                              ),
                            ),
                          if (duration != null && calories != null) SizedBox(width: 8 * scaleFactor),
                          if (calories != null)
                            Row(
                              children: [
                                Icon(
                                  Icons.local_fire_department,
                                  size: 14 * scaleFactor,
                                  color: enabled ? Colors.grey : Colors.black38,
                                ),
                                SizedBox(width: 4 * scaleFactor),
                                Text(
                                  calories!,
                                  style: TextStyle(
                                    fontSize: 12 * scaleFactor,
                                    color: enabled ? Colors.grey : Colors.black38,
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            SizedBox(width: 12 * scaleFactor),
            Opacity(
              opacity: enabled ? 0.7 : 0.3,
              child: Image.asset(
                imagePath,
                width: imageSize * scaleFactor,
                height: imageSize * scaleFactor,
                fit: BoxFit.cover,
                color: enabled ? null : Colors.black38,
              ),
            ),
          ],
        ),
      ),
    );
  }
}