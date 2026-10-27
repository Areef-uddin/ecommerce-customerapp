import 'dart:async';
import 'dart:convert';
import 'dart:js' as js;
import 'dart:js_util' as js_util;

Future<Map<String, dynamic>?> triggerFirebaseGoogleSignIn() async {
  try {
    if (js.context.hasProperty('signInWithGoogleFirebase')) {
      final promise = js.context.callMethod('signInWithGoogleFirebase');
      final result = await js_util.promiseToFuture(promise);
      if (result != null) {
        if (result is String) {
          return jsonDecode(result) as Map<String, dynamic>;
        }
        return Map<String, dynamic>.from(result as Map);
      }
    }
  } catch (e) {
    // Re-throw so the caller can display the specific Firebase error
    rethrow;
  }
  return null;
}
