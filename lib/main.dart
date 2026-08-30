import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

// الاستيرادات الخاصة بالهيكل الجديد
import 'core/localization/message.dart';
import 'core/theme/theme.dart';
import 'routes/app_pages.dart';
import 'data/services/socket_service.dart';
import 'features/auth/presentation/controllers/auth_controller.dart';
import 'core/bindings/initial_binding.dart';

void main() async {
  // التأكد من تهيئة أدوات Flutter قبل أي عملية أخرى
  WidgetsFlutterBinding.ensureInitialized();

  // إعدادات شريط النظام (Status Bar) والتحكم في الشفافية لتحسين المظهر البصري
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    systemNavigationBarColor: Colors.transparent,
    systemNavigationBarIconBrightness: Brightness.dark,
    statusBarColor: Colors.transparent,
  ));

  // تفعيل خاصية التمدد خلف أشرطة النظام (Edge-to-Edge)
  if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  }

  // تهيئة Firebase والاشعارات (معطلة حالياً لدعم تشغيل لينكس)
  /*
  if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
    await Firebase.initializeApp();
    await Get.putAsync(() => NotificationService().init());
  }
  */

  // تهيئة مخزن البيانات المحلي (GetStorage)
  await GetStorage.init();
  final box = GetStorage();

  // حقن المتحكمات الأساسية في ذاكرة التطبيق بشكل دائم يتم الآن عبر InitialBinding في GetMaterialApp
  // إدارة خدمة السوكيت للربط مع الخادم في حال وجود توكن مسبق تتم برمجياً داخل onInit للمتحكمات

  // تحديد اللغة المختارة من المستخدم أو استخدام لغة الجهاز الافتراضية
  String? savedLang = box.read('lang');
  Locale initialLocale = savedLang != null
      ? Locale(savedLang)
      : (Get.deviceLocale ?? const Locale('en'));

  runApp(MyApp(initialLocale: initialLocale));
}

class MyApp extends StatelessWidget {
  final Locale initialLocale;

  const MyApp({super.key, required this.initialLocale});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      // إعدادات العنوان واللغة
      title: 'NUMNOW Courier',
      debugShowCheckedModeBanner: false,
      translations: Messages(),
      locale: initialLocale,
      fallbackLocale: const Locale('en'),

      // إعدادات الثيم (فاتح / داكن)
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,

      // حقن التبعيات الأولية (Professional Binding)
      initialBinding: InitialBinding(),

      // إدارة المسارات من الملف المنفصل
      initialRoute: AppPages.initial,
      getPages: AppPages.routes,

      // غلاف عام للتطبيق للتحكم في الأبعاد والمنطقة الآمنة (SafeArea)
      builder: (context, child) {
        return Scaffold(
          // منع لوحة المفاتيح من إفساد تصميم الشاشة عند ظهورها
          resizeToAvoidBottomInset: false,
          body: SafeArea(
            top: false,
            // السماح للمحتوى بالوصول لأعلى الشاشة خلف شريط الحالة
            bottom: true,
            // حماية أزرار التحكم السفلية من التداخل مع نظام التشغيل
            child: child!,
          ),
        );
      },
    );
  }
}