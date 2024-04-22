import 'package:flutter/material.dart';
import 'package:server_entry_dashboard/app.dart';

class NotFoundPage extends StatefulWidget {
  static String getRoute() => '/404';

  static Widget Function() getPage() => () => const NotFoundPage();

  const NotFoundPage({super.key});

  @override
  State<NotFoundPage> createState() => _NotFoundPageState();
}

class _NotFoundPageState extends State<NotFoundPage> {
  @override
  Widget build(BuildContext context) {
    app.titleController.updateTitle('404 Not Found');

    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            '404 Not Found',
            style: TextStyle(fontSize: 24),
          ),
        ],
      ),
    );
  }
}
