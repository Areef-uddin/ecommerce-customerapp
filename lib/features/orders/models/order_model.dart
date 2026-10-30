class OrderModel {
  final int id;
  final String orderNumber;
  final String trackingNumber;
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
  final String courierName;
  final bool isDemoMode;
  final String currentLocation;
  final String deliveryPartnerName;
  final String deliveryPartnerPhone;
  final double deliveryPartnerRating;
  final String deliveryPartnerVehicle;
  final String estimatedDelivery;
  final String createdAt;
  final List<OrderItemModel> items;
  final List<OrderTimelineModel> timeline;
  final ShipmentTrackingModel? shipment;

  OrderModel({
    required this.id,
    required this.orderNumber,
    required this.trackingNumber,
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
    this.courierName = 'StyleHub Express',
    this.isDemoMode = false,
    this.currentLocation = 'Bengaluru Fulfillment Center',
    this.deliveryPartnerName = 'Rahul Kumar',
    this.deliveryPartnerPhone = '+91 9876543210',
    this.deliveryPartnerRating = 4.8,
    this.deliveryPartnerVehicle = 'KA-01-SH-4421',
    this.estimatedDelivery = '',
    required this.createdAt,
    this.items = const [],
    this.timeline = const [],
    this.shipment,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    var itemsList = <OrderItemModel>[];
    if (json['items'] != null) {
      for (var it in json['items']) {
        itemsList.add(OrderItemModel.fromJson(it));
      }
    }

    // Parse shipment if present
    ShipmentTrackingModel? shipmentModel;
    if (json['shipment'] != null) {
      shipmentModel = ShipmentTrackingModel.fromJson(json['shipment']);
    }

    var tlList = <OrderTimelineModel>[];
    // Prioritize shipment milestones if available for the 7 stages
    if (shipmentModel != null && shipmentModel.milestones.isNotEmpty) {
      for (var m in shipmentModel.milestones) {
        tlList.add(
          OrderTimelineModel(
            statusStep: m.statusStep,
            dateText: m.dateFormatted.isNotEmpty ? m.dateFormatted : 'Expected',
            isCompleted: m.isCompleted,
            orderIndex: m.orderIndex,
            title: m.title,
            location: m.location,
            description: m.description,
            timestamp: m.timestamp,
          ),
        );
      }
    } else if (json['timeline'] != null) {
      for (var tl in json['timeline']) {
        tlList.add(OrderTimelineModel.fromJson(tl));
      }
    }

    final int idVal = json['id'] ?? 0;
    final String fallbackTracking = 'TEST-FASH-${1000 + idVal}';

    return OrderModel(
      id: idVal,
      orderNumber: json['order_number'] ?? '',
      trackingNumber:
          json['tracking_number'] ??
          (shipmentModel?.trackingNumber ?? fallbackTracking),
      customerName: json['customer_name'] ?? '',
      phone: json['phone'] ?? '',
      deliveryAddress: json['delivery_address'] ?? '',
      addressType: json['address_type'] ?? 'Home',
      paymentMethod: json['payment_method'] ?? 'UPI',
      paymentStatus: json['payment_status'] ?? 'Paid',
      orderStatus: json['order_status'] ?? 'Order Placed',
      itemTotal: double.tryParse(json['item_total'].toString()) ?? 0.0,
      discountAmount:
          double.tryParse(json['discount_amount'].toString()) ?? 0.0,
      deliveryCharges:
          double.tryParse(json['delivery_charges'].toString()) ?? 0.0,
      totalAmount: double.tryParse(json['total_amount'].toString()) ?? 0.0,
      courierName:
          shipmentModel?.courierName ??
          (json['courier_name'] ?? 'StyleHub Express'),
      isDemoMode: shipmentModel?.isDemoMode ?? (json['is_demo_mode'] ?? false),
      currentLocation:
          shipmentModel?.currentLocation ??
          (json['current_location'] ?? 'Bengaluru Fulfillment Center'),
      deliveryPartnerName:
          shipmentModel?.deliveryPartner?.name ??
          (json['delivery_partner_name'] ?? 'Rahul Kumar'),
      deliveryPartnerPhone:
          shipmentModel?.deliveryPartner?.phone ??
          (json['delivery_partner_phone'] ?? '+91 9876543210'),
      deliveryPartnerRating:
          shipmentModel?.deliveryPartner?.rating ??
          (double.tryParse(json['delivery_partner_rating'].toString()) ?? 4.8),
      deliveryPartnerVehicle:
          shipmentModel?.deliveryPartner?.vehicle ??
          (json['delivery_partner_vehicle'] ?? 'KA-01-SH-4421'),
      estimatedDelivery: json['estimated_delivery'] ?? '',
      createdAt: json['created_at'] ?? '',
      items: itemsList,
      timeline: tlList,
      shipment: shipmentModel,
    );
  }
}

class OrderItemModel {
  final int id;
  final int? productId;
  final String productName;
  final double price;
  final int quantity;
  final String size;
  final String color;
  final String imageUrl;

  OrderItemModel({
    required this.id,
    this.productId,
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
      productId: json['product'] is int
          ? json['product'] as int
          : (json['product'] is Map
                ? int.tryParse(json['product']['id'].toString())
                : int.tryParse(json['product'].toString())),
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
  final String title;
  final String location;
  final String description;
  final String timestamp;

  OrderTimelineModel({
    required this.statusStep,
    required this.dateText,
    required this.isCompleted,
    required this.orderIndex,
    this.title = '',
    this.location = '',
    this.description = '',
    this.timestamp = '',
  });

  factory OrderTimelineModel.fromJson(Map<String, dynamic> json) {
    return OrderTimelineModel(
      statusStep: json['status_step'] ?? '',
      dateText: json['date_text'] ?? '',
      isCompleted: json['is_completed'] ?? false,
      orderIndex: json['order_index'] ?? 0,
      title: json['title'] ?? (json['status_step'] ?? ''),
      location: json['location'] ?? '',
      description: json['description'] ?? '',
      timestamp: json['timestamp'] ?? '',
    );
  }
}

class ShipmentTrackingModel {
  final int id;
  final String trackingNumber;
  final String courierName;
  final bool isDemoMode;
  final String currentStatus;
  final String currentLocation;
  final String estimatedDelivery;
  final DeliveryPartnerModel? deliveryPartner;
  final List<TrackingMilestoneModel> milestones;

  ShipmentTrackingModel({
    required this.id,
    required this.trackingNumber,
    required this.courierName,
    required this.isDemoMode,
    required this.currentStatus,
    required this.currentLocation,
    required this.estimatedDelivery,
    this.deliveryPartner,
    this.milestones = const [],
  });

  factory ShipmentTrackingModel.fromJson(Map<String, dynamic> json) {
    var mlList = <TrackingMilestoneModel>[];
    if (json['milestones'] != null) {
      for (var m in json['milestones']) {
        mlList.add(TrackingMilestoneModel.fromJson(m));
      }
    }

    return ShipmentTrackingModel(
      id: json['id'] ?? 0,
      trackingNumber: json['tracking_number'] ?? '',
      courierName: json['courier_name'] ?? 'StyleHub Express',
      isDemoMode: json['is_demo_mode'] ?? false,
      currentStatus: json['current_status'] ?? 'Order Placed',
      currentLocation:
          json['current_location'] ?? 'Bengaluru Fulfillment Center',
      estimatedDelivery: json['estimated_delivery'] ?? '',
      deliveryPartner: json['delivery_partner'] != null
          ? DeliveryPartnerModel.fromJson(json['delivery_partner'])
          : null,
      milestones: mlList,
    );
  }
}

class DeliveryPartnerModel {
  final String name;
  final String phone;
  final double rating;
  final String vehicle;

  DeliveryPartnerModel({
    required this.name,
    required this.phone,
    required this.rating,
    required this.vehicle,
  });

  factory DeliveryPartnerModel.fromJson(Map<String, dynamic> json) {
    return DeliveryPartnerModel(
      name: json['name'] ?? 'Rahul Kumar',
      phone: json['phone'] ?? '+91 9876543210',
      rating: double.tryParse(json['rating'].toString()) ?? 4.8,
      vehicle: json['vehicle'] ?? 'KA-01-SH-4421',
    );
  }
}

class TrackingMilestoneModel {
  final int id;
  final String statusStep;
  final String title;
  final String location;
  final String description;
  final String timestamp;
  final String dateFormatted;
  final bool isCompleted;
  final int orderIndex;

  TrackingMilestoneModel({
    required this.id,
    required this.statusStep,
    required this.title,
    required this.location,
    required this.description,
    required this.timestamp,
    required this.dateFormatted,
    required this.isCompleted,
    required this.orderIndex,
  });

  factory TrackingMilestoneModel.fromJson(Map<String, dynamic> json) {
    return TrackingMilestoneModel(
      id: json['id'] ?? 0,
      statusStep: json['status_step'] ?? (json['status'] ?? ''),
      title: json['title'] ?? '',
      location: json['location'] ?? '',
      description: json['description'] ?? '',
      timestamp: json['timestamp'] ?? '',
      dateFormatted: json['date_formatted'] ?? '',
      isCompleted: json['is_completed'] ?? false,
      orderIndex: json['order_index'] ?? 0,
    );
  }
}
