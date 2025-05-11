import 'package:flutter/material.dart';

class TaskTypeCard extends StatelessWidget {
  final String label;
  final String subtext;
  final String hexColor1;
  final String hexColor2;
  final String imagePath;
  final VoidCallback? onTap;
  final bool enabled;

  const TaskTypeCard({
    super.key,
    required this.label,
    required this.subtext,
    required this.hexColor1,
    required this.hexColor2,
    required this.imagePath,
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
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: enabled ? [color1, color2] : [Colors.grey, Colors.grey],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 4,
              offset: const Offset(0, 6),
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
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: enabled ? Colors.black87 : Colors.black38,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    subtext,
                    style: TextStyle(
                      fontSize: 14,
                      color: enabled ? Colors.black54 : Colors.black38,
                    ),
                  ),
                ],
              ),
            ),
            if (!enabled)
              const Icon(
                Icons.lock,
                color: Colors.black38,
              ),
            const SizedBox(width: 16),
            Opacity(
              opacity: 0.7, // A double between 0.0 and 1.0
              child: Image.asset(
                imagePath,
                width: 40,
                height: 40,
                fit: BoxFit.cover,
                color: enabled ? null : Colors.black38,
              ),
            )
          ],
        ),
      ),
    );
  }
}