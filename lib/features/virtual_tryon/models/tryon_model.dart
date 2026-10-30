import '../../product/models/product_model.dart';

class TryOnJobModel {
  final int id;
  final int productId;
  final ProductModel? productDetails;
  final String visualizationMode;
  final String userImageUrl;
  final String productImageUrl;
  final String status; // pending, processing, completed, failed
  final String resultDisplayUrl;
  final String errorMessage;
  final String promptUsed;
  final Map<String, dynamic> metadata;
  final String createdAt;
  final String? completedAt;

  TryOnJobModel({
    required this.id,
    required this.productId,
    this.productDetails,
    required this.visualizationMode,
    required this.userImageUrl,
    required this.productImageUrl,
    required this.status,
    required this.resultDisplayUrl,
    this.errorMessage = '',
    this.promptUsed = '',
    this.metadata = const {},
    required this.createdAt,
    this.completedAt,
  });

  bool get isCompleted => status == 'completed' && resultDisplayUrl.isNotEmpty;
  bool get isProcessing => status == 'processing' || status == 'pending';
  bool get isFailed => status == 'failed';

  factory TryOnJobModel.fromJson(Map<String, dynamic> json) {
    return TryOnJobModel(
      id: json['id'] ?? 0,
      productId: json['product'] ?? 0,
      productDetails: json['product_details'] != null
          ? ProductModel.fromJson(json['product_details'])
          : null,
      visualizationMode: json['visualization_mode'] ?? 'clothing',
      userImageUrl: json['user_image_url'] ?? (json['user_image'] ?? ''),
      productImageUrl: json['product_image_url'] ?? '',
      status: json['status'] ?? 'pending',
      resultDisplayUrl: json['result_display_url'] ?? (json['result_image_url'] ?? ''),
      errorMessage: json['error_message'] ?? '',
      promptUsed: json['prompt_used'] ?? '',
      metadata: json['metadata'] is Map ? Map<String, dynamic>.from(json['metadata']) : {},
      createdAt: json['created_at'] ?? '',
      completedAt: json['completed_at'],
    );
  }
}

