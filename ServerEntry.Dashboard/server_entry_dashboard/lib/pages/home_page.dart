import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:get/get.dart';
import 'package:server_entry_dashboard/app.dart';
import 'package:server_entry_dashboard/pages/routes/pages.dart';
import 'package:server_entry_dashboard/widgets/home/cpu_info.dart';
import 'package:server_entry_dashboard/widgets/home/ram_info.dart';

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
      const CpuInfoWidget(),
      const RamInfoWidget(),
    ];

    var random = Random();

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: const Icon(Icons.edit),
      ),
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
            height: (index % 5 + 1) * 100 + random.nextInt(100) * 1.0,
            margin: const EdgeInsets.fromLTRB(10, 10, 10, 0),
            child: InfoCard(title: 'Test Widget', value: 'Index: $index'),
          );
        },
      ),
    );
  }
}

class InfoCard extends StatelessWidget {
  final String title;
  final String value;

  const InfoCard({
    super.key,
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
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8.0),
            Text(
              value,
              style: const TextStyle(
                fontSize: 16.0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
