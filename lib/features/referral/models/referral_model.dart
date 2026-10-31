class ReferralStatsModel {
  final String referralCode;
  final String referralLink;
  final int totalInvites;
  final int successfulReferrals;
  final int pendingReferrals;
  final double rewardsEarned;
  final double minOrderForReward;
  final double rewardPerReferral;

  ReferralStatsModel({
    required this.referralCode,
    required this.referralLink,
    required this.totalInvites,
    required this.successfulReferrals,
    required this.pendingReferrals,
    required this.rewardsEarned,
    this.minOrderForReward = 300.0,
    this.rewardPerReferral = 100.0,
  });

  factory ReferralStatsModel.fromJson(Map<String, dynamic> json) {
    return ReferralStatsModel(
      referralCode: json['referral_code'] ?? '',
      referralLink: json['referral_link'] ?? '',
      totalInvites: json['total_invites'] ?? 0,
      successfulReferrals: json['successful_referrals'] ?? 0,
      pendingReferrals: json['pending_referrals'] ?? 0,
      rewardsEarned: double.tryParse(json['rewards_earned']?.toString() ?? '0') ?? 0.0,
      minOrderForReward: double.tryParse(json['min_order_for_reward']?.toString() ?? '300') ?? 300.0,
      rewardPerReferral: double.tryParse(json['reward_per_referral']?.toString() ?? '100') ?? 100.0,
    );
  }
}

class ReferralItemModel {
  final int id;
  final String friendName;
  final String status; // pending, successful, rejected
  final String codeUsed;
  final String referralDate;
  final String? qualifiedAt;
  final double rewardAmount;

  ReferralItemModel({
    required this.id,
    required this.friendName,
    required this.status,
    required this.codeUsed,
    required this.referralDate,
    this.qualifiedAt,
    required this.rewardAmount,
  });

  bool get isSuccessful => status == 'successful';
  bool get isPending => status == 'pending';
  bool get isRejected => status == 'rejected';

  factory ReferralItemModel.fromJson(Map<String, dynamic> json) {
    return ReferralItemModel(
      id: json['id'] ?? 0,
      friendName: json['friend_name'] ?? 'Friend',
      status: json['status'] ?? 'pending',
      codeUsed: json['code_used'] ?? '',
      referralDate: json['referral_date'] ?? '',
      qualifiedAt: json['qualified_at'],
      rewardAmount: double.tryParse(json['reward_amount']?.toString() ?? '0') ?? 0.0,
    );
  }
}

class ReferralRewardModel {
  final int id;
  final double rewardAmount;
  final String rewardType;
  final bool isCredited;
  final String creditedDate;
  final String notes;

  ReferralRewardModel({
    required this.id,
    required this.rewardAmount,
    required this.rewardType,
    required this.isCredited,
    required this.creditedDate,
    required this.notes,
  });

  factory ReferralRewardModel.fromJson(Map<String, dynamic> json) {
    return ReferralRewardModel(
      id: json['id'] ?? 0,
      rewardAmount: double.tryParse(json['reward_amount']?.toString() ?? '0') ?? 0.0,
      rewardType: json['reward_type'] ?? 'wallet_credit',
      isCredited: json['is_credited'] ?? true,
      creditedDate: json['credited_date'] ?? '',
      notes: json['notes'] ?? '',
    );
  }
}

