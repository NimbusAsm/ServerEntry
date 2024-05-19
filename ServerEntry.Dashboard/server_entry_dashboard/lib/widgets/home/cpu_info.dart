import 'dart:convert';

import 'package:fl_chart/fl_chart.dart';
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
    return Stream.periodic(const Duration(seconds: 1), (i) async {
      var time = DateTime.now();

      var result = await ApiResolver().hardwareStatus().processors(null, range: 'cpu');

      if (result == null) return null;

      var jsonBody = jsonDecode(result)[0];

      var info = CpuInfoWidgetData()
        ..name = jsonBody['name']
        ..usage = jsonBody['usage']
        ..coreCount = jsonBody['coreCount']
        ..frequency = jsonBody['frequency']
        ..requestId = i
        ..requestTime = time;

      var usageHistory = await ApiResolver().hardwareStatus().cpuUsageHistory(null);

      if (usageHistory != null) {
        info.usageHistory = json.decode(usageHistory);
      }

      return info;
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
              var chartBorderColor = Get.isDarkMode ? Colors.grey : Colors.black12;

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
                          Wrap(
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
                                  const SizedBox(height: 14),
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
                          Container(
                            margin: const EdgeInsets.only(left: 15, right: 15, top: 20, bottom: 0),
                            height: 80.0 + (info.getMaxUsageHistoryNested() * 1.0 / 20.0) * 12.0,
                            child: LineChart(
                              LineChartData(
                                minX: 0,
                                maxX: 4,
                                minY: 0,
                                maxY: info.getMaxUsageHistoryNested() * 1.0,
                                lineBarsData: [
                                  LineChartBarData(
                                    spots: info.getUsageHistorySpots(),
                                    color: Get.isDarkMode ? Colors.indigoAccent : Colors.blueGrey,
                                    isStrokeCapRound: true,
                                    isStrokeJoinRound: true,
                                  ),
                                ],
                                titlesData: FlTitlesData(
                                  show: true,
                                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                  bottomTitles: AxisTitles(
                                    sideTitles: SideTitles(
                                      showTitles: true,
                                      reservedSize: 40,
                                      interval: 1,
                                      getTitlesWidget: (a, b) => Padding(
                                        padding: const EdgeInsets.only(top: 10),
                                        child: Text((() {
                                          var value = (a.toInt() - 4).abs() * 0.5;
                                          if (value == 0) {
                                            return 'now';
                                          } else {
                                            return '${value}s ago';
                                          }
                                        })()),
                                      ),
                                    ),
                                  ),
                                  leftTitles: AxisTitles(
                                    sideTitles: SideTitles(
                                      showTitles: true,
                                      interval: 20,
                                      getTitlesWidget: (a, b) => Text('${a.toInt()} %'),
                                      reservedSize: 50,
                                    ),
                                  ),
                                ),
                                gridData: FlGridData(
                                  show: true,
                                  drawVerticalLine: true,
                                  horizontalInterval: 20,
                                  verticalInterval: 1,
                                  getDrawingHorizontalLine: (value) {
                                    return FlLine(
                                      color: chartBorderColor,
                                      strokeWidth: 1,
                                    );
                                  },
                                  getDrawingVerticalLine: (value) {
                                    return FlLine(
                                      color: chartBorderColor,
                                      strokeWidth: 1,
                                    );
                                  },
                                ),
                                borderData: FlBorderData(
                                  show: true,
                                  border: Border.all(color: chartBorderColor),
                                ),
                              ),
                              duration: const Duration(milliseconds: 0),
                            ),
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

  late Map<String, dynamic> usageHistory;

  int getMaxUsageHistoryNested() {
    var maxOne = 0.0;
    if (usageHistory.length < 5) {
      for (var element in usageHistory.values) {
        var value = double.parse(element.toString()) * 100;
        if (value > maxOne) maxOne = value;
      }
    } else {
      usageHistory.values.skip(usageHistory.length - 5).take(5).forEach((element) {
        var value = double.parse(element.toString()) * 100;
        if (value > maxOne) maxOne = value;
      });
    }
    if (maxOne <= 10) {
      return 10;
    } else if (maxOne <= 20) {
      return 20;
    } else if (maxOne <= 40) {
      return 40;
    } else if (maxOne <= 60) {
      return 60;
    } else if (maxOne <= 80) {
      return 80;
    } else {
      return 100;
    }
  }

  List<FlSpot> getUsageHistorySpots() {
    var result = <FlSpot>[];
    var index = 0;
    if (usageHistory.length < 5) {
      for (var element in usageHistory.values) {
        result.add(FlSpot(index * 1.0, double.parse(element.toString()) * 100));
        index += 1;
      }
      return result;
    }
    usageHistory.values.skip(usageHistory.length - 5).take(5).forEach((element) {
      result.add(FlSpot(index * 1.0, double.parse(element.toString()) * 100));
      index += 1;
    });
    return result;
  }
}
