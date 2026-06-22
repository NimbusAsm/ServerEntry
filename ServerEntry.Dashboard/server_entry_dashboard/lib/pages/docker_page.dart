import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:server_entry_dashboard/app.dart';
import 'package:server_entry_dashboard/data/api_resolver.dart';
import 'package:server_entry_dashboard/pages/routes/pages.dart';
import 'package:server_entry_dashboard/widgets/docker/container_card.dart';

class DockerPage extends StatefulWidget implements ConstantPage {
  static String getRoute() => '/docker';

  static Widget Function() getPage() => () => const DockerPage();

  const DockerPage({super.key});

  @override
  State<DockerPage> createState() => _DockerPageState();
}

class _DockerPageState extends State<DockerPage> {
  late Future<List<dynamic>?> _containersFuture;
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    _containersFuture = _fetchContainers();
    _refreshTimer = Timer.periodic(const Duration(seconds: 10), (_) {
      if (mounted) {
        setState(() {
          _containersFuture = _fetchContainers();
        });
      }
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  Future<List<dynamic>?> _fetchContainers() async {
    final result = await ApiResolver().docker().listContainers(all: true);
    if (result == null) return null;
    return jsonDecode(result) as List<dynamic>;
  }

  @override
  Widget build(BuildContext context) {
    app.titleController.updateTitle('DockerPage_Title'.tr);

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () => setState(() {
          _containersFuture = _fetchContainers();
        }),
        tooltip: 'DockerPage_Refresh'.tr,
        child: const Icon(Icons.refresh),
      ),
      body: FutureBuilder<List<dynamic>?>(
        future: _containersFuture,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    '${'DockerPage_Error'.tr}: ${snapshot.error}',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => setState(() {
                      _containersFuture = _fetchContainers();
                    }),
                    child: Text('DockerPage_Retry'.tr),
                  ),
                ],
              ),
            );
          }

          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          var containers = snapshot.data;

          if (containers == null || containers.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.inbox, size: 48, color: Colors.grey.shade400),
                  const SizedBox(height: 16),
                  Text(
                    'DockerPage_NoContainers'.tr,
                    style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
                  ),
                ],
              ),
            );
          }

          // Sort: running containers first, then by name
          containers.sort((a, b) {
            var aRunning = (a['state'] == 'running') ? 0 : 1;
            var bRunning = (b['state'] == 'running') ? 0 : 1;
            if (aRunning != bRunning) return aRunning.compareTo(bRunning);
            return (a['name'] ?? '').toString().compareTo((b['name'] ?? '').toString());
          });

          var runningCount = containers.where((c) => c['state'] == 'running').length;

          return Column(
            children: [
              // Summary bar
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                color: Theme.of(context).colorScheme.surfaceContainerHighest.withAlpha(80),
                child: Row(
                  children: [
                    Text(
                      '${'DockerPage_Containers'.tr}: ${containers.length}',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(width: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.green.shade100,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '${'DockerPage_Running'.tr}: $runningCount',
                        style: TextStyle(fontSize: 12, color: Colors.green.shade800),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '${'DockerPage_Stopped'.tr}: ${containers.length - runningCount}',
                        style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                      ),
                    ),
                  ],
                ),
              ),
              // Container list
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(10),
                  itemCount: containers.length,
                  itemBuilder: (context, index) {
                    return ContainerCard(
                      containerData: containers[index],
                      onAction: () {
                        setState(() {
                          _containersFuture = _fetchContainers();
                        });
                      },
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
