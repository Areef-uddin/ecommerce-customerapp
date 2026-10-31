import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/routes/app_routes.dart';
import '../controllers/referral_controller.dart';

class ReferralProfileCard extends StatelessWidget {
  const ReferralProfileCard({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ReferralController());

    return Obx(() {
      final stats = controller.stats.value;
      final code = stats?.referralCode ?? '---';
      final totalInvites = stats?.totalInvites ?? 0;
      final successful = stats?.successfulReferrals ?? 0;
      final pending = stats?.pendingReferrals ?? 0;
      final rewardsEarned = stats?.rewardsEarned ?? 0.0;
      final rewardPerRef = stats?.rewardPerReferral ?? 100.0;

      return Container(
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: const LinearGradient(
            colors: [
              Color(0xFF0F172A),
              Color(0xFF1E293B),
              Color(0xFF134E4A),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF134E4A).withOpacity(0.25),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Ambient decorative background bubble
            Positioned(
              right: -30,
              top: -30,
              child: Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF10B981).withOpacity(0.08),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Header with Badge
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: const Color(0xFF10B981).withOpacity(0.18),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: const Color(0xFF10B981).withOpacity(0.4)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.card_giftcard_rounded, color: Color(0xFF34D399), size: 14),
                            const SizedBox(width: 6),
                            Text(
                              'EARN ₹${rewardPerRef.toInt()} PER FRIEND',
                              style: GoogleFonts.plusJakartaSans(
                                color: const Color(0xFF34D399),
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        visualDensity: VisualDensity.compact,
                        icon: const Icon(Icons.refresh_rounded, color: Colors.white70, size: 18),
                        onPressed: () => controller.fetchStats(),
                        tooltip: 'Refresh Stats',
                      ),
                    ],
                  ),

                  const SizedBox(height: 14),

                  // 2. Heading & Subtitle
                  Text(
                    'Refer Friends & Earn Rewards',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: -0.4,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Share the love. Invite your friends and earn rewards.',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF94A3B8),
                      height: 1.35,
                    ),
                  ),

                  const SizedBox(height: 20),

                  // 3. Referral Code Box + Copy
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white.withOpacity(0.12)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'YOUR REFERRAL CODE',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF94A3B8),
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              code,
                              style: GoogleFonts.firaCode(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: const Color(0xFFF8FAFC),
                                letterSpacing: 1.5,
                              ),
                            ),
                          ],
                        ),
                        InkWell(
                          onTap: controller.copyReferralCode,
                          borderRadius: BorderRadius.circular(10),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.copy_rounded, color: Colors.white, size: 14),
                                const SizedBox(width: 6),
                                Text(
                                  'Copy',
                                  style: GoogleFonts.plusJakartaSans(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 18),

                  // 4. Statistics Grid (4 Key Metrics)
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white.withOpacity(0.06)),
                    ),
                    child: Row(
                      children: [
                        _buildStatCol('Total Invites', '$totalInvites', Icons.send_rounded, const Color(0xFF38BDF8)),
                        _buildDivider(),
                        _buildStatCol('Successful', '$successful', Icons.check_circle_rounded, const Color(0xFF34D399)),
                        _buildDivider(),
                        _buildStatCol('Pending', '$pending', Icons.hourglass_top_rounded, const Color(0xFFFBBF24)),
                        _buildDivider(),
                        _buildStatCol('Rewards', '₹${rewardsEarned.toInt()}', Icons.wallet_rounded, const Color(0xFFA78BFA)),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // 5. Actions: WhatsApp Share (Green) & View My Referrals Button
                  Row(
                    children: [
                      // WhatsApp Green Button
                      Expanded(
                        flex: 6,
                        child: ElevatedButton(
                          onPressed: controller.shareOnWhatsApp,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF25D366),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // WhatsApp Icon SVG-like representation
                              Container(
                                padding: const EdgeInsets.all(2),
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white,
                                ),
                                child: const Icon(Icons.chat_bubble_rounded, color: Color(0xFF25D366), size: 14),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Share on WhatsApp',
                                style: GoogleFonts.plusJakartaSans(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 13,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),

                      // View My Referrals Button
                      Expanded(
                        flex: 4,
                        child: OutlinedButton(
                          onPressed: () => Get.toNamed(AppRoutes.referralHistory),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: Colors.white.withOpacity(0.25)),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: Text(
                            'My Referrals',
                            style: GoogleFonts.plusJakartaSans(
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildStatCol(String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(height: 6),
          Text(
            value,
            style: GoogleFonts.plusJakartaSans(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(
              color: const Color(0xFF94A3B8),
              fontSize: 9,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      width: 1,
      height: 32,
      color: Colors.white.withOpacity(0.1),
    );
  }
}

