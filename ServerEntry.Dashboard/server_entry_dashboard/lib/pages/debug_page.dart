import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:server_entry_dashboard/app.dart';
import 'package:server_entry_dashboard/pages/routes/developing_page.dart';
import 'package:server_entry_dashboard/pages/tests/api_test_page.dart';
import 'package:server_entry_dashboard/pages/routes/pages.dart';

class DebugPage extends StatefulWidget implements ConstantPage {
  static String getRoute() => '/debug';

  static Widget Function() getPage() => () => const DebugPage();

  const DebugPage({super.key});

  @override
  State<DebugPage> createState() => _DebugPageState();
}

class _DebugPageState extends State<DebugPage> with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();

    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    app.titleController.updateTitle('Debug Page');

    return NestedScrollView(
      headerSliverBuilder: (context, innerBoxIsScrolled) => [
        SliverAppBar(
          title: Text('DebugPage_Title'.tr),
          pinned: true,
          snap: true,
          floating: true,
          forceElevated: innerBoxIsScrolled,
          bottom: TabBar(
            controller: _tabController,
            tabs: const <Tab>[
              Tab(text: 'Api Test', icon: Icon(Icons.api)),
              Tab(text: 'Developing Test', icon: Icon(Icons.question_answer)),
              Tab(text: 'Developing Test', icon: Icon(Icons.question_answer)),
            ],
          ),
        ),
      ],
      body: TabBarView(
        controller: _tabController,
        children: const [
          ApiTestPage(),
          DevelopingPage(name: 'A'),
          DevelopingPage(name: 'B'),
        ],
      ),
    );
  }
}
