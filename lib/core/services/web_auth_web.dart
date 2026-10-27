import 'dart:async';
import 'dart:convert';
import 'dart:js' as js;
import 'dart:js_util' as js_util;
import 'package:flutter/foundation.dart';

Future<Map<String, dynamic>?> triggerFirebaseGoogleSignIn() async {
  try {
    if (!js.context.hasProperty('signInWithGoogleFirebase')) {
      throw 'Firebase Auth is still initializing. Please refresh your browser tab (Ctrl+F5).';
    }
    final promise = js.context.callMethod('signInWithGoogleFirebase');
    if (promise == null) {
      throw 'Google Sign-In could not be started. Please reload the browser tab.';
    }
    final result = await js_util.promiseToFuture(promise);
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
    if (!js.context.hasProperty('sendFirebasePhoneOtp')) {
      throw 'Firebase Phone Auth is not ready on this page.';
    }
    final promise = js.context.callMethod('sendFirebasePhoneOtp', [phoneNumber]);
    if (promise == null) throw 'Failed to initiate Firebase Phone Auth.';
    final res = await js_util.promiseToFuture(promise);
    return res != null;
  } catch (e) {
    debugPrint('Firebase send phone OTP error: $e');
    rethrow;
  }
}

Future<Map<String, dynamic>?> verifyFirebasePhoneOtp(String code) async {
  try {
    if (!js.context.hasProperty('verifyFirebasePhoneOtp')) {
      throw 'Firebase Phone Auth is not ready on this page.';
    }
    final promise = js.context.callMethod('verifyFirebasePhoneOtp', [code]);
    if (promise == null) throw 'Failed to verify Firebase OTP.';
    final res = await js_util.promiseToFuture(promise);
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
