import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:server_entry_dashboard/data/api_resolver.dart';
import 'package:server_entry_dashboard/widgets/home/const/pending_widget.dart';
import 'package:server_entry_dashboard/widgets/home/utils/percent_processor.dart';
import 'package:server_entry_dashboard/widgets/widget_info_time.dart';

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
                          LinearProgressIndicator(
                            value: info.usage,
                            backgroundColor: const Color.fromARGB(92, 158, 158, 158),
                            borderRadius: BorderRadius.circular(15.0),
                            minHeight: 8.0,
                          ),
                          const SizedBox(height: 10),
                          Table(
                            columnWidths: const {
                              0: FlexColumnWidth(),
                              1: FixedColumnWidth(20.0),
                              2: FlexColumnWidth(),
                            },
                            children: [
                              TableRow(children: [
                                const SizedBox(),
                                const SizedBox(),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('${'HomePage_RamWidget_Usage'.tr}: '),
                                    Text(info.usage.toProgressString()),
                                  ],
                                ),
                              ]),
                              const TableRow(children: [
                                SizedBox(),
                                SizedBox(),
                                SizedBox(),
                              ]),
                              TableRow(children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('${'HomePage_RamWidget_Available'.tr}: '),
                                    Text(info.available),
                                  ],
                                ),
                                const SizedBox(),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('${'HomePage_RamWidget_Capacity'.tr}: '),
                                    Text(info.capacity),
                                  ],
                                ),
                              ]),
                              TableRow(children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('${'HomePage_RamWidget_Commited'.tr}: '),
                                    Text(info.commitedSize),
                                  ],
                                ),
                                const SizedBox(),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('${'HomePage_RamWidget_Cached'.tr}: '),
                                    Text(info.cachedSize),
                                  ],
                                ),
                              ]),
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

class RamInfoWidgetData {
  late String commitedSize;

  late String cachedSize;

  late String available;

  late String capacity;

  late double usage;

  late int requestId;

  late DateTime requestTime;
}
