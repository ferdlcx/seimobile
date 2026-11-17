import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../../features/admin_data/data/models/master_models.dart';

/// Komponen chip pill kecil membulat penuh (`borderRadius: 999`)
/// tanpa ikon centang agar identik dengan label/filter pada mockup Figma.
class PillChip extends StatelessWidget {
  final String label;
  final bool selected;
  final Color activeColor;
  final VoidCallback onTap;

  const PillChip({
    super.key,
    required this.label,
    required this.selected,
    required this.activeColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? activeColor : Colors.white,
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: selected ? activeColor : AppColors.borderStrong,
              width: 1,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: selected ? Colors.white : AppColors.textSecondary,
              height: 1.2,
            ),
          ),
        ),
      ),
    );
  }
}

/// Bar filter wilayah 2 baris (`Semua`, `Purwokerto Timur`, `Purwokerto Barat`,
/// `Purwokerto Selatan`, `Sokaraja`) menggunakan [PillChip].
class WilayahFilterBar extends StatelessWidget {
  final List<Wilayah> wilayahList;
  final int? selectedWilayahId;
  final ValueChanged<int?> onSelected;
  final Color activeColor;
  final bool includeAll;

  const WilayahFilterBar({
    super.key,
    required this.wilayahList,
    required this.selectedWilayahId,
    required this.onSelected,
    required this.activeColor,
    this.includeAll = true,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: [
        if (includeAll)
          PillChip(
            label: 'Semua',
            selected: selectedWilayahId == null,
            activeColor: activeColor,
            onTap: () => onSelected(null),
          ),
        ...wilayahList.map(
          (w) => PillChip(
            label: w.nama,
            selected: selectedWilayahId == w.id,
            activeColor: activeColor,
            onTap: () => onSelected(w.id),
          ),
        ),
      ],
    );
  }
}
