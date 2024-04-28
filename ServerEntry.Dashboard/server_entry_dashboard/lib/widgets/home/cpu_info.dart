import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:server_entry_dashboard/data/api_resolver.dart';

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
        ..usage = jsonBody['usage']
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

              var waitting = const Padding(
                padding: EdgeInsets.all(30),
                child: Center(
                  child: SizedBox(
                    width: 200,
                    height: 200,
                    child: CircularProgressIndicator.adaptive(),
                  ),
                ),
              );

              switch (snapshot.connectionState) {
                case ConnectionState.none:
                  return waitting;
                case ConnectionState.waiting:
                  return waitting;
                case ConnectionState.active:
                  return FutureBuilder(
                    future: snapshot.data,
                    builder: (context, snapshot) {
                      var info = snapshot.data;

                      if (info == null) return waitting;

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
                                        child: CircularProgressIndicator(value: info.usage),
                                      ),
                                    ),
                                    Center(
                                      child: Text('${(info.usage * 100).toStringAsFixed(1)} %'),
                                    ),
                                  ],
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
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
                          const SizedBox(height: 10),
                          Text(info.name, style: const TextStyle(fontSize: 20)),
                          const SizedBox(height: 15),
                          Row(
                            children: [
                              const Spacer(),
                              Tooltip(
                                message: '${'HomePage_UpdatedAt'.tr}: ${info.requestTime} (${info.requestId})',
                                child: const Icon(Icons.info),
                              ),
                            ],
                          ),
                        ],
                      );
                    },
                  );
                case ConnectionState.done:
                  return waitting;
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
