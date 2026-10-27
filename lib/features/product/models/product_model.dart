class ProductModel {
  final int id;
  final String name;
  final String slug;
  final String categoryName;
  final String subcategoryName;
  final String description;
  final double price;
  final double? originalPrice;
  final int discountPercent;
  final double rating;
  final int reviewCount;
  final bool isTrending;
  final bool isNewArrival;
  final bool inStock;
  final String primaryImage;
  final List<String> images;
  final List<ProductColorModel> colors;
  final List<String> sizes;
  bool isWishlisted;

  ProductModel({
    required this.id,
    required this.name,
    required this.slug,
    this.categoryName = '',
    this.subcategoryName = '',
    this.description = '',
    required this.price,
    this.originalPrice,
    this.discountPercent = 0,
    this.rating = 4.5,
    this.reviewCount = 0,
    this.isTrending = false,
    this.isNewArrival = false,
    this.inStock = true,
    required this.primaryImage,
    this.images = const [],
    this.colors = const [],
    this.sizes = const [],
    this.isWishlisted = false,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    List<String> imgList = [];
    if (json['images'] != null) {
      for (var img in json['images']) {
        imgList.add(img['image_url'] ?? '');
      }
    }

    List<ProductColorModel> colorList = [];
    if (json['colors'] != null) {
      for (var c in json['colors']) {
        colorList.add(ProductColorModel.fromJson(c));
      }
    }

    List<String> sizeList = [];
    if (json['sizes'] != null) {
      for (var s in json['sizes']) {
        sizeList.add(s['size'] ?? '');
      }
    }

    final primImg = json['primary_image'] ??
        (imgList.isNotEmpty ? imgList.first : 'https://images.unsplash.com/photo-1572804013309-59a88b7e92f1?w=600');

    return ProductModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      slug: json['slug'] ?? '',
      categoryName: json['category_name'] ?? '',
      subcategoryName: json['subcategory_name'] ?? '',
      description: json['description'] ?? '',
      price: double.tryParse(json['price'].toString()) ?? 0.0,
      originalPrice: json['original_price'] != null ? double.tryParse(json['original_price'].toString()) : null,
      discountPercent: json['discount_percent'] ?? 0,
      rating: double.tryParse(json['rating'].toString()) ?? 4.5,
      reviewCount: json['review_count'] ?? 0,
      isTrending: json['is_trending'] ?? false,
      isNewArrival: json['is_new_arrival'] ?? false,
      inStock: json['in_stock'] ?? true,
      primaryImage: primImg,
      images: imgList.isNotEmpty ? imgList : [primImg],
      colors: colorList,
      sizes: sizeList,
      isWishlisted: json['is_wishlisted'] ?? false,
    );
  }
}

class ProductColorModel {
  final int id;
  final String name;
  final String hexCode;

  ProductColorModel({required this.id, required this.name, required this.hexCode});

  factory ProductColorModel.fromJson(Map<String, dynamic> json) {
    return ProductColorModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      hexCode: json['hex_code'] ?? '#000000',
    );
  }
}
