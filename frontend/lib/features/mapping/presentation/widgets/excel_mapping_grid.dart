import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/format.dart';
import '../../data/models/mapping_toko_model.dart';

/// Grid mapping toko × 12 bulan bergaya GitHub contribution matrix.
/// Seluruh 12 kolom bulan (`JAN`–`DES`) ditampilkan sekaligus dalam satu card putih bersih.
/// Kotak aktif diisi teal solid (`#0F7B6C`), kotak nonaktif putih berborder tipis.
class ExcelMappingGrid extends StatelessWidget {
  final List<MappingToko> items;
  final void Function(int itemIndex, int monthIndex) onToggleCell;

  const ExcelMappingGrid({
    super.key,
    required this.items,
    required this.onToggleCell,
  });

  String _shortStoreName(String name) {
    if (name.startsWith('Toko ')) {
      return name.substring(5);
    }
    return name;
  }

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return Container(
        height: 120,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.border),
        ),
        child: const Text(
          'Tidak ada toko yang sesuai dengan filter wilayah.',
          style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
        ),
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final maxWidth = constraints.maxWidth;
          // Lebar kolom nama toko adaptif agar 12 kotak bulan muat tanpa overflow
          final nameColWidth = maxWidth < 300 ? 74.0 : 88.0;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: TOKO + JAN..DES
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    SizedBox(
                      width: nameColWidth,
                      child: const Text(
                        'TOKO',
                        style: TextStyle(
                          fontSize: 8.5,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textSecondary,
                          letterSpacing: 0.4,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Row(
                        children: List.generate(12, (mIdx) {
                          return Expanded(
                            child: Center(
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  AppFormat.bulanGridHeaders[mIdx],
                                  style: const TextStyle(
                                    fontSize: 7.5,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ),
                            ),
                          );
                        }),
                      ),
                    ),
                  ],
                ),
              ),

              // Baris per toko
              ...List.generate(items.length, (rowIdx) {
                final item = items[rowIdx];
                return Padding(
                  padding: EdgeInsets.only(
                    bottom: rowIdx == items.length - 1 ? 0 : 7,
                  ),
                  child: Row(
                    children: [
                      SizedBox(
                        width: nameColWidth,
                        child: Text(
                          _shortStoreName(item.toko.nama),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Row(
                          children: List.generate(12, (colIdx) {
                            final isActive = item.bulan[colIdx];
                            return Expanded(
                              child: Center(
                                child: GestureDetector(
                                  behavior: HitTestBehavior.opaque,
                                  onTap: () => onToggleCell(rowIdx, colIdx),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 2,
                                    ),
                                    child: Container(
                                      width: 14,
                                      height: 14,
                                      decoration: BoxDecoration(
                                        color: isActive
                                            ? AppColors.adminTeal
                                            : Colors.white,
                                        borderRadius: BorderRadius.circular(3.5),
                                        border: isActive
                                            ? null
                                            : Border.all(
                                                color: AppColors.borderStrong,
                                                width: 1,
                                              ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
          );
        },
      ),
    );
  }
}
