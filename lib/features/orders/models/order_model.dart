class OrderModel {
  final int id;
  final String orderNumber;
  final String customerName;
  final String phone;
  final String deliveryAddress;
  final String addressType;
  final String paymentMethod;
  final String paymentStatus;
  final String orderStatus;
  final double itemTotal;
  final double discountAmount;
  final double deliveryCharges;
  final double totalAmount;
  final String deliveryPartnerName;
  final String deliveryPartnerPhone;
  final double deliveryPartnerRating;
  final String deliveryPartnerVehicle;
  final String estimatedDelivery;
  final String createdAt;
  final List<OrderItemModel> items;
  final List<OrderTimelineModel> timeline;

  OrderModel({
    required this.id,
    required this.orderNumber,
    required this.customerName,
    required this.phone,
    required this.deliveryAddress,
    required this.addressType,
    required this.paymentMethod,
    required this.paymentStatus,
    required this.orderStatus,
    required this.itemTotal,
    required this.discountAmount,
    required this.deliveryCharges,
    required this.totalAmount,
    this.deliveryPartnerName = 'Rahul Kumar',
    this.deliveryPartnerPhone = '+91 9876543210',
    this.deliveryPartnerRating = 4.8,
    this.deliveryPartnerVehicle = 'TB1234',
    this.estimatedDelivery = '',
    required this.createdAt,
    this.items = const [],
    this.timeline = const [],
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    var itemsList = <OrderItemModel>[];
    if (json['items'] != null) {
      for (var it in json['items']) {
        itemsList.add(OrderItemModel.fromJson(it));
      }
    }

    var tlList = <OrderTimelineModel>[];
    if (json['timeline'] != null) {
      for (var tl in json['timeline']) {
        tlList.add(OrderTimelineModel.fromJson(tl));
      }
    }

    return OrderModel(
      id: json['id'] ?? 0,
      orderNumber: json['order_number'] ?? '',
      customerName: json['customer_name'] ?? '',
      phone: json['phone'] ?? '',
      deliveryAddress: json['delivery_address'] ?? '',
      addressType: json['address_type'] ?? 'Home',
      paymentMethod: json['payment_method'] ?? 'UPI',
      paymentStatus: json['payment_status'] ?? 'Paid',
      orderStatus: json['order_status'] ?? 'Placed',
      itemTotal: double.tryParse(json['item_total'].toString()) ?? 0.0,
      discountAmount: double.tryParse(json['discount_amount'].toString()) ?? 0.0,
      deliveryCharges: double.tryParse(json['delivery_charges'].toString()) ?? 0.0,
      totalAmount: double.tryParse(json['total_amount'].toString()) ?? 0.0,
      deliveryPartnerName: json['delivery_partner_name'] ?? 'Rahul Kumar',
      deliveryPartnerPhone: json['delivery_partner_phone'] ?? '+91 9876543210',
      deliveryPartnerRating: double.tryParse(json['delivery_partner_rating'].toString()) ?? 4.8,
      deliveryPartnerVehicle: json['delivery_partner_vehicle'] ?? 'TB1234',
      estimatedDelivery: json['estimated_delivery'] ?? '',
      createdAt: json['created_at'] ?? '',
      items: itemsList,
      timeline: tlList,
    );
  }
}

class OrderItemModel {
  final int id;
  final String productName;
  final double price;
  final int quantity;
  final String size;
  final String color;
  final String imageUrl;

  OrderItemModel({
    required this.id,
    required this.productName,
    required this.price,
    required this.quantity,
    required this.size,
    required this.color,
    required this.imageUrl,
  });

  factory OrderItemModel.fromJson(Map<String, dynamic> json) {
    return OrderItemModel(
      id: json['id'] ?? 0,
      productName: json['product_name'] ?? '',
      price: double.tryParse(json['price'].toString()) ?? 0.0,
      quantity: json['quantity'] ?? 1,
      size: json['size'] ?? 'M',
      color: json['color'] ?? 'Pink',
      imageUrl: json['image_url'] ?? '',
    );
  }
}

class OrderTimelineModel {
  final String statusStep;
  final String dateText;
  final bool isCompleted;
  final int orderIndex;

  OrderTimelineModel({
    required this.statusStep,
    required this.dateText,
    required this.isCompleted,
    required this.orderIndex,
  });

  factory OrderTimelineModel.fromJson(Map<String, dynamic> json) {
    return OrderTimelineModel(
      statusStep: json['status_step'] ?? '',
      dateText: json['date_text'] ?? '',
      isCompleted: json['is_completed'] ?? false,
      orderIndex: json['order_index'] ?? 0,
    );
  }
}
