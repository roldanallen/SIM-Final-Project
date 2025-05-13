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

    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.symmetric(vertical: 10),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: enabled ? [color1, color2] : [Colors.grey, Colors.grey],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 4,
              offset: const Offset(0, 4),
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
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: enabled ? Colors.black54 : Colors.black38,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtext,
                    style: TextStyle(
                      fontSize: 14,
                      color: enabled ? Colors.black87 : Colors.black38,
                    ),
                  ),
                  if (duration != null || calories != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Row(
                        children: [
                          if (duration != null)
                            Text(
                              duration!,
                              style: TextStyle(
                                fontSize: 12,
                                color: enabled ? Colors.grey : Colors.black38,
                              ),
                            ),
                          if (duration != null && calories != null) const SizedBox(width: 8),
                          if (calories != null)
                            Row(
                              children: [
                                Icon(
                                  Icons.local_fire_department,
                                  size: 14,
                                  color: enabled ? Colors.grey : Colors.black38,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  calories!,
                                  style: TextStyle(
                                    fontSize: 12,
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
            const SizedBox(width: 16),
            Opacity(
              opacity: enabled ? 0.7 : 0.3,
              child: Image.asset(
                imagePath,
                width: 60, // Larger image to match the UI
                height: 60,
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