import 'package:cherrilog/cherrilog.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:server_entry_dashboard/app.dart';
import 'package:server_entry_dashboard/pages/navigation_page.dart';
import 'package:server_entry_dashboard/pages/routes/pages.dart';
import 'package:server_entry_dashboard/utils/themes/dark_theme.dart';
import 'package:server_entry_dashboard/utils/themes/light_theme.dart';
import 'package:server_entry_dashboard/utils/translation.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  app.init();

  info('Dashboard entered.');

  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Server Entry',
      onGenerateTitle: (_) => app.titleController.title.value,
      translations: Translation(),
      locale: Get.deviceLocale,
      fallbackLocale: const Locale('en', 'US'),
      themeMode: ThemeMode.system,
      theme: lightThemeData,
      darkTheme: darkThemeData,
      getPages: getPages(),
      unknownRoute: GetPage(
        name: NavigationPage.getRoute(),
        page: NavigationPage.getPage(),
      ),
      home: const NavigationPage(),
    );
  }
}
