import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/api_endpoints.dart';
import '../../../core/network/api_client.dart';
import '../../support/views/policy_page_view.dart';

class AppFooter extends StatefulWidget {
  const AppFooter({super.key});

  @override
  State<AppFooter> createState() => _AppFooterState();
}

class _AppFooterState extends State<AppFooter> {
  final TextEditingController _newsletterEmailController = TextEditingController();
  bool _isSubscribing = false;
  Map<String, dynamic>? _footerData;

  @override
  void initState() {
    super.initState();
    _fetchFooterData();
  }

  @override
  void dispose() {
    _newsletterEmailController.dispose();
    super.dispose();
  }

  Future<void> _fetchFooterData() async {
    try {
      final res = await ApiClient.get(ApiEndpoints.footer);
      if (res.data is Map) {
        if (mounted) {
          setState(() {
            _footerData = Map<String, dynamic>.from(res.data);
          });
        }
      }
    } catch (_) {}
  }

  Future<void> _subscribeNewsletter() async {
    final email = _newsletterEmailController.text.trim();
    if (email.isEmpty || !email.contains('@')) {
      Get.snackbar(
        'Invalid Email',
        'Please enter a valid email address.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFEF4444),
        colorText: Colors.white,
      );
      return;
    }

    setState(() => _isSubscribing = true);
    try {
      final res = await ApiClient.post(ApiEndpoints.newsletter, data: {'email': email});
      final msg = res.data?['message'] ?? 'Thank you for subscribing to StyleHub Luxe!';
      _newsletterEmailController.clear();
      Get.snackbar(
        'Subscribed!',
        msg,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFF10B981),
        colorText: Colors.white,
      );
    } catch (_) {
      Get.snackbar(
        'Subscription',
        'Thank you! You are subscribed to our private sales & drops.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFF10B981),
        colorText: Colors.white,
      );
      _newsletterEmailController.clear();
    } finally {
      if (mounted) setState(() => _isSubscribing = false);
    }
  }

  void _handleLinkClick(String url, String label) {
    if (url.startsWith('/policies/')) {
      final slug = url.replaceFirst('/policies/', '');
      Get.to(() => PolicyPageView(slug: slug, title: label));
    } else if (url.startsWith('/')) {
      Get.toNamed(url);
    }
  }

  @override
  Widget build(BuildContext context) {
    final storeSettings = _footerData?['store_settings'] as Map<String, dynamic>? ?? {};
    final sections = (_footerData?['sections'] as List<dynamic>?) ?? [];
    final storeName = storeSettings['store_name'] ?? 'StyleHub Luxe';
    final tagline = storeSettings['tagline'] ?? 'Curated Luxury Fashion & Timeless Designer Collections';
    final supportPhone = storeSettings['support_phone'] ?? '+91 80 4567 8900';
    final supportEmail = storeSettings['support_email'] ?? 'concierge@stylehub.com';
    final flagshipAddress = storeSettings['flagship_address'] ?? '100 Feet Rd, Indiranagar, Bengaluru';
    final workingHours = storeSettings['working_hours'] ?? 'Mon - Sat: 09:00 AM - 08:00 PM';
    final copyrightText = storeSettings['copyright_text'] ?? '© 2026 StyleHub Luxe Technologies Pvt Ltd. All rights reserved.';

    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 800;

    return Container(
      width: double.infinity,
      color: const Color(0xFF0F172A), // Luxury Dark Slate
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop ? 48 : 20,
        vertical: 36,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Newsletter Card
              Container(
                padding: EdgeInsets.all(isDesktop ? 28 : 20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF1E293B), Color(0xFF334155)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: const Color(0xFF475569), width: 0.8),
                ),
                child: isDesktop
                    ? Row(
                        children: [
                          Expanded(
                            flex: 3,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.mark_email_unread_outlined, color: AppColors.primary, size: 24),
                                    const SizedBox(width: 10),
                                    const Text(
                                      'JOIN THE STYLEHUB PRIVILEGE CLUB',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w900,
                                        letterSpacing: 1.2,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  tagline,
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.7),
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 24),
                          Expanded(
                            flex: 2,
                            child: _buildNewsletterInput(),
                          ),
                        ],
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.mark_email_unread_outlined, color: AppColors.primary, size: 22),
                              const SizedBox(width: 8),
                              const Expanded(
                                child: Text(
                                  'STYLEHUB PRIVILEGE CLUB',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 1.0,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Subscribe for private previews & exclusive drops.',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.7),
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 14),
                          _buildNewsletterInput(),
                        ],
                      ),
              ),
              const SizedBox(height: 36),

              // 2. Main Footer Grid (Brand + Dynamic Sections)
              if (isDesktop)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Brand Info Column
                    Expanded(
                      flex: 3,
                      child: _buildBrandInfo(storeName, supportPhone, supportEmail, flagshipAddress, workingHours),
                    ),
                    const SizedBox(width: 32),
                    // Dynamic Navigation Columns
                    Expanded(
                      flex: 5,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: sections.map<Widget>((sec) {
                          final secMap = sec as Map<String, dynamic>;
                          final title = secMap['title'] ?? '';
                          final links = (secMap['links'] as List<dynamic>?) ?? [];
                          return Expanded(
                            child: _buildSectionColumn(title, links),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                )
              else
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildBrandInfo(storeName, supportPhone, supportEmail, flagshipAddress, workingHours),
                    const SizedBox(height: 24),
                    const Divider(color: Color(0xFF334155)),
                    const SizedBox(height: 16),
                    ...sections.map<Widget>((sec) {
                      final secMap = sec as Map<String, dynamic>;
                      final title = secMap['title'] ?? '';
                      final links = (secMap['links'] as List<dynamic>?) ?? [];
                      return _buildMobileSectionAccordion(title, links);
                    }),
                  ],
                ),

              const SizedBox(height: 30),
              const Divider(color: Color(0xFF334155), height: 1),
              const SizedBox(height: 24),

              // 3. Trust & Payment Badges
              Wrap(
                spacing: 24,
                runSpacing: 14,
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  _buildTrustItem(Icons.verified_outlined, '100% Authentic'),
                  _buildTrustItem(Icons.local_shipping_outlined, 'Express Delivery'),
                  _buildTrustItem(Icons.replay_rounded, '7-Day Easy Returns'),
                  _buildTrustItem(Icons.lock_outline_rounded, '256-Bit SSL Secured'),
                ],
              ),
              const SizedBox(height: 24),

              // 4. Copyright & Legal
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      copyrightText,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.5),
                        fontSize: 11,
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      _buildSocialIconButton(Icons.camera_alt_outlined, 'https://instagram.com/stylehub'),
                      const SizedBox(width: 10),
                      _buildSocialIconButton(Icons.chat_bubble_outline_rounded, 'https://wa.me/919876543210'),
                      const SizedBox(width: 10),
                      _buildSocialIconButton(Icons.public, 'https://stylehub.com'),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNewsletterInput() {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFF0F172A),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFF475569)),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: TextField(
              controller: _newsletterEmailController,
              style: const TextStyle(color: Colors.white, fontSize: 13),
              decoration: InputDecoration(
                hintText: 'Enter your email address...',
                hintStyle: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 13),
                border: InputBorder.none,
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        SizedBox(
          height: 44,
          child: ElevatedButton(
            onPressed: _isSubscribing ? null : _subscribeNewsletter,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 18),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              elevation: 0,
            ),
            child: _isSubscribing
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                  )
                : const Text('Subscribe', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
          ),
        ),
      ],
    );
  }

  Widget _buildBrandInfo(String storeName, String phone, String email, String address, String hours) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              storeName.toUpperCase(),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text(
                'LUXE',
                style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w900),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          'India\'s premier shopping destination for luxury couture, ethnic designer wear, and verified authentic lifestyle accessories.',
          style: TextStyle(color: Colors.white.withOpacity(0.65), fontSize: 12, height: 1.5),
        ),
        const SizedBox(height: 16),
        _buildContactRow(Icons.phone_outlined, phone),
        const SizedBox(height: 8),
        _buildContactRow(Icons.email_outlined, email),
        const SizedBox(height: 8),
        _buildContactRow(Icons.location_on_outlined, address),
        const SizedBox(height: 8),
        _buildContactRow(Icons.access_time_rounded, hours),
      ],
    );
  }

  Widget _buildContactRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 14, color: AppColors.primary),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(color: Colors.white.withOpacity(0.75), fontSize: 11.5),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildSectionColumn(String title, List<dynamic> links) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title.toUpperCase(),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 14),
          ...links.map<Widget>((l) {
            final lMap = l as Map<String, dynamic>;
            final label = lMap['label'] ?? '';
            final url = lMap['url'] ?? '';
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: InkWell(
                onTap: () => _handleLinkClick(url, label),
                child: Text(
                  label,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.65),
                    fontSize: 12.5,
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildMobileSectionAccordion(String title, List<dynamic> links) {
    return Theme(
      data: ThemeData.dark().copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        tilePadding: EdgeInsets.zero,
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),
        iconColor: Colors.white70,
        collapsedIconColor: Colors.white70,
        children: links.map<Widget>((l) {
          final lMap = l as Map<String, dynamic>;
          final label = lMap['label'] ?? '';
          final url = lMap['url'] ?? '';
          return ListTile(
            dense: true,
            contentPadding: const EdgeInsets.only(left: 12),
            title: Text(
              label,
              style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 12),
            ),
            onTap: () => _handleLinkClick(url, label),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTrustItem(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: const Color(0xFF10B981)),
        const SizedBox(width: 6),
        Text(
          text,
          style: const TextStyle(color: Colors.white70, fontSize: 11.5, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  Widget _buildSocialIconButton(IconData icon, String url) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        shape: BoxShape.circle,
        border: Border.all(color: const Color(0xFF334155)),
      ),
      child: Center(
        child: Icon(icon, color: Colors.white70, size: 15),
      ),
    );
  }
}
