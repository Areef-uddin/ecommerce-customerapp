import 'dart:async';
import 'dart:convert';
import 'dart:html' as html;
import 'dart:js_util' as js_util;
import 'package:flutter/foundation.dart';

Future<Map<String, dynamic>?> triggerFirebaseGoogleSignIn() async {
  try {
    if (!js_util.hasProperty(html.window, 'signInWithGoogleFirebase')) {
      throw 'Google Sign-In is initializing. Please refresh the browser tab (Ctrl+Shift+R).';
    }
    final dynamic promise = js_util.callMethod(html.window, 'signInWithGoogleFirebase', []);
    if (promise == null) {
      throw 'Google Sign-In returned null. Please reload the browser tab.';
    }
    final dynamic result = await js_util.promiseToFuture(promise);
    if (result != null) {
      if (result is String) {
        return jsonDecode(result) as Map<String, dynamic>;
      }
      return Map<String, dynamic>.from(result as Map);
    }
  } catch (e) {
    debugPrint('Firebase Google Sign-In error: $e');
    rethrow;
  }
  return null;
}

Future<bool> sendFirebasePhoneOtp(String phoneNumber) async {
  try {
    if (!js_util.hasProperty(html.window, 'sendFirebasePhoneOtp')) {
      throw 'Firebase Phone Auth is not ready on this page.';
    }
    final dynamic promise = js_util.callMethod(html.window, 'sendFirebasePhoneOtp', [phoneNumber]);
    if (promise == null) throw 'Failed to initiate Firebase Phone Auth.';
    final dynamic res = await js_util.promiseToFuture(promise);
    return res != null;
  } catch (e) {
    debugPrint('Firebase send phone OTP error: $e');
    rethrow;
  }
}

Future<Map<String, dynamic>?> verifyFirebasePhoneOtp(String code) async {
  try {
    if (!js_util.hasProperty(html.window, 'verifyFirebasePhoneOtp')) {
      throw 'Firebase Phone Auth is not ready on this page.';
    }
    final dynamic promise = js_util.callMethod(html.window, 'verifyFirebasePhoneOtp', [code]);
    if (promise == null) throw 'Failed to verify Firebase OTP.';
    final dynamic res = await js_util.promiseToFuture(promise);
    if (res != null) {
      if (res is String) return jsonDecode(res) as Map<String, dynamic>;
      return Map<String, dynamic>.from(res as Map);
    }
  } catch (e) {
    debugPrint('Firebase verify phone OTP error: $e');
    rethrow;
  }
  return null;
}

Future<Map<String, dynamic>?> triggerRazorpayCheckout(Map<String, dynamic> options) async {
  try {
    if (!js_util.hasProperty(html.window, 'openRazorpayCheckout')) {
      throw 'Razorpay Checkout is not ready on this page.';
    }
    final optionsJson = jsonEncode(options);
    final dynamic promise = js_util.callMethod(html.window, 'openRazorpayCheckout', [optionsJson]);
    if (promise == null) throw 'Failed to open Razorpay gateway.';
    final dynamic res = await js_util.promiseToFuture(promise);
    if (res != null) {
      if (res is String) return jsonDecode(res) as Map<String, dynamic>;
      return Map<String, dynamic>.from(res as Map);
    }
  } catch (e) {
    debugPrint('Razorpay Checkout error: $e');
    rethrow;
  }
  return null;
}

Future<String?> pickImageAsBase64() async {
  const maxInputBytes = 10 * 1024 * 1024;
  const targetMaxSide = 1600;
  const maxCompressedBytes = 2 * 1024 * 1024;
  try {
    final completer = Completer<String?>();
    final uploadInput = html.FileUploadInputElement()..accept = 'image/*';
    uploadInput.click();
    uploadInput.onChange.listen((e) {
      final files = uploadInput.files;
      if (files != null && files.isNotEmpty) {
        final file = files[0];
        if (!file.type.startsWith('image/')) {
          completer.completeError(FormatException('Choose a JPG, PNG, or WebP image.'));
          return;
        }
        if (file.size > maxInputBytes) {
          completer.completeError(FormatException('Choose a photo smaller than 10MB.'));
          return;
        }

        () async {
          final objectUrl = html.Url.createObjectUrl(file);
          try {
            final image = html.ImageElement();
            final loaded = image.onLoad.first;
            image.src = objectUrl;
            await loaded.timeout(const Duration(seconds: 20));

            final naturalWidth = image.naturalWidth;
            final naturalHeight = image.naturalHeight;
            if (naturalWidth == 0 || naturalHeight == 0) {
              throw FormatException('The selected image could not be decoded. Try a JPG or PNG photo.');
            }

            final longestSide = naturalWidth > naturalHeight ? naturalWidth : naturalHeight;
            final scale = (targetMaxSide / longestSide).clamp(0.0, 1.0);
            final width = (naturalWidth * scale).round().clamp(1, targetMaxSide).toInt();
            final height = (naturalHeight * scale).round().clamp(1, targetMaxSide).toInt();
            final canvas = html.CanvasElement(width: width, height: height);
            canvas.context2D.drawImageScaled(image, 0, 0, width, height);

            for (final quality in [0.84, 0.72, 0.60]) {
              final compressed = canvas.toDataUrl('image/jpeg', quality);
              final estimatedBytes = compressed.length * 3 ~/ 4;
              if (estimatedBytes <= maxCompressedBytes || quality == 0.60) {
                if (estimatedBytes > maxCompressedBytes) {
                  throw FormatException('This photo could not be compressed enough. Choose a smaller image.');
                }
                completer.complete(compressed);
                return;
              }
            }
          } catch (error) {
            completer.completeError(error);
          } finally {
            html.Url.revokeObjectUrl(objectUrl);
          }
        }();
      } else {
        completer.complete(null);
      }
    });
    return await completer.future;
  } catch (e) {
    debugPrint('Error picking image: $e');
    return null;
  }
}
