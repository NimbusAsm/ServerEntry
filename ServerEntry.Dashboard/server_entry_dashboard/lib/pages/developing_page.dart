import 'package:flutter/material.dart';

class DevelopingPage extends StatefulWidget {
  const DevelopingPage({super.key});

  @override
  State<DevelopingPage> createState() => _DevelopingPageState();
}

class _DevelopingPageState extends State<DevelopingPage> {
  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            'Developing ...',
          ),
        ],
      ),
    );
  }
}
