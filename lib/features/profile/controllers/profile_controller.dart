import 'package:get/get.dart';
import '../../../core/constants/api_endpoints.dart';
import '../../../core/network/api_client.dart';
import '../../../core/storage/storage_service.dart';

class ProfileController extends GetxController {
  final userName = 'Shopper'.obs;
  final userEmail = ''.obs;
  final userAvatar = 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=400'.obs;
  final userPhone = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadLocalUser();
    fetchProfile();
  }

  void loadLocalUser() {
    final user = StorageService.getUser();
    if (user != null) {
      userName.value = user['full_name'] ?? 'Shopper';
      userEmail.value = user['email'] ?? '';
      if (user['avatar'] != null) userAvatar.value = user['avatar'];
      if (user['phone'] != null) userPhone.value = user['phone'];
    }
  }

  Future<void> fetchProfile() async {
    try {
      final res = await ApiClient.get(ApiEndpoints.profile);
      userName.value = res.data['full_name'] ?? 'Shopper';
      userEmail.value = res.data['email'] ?? '';
      if (res.data['avatar'] != null) userAvatar.value = res.data['avatar'];
      await StorageService.saveUser(res.data);
    } catch (_) {}
  }

  Future<void> logout() async {
    await StorageService.clearAuth();
    Get.offAllNamed('/login');
  }
}
