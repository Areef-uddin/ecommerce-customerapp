import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'core/routes/app_pages.dart';
import 'core/services/fcm_service.dart';
import 'core/storage/storage_service.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/views/login_view.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Set status bar styling
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  // Initialize Local Storage & FCM
  await StorageService.init();
  FcmService.init();

  runApp(const StyleHubApp());
}

class StyleHubApp extends StatelessWidget {
  const StyleHubApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'StyleHub',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      initialRoute: AppPages.initial,
      getPages: AppPages.routes,
      unknownRoute: GetPage(name: '/not-found', page: () => const LoginView()),
      defaultTransition: Transition.cupertino,
    );
  }
}
