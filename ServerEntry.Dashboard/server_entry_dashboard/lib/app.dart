import 'package:cherrilog/cherrilog.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:server_entry_dashboard/utils/controllers/title_controller.dart';

class _App {
  static final _App _singleton = _App._internal();

  var navigationIndex = 0.obs;

  late PageController navPageController;

  final titleController = Get.put(TitleController());

  void navPageTo(int index) {
    var delta = (index - app.navigationIndex.value).abs();
    app.navigationIndex.value = index;
    navPageController.animateToPage(
      index,
      duration: Duration(milliseconds: 150 + delta * 200),
      curve: Curves.easeInOutCubic,
    );
  }

  void init() {
    CherriLog.init(
      options: CherriOptions()
        ..useBuffer = false
        ..logLevelRange = CherriLogLevelRanges.all,
    ).logTo(CherriConsole());
  }

  void delay(Function func, int milliseconds) {
    Future.delayed(Duration(milliseconds: milliseconds)).then((value) => func.call());
  }

  factory _App() {
    return _singleton;
  }

  _App._internal();
}

var app = _App();
