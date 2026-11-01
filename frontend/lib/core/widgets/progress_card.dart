import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Kartu gelap navy dengan angka besar (mis. `4 / 6` atau `88.9`) dan progress bar tipis.
class ProgressCard extends StatelessWidget {
  final String title;
  final String mainValue;
  final String subtitle;
  final double? progress; // 0.0 .. 1.0
  final Color progressColor;

  const ProgressCard({
    super.key,
    required this.title,
    required this.mainValue,
    required this.subtitle,
    this.progress,
    this.progressColor = AppColors.salesOrange,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.navyHeader,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title.toUpperCase(),
            style: const TextStyle(
              color: Color(0xFF94A3B8),
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.6,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            mainValue,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.w800,
            ),
          ),
          if (progress != null) ...[
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress!.clamp(0.0, 1.0),
                minHeight: 6,
                backgroundColor: const Color(0xFF1E293B),
                valueColor: AlwaysStoppedAnimation<Color>(progressColor),
              ),
            ),
          ],
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: const TextStyle(
              color: Color(0xFFCBD5E1),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
