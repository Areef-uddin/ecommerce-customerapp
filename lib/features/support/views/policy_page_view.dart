import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/api_endpoints.dart';
import '../../../core/network/api_client.dart';

class PolicyPageView extends StatefulWidget {
  final String? slug;
  final String? title;

  const PolicyPageView({super.key, this.slug, this.title});

  @override
  State<PolicyPageView> createState() => _PolicyPageViewState();
}

class _PolicyPageViewState extends State<PolicyPageView> {
  bool _isLoading = true;
  String _title = 'Policy';
  String _content = '';
  String _updatedAt = '';
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadPolicyContent();
  }

  Future<void> _loadPolicyContent() async {
    final slug = widget.slug ?? (Get.parameters['slug'] ?? (Get.arguments is String ? Get.arguments : 'privacy-policy'));
    final fallbackTitle = widget.title ?? (Get.parameters['title'] ?? 'Policy');

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _title = fallbackTitle;
    });

    try {
      final res = await ApiClient.get('${ApiEndpoints.policies}$slug/');
      if (res.data != null && res.data is Map) {
        final data = res.data as Map<String, dynamic>;
        setState(() {
          _title = data['title'] ?? fallbackTitle;
          _content = data['content'] ?? 'No content available for this policy.';
          _updatedAt = data['updated_at'] ?? '';
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = 'Could not load policy details.';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load policy. Please try again later.';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Color(0xFF0F172A)),
          onPressed: () => Get.back(),
        ),
        title: Text(
          _title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: Color(0xFF0F172A),
          ),
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            )
          : _errorMessage != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.info_outline, size: 48, color: Colors.grey),
                        const SizedBox(height: 12),
                        Text(
                          _errorMessage!,
                          style: const TextStyle(fontSize: 15, color: Colors.grey),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _loadPolicyContent,
                          style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                          child: const Text('Retry', style: TextStyle(color: Colors.white)),
                        ),
                      ],
                    ),
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 800),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (_updatedAt.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: Text(
                                'Last updated: ${_formatDate(_updatedAt)}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF94A3B8),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ..._buildFormattedContent(_content),
                          const SizedBox(height: 40),
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: const Color(0xFFE2E8F0)),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.support_agent_rounded, color: AppColors.primary, size: 28),
                                const SizedBox(width: 14),
                                const Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Need more assistance?',
                                        style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                                      ),
                                      Text(
                                        'Our 24/7 VIP Concierge team is here to help.',
                                        style: TextStyle(fontSize: 12, color: Colors.grey),
                                      ),
                                    ],
                                  ),
                                ),
                                TextButton(
                                  onPressed: () => Get.toNamed('/help-support'),
                                  child: const Text('Contact Us', style: TextStyle(fontWeight: FontWeight.w700)),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 30),
                        ],
                      ),
                    ),
                  ),
                ),
    );
  }

  String _formatDate(String isoString) {
    try {
      final dt = DateTime.parse(isoString);
      return '${dt.day}/${dt.month}/${dt.year}';
    } catch (_) {
      return isoString;
    }
  }

  List<Widget> _buildFormattedContent(String rawText) {
    final lines = rawText.split('\n');
    final widgets = <Widget>[];

    for (final line in lines) {
      final trimmed = line.trim();
      if (trimmed.isEmpty) {
        widgets.add(const SizedBox(height: 10));
      } else if (trimmed.startsWith('# ')) {
        widgets.add(Padding(
          padding: const EdgeInsets.only(top: 14, bottom: 6),
          child: Text(
            trimmed.substring(2),
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Color(0xFF0F172A)),
          ),
        ));
      } else if (trimmed.startsWith('## ')) {
        widgets.add(Padding(
          padding: const EdgeInsets.only(top: 14, bottom: 6),
          child: Text(
            trimmed.substring(3),
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
          ),
        ));
      } else if (trimmed.startsWith('### ')) {
        widgets.add(Padding(
          padding: const EdgeInsets.only(top: 10, bottom: 4),
          child: Text(
            trimmed.substring(4),
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Color(0xFF1E293B)),
          ),
        ));
      } else if (trimmed.startsWith('- ')) {
        widgets.add(Padding(
          padding: const EdgeInsets.symmetric(vertical: 3),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('• ', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.primary)),
              Expanded(
                child: Text(
                  trimmed.substring(2),
                  style: const TextStyle(fontSize: 14, height: 1.5, color: Color(0xFF334155)),
                ),
              ),
            ],
          ),
        ));
      } else {
        widgets.add(Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Text(
            trimmed,
            style: const TextStyle(fontSize: 14, height: 1.6, color: Color(0xFF334155)),
          ),
        ));
      }
    }

    return widgets;
  }
}
