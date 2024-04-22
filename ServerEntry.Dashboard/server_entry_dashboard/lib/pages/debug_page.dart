import 'package:flutter/material.dart';
import 'package:server_entry_dashboard/app.dart';
import 'package:server_entry_dashboard/pages/tests/api_test_page.dart';
import 'package:server_entry_dashboard/pages/routes/pages.dart';

class DebugPage extends StatefulWidget implements ConstantPage {
  static String getRoute() => '/debug';

  static Widget Function() getPage() => () => const DebugPage();

  const DebugPage({super.key});

  @override
  State<DebugPage> createState() => _DebugPageState();
}

class _DebugPageState extends State<DebugPage> {
  @override
  Widget build(BuildContext context) {
    app.titleController.updateTitle('Debug Page');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Debug'),
      ),
      body: const ApiTestPage(),
    );
  }
}
