import 'package:dio/dio.dart';
import 'package:get/get.dart' as getx;
import '../constants/api_endpoints.dart';
import '../storage/storage_service.dart';

class ApiClient {
  static final Dio dio = Dio(
    BaseOptions(
      baseUrl: ApiEndpoints.baseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ),
  )..interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          final token = StorageService.getAccessToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (DioException error, handler) async {
          if (error.response?.statusCode == 401) {
            // Token expired or invalid
            await StorageService.clearAuth();
            getx.Get.offAllNamed('/login');
          }
          return handler.next(error);
        },
      ),
    );

  // Helper methods
  static Future<Response> get(String path, {Map<String, dynamic>? queryParameters}) async {
    return await dio.get(path, queryParameters: queryParameters);
  }

  static Future<Response> post(String path, {dynamic data}) async {
    return await dio.post(path, data: data);
  }

  static Future<Response> put(String path, {dynamic data}) async {
    return await dio.put(path, data: data);
  }

  static Future<Response> patch(String path, {dynamic data}) async {
    return await dio.patch(path, data: data);
  }

  static Future<Response> delete(String path, {dynamic data}) async {
    return await dio.delete(path, data: data);
  }
}
