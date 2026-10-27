import '../../product/models/product_model.dart';

class CartItemModel {
  final int id;
  final ProductModel product;
  int quantity;
  final String size;
  final String color;
  final double totalPrice;

  CartItemModel({
    required this.id,
    required this.product,
    required this.quantity,
    required this.size,
    required this.color,
    required this.totalPrice,
  });

  factory CartItemModel.fromJson(Map<String, dynamic> json) {
    return CartItemModel(
      id: json['id'] ?? 0,
      product: ProductModel.fromJson(json['product'] ?? {}),
      quantity: json['quantity'] ?? 1,
      size: json['size'] ?? 'M',
      color: json['color'] ?? 'Pink',
      totalPrice: double.tryParse(json['total_price'].toString()) ?? 0.0,
    );
  }
}

class CartSummaryModel {
  final int count;
  final double itemTotal;
  final double discountAmount;
  final String deliveryCharges;
  final double finalTotal;
  final bool couponApplied;

  CartSummaryModel({
    required this.count,
    required this.itemTotal,
    required this.discountAmount,
    required this.deliveryCharges,
    required this.finalTotal,
    required this.couponApplied,
  });

  factory CartSummaryModel.fromJson(Map<String, dynamic> json) {
    return CartSummaryModel(
      count: json['count'] ?? 0,
      itemTotal: double.tryParse(json['item_total'].toString()) ?? 0.0,
      discountAmount: double.tryParse(json['discount_amount'].toString()) ?? 0.0,
      deliveryCharges: json['delivery_charges']?.toString() ?? 'FREE',
      finalTotal: double.tryParse(json['final_total'].toString()) ?? 0.0,
      couponApplied: json['coupon_applied'] ?? false,
    );
  }
}
