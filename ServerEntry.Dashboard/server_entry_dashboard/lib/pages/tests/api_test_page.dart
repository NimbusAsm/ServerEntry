import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:server_entry_dashboard/data/api_resolver.dart';

class ApiTestPage extends StatefulWidget {
  const ApiTestPage({super.key});

  @override
  State<ApiTestPage> createState() => _ApiTestPageState();
}

class _ApiTestPageState extends State<ApiTestPage> {
  final urls = [
    'http://localhost:5111/Api/V1/HardwareStatus',
    'http://localhost:5111/Api/V1/HardwareStatus/Processors',
    'http://localhost:5111/Api/V1/HardwareStatus/Memory',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        margin: const EdgeInsets.all(30),
        child: ListView(
          children: urls
              .map(
                (e) => ApiTestTile(
                  dataFetcher: () async {
                    var result = await ApiResolver.get(e);
                    return result ?? 'Failed to fetch data!';
                  },
                  url: e,
                ),
              )
              .toList(),
        ),
      ),
    );
  }
}

class ApiTestTile extends StatelessWidget {
  @override
  const ApiTestTile({super.key, required this.dataFetcher, required this.url});

  final Future<String> Function() dataFetcher;

  final String url;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: dataFetcher.call(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator.adaptive();
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else {
          return ListTile(
            title: Text('[Succeeded] $url'),
            trailing: const Icon(Icons.arrow_right),
            onTap: () {
              Get.to(
                Scaffold(
                  body: Padding(
                    padding: const EdgeInsets.all(30),
                    child: Text(snapshot.data.toString()),
                  ),
                ),
              );
            },
          );
        }
      },
    );
  }
}
