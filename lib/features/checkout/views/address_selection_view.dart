import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/routes/app_routes.dart';
import '../controllers/checkout_controller.dart';
import '../../profile/models/address_model.dart';

class AddressSelectionView extends StatelessWidget {
  const AddressSelectionView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(CheckoutController());

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF0F172A)),
          onPressed: () {
            if (Navigator.canPop(context)) {
              Get.back();
            } else {
              Get.offNamed(AppRoutes.cart);
            }
          },
        ),
        title: Text(
          'Select Delivery Address',
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w800,
            fontSize: 18,
            color: const Color(0xFF0F172A),
          ),
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640),
          child: Obx(() {
            if (controller.isLoading.value) {
              return const Center(child: CircularProgressIndicator(color: AppColors.primary));
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ...controller.addresses.map((addr) => _buildAddressCard(context, addr, controller)),
                  const SizedBox(height: 16),

                  // + Add New Address Dashed Outline Button (Matching Image 3 Screen 1)
                  GestureDetector(
                    onTap: () => _showAddAddressDialog(context, controller),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: const Color(0xFFE11D48),
                          width: 1.5,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.add, color: Color(0xFFE11D48), size: 20),
                          const SizedBox(width: 8),
                          Text(
                            '+ Add New Address',
                            style: GoogleFonts.plusJakartaSans(
                              color: const Color(0xFFE11D48),
                              fontWeight: FontWeight.w800,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Continue Button: Dark Navy [ Continue  → ]
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: controller.selectedAddressId.value != 0
                          ? () => Get.toNamed('/checkout-payment')
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0F172A),
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: const Color(0xFF94A3B8),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Continue',
                            style: GoogleFonts.plusJakartaSans(
                              fontWeight: FontWeight.w800,
                              fontSize: 15,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Icon(Icons.arrow_forward_rounded, size: 18, color: Colors.white),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildAddressCard(BuildContext context, AddressModel addr, CheckoutController controller) {
    return Obx(() {
      final isSelected = controller.selectedAddressId.value == addr.id;
      final isHome = addr.addressType.toLowerCase() == 'home';

      return GestureDetector(
        onTap: () => controller.selectedAddressId.value = addr.id,
        child: Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(
              color: isSelected ? const Color(0xFFE11D48) : const Color(0xFFE2E8F0),
              width: isSelected ? 1.5 : 1,
            ),
            borderRadius: BorderRadius.circular(16),
            color: isSelected ? const Color(0xFFFFF1F2) : Colors.white,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Radio selection indicator
              Container(
                margin: const EdgeInsets.only(top: 2),
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected ? const Color(0xFFE11D48) : const Color(0xFF94A3B8),
                    width: isSelected ? 2 : 1.5,
                  ),
                  color: Colors.white,
                ),
                child: isSelected
                    ? Center(
                        child: Container(
                          width: 12,
                          height: 12,
                          decoration: const BoxDecoration(
                            color: Color(0xFFE11D48),
                            shape: BoxShape.circle,
                          ),
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: 12),

              // Icon container (Home or Office box)
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFFFFE4E6) : const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  isHome ? Icons.home_outlined : Icons.business_center_outlined,
                  color: isSelected ? const Color(0xFFE11D48) : const Color(0xFF64748B),
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),

              // Address Details (Title, Default Badge, Full Address)
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          addr.addressType,
                          style: GoogleFonts.plusJakartaSans(
                            fontWeight: FontWeight.w800,
                            fontSize: 15,
                            color: const Color(0xFF0F172A),
                          ),
                        ),
                        if (addr.isDefault) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFE4E6),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              'Default',
                              style: GoogleFonts.plusJakartaSans(
                                color: const Color(0xFFE11D48),
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      addr.state.isNotEmpty
                          ? '${addr.addressLine}, ${addr.city} - ${addr.postalCode}, ${addr.state}'
                          : '${addr.addressLine}, ${addr.city} - ${addr.postalCode}',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        color: const Color(0xFF64748B),
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),

              // Edit option and Chevron (Matching User Request: "and edit option last image me bhi de bhai")
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit_outlined, size: 18, color: Color(0xFF0284C7)),
                    tooltip: 'Edit Address',
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                    onPressed: () => _showEditAddressDialog(context, addr, controller),
                  ),
                  const Icon(Icons.chevron_right_rounded, color: Color(0xFF94A3B8), size: 22),
                ],
              ),
            ],
          ),
        ),
      );
    });
  }

  // Edit Address Dialog Modal
  void _showEditAddressDialog(BuildContext context, AddressModel addr, CheckoutController controller) {
    final nameCtrl = TextEditingController(text: addr.fullName);
    final phoneCtrl = TextEditingController(text: addr.phone);
    final addrCtrl = TextEditingController(text: addr.addressLine);
    final cityCtrl = TextEditingController(text: addr.city);
    final pinCtrl = TextEditingController(text: addr.postalCode);
    final stateCtrl = TextEditingController(text: addr.state.isNotEmpty ? addr.state : 'Karnataka, India');
    final typeVal = addr.addressType.obs;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.fromLTRB(24, 24, 24, MediaQuery.of(ctx).viewInsets.bottom + 24),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Edit Delivery Address',
                      style: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.w800, color: const Color(0xFF0F172A)),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Color(0xFF64748B)),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(labelText: 'Full Name'),
                  style: GoogleFonts.plusJakartaSans(),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: phoneCtrl,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(labelText: 'Phone Number'),
                  style: GoogleFonts.plusJakartaSans(),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: addrCtrl,
                  decoration: const InputDecoration(labelText: 'Address Line / Street / House'),
                  style: GoogleFonts.plusJakartaSans(),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: cityCtrl,
                        decoration: const InputDecoration(labelText: 'City'),
                        style: GoogleFonts.plusJakartaSans(),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: pinCtrl,
                        decoration: const InputDecoration(labelText: 'PIN Code'),
                        style: GoogleFonts.plusJakartaSans(),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  'Address Type',
                  style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, fontSize: 13, color: const Color(0xFF0F172A)),
                ),
                const SizedBox(height: 8),
                Obx(
                  () => Row(
                    children: ['Home', 'Office', 'Other'].map((type) {
                      final isSel = typeVal.value == type;
                      return GestureDetector(
                        onTap: () => typeVal.value = type,
                        child: Container(
                          margin: const EdgeInsets.only(right: 12),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: isSel ? const Color(0xFFFFF1F2) : Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: isSel ? const Color(0xFFE11D48) : const Color(0xFFE2E8F0)),
                          ),
                          child: Text(
                            type,
                            style: GoogleFonts.plusJakartaSans(
                              color: isSel ? const Color(0xFFE11D48) : const Color(0xFF0F172A),
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      controller.updateAddress(
                        addr.id,
                        fullName: nameCtrl.text.trim(),
                        phone: phoneCtrl.text.trim(),
                        addressLine: addrCtrl.text.trim(),
                        city: cityCtrl.text.trim(),
                        state: stateCtrl.text.trim(),
                        postalCode: pinCtrl.text.trim(),
                        addressType: typeVal.value,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0F172A),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text(
                      'Save Changes',
                      style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800, fontSize: 14),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Add Address Dialog Modal
  void _showAddAddressDialog(BuildContext context, CheckoutController controller) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.fromLTRB(24, 24, 24, MediaQuery.of(ctx).viewInsets.bottom + 24),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Add Delivery Address',
                      style: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.w800, color: const Color(0xFF0F172A)),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Color(0xFF64748B)),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: controller.fullNameController,
                  decoration: const InputDecoration(labelText: 'Full Name'),
                  style: GoogleFonts.plusJakartaSans(),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: controller.phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(labelText: 'Phone Number'),
                  style: GoogleFonts.plusJakartaSans(),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: controller.addressController,
                  decoration: const InputDecoration(labelText: 'Street / House / Area'),
                  style: GoogleFonts.plusJakartaSans(),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: controller.cityController,
                        decoration: const InputDecoration(labelText: 'City'),
                        style: GoogleFonts.plusJakartaSans(),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: controller.pinController,
                        decoration: const InputDecoration(labelText: 'PIN Code'),
                        style: GoogleFonts.plusJakartaSans(),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  'Address Type',
                  style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, fontSize: 13, color: const Color(0xFF0F172A)),
                ),
                const SizedBox(height: 8),
                Obx(
                  () => Row(
                    children: ['Home', 'Office', 'Other'].map((type) {
                      final isSel = controller.addressType.value == type;
                      return GestureDetector(
                        onTap: () => controller.addressType.value = type,
                        child: Container(
                          margin: const EdgeInsets.only(right: 12),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: isSel ? const Color(0xFFFFF1F2) : Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: isSel ? const Color(0xFFE11D48) : const Color(0xFFE2E8F0)),
                          ),
                          child: Text(
                            type,
                            style: GoogleFonts.plusJakartaSans(
                              color: isSel ? const Color(0xFFE11D48) : const Color(0xFF0F172A),
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => controller.addNewAddress(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0F172A),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text(
                      'Save Address',
                      style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800, fontSize: 14),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
