import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/api_endpoints.dart';
import '../../../core/network/api_client.dart';
import 'policy_page_view.dart';

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

  void _handleTopicClick(String title) {
    if (title == 'Track My Order') {
      Get.toNamed('/my-orders');
    } else if (title == 'Returns & Refunds') {
      Get.toNamed('/return-refund');
    } else if (title == 'Shipping & Delivery') {
      Get.to(() => const PolicyPageView(slug: 'shipping-policy', title: 'Shipping & Delivery'));
    } else {
      final related = _faqs.firstWhereOrNull((f) => f['category'] == title);
      if (related != null) {
        Get.defaultDialog(
          title: related['question'] ?? title,
          titleStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
          middleText: related['answer'] ?? 'Support assistance available 24/7.',
          textConfirm: 'Got it',
          confirmTextColor: Colors.white,
          buttonColor: AppColors.primary,
          onConfirm: () => Get.back(),
        );
      } else {
        Get.defaultDialog(
          title: title,
          titleStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
          middleText: 'For direct assistance with $title, email our VIP concierge at concierge@stylehub.com or call +91 80 4567 8900.',
          textConfirm: 'Understood',
          confirmTextColor: Colors.white,
          buttonColor: AppColors.primary,
          onConfirm: () => Get.back(),
        );
      }
    }
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

    final policies = [
      {'title': 'About StyleHub Luxe', 'slug': 'about-us'},
      {'title': 'Privacy Policy', 'slug': 'privacy-policy'},
      {'title': 'Terms of Service', 'slug': 'terms-conditions'},
      {'title': 'Return & Refund Policy', 'slug': 'refund-policy'},
      {'title': 'Shipping & Delivery Policy', 'slug': 'shipping-policy'},
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
            // Search FAQ bar
            const TextField(
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.search, color: AppColors.textMuted),
                hintText: 'Search for help, topics, returns...',
              ),
            ),
            const SizedBox(height: 24),

            // Help Topics List
            const Text(
              'HELP TOPICS',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: Color(0xFF64748B),
                letterSpacing: 0.8,
              ),
            ),
            const SizedBox(height: 12),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: supportTopics.length,
              separatorBuilder: (_, _) => const Divider(height: 1, color: AppColors.divider),
              itemBuilder: (context, idx) {
                final topic = supportTopics[idx];
                final title = topic['title'] as String;
                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(vertical: 2),
                  leading: Icon(topic['icon'] as IconData, color: AppColors.textPrimary, size: 22),
                  title: Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                  ),
                  trailing: const Icon(Icons.chevron_right, color: AppColors.textMuted),
                  onTap: () => _handleTopicClick(title),
                );
              },
            ),

            const SizedBox(height: 32),

            // Legal & Policies Section
            const Text(
              'POLICIES & LEGAL (CMS)',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: Color(0xFF64748B),
                letterSpacing: 0.8,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: policies.length,
                separatorBuilder: (_, _) => const Divider(height: 1, color: Color(0xFFE2E8F0)),
                itemBuilder: (context, idx) {
                  final p = policies[idx];
                  return ListTile(
                    dense: true,
                    leading: const Icon(Icons.article_outlined, color: AppColors.primary, size: 20),
                    title: Text(
                      p['title']!,
                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 13, color: Colors.grey),
                    onTap: () {
                      Get.to(() => PolicyPageView(slug: p['slug']!, title: p['title']!));
                    },
                  );
                },
              ),
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}

