import 'package:flutter/material.dart';
import 'package:get/get.dart';

class WidgetInfoTime extends StatelessWidget {
  @override
  const WidgetInfoTime({
    super.key,
    required this.requestTime,
    required this.requestId,
    this.padding = const EdgeInsets.only(top: 15.0),
  });

  final DateTime requestTime;
  final int requestId;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Row(
        children: [
          const Spacer(),
          Tooltip(
            message: '${'HomePage_UpdatedAt'.tr}: $requestTime ($requestId)',
            child: const Icon(Icons.info),
          ),
        ],
      ),
    );
  }
}
