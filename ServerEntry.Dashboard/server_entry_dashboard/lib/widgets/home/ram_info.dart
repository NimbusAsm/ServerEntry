import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:server_entry_dashboard/data/api_resolver.dart';

class RamInfoWidget extends StatelessWidget {
  @override
  const RamInfoWidget({super.key});

  Stream<Future<RamInfoWidgetData?>> getDataProvider() {
    return Stream.periodic(const Duration(seconds: 3), (i) async {
      var time = DateTime.now();

      var result = await ApiResolver().hardwareStatus().memory(null, range: 'ram');

      if (result == null) return null;

      var jsonBody = jsonDecode(result)[0];

      return RamInfoWidgetData()
        ..commitedSize = jsonBody['commitedSize']['displayText']
        ..cachedSize = jsonBody['cachedSize']['displayText']
        ..available = jsonBody['available']['displayText']
        ..capacity = jsonBody['capacity']['displayText']
        ..usage = jsonBody['usage']
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
          child: StreamBuilder<Future<RamInfoWidgetData?>>(
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
                            ],
                          ),
                          const SizedBox(height: 10),
                          Table(
                            children: [
                              TableRow(children: [
                                Text('${'HomePage_RamWidget_Available'.tr}: '),
                                Text(info.available),
                                Text('${'HomePage_RamWidget_Capacity'.tr}: '),
                                Text(info.capacity),
                              ]),
                              TableRow(children: [
                                Text('${'HomePage_RamWidget_Commited'.tr}: '),
                                Text(info.commitedSize),
                                Text('${'HomePage_RamWidget_Cached'.tr}: '),
                                Text(info.cachedSize),
                              ]),
                            ],
                          ),
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

class RamInfoWidgetData {
  late String commitedSize;

  late String cachedSize;

  late String available;

  late String capacity;

  late double usage;

  late int requestId;

  late DateTime requestTime;
}
