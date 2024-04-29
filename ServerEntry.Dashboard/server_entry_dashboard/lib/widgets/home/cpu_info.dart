import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:server_entry_dashboard/data/api_resolver.dart';
import 'package:server_entry_dashboard/widgets/home/const/pending_widget.dart';
import 'package:server_entry_dashboard/widgets/home/utils/percent_processor.dart';
import 'package:server_entry_dashboard/widgets/widget_info_time.dart';

class CpuInfoWidget extends StatelessWidget {
  @override
  const CpuInfoWidget({super.key});

  Stream<Future<CpuInfoWidgetData?>> getDataProvider() {
    return Stream.periodic(const Duration(seconds: 3), (i) async {
      var time = DateTime.now();

      var result = await ApiResolver().hardwareStatus().processors(null, range: 'cpu');

      if (result == null) return null;

      var jsonBody = jsonDecode(result)[0];

      return CpuInfoWidgetData()
        ..name = jsonBody['name']
        ..usage = Random().nextDouble() // jsonBody['usage']
        ..coreCount = jsonBody['coreCount']
        ..frequency = jsonBody['frequency']
        ..requestId = i
        ..requestTime = time;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(10, 10, 10, 0),
      child: Card(
        elevation: 4.0,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: StreamBuilder<Future<CpuInfoWidgetData?>>(
            stream: getDataProvider(),
            builder: (context, snapshot) {
              if (snapshot.hasError) return Text('Error: ${snapshot.error}');

              switch (snapshot.connectionState) {
                case ConnectionState.none:
                  return const PendingWidget();
                case ConnectionState.waiting:
                  return const PendingWidget();
                case ConnectionState.active:
                  return FutureBuilder(
                    future: snapshot.data,
                    builder: (context, snapshot) {
                      var info = snapshot.data;

                      if (info == null) return const PendingWidget();

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 80,
                                height: 80,
                                margin: const EdgeInsets.all(20),
                                child: Stack(
                                  children: [
                                    Center(
                                      child: SizedBox(
                                        width: 80,
                                        height: 80,
                                        child: CircularProgressIndicator(
                                          value: info.usage,
                                          backgroundColor: const Color.fromARGB(92, 158, 158, 158),
                                          strokeWidth: 8.0,
                                          strokeCap: StrokeCap.round,
                                        ),
                                      ),
                                    ),
                                    Center(
                                      child: Text(info.usage.toProgressString()),
                                    ),
                                  ],
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(info.name, style: const TextStyle(fontSize: 16)),
                                  Text(
                                    '${info.coreCount} ${'HomePage_CpuWidget_PhysicalCore${info.coreCount > 1 ? 's' : ''}Count'.tr}',
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                  Text(
                                    'NaN ${'HomePage_CpuWidget_LogicalCoreCount'.tr}',
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                  Text(
                                    '${info.frequency} MHz (${(info.frequency / 1000).toStringAsFixed(2)} GHz)',
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                ],
                              )
                            ],
                          ),
                          WidgetInfoTime(requestTime: info.requestTime, requestId: info.requestId),
                        ],
                      );
                    },
                  );
                case ConnectionState.done:
                  return const PendingWidget();
              }
            },
          ),
        ),
      ),
    );
  }
}

class CpuInfoWidgetData {
  late String name;

  late double usage;

  late int coreCount;

  late double frequency;

  late int requestId;

  late DateTime requestTime;
}
