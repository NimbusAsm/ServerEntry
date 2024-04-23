import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:get/get.dart';
import 'package:server_entry_dashboard/app.dart';
import 'package:server_entry_dashboard/pages/routes/pages.dart';
import 'package:server_entry_dashboard/widgets/home/device_info.dart';

class HomePage extends StatefulWidget implements ConstantPage {
  static String getRoute() => '/home';

  static Widget Function() getPage() => () => const HomePage();

  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    app.titleController.updateTitle('HomePage_Title'.tr);

    var widgets = [
      const DeviceInfoWidget(),
    ];

    return Scaffold(
      body: MasonryGridView.count(
        itemCount: 11,
        crossAxisCount: 4,
        mainAxisSpacing: 0,
        crossAxisSpacing: 0,
        itemBuilder: (context, index) {
          if (index >= 0 && index < widgets.length) {
            return widgets[index];
          }

          return Container(
            height: (index % 5 + 1) * 100,
            margin: const EdgeInsets.fromLTRB(10, 10, 10, 0),
            child: Card.filled(
              color: Colors.indigo,
              child: Center(
                child: Text('$index'),
              ),
            ),
          );
        },
      ),
    );
  }
}

class InfoCard extends StatelessWidget {
  final String title;
  final String value;

  InfoCard({
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4.0,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8.0),
            Text(
              value,
              style: TextStyle(
                fontSize: 16.0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
