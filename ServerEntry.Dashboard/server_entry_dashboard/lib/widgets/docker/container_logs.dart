import 'dart:convert';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:server_entry_dashboard/data/api_resolver.dart';

class ContainerLogsViewer extends StatefulWidget {
  final String containerId;
  final String containerName;

  const ContainerLogsViewer({
    super.key,
    required this.containerId,
    required this.containerName,
  });

  @override
  State<ContainerLogsViewer> createState() => _ContainerLogsViewerState();
}

class _ContainerLogsViewerState extends State<ContainerLogsViewer> {
  String _logs = '';
  bool _loading = true;
  int _tail = 100;
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    _fetchLogs();
    _refreshTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (mounted) _fetchLogs();
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  Future<void> _fetchLogs() async {
    final result = await ApiResolver().docker().getContainerLogs(
      widget.containerId,
      tail: _tail,
    );

    if (result != null && mounted) {
      var decoded = jsonDecode(result);
      setState(() {
        _logs = decoded['logs'] ?? '';
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.containerName} — ${'DockerCard_Logs'.tr}'),
        actions: [
          // Tail lines selector
          PopupMenuButton<int>(
            tooltip: '${'DockerLogs_Tail'.tr}: $_tail',
            icon: const Icon(Icons.filter_list),
            onSelected: (value) {
              setState(() {
                _tail = value;
                _loading = true;
              });
              _fetchLogs();
            },
            itemBuilder: (context) => [50, 100, 200, 500, 1000]
                .map((n) => PopupMenuItem(value: n, child: Text('$n ${'DockerLogs_Lines'.tr}')))
                .toList(),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() => _loading = true);
              _fetchLogs();
            },
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _logs.isEmpty
              ? Center(
                  child: Text(
                    'DockerLogs_Empty'.tr,
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(12),
                  child: SelectableText(
                    _logs,
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 12,
                      height: 1.4,
                    ),
                  ),
                ),
    );
  }
}
