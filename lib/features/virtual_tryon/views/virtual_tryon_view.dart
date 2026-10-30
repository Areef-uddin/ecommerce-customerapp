import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/routes/app_routes.dart';
import '../../cart/controllers/cart_controller.dart';
import '../controllers/tryon_controller.dart';
import '../models/tryon_model.dart';

class VirtualTryOnView extends StatefulWidget {
  const VirtualTryOnView({super.key});

  @override
  State<VirtualTryOnView> createState() => _VirtualTryOnViewState();
}

class _VirtualTryOnViewState extends State<VirtualTryOnView> {
  final controller = Get.put(TryOnController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: Color(0xFF0F172A)),
          onPressed: () => Get.back(),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFE11D48), Color(0xFF9333EA)],
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.auto_awesome, color: Colors.white, size: 16),
            ),
            const SizedBox(width: 10),
            Text(
              'AI Virtual Studio',
              style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.w800,
                fontSize: 18,
                color: const Color(0xFF0F172A),
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.history_rounded, color: Color(0xFF0F172A)),
            tooltip: 'Try-On History',
            onPressed: () => _showHistoryBottomSheet(context),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Obx(() {
              final product = controller.currentProduct.value;
              final job = controller.currentJob.value;
              final hasResult = job != null && job.isCompleted;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. PRODUCT REFERENCE HEADER CARD
                  if (product != null) _buildProductReferenceCard(product),

                  const SizedBox(height: 16),

                  // 2. VISUALIZATION MODE SELECTOR
                  _buildModeSelector(),

                  const SizedBox(height: 16),

                  // 3. BEFORE & AFTER PREVIEW OR PHOTO UPLOAD AREA
                  if (hasResult)
                    _buildBeforeAfterInteractiveViewer(job)
                  else if (controller.isGenerating.value)
                    _buildGeneratingProgressCard()
                  else
                    _buildPhotoUploadArea(),

                  const SizedBox(height: 18),

                  // 4. CONSENT NOTICE
                  if (!hasResult && !controller.isGenerating.value)
                    _buildConsentNotice(),

                  const SizedBox(height: 16),

                  // 5. PRIMARY ACTION BUTTON
                  if (!hasResult)
                    _buildGenerateButton()
                  else
                    _buildCompletedActions(product, job),

                  const SizedBox(height: 24),
                ],
              );
            }),
          ),
        ),
      ),
    );
  }

  // 1. Product Reference Card
  Widget _buildProductReferenceCard(dynamic product) {
    final firstImg = product.images.isNotEmpty ? product.images.first : '';

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [
          BoxShadow(color: Color(0x06000000), blurRadius: 10, offset: Offset(0, 2)),
        ],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              firstImg,
              width: 64,
              height: 64,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(width: 64, height: 64, color: const Color(0xFFF1F5F9)),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFCE7F3),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        product.categoryName.toUpperCase(),
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFFBE185D),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  product.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                    color: const Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '₹${product.price.toInt()}',
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                    color: const Color(0xFFE11D48),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 2. Visualization Mode Selector
  Widget _buildModeSelector() {
    final modes = [
      {'key': 'clothing', 'label': 'Clothing', 'icon': Icons.checkroom_rounded},
      {'key': 'footwear', 'label': 'Footwear', 'icon': Icons.ice_skating_outlined},
      {'key': 'accessories', 'label': 'Accessories', 'icon': Icons.watch_outlined},
      {'key': 'furniture', 'label': 'In My Space', 'icon': Icons.chair_outlined},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'SELECT VISUALIZATION MODE',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 11,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF64748B),
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: modes.map((m) {
              final isSel = controller.selectedMode.value == m['key'];
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(m['icon'] as IconData, size: 16, color: isSel ? Colors.white : const Color(0xFF0F172A)),
                      const SizedBox(width: 6),
                      Text(
                        m['label'] as String,
                        style: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                          color: isSel ? Colors.white : const Color(0xFF0F172A),
                        ),
                      ),
                    ],
                  ),
                  selected: isSel,
                  selectedColor: const Color(0xFF0F172A),
                  backgroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                    side: BorderSide(color: isSel ? const Color(0xFF0F172A) : const Color(0xFFE2E8F0)),
                  ),
                  onSelected: (val) {
                    if (val) controller.selectedMode.value = m['key'] as String;
                  },
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  // 3. Photo Upload Area
  Widget _buildPhotoUploadArea() {
    final hasPhoto = controller.userImageBase64.value != null;

    if (hasPhoto) {
      final imgVal = controller.userImageBase64.value!;
      final isUrl = imgVal.startsWith('http');

      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'YOUR REFERENCE PHOTO',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF64748B),
                  ),
                ),
                TextButton.icon(
                  onPressed: controller.removePhoto,
                  icon: const Icon(Icons.close_rounded, size: 16, color: Color(0xFFE11D48)),
                  label: Text('Remove', style: GoogleFonts.plusJakartaSans(color: const Color(0xFFE11D48), fontSize: 12, fontWeight: FontWeight.w700)),
                ),
              ],
            ),
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: isUrl
                  ? Image.network(imgVal, height: 320, width: double.infinity, fit: BoxFit.cover)
                  : (controller.userImageBytes.value != null
                      ? Image.memory(controller.userImageBytes.value!, height: 320, width: double.infinity, fit: BoxFit.cover)
                      : Container(height: 320, color: Colors.grey.shade200)),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: controller.pickUserPhoto,
              icon: const Icon(Icons.photo_camera_back_outlined, size: 16),
              label: const Text('Change Photo'),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFFE2E8F0)),
                foregroundColor: const Color(0xFF0F172A),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        children: [
          // Upload Drop Zone
          GestureDetector(
            onTap: controller.pickUserPhoto,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 16),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFCBD5E1), width: 1.5, strokeAlign: BorderSide.strokeAlignInside),
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFF6FF),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.add_a_photo_outlined, size: 36, color: Color(0xFF2563EB)),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'Upload Your Photo',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Tap to browse gallery or take a picture\nJPG, PNG accepted up to 10MB',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      color: const Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 18),

          // Instant Test with Sample Models
          Row(
            children: [
              const Expanded(child: Divider(color: Color(0xFFE2E8F0))),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Text('OR TEST WITH A SAMPLE MODEL', style: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.w800, color: const Color(0xFF94A3B8))),
              ),
              const Expanded(child: Divider(color: Color(0xFFE2E8F0))),
            ],
          ),

          const SizedBox(height: 14),

          Row(
            children: controller.samplePortraits.map((sample) {
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: InkWell(
                    onTap: () => controller.useSamplePortrait(sample['url']!),
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Column(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              sample['url']!,
                              height: 60,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            sample['name']!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF0F172A),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // 4. Generating Progress Animation Card
  Widget _buildGeneratingProgressCard() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFFE11D48), Color(0xFF9333EA)]),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.auto_awesome, color: Colors.white, size: 36),
          ),
          const SizedBox(height: 24),
          Text(
            'Creating Your AI Preview',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: const Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            controller.progressMessage.value,
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 24),
          const SizedBox(
            width: 180,
            child: LinearProgressIndicator(
              color: Color(0xFFE11D48),
              backgroundColor: Color(0xFFF1F5F9),
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }

  // 5. Interactive Before / After Comparison Slider
  Widget _buildBeforeAfterInteractiveViewer(TryOnJobModel job) {
    final beforeUrl = job.userImageUrl;
    final afterUrl = job.resultDisplayUrl;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [
          BoxShadow(color: Color(0x0A000000), blurRadius: 16, offset: Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.compare_arrows_rounded, color: Color(0xFFE11D48), size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'BEFORE / AFTER PREVIEW',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                        color: const Color(0xFF0F172A),
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFFECFDF5),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    'Slide bar to compare',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF059669),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Interactive Comparison Slider Box
          LayoutBuilder(
            builder: (context, constraints) {
              final w = constraints.maxWidth;
              const h = 420.0;

              return ClipRRect(
                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20)),
                child: SizedBox(
                  width: w,
                  height: h,
                  child: Stack(
                    children: [
                      // Layer 1: BEFORE Image (Full width background)
                      Positioned.fill(
                        child: Image.network(
                          beforeUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(color: Colors.grey.shade300),
                        ),
                      ),

                      // Layer 2: AFTER Image (Clipped dynamically by split position)
                      Positioned.fill(
                        child: Obx(() {
                          final split = controller.comparisonPosition.value.clamp(0.0, 1.0);
                          return ClipRect(
                            clipper: _HorizontalSplitClipper(split),
                            child: Image.network(
                              afterUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(color: Colors.pink.shade100),
                            ),
                          );
                        }),
                      ),

                      // Badges: "Original" & "AI Try-On"
                      Positioned(
                        top: 14,
                        left: 14,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.65),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            'Original',
                            style: GoogleFonts.plusJakartaSans(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ),

                      Positioned(
                        top: 14,
                        right: 14,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(colors: [Color(0xFFE11D48), Color(0xFF9333EA)]),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            'AI Try-On',
                            style: GoogleFonts.plusJakartaSans(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ),

                      // Divider Line & Draggable Handle
                      Obx(() {
                        final split = controller.comparisonPosition.value.clamp(0.0, 1.0);
                        final xPos = w * split;

                        return Positioned(
                          left: xPos - 18,
                          top: 0,
                          bottom: 0,
                          child: GestureDetector(
                            behavior: HitTestBehavior.translucent,
                            onHorizontalDragUpdate: (details) {
                              final newPos = (details.globalPosition.dx - 20) / w;
                              controller.comparisonPosition.value = newPos.clamp(0.05, 0.95);
                            },
                            child: SizedBox(
                              width: 36,
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  // White vertical line
                                  Container(
                                    width: 3,
                                    height: h,
                                    color: Colors.white,
                                  ),
                                  // Center circular thumb
                                  Container(
                                    width: 32,
                                    height: 32,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      shape: BoxShape.circle,
                                      boxShadow: const [
                                        BoxShadow(color: Color(0x33000000), blurRadius: 8, offset: Offset(0, 2)),
                                      ],
                                      border: Border.all(color: const Color(0xFFE11D48), width: 2),
                                    ),
                                    child: const Icon(Icons.code_rounded, size: 16, color: Color(0xFFE11D48)),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // 6. Consent Notice
  Widget _buildConsentNotice() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 22,
          height: 22,
          child: Checkbox(
            value: controller.hasConsented.value,
            activeColor: const Color(0xFFE11D48),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
            onChanged: (val) => controller.hasConsented.value = val ?? true,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            'I understand this photo is securely processed with AI to visualize this product. Photos are kept private and never shared.',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11,
              color: const Color(0xFF64748B),
              height: 1.3,
            ),
          ),
        ),
      ],
    );
  }

  // 7. Generate Preview Button
  Widget _buildGenerateButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: controller.isGenerating.value ? null : controller.generatePreview,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFE11D48),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          elevation: 0,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.auto_awesome, size: 18, color: Colors.white),
            const SizedBox(width: 8),
            Text(
              'Generate My Preview',
              style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.w900,
                fontSize: 15,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 8. Actions after Preview is generated
  Widget _buildCompletedActions(dynamic product, TryOnJobModel job) {
    final cartController = Get.isRegistered<CartController>()
        ? Get.find<CartController>()
        : Get.put(CartController());

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () async {
                  if (product != null) {
                    try {
                      String defaultSize = 'M';
                      if (product.sizes is List && (product.sizes as List).isNotEmpty) {
                        defaultSize = (product.sizes as List).first.toString();
                      }
                      String defaultColor = 'Standard';
                      if (product.colors is List && (product.colors as List).isNotEmpty) {
                        final c = (product.colors as List).first;
                        defaultColor = (c is Map && c['name'] != null) ? c['name'] : (c?.name ?? 'Standard');
                      }

                      await ApiClient.post(ApiEndpoints.cart, data: {
                        'product_id': product.id,
                        'quantity': 1,
                        'size': defaultSize,
                        'color': defaultColor,
                      });
                      await cartController.fetchCart();
                      Get.snackbar(
                        'Added to Bag',
                        '${product.name} is now in your shopping bag!',
                        backgroundColor: const Color(0xFF10B981),
                        colorText: Colors.white,
                        snackPosition: SnackPosition.TOP,
                      );
                      Get.toNamed(AppRoutes.cart);
                    } catch (_) {
                      cartController.fetchCart();
                      Get.toNamed(AppRoutes.cart);
                    }
                  }
                },
                icon: const Icon(Icons.shopping_bag_outlined, size: 16),
                label: const FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    'Add to Bag',
                    maxLines: 1,
                    style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE11D48),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {
                  controller.currentJob.value = null; // Re-run or change photo
                },
                icon: const Icon(Icons.refresh_rounded, size: 16),
                label: const FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    'Generate Again',
                    maxLines: 1,
                    style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF0F172A),
                  side: const BorderSide(color: Color(0xFFCBD5E1), width: 1.5),
                  padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          child: TextButton.icon(
            onPressed: () => Get.back(),
            icon: const Icon(Icons.arrow_back, size: 16, color: Color(0xFF64748B)),
            label: Text('Try Another Product', style: GoogleFonts.plusJakartaSans(color: const Color(0xFF64748B), fontWeight: FontWeight.w700)),
          ),
        ),
      ],
    );
  }

  // 9. History Modal Bottom Sheet
  void _showHistoryBottomSheet(BuildContext context) {
    controller.fetchHistory();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Try-On History', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w900, fontSize: 18)),
                  IconButton(icon: const Icon(Icons.close), onPressed: () => Get.back()),
                ],
              ),
              const Divider(),
              Expanded(
                child: Obx(() {
                  if (controller.isLoadingHistory.value) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (controller.historyJobs.isEmpty) {
                    return const Center(child: Text('No previous try-ons saved.'));
                  }
                  return ListView.separated(
                    itemCount: controller.historyJobs.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (ctx, idx) {
                      final h = controller.historyJobs[idx];
                      return ListTile(
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            h.resultDisplayUrl.isNotEmpty ? h.resultDisplayUrl : h.userImageUrl,
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(width: 50, height: 50, color: Colors.grey.shade200),
                          ),
                        ),
                        title: Text(h.productDetails?.name ?? 'Try-On #${h.id}', style: const TextStyle(fontWeight: FontWeight.w700)),
                        subtitle: Text('${h.visualizationMode} • ${h.status}'),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_outline, size: 20),
                          onPressed: () => controller.deleteHistoryJob(h.id),
                        ),
                        onTap: () {
                          Get.back();
                          controller.currentJob.value = h;
                        },
                      );
                    },
                  );
                }),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _HorizontalSplitClipper extends CustomClipper<Rect> {
  final double split;
  _HorizontalSplitClipper(this.split);

  @override
  Rect getClip(Size size) {
    return Rect.fromLTRB(size.width * split, 0, size.width, size.height);
  }

  @override
  bool shouldReclip(_HorizontalSplitClipper oldClipper) => oldClipper.split != split;
}

