import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:server_entry_dashboard/data/api_resolver.dart';
import 'package:server_entry_dashboard/widgets/home/const/pending_widget.dart';
import 'package:server_entry_dashboard/widgets/home/utils/percent_processor.dart';
import 'package:server_entry_dashboard/widgets/widget_info_time.dart';

class DiskInfoWidget extends StatelessWidget {
  const DiskInfoWidget({super.key});

  Stream<Future<List<DiskInfoWidgetData>?>> getDataProvider() {
    return Stream.periodic(const Duration(seconds: 5), (i) async {
      var time = DateTime.now();

      var result = await ApiResolver().hardwareStatus().memory(null, range: 'disks');

      if (result == null) return null;

      var jsonList = jsonDecode(result) as List<dynamic>;

      return jsonList.map((jsonBody) {
        return DiskInfoWidgetData()
          ..name = jsonBody['name'] ?? 'Unknown'
          ..capacity = jsonBody['capacity']?['displayText'] ?? 'N/A'
          ..available = jsonBody['available']?['displayText'] ?? 'N/A'
          ..usage = (jsonBody['usage'] as num?)?.toDouble() ?? 0.0
          ..load = (jsonBody['load'] as num?)?.toDouble() ?? 0.0
          ..readSpeed = jsonBody['readSpeedPerSecond']?['displayText'] ?? '-'
          ..writeSpeed = jsonBody['writeSpeedPerSecond']?['displayText'] ?? '-'
          ..isHostOs = jsonBody['isHostingOperatingSystem'] ?? false
          ..partitions = (jsonBody['partitions'] as List<dynamic>?)?.map((p) {
            return PartitionWidgetData()
              ..name = p['name'] ?? '?'
              ..size = p['size']?['displayText'] ?? 'N/A';
          }).toList() ?? []
          ..requestId = i
          ..requestTime = time;
      }).toList();
    });
  }

  String _formatSpeed(String speed) {
    return speed == '-' || speed == '0 B' ? '-' : '$speed/s';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(10, 10, 10, 0),
      child: Card(
        elevation: 4.0,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: StreamBuilder<Future<List<DiskInfoWidgetData>?>>(
            stream: getDataProvider(),
            builder: (context, snapshot) {
              if (snapshot.hasError) return Text('Error: ${snapshot.error}');

              switch (snapshot.connectionState) {
                case ConnectionState.none:
                case ConnectionState.waiting:
                case ConnectionState.done:
                  return const PendingWidget();
                case ConnectionState.active:
                  return FutureBuilder(
                    future: snapshot.data,
                    builder: (context, snapshot) {
                      var disks = snapshot.data;

                      if (disks == null || disks.isEmpty) return const PendingWidget();

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.storage, size: 20),
                              const SizedBox(width: 8),
                              Text(
                                '${'HomePage_DiskWidget_Title'.tr} (${disks.length})',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          ...disks.map((disk) => _buildDiskCard(context, disk)),
                          if (disks.isNotEmpty)
                            WidgetInfoTime(
                              requestTime: disks.first.requestTime,
                              requestId: disks.first.requestId,
                            ),
                        ],
                      );
                    },
                  );
              }
            },
          ),
        ),
      ),
    );
  }

  Widget _buildDiskCard(BuildContext context, DiskInfoWidgetData disk) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).dividerColor),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Disk name and host OS badge
          Row(
            children: [
              Text(
                disk.name,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              if (disk.isHostOs) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.green.shade100,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'OS',
                    style: TextStyle(fontSize: 11, color: Colors.green.shade800),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 8),

          // Usage progress bar
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: disk.usage,
                    minHeight: 10,
                    backgroundColor: const Color.fromARGB(92, 158, 158, 158),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                width: 60,
                child: Text(
                  disk.usage.toProgressString(),
                  textAlign: TextAlign.right,
                  style: const TextStyle(fontSize: 13),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Capacity details
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${'HomePage_DiskWidget_Available'.tr}: ${disk.available}',
                style: const TextStyle(fontSize: 13),
              ),
              Text(
                '${'HomePage_DiskWidget_Capacity'.tr}: ${disk.capacity}',
                style: const TextStyle(fontSize: 13),
              ),
            ],
          ),
          const SizedBox(height: 4),

          // I/O speeds
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.download, size: 14, color: Colors.grey.shade600),
                  const SizedBox(width: 4),
                  Text(
                    'R: ${_formatSpeed(disk.readSpeed)}',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                ],
              ),
              Row(
                children: [
                  Icon(Icons.upload, size: 14, color: Colors.grey.shade600),
                  const SizedBox(width: 4),
                  Text(
                    'W: ${_formatSpeed(disk.writeSpeed)}',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ],
          ),

          // Partitions expandable section
          if (disk.partitions.isNotEmpty) ...[
            const SizedBox(height: 6),
            ExpansionTile(
              tilePadding: EdgeInsets.zero,
              title: Text(
                '${'HomePage_DiskWidget_Partitions'.tr} (${disk.partitions.length})',
                style: const TextStyle(fontSize: 13),
              ),
              children: disk.partitions.map((p) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(p.name, style: const TextStyle(fontSize: 12)),
                      Text(p.size, style: const TextStyle(fontSize: 12)),
                    ],
                  ),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }
}

class DiskInfoWidgetData {
  late String name;
  late String capacity;
  late String available;
  late double usage;
  late double load;
  late String readSpeed;
  late String writeSpeed;
  late bool isHostOs;
  late List<PartitionWidgetData> partitions;
  late int requestId;
  late DateTime requestTime;
}

class PartitionWidgetData {
  late String name;
  late String size;
}
