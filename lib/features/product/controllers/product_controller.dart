import 'package:get/get.dart';
import '../../../core/constants/api_endpoints.dart';
import '../../../core/network/api_client.dart';
import '../models/product_model.dart';

class ProductController extends GetxController {
  final isLoading = true.obs;
  final products = <ProductModel>[].obs;
  final currentProduct = Rxn<ProductModel>();

  // Filter & Sort State
  final currentSort = 'newest'.obs;
  final isGridView = true.obs;
  final pageTitle = 'Products'.obs;

  // Detail View State
  final selectedColorIndex = 0.obs;
  final selectedSize = 'M'.obs;
  final currentImageIndex = 0.obs;
  final isAddingToCart = false.obs;

  // Size Guide State
  final sizeGuideCategory = 'Women'.obs;
  final isUnitInches = true.obs;
  final sizeGuideList = <Map<String, dynamic>>[].obs;

  Future<void> fetchProductList({
    String? category,
    String? subcategory,
    String? search,
    bool? trending,
  }) async {
    try {
      isLoading.value = true;
      String url = '${ApiEndpoints.products}?sort=${currentSort.value}';
      if (category != null && category.isNotEmpty) url += '&category=$category';
      if (subcategory != null && subcategory.isNotEmpty) url += '&subcategory=$subcategory';
      if (search != null && search.isNotEmpty) url += '&search=$search';
      if (trending == true) url += '&trending=true';

      final res = await ApiClient.get(url);
      if (res.data is List) {
        products.assignAll(
          (res.data as List).map((p) => ProductModel.fromJson(p)).toList(),
        );
      }
    } catch (e) {
      // error
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchProductDetail(int id) async {
    try {
      isLoading.value = true;
      final res = await ApiClient.get('${ApiEndpoints.products}$id/');
      currentProduct.value = ProductModel.fromJson(res.data);
      if (currentProduct.value != null && currentProduct.value!.sizes.isNotEmpty) {
        selectedSize.value = currentProduct.value!.sizes.first;
      }
    } catch (e) {
      // error
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchSizeGuide() async {
    try {
      final res = await ApiClient.get('${ApiEndpoints.sizeGuide}?category=${sizeGuideCategory.value}');
      if (res.data is List) {
        sizeGuideList.assignAll(List<Map<String, dynamic>>.from(res.data));
      }
    } catch (e) {
      // error
    }
  }

  Future<void> addToCart() async {
    final product = currentProduct.value;
    if (product == null) return;

    try {
      isAddingToCart.value = true;
      String colorName = 'Standard';
      if (product.colors.isNotEmpty && selectedColorIndex.value < product.colors.length) {
        colorName = product.colors[selectedColorIndex.value].name;
      }

      await ApiClient.post(ApiEndpoints.cart, data: {
        'product_id': product.id,
        'quantity': 1,
        'size': selectedSize.value,
        'color': colorName,
      });

      Get.snackbar(
        'Added to Cart',
        '${product.name} added to your shopping bag',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar('Error', 'Failed to add item to cart');
    } finally {
      isAddingToCart.value = false;
    }
  }

  Future<void> buyNow() async {
    final product = currentProduct.value;
    if (product == null) return;

    try {
      isAddingToCart.value = true;
      String colorName = 'Standard';
      if (product.colors.isNotEmpty && selectedColorIndex.value < product.colors.length) {
        colorName = product.colors[selectedColorIndex.value].name;
      }

      await ApiClient.post(ApiEndpoints.cart, data: {
        'product_id': product.id,
        'quantity': 1,
        'size': selectedSize.value,
        'color': colorName,
      });

      Get.toNamed('/checkout-address');
    } catch (e) {
      Get.snackbar('Error', 'Failed to proceed to checkout');
    } finally {
      isAddingToCart.value = false;
    }
  }

  void toggleSort() {
    if (currentSort.value == 'newest') {
      currentSort.value = 'price_low_high';
    } else if (currentSort.value == 'price_low_high') {
      currentSort.value = 'price_high_low';
    } else {
      currentSort.value = 'newest';
    }
  }
}
