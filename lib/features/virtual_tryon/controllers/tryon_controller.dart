import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/api_endpoints.dart';
import '../../../core/network/api_client.dart';
import '../../../core/services/web_auth_helper.dart';
import '../../product/models/product_model.dart';
import '../models/tryon_model.dart';

class TryOnController extends GetxController {
  final currentProduct = Rxn<ProductModel>();
  final selectedMode = 'clothing'.obs; // clothing, footwear, accessories, furniture
  final userImageBase64 = RxnString();
  final userImageBytes = Rxn<Uint8List>();
  final isGenerating = false.obs;
  final currentJob = Rxn<TryOnJobModel>();
  final comparisonPosition = 0.5.obs; // 0.0 to 1.0 for Before/After slider
  final hasConsented = true.obs;

  final historyJobs = <TryOnJobModel>[].obs;
  final isLoadingHistory = false.obs;

  // Generation progress steps
  final progressStep = 0.obs;
  final progressMessage = 'Preparing AI environment...'.obs;
  Timer? _progressTimer;

  // Curated demo sample portraits for instant 1-tap testing
  final samplePortraits = [
    {
      'name': 'Female Portrait',
      'url': 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=600',
    },
    {
      'name': 'Male Model',
      'url': 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=600',
    },
    {
      'name': 'Full Body Pose',
      'url': 'https://images.unsplash.com/photo-1515886657613-9f3515b0c78f?w=600',
    },
  ];

  @override
  void onInit() {
    super.onInit();
    if (Get.arguments is ProductModel) {
      setProduct(Get.arguments as ProductModel);
    }
    fetchHistory();
  }

  @override
  void onClose() {
    _progressTimer?.cancel();
    super.onClose();
  }

  void setProduct(ProductModel prod) {
    currentProduct.value = prod;
    final cat = prod.categoryName.toLowerCase();
    if (cat.contains('shoe') || cat.contains('footwear')) {
      selectedMode.value = 'footwear';
    } else if (cat.contains('bag') || cat.contains('access') || cat.contains('watch')) {
      selectedMode.value = 'accessories';
    } else if (cat.contains('furn') || cat.contains('home') || cat.contains('decor')) {
      selectedMode.value = 'furniture';
    } else {
      selectedMode.value = 'clothing';
    }
  }

  Future<void> pickUserPhoto() async {
    try {
      final base64String = await pickImageAsBase64();
      if (base64String != null && base64String.isNotEmpty) {
        userImageBase64.value = base64String;
        final cleanBase64 = base64String.contains(',')
            ? base64String.split(',')[1]
            : base64String;
        userImageBytes.value = base64Decode(cleanBase64);
        currentJob.value = null; // Reset previous result for new photo
      }
    } catch (e) {
      final message = e.toString().replaceFirst('FormatException: ', '');
      Get.snackbar('Photo Not Ready', message);
    }
  }

  Future<void> useSamplePortrait(String url) async {
    try {
      userImageBase64.value = url;
      userImageBytes.value = null; // Loaded directly via NetworkImage
      currentJob.value = null;
    } catch (_) {}
  }

  void removePhoto() {
    userImageBase64.value = null;
    userImageBytes.value = null;
    currentJob.value = null;
  }

  void _startProgressSimulation() {
    progressStep.value = 0;
    progressMessage.value = 'Analyzing photo geometry & lighting...';

    _progressTimer?.cancel();
    _progressTimer = Timer.periodic(const Duration(milliseconds: 1400), (t) {
      if (progressStep.value == 0) {
        progressStep.value = 1;
        progressMessage.value = 'Contouring fabric folds and physical alignment...';
      } else if (progressStep.value == 1) {
        progressStep.value = 2;
        progressMessage.value = 'Rendering realistic shadows & texture occlusion...';
      } else if (progressStep.value == 2) {
        progressStep.value = 3;
        progressMessage.value = 'Finalizing photorealistic mirror preview...';
      } else {
        t.cancel();
      }
    });
  }

  Future<void> generatePreview() async {
    final prod = currentProduct.value;
    if (prod == null) {
      Get.snackbar('Error', 'Please select a product first.');
      return;
    }

    if (userImageBase64.value == null || userImageBase64.value!.isEmpty) {
      Get.snackbar('Upload Required', 'Please upload or select a personal photo first.');
      return;
    }

    if (!hasConsented.value) {
      Get.snackbar('Consent Required', 'Please confirm AI processing consent.');
      return;
    }

    try {
      isGenerating.value = true;
      _startProgressSimulation();

      final data = <String, dynamic>{
        'product_id': prod.id,
        'mode': selectedMode.value,
      };

      if (userImageBase64.value!.startsWith('http')) {
        // Sample portrait URL
        data['user_image_base64'] = userImageBase64.value!;
      } else {
        data['user_image_base64'] = userImageBase64.value!;
      }

      final res = await ApiClient.post(
        ApiEndpoints.tryonGenerate,
        data: data,
        options: Options(receiveTimeout: const Duration(seconds: 130)),
      );
      final job = TryOnJobModel.fromJson(res.data);
      currentJob.value = job;

      if (job.isCompleted) {
        Get.snackbar(
          'Preview Generated!',
          'Your virtual try-on is ready. Slide to compare Before & After.',
          backgroundColor: const Color(0xFF10B981),
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
        );
        fetchHistory();
      } else if (job.isFailed) {
        Get.snackbar(
          'Try-On Notice',
          job.errorMessage.isNotEmpty ? job.errorMessage : 'Could not generate preview with selected image.',
          backgroundColor: Colors.amber.shade900,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
        );
      }
    } catch (e) {
      debugPrint('Virtual Try-On error: $e');
      String cleanMsg = 'Could not generate preview with selected image. Please try another photo.';
      if (e is DioException) {
        final responseData = e.response?.data;
        if (responseData is Map && responseData['detail'] is String) {
          cleanMsg = responseData['detail'] as String;
        } else if (e.response?.statusCode == 413) {
          cleanMsg = 'This photo is too large. Choose a clear image under 10MB.';
        } else if (e.response == null) {
          cleanMsg = 'Could not reach the AI service. Check that the backend is running and try again.';
        }
      }
      Get.snackbar(
        'AI Try-On Notice',
        cleanMsg,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 4),
      );
      _progressTimer?.cancel();
      isGenerating.value = false;
    } finally {
      _progressTimer?.cancel();
      isGenerating.value = false;
    }
  }

  Future<void> fetchHistory() async {
    try {
      isLoadingHistory.value = true;
      final res = await ApiClient.get(ApiEndpoints.tryonHistory);
      if (res.data is List) {
        historyJobs.assignAll(
          (res.data as List).map((j) => TryOnJobModel.fromJson(j)).toList(),
        );
      }
    } catch (_) {
    } finally {
      isLoadingHistory.value = false;
    }
  }

  Future<void> deleteHistoryJob(int id) async {
    try {
      await ApiClient.delete('${ApiEndpoints.tryonHistory}$id/');
      historyJobs.removeWhere((j) => j.id == id);
      if (currentJob.value?.id == id) {
        currentJob.value = null;
      }
      Get.snackbar('Deleted', 'Try-on record removed');
    } catch (e) {
      Get.snackbar('Error', 'Failed to delete entry');
    }
  }
}

