import '../models/product_model.dart';

class DeliveryJob {
  final String id;
  final String customerName;
  final String customerContact;
  final String customerAddress;
  final DateTime scheduledDate;
  final String scheduledStartTime;
  final String scheduledEndTime;
  final String status; // 'pending', 'picked_up', 'en_route', 'delivered'
  final String? assignedPersonnelId;
  final String? proofImageUrl;
  final DateTime? deliveredAt;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final List<DeliveryItem> items;

  DeliveryJob({
    required this.id,
    required this.customerName,
    required this.customerContact,
    required this.customerAddress,
    required this.scheduledDate,
    required this.scheduledStartTime,
    required this.scheduledEndTime,
    required this.status,
    this.assignedPersonnelId,
    this.proofImageUrl,
    this.deliveredAt,
    required this.createdAt,
    this.updatedAt,
    this.items = const [],
  });

  factory DeliveryJob.fromJson(Map<String, dynamic> json) {
    // Parse delivery items if they exist
    List<DeliveryItem> deliveryItems = [];
    if (json['delivery_items'] != null) {
      deliveryItems = (json['delivery_items'] as List)
          .map((item) => DeliveryItem.fromJson(item))
          .toList();
    }

    return DeliveryJob(
      id: json['id']?.toString() ?? '',
      customerName: json['customer_name']?.toString() ?? '',
      customerContact: json['customer_contact']?.toString() ?? '',
      customerAddress: json['customer_address'] as String,
      scheduledDate: DateTime.parse(json['scheduled_date'] as String),
      scheduledStartTime: json['scheduled_start_time'] as String,
      scheduledEndTime: json['scheduled_end_time'] as String,
      status: json['status']?.toString() ?? '',
      assignedPersonnelId: json['assigned_personnel_id']?.toString() ?? '',
      proofImageUrl: json['proof_image_url']?.toString() ?? '',
      deliveredAt: json['delivered_at'] != null
          ? DateTime.parse(json['delivered_at'] as String)
          : null,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
      items: (json['delivery_items'] as List<dynamic>?)
          ?.map((item) => DeliveryItem.fromJson(item))
          .toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'customer_name': customerName,
      'customer_contact': customerContact,
      'customer_address': customerAddress,
      'scheduled_date': scheduledDate.toIso8601String().split('T')[0],
      'scheduled_start_time': scheduledStartTime,
      'scheduled_end_time': scheduledEndTime,
      'status': status,
      'assigned_personnel_id': assignedPersonnelId,
      'proof_image_url': proofImageUrl,
      'delivered_at': deliveredAt?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  DeliveryJob copyWith({
    String? id,
    String? customerName,
    String? customerContact,
    String? customerAddress,
    DateTime? scheduledDate,
    String? scheduledStartTime,
    String? scheduledEndTime,
    String? status,
    String? assignedPersonnelId,
    String? proofImageUrl,
    DateTime? deliveredAt,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<DeliveryItem>? items,
  }) {
    return DeliveryJob(
      id: id ?? this.id,
      customerName: customerName ?? this.customerName,
      customerContact: customerContact ?? this.customerContact,
      customerAddress: customerAddress ?? this.customerAddress,
      scheduledDate: scheduledDate ?? this.scheduledDate,
      scheduledStartTime: scheduledStartTime ?? this.scheduledStartTime,
      scheduledEndTime: scheduledEndTime ?? this.scheduledEndTime,
      status: status ?? this.status,
      assignedPersonnelId: assignedPersonnelId ?? this.assignedPersonnelId,
      proofImageUrl: proofImageUrl ?? this.proofImageUrl,
      deliveredAt: deliveredAt ?? this.deliveredAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      items: items ?? this.items,
    );
  }

  String get formattedTimeSlot => '$scheduledStartTime - $scheduledEndTime';

  bool get isPending => status == 'pending';
  bool get isPickedUp => status == 'picked_up';
  bool get isEnRoute => status == 'en_route';
  bool get isDelivered => status == 'delivered';
}

class DeliveryItem {
  final String id;
  final String deliveryJobId;
  final String productId;
  final int quantity;
  final DateTime createdAt;
  final Product? product; // Optional product details

  DeliveryItem({
    required this.id,
    required this.deliveryJobId,
    required this.productId,
    required this.quantity,
    required this.createdAt,
    this.product,
  });

  factory DeliveryItem.fromJson(Map<String, dynamic> json) {

    return DeliveryItem(
      id: json['id']?.toString() ?? '',
      productId: json['product_id']?.toString() ?? '',
      deliveryJobId: json['delivery_job_id']?.toString() ?? '',
      quantity: json['quantity'] as int,
      createdAt: DateTime.parse(json['created_at'] as String),product: json['products'] != null
        ? Product.fromJson(json['products'])
        : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'delivery_job_id': deliveryJobId,
      'product_id': productId,
      'quantity': quantity,
      'created_at': createdAt.toIso8601String(),
    };
  }
}

