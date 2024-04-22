import 'package:flutter/material.dart';
import 'package:server_entry_dashboard/app.dart';
import 'package:server_entry_dashboard/pages/routes/pages.dart';

class DevelopingPage extends StatefulWidget implements ConstantPage {
  static String getRoute() => '/developing';

  static Widget Function() getPage() => () => const DevelopingPage(name: 'Developing Page');

  const DevelopingPage({super.key, required this.name});

  final String? name;

  @override
  State<DevelopingPage> createState() => _DevelopingPageState();
}

class _DevelopingPageState extends State<DevelopingPage> {
  @override
  Widget build(BuildContext context) {
    app.titleController.updateTitle('${widget.name}.dev');

    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Developing ...',
            ),
          ],
        ),
      ),
    );
  }
}
