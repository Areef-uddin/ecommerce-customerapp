import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../controllers/product_controller.dart';

class SizeGuideSheet extends StatelessWidget {
  const SizeGuideSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ProductController>();

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Drag handle & title
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Size Guide', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Get.back(),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.border),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Obx(
                () => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Category selector (Women, Men, Kids)
                    Row(
                      children: ['Women', 'Men', 'Kids'].map((cat) {
                        final isSel = controller.sizeGuideCategory.value == cat;
                        return GestureDetector(
                          onTap: () {
                            controller.sizeGuideCategory.value = cat;
                            controller.fetchSizeGuide();
                          },
                          child: Container(
                            margin: const EdgeInsets.only(right: 16),
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              color: isSel ? AppColors.primaryLight : Colors.transparent,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              cat,
                              style: TextStyle(
                                fontWeight: isSel ? FontWeight.w800 : FontWeight.w600,
                                color: isSel ? AppColors.primary : AppColors.textSecondary,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),

                    // Unit Toggle (INCHES | CM)
                    Center(
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF3F4F6),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            GestureDetector(
                              onTap: () => controller.isUnitInches.value = true,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
                                decoration: BoxDecoration(
                                  color: controller.isUnitInches.value ? Colors.white : Colors.transparent,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Text(
                                  'INCHES',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: controller.isUnitInches.value ? AppColors.primary : AppColors.textSecondary,
                                  ),
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: () => controller.isUnitInches.value = false,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
                                decoration: BoxDecoration(
                                  color: !controller.isUnitInches.value ? Colors.white : Colors.transparent,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Text(
                                  'CM',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: !controller.isUnitInches.value ? AppColors.primary : AppColors.textSecondary,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Measurement Table matching Screen 9
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.border),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Table(
                        border: TableBorder.all(color: AppColors.divider),
                        children: [
                          TableRow(
                            decoration: const BoxDecoration(color: Color(0xFFF9FAFB)),
                            children: const [
                              Padding(padding: EdgeInsets.all(10), child: Text('Size', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13))),
                              Padding(padding: EdgeInsets.all(10), child: Text('Bust', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13))),
                              Padding(padding: EdgeInsets.all(10), child: Text('Waist', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13))),
                              Padding(padding: EdgeInsets.all(10), child: Text('Hip', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13))),
                            ],
                          ),
                          _buildTableRow('XS', controller.isUnitInches.value ? '32' : '81', controller.isUnitInches.value ? '24' : '61', controller.isUnitInches.value ? '34' : '86'),
                          _buildTableRow('S', controller.isUnitInches.value ? '34' : '86', controller.isUnitInches.value ? '26' : '66', controller.isUnitInches.value ? '36' : '91'),
                          _buildTableRow('M', controller.isUnitInches.value ? '36' : '91', controller.isUnitInches.value ? '28' : '71', controller.isUnitInches.value ? '38' : '96'),
                          _buildTableRow('L', controller.isUnitInches.value ? '38' : '96', controller.isUnitInches.value ? '30' : '76', controller.isUnitInches.value ? '40' : '101'),
                          _buildTableRow('XL', controller.isUnitInches.value ? '40' : '101', controller.isUnitInches.value ? '32' : '81', controller.isUnitInches.value ? '42' : '106'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 28),

                    // "How to Measure" section
                    const Text('How to Measure', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
                    const SizedBox(height: 12),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 80,
                          height: 100,
                          decoration: BoxDecoration(
                            border: Border.all(color: AppColors.border),
                            borderRadius: BorderRadius.circular(10),
                            color: const Color(0xFFF9FAFB),
                          ),
                          child: const Icon(Icons.accessibility_new, size: 50, color: AppColors.primary),
                        ),
                        const SizedBox(width: 16),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Bust', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                              Text('Measure around the fullest part of your chest.', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                              SizedBox(height: 8),
                              Text('Waist', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                              Text('Measure around your natural waistline.', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  TableRow _buildTableRow(String size, String bust, String waist, String hip) {
    return TableRow(
      children: [
        Padding(padding: const EdgeInsets.all(10), child: Text(size, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13))),
        Padding(padding: const EdgeInsets.all(10), child: Text(bust, style: const TextStyle(fontSize: 13))),
        Padding(padding: const EdgeInsets.all(10), child: Text(waist, style: const TextStyle(fontSize: 13))),
        Padding(padding: const EdgeInsets.all(10), child: Text(hip, style: const TextStyle(fontSize: 13))),
      ],
    );
  }
}
