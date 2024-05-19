import 'package:flutter/material.dart';
import 'package:get/get.dart';
// import 'package:server_entry_dashboard/pages/debug_page.dart';
import 'package:server_entry_dashboard/pages/home_page.dart';
import 'package:server_entry_dashboard/pages/navigation_page.dart';
import 'package:server_entry_dashboard/pages/routes/developing_page.dart';
import 'package:server_entry_dashboard/pages/routes/not_found_page.dart';

List<GetPage<dynamic>> getPages() => [
      // Routing pages
      GetPage(name: NavigationPage.getRoute(), page: NavigationPage.getPage()),
      GetPage(name: NotFoundPage.getRoute(), page: NotFoundPage.getPage()),
      GetPage(name: DevelopingPage.getRoute(), page: DevelopingPage.getPage()),
      // Normal pages
      GetPage(name: HomePage.getRoute(), page: HomePage.getPage()),
      // GetPage(name: DebugPage.getRoute(), page: DebugPage.getPage()),
    ];

abstract class ConstantPage {
  static String getRoute() {
    return '/404';
  }

  static Widget Function() getPage() => () => const NotFoundPage();
}
