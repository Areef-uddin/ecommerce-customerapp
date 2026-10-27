class CategoryModel {
  final int id;
  final String name;
  final String slug;
  final String imageUrl;
  final String icon;
  final int displayOrder;
  final List<SubCategoryModel> subcategories;

  CategoryModel({
    required this.id,
    required this.name,
    required this.slug,
    required this.imageUrl,
    this.icon = '',
    this.displayOrder = 0,
    this.subcategories = const [],
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    var subs = <SubCategoryModel>[];
    if (json['subcategories'] != null) {
      for (var s in json['subcategories']) {
        subs.add(SubCategoryModel.fromJson(s));
      }
    }
    return CategoryModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      slug: json['slug'] ?? '',
      imageUrl: json['image_url'] ?? '',
      icon: json['icon'] ?? '',
      displayOrder: json['display_order'] ?? 0,
      subcategories: subs,
    );
  }
}

class SubCategoryModel {
  final int id;
  final String name;
  final String slug;
  final String imageUrl;
  final int itemCount;

  SubCategoryModel({
    required this.id,
    required this.name,
    required this.slug,
    required this.imageUrl,
    this.itemCount = 0,
  });

  factory SubCategoryModel.fromJson(Map<String, dynamic> json) {
    return SubCategoryModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      slug: json['slug'] ?? '',
      imageUrl: json['image_url'] ?? '',
      itemCount: json['item_count'] ?? 0,
    );
  }
}
