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
