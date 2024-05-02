import 'package:flutter/material.dart';

class PendingWidget extends StatelessWidget {
  @override
  const PendingWidget({super.key, this.width = 150.0, this.height = 150.0});

  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(30),
      child: Center(
        child: SizedBox(
          width: width,
          height: height,
          child: const CircularProgressIndicator.adaptive(),
        ),
      ),
    );
  }
}
