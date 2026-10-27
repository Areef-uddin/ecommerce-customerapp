import 'package:get/get.dart';
import '../../../core/constants/api_endpoints.dart';
import '../../../core/network/api_client.dart';
import '../models/category_model.dart';

class CategoryController extends GetxController {
  final isLoading = true.obs;
  final categories = <CategoryModel>[].obs;
  final selectedCategoryIndex = 0.obs;

  @override
  void onInit() {
    super.onInit();
    fetchCategories();
  }

  Future<void> fetchCategories() async {
    try {
      isLoading.value = true;
      final res = await ApiClient.get(ApiEndpoints.categories);
      if (res.data is List) {
        categories.assignAll(
          (res.data as List).map((c) => CategoryModel.fromJson(c)).toList(),
        );
      }
    } catch (e) {
      // error handling
    } finally {
      isLoading.value = false;
    }
  }

  CategoryModel? get currentCategory {
    if (categories.isEmpty) return null;
    return categories[selectedCategoryIndex.value];
  }
}
