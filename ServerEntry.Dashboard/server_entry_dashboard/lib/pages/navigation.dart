import 'package:community_material_icon/community_material_icon.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:server_entry_dashboard/app.dart';
import 'package:server_entry_dashboard/pages/developing_page.dart';
import 'package:server_entry_dashboard/widgets/theme_switcher.dart';

class NavigationPage extends StatefulWidget {
  const NavigationPage({super.key});

  @override
  State<NavigationPage> createState() => _NavigationPageState();
}

class _NavigationPageState extends State<NavigationPage> {
  final _buttonsPadding = 5.0;
  final _pageController = PageController(initialPage: 0);

  @override
  void initState() {
    super.initState();
    app.navPageController = _pageController;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: <Widget>[
          Obx(
            () => NavigationRail(
              selectedIndex: app.navigationIndex.value,
              groupAlignment: -1.0,
              onDestinationSelected: (index) => app.navPageTo(index),
              useIndicator: true,
              labelType: NavigationRailLabelType.all,
              trailing: Column(
                children: [
                  const SizedBox(height: 20),
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.bug_report),
                  ),
                  const SizedBox(height: 5),
                  const ThemeSwitcher(),
                  const SizedBox(height: 5),
                  PopupMenuButton(
                    tooltip: '',
                    icon: const Icon(Icons.translate),
                    position: PopupMenuPosition.under,
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        child: const Text('简体中文'),
                        onTap: () => Get.updateLocale(const Locale('zh', 'CN')),
                      ),
                      PopupMenuItem(
                        child: const Text('English (US)'),
                        onTap: () => Get.updateLocale(const Locale('en', 'US')),
                      ),
                    ],
                  ),
                ],
              ),
              destinations: <NavigationRailDestination>[
                NavigationRailDestination(
                  icon: const Icon(Icons.home),
                  selectedIcon: const Icon(Icons.home_outlined),
                  label: Text('Nav_HomePage'.tr),
                  padding: EdgeInsets.symmetric(vertical: _buttonsPadding),
                ),
                NavigationRailDestination(
                  icon: const Icon(Icons.web),
                  selectedIcon: const Icon(Icons.web_outlined),
                  label: Text('Nav_WebsitesPage'.tr),
                  padding: EdgeInsets.symmetric(vertical: _buttonsPadding),
                ),
                NavigationRailDestination(
                  icon: const Icon(CommunityMaterialIcons.cube),
                  selectedIcon: const Icon(CommunityMaterialIcons.cube_outline),
                  label: Text('Nav_AppsPage'.tr),
                  padding: EdgeInsets.symmetric(vertical: _buttonsPadding),
                ),
                NavigationRailDestination(
                  icon: const Icon(Icons.settings),
                  selectedIcon: const Icon(Icons.settings_outlined),
                  label: Text('Nav_Settings'.tr),
                  padding: EdgeInsets.symmetric(vertical: _buttonsPadding),
                ),
              ],
            ),
          ),
          const VerticalDivider(thickness: 1, width: 1),
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              scrollDirection: Axis.vertical,
              children: const [
                ClipRect(child: DevelopingPage()),
                ClipRect(child: DevelopingPage()),
                ClipRect(child: DevelopingPage()),
                ClipRect(child: DevelopingPage()),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
