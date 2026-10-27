import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/api_endpoints.dart';
import '../../../core/network/api_client.dart';

class HelpSupportView extends StatefulWidget {
  const HelpSupportView({super.key});

  @override
  State<HelpSupportView> createState() => _HelpSupportViewState();
}

class _HelpSupportViewState extends State<HelpSupportView> {
  final List<Map<String, dynamic>> _faqs = [];

  @override
  void initState() {
    super.initState();
    _fetchFaqs();
  }

  Future<void> _fetchFaqs() async {
    try {
      final res = await ApiClient.get(ApiEndpoints.faqs);
      if (res.data is List) {
        setState(() {
          _faqs.addAll(List<Map<String, dynamic>>.from(res.data));
        });
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final supportTopics = [
      {'title': 'Track My Order', 'icon': Icons.local_shipping_outlined},
      {'title': 'Returns & Refunds', 'icon': Icons.replay_outlined},
      {'title': 'Payment Issues', 'icon': Icons.credit_card_outlined},
      {'title': 'Product Information', 'icon': Icons.info_outline},
      {'title': 'Account & Profile', 'icon': Icons.person_outline},
      {'title': 'Shipping & Delivery', 'icon': Icons.inventory_2_outlined},
      {'title': 'Contact Us', 'icon': Icons.support_agent_outlined},
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
        title: const Text('Help & Support', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search FAQ bar matching Screen 20
            const TextField(
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.search, color: AppColors.textMuted),
                hintText: 'Search for help...',
              ),
            ),
            const SizedBox(height: 24),

            // Help Topics List matching Screen 20
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: supportTopics.length,
              separatorBuilder: (_, _) => const Divider(height: 1, color: AppColors.divider),
              itemBuilder: (context, idx) {
                final topic = supportTopics[idx];
                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(vertical: 2),
                  leading: Icon(topic['icon'] as IconData, color: AppColors.textPrimary, size: 22),
                  title: Text(
                    topic['title'] as String,
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                  ),
                  trailing: const Icon(Icons.chevron_right, color: AppColors.textMuted),
                  onTap: () {
                    // Show FAQs related to topic
                    final related = _faqs.firstWhereOrNull((f) => f['category'] == topic['title']);
                    if (related != null) {
                      Get.defaultDialog(
                        title: related['question'] ?? topic['title']!,
                        titleStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                        middleText: related['answer'] ?? 'Support assistance available 24/7.',
                        textConfirm: 'Got it',
                        confirmTextColor: Colors.white,
                        buttonColor: AppColors.primary,
                        onConfirm: () => Get.back(),
                      );
                    }
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
