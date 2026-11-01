import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/format.dart';
import '../../data/models/mapping_toko_model.dart';

/// Grid mapping toko × 12 bulan mirip Excel.
/// Kolom toko sticky di sisi kiri, kolom bulan JAN–DES dapat digulir horizontal,
/// dan setiap sel dapat diketuk untuk toggle titik hijau rencana kunjungan.
class ExcelMappingGrid extends StatelessWidget {
  final List<MappingToko> items;
  final void Function(int itemIndex, int monthIndex) onToggleCell;

  const ExcelMappingGrid({
    super.key,
    required this.items,
    required this.onToggleCell,
  });

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return Container(
        height: 140,
        alignment: Alignment.center,
        child: const Text(
          'Tidak ada toko yang sesuai dengan filter wilayah.',
          style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
        ),
      );
    }

    const double rowHeight = 44.0;
    const double headerHeight = 36.0;
    const double stickyColWidth = 130.0;
    const double monthColWidth = 42.0;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Kolom Toko (Sticky di sisi kiri)
          SizedBox(
            width: stickyColWidth,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Kolom Toko
                Container(
                  height: headerHeight,
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  alignment: Alignment.centerLeft,
                  decoration: const BoxDecoration(
                    color: Color(0xFFF8FAFC),
                    border: Border(
                      bottom: BorderSide(color: AppColors.border),
                      right: BorderSide(color: AppColors.border, width: 1.5),
                    ),
                  ),
                  child: const Text(
                    'TOKO',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textSecondary,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                // Baris Nama Toko
                ...List.generate(items.length, (index) {
                  final item = items[index];
                  return Container(
                    height: rowHeight,
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    alignment: Alignment.centerLeft,
                    decoration: BoxDecoration(
                      color: index.isEven ? Colors.white : const Color(0xFFFAFAFA),
                      border: const Border(
                        bottom: BorderSide(color: AppColors.border),
                        right: BorderSide(color: AppColors.border, width: 1.5),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          item.toko.nama,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Text(
                          item.toko.noJo,
                          style: const TextStyle(
                            fontSize: 10,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),

          // Kolom 12 Bulan (Dapat digulir horizontal)
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: SizedBox(
                width: monthColWidth * 12,
                child: Column(
                  children: [
                    // Header Bulan (JAN - DES)
                    Container(
                      height: headerHeight,
                      decoration: const BoxDecoration(
                        color: Color(0xFFF8FAFC),
                        border: Border(
                          bottom: BorderSide(color: AppColors.border),
                        ),
                      ),
                      child: Row(
                        children: List.generate(12, (mIdx) {
                          return Container(
                            width: monthColWidth,
                            alignment: Alignment.center,
                            decoration: const BoxDecoration(
                              border: Border(
                                right: BorderSide(color: AppColors.border),
                              ),
                            ),
                            child: Text(
                              AppFormat.bulanGridHeaders[mIdx],
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          );
                        }),
                      ),
                    ),
                    // Baris Sel Toggle
                    ...List.generate(items.length, (rowIdx) {
                      final item = items[rowIdx];
                      return Container(
                        height: rowHeight,
                        decoration: BoxDecoration(
                          color: rowIdx.isEven ? Colors.white : const Color(0xFFFAFAFA),
                          border: const Border(
                            bottom: BorderSide(color: AppColors.border),
                          ),
                        ),
                        child: Row(
                          children: List.generate(12, (colIdx) {
                            final isActive = item.bulan[colIdx];
                            return InkWell(
                              onTap: () => onToggleCell(rowIdx, colIdx),
                              child: Container(
                                width: monthColWidth,
                                height: rowHeight,
                                alignment: Alignment.center,
                                decoration: const BoxDecoration(
                                  border: Border(
                                    right: BorderSide(color: AppColors.border),
                                  ),
                                ),
                                child: Container(
                                  width: 14,
                                  height: 14,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: isActive
                                        ? const Color(0xFF16A34A)
                                        : const Color(0xFFCBD5E1),
                                  ),
                                ),
                              ),
                            );
                          }),
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
