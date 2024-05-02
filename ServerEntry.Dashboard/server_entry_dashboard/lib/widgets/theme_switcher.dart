import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ThemeSwitcher extends StatefulWidget {
  const ThemeSwitcher({super.key});

  @override
  State<ThemeSwitcher> createState() => _ThemeSwitcherState();
}

class _ThemeSwitcherState extends State<ThemeSwitcher> {
  final isDarkMode = Get.isDarkMode.obs;

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => IconButton(
        onPressed: () {
          Get.changeThemeMode(isDarkMode.value ? ThemeMode.light : ThemeMode.dark);
          isDarkMode.value = !isDarkMode.value;
        },
        icon: isDarkMode.value ? const Icon(Icons.dark_mode) : const Icon(Icons.light_mode),
      ),
    );
  }
}
