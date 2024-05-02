import 'package:flutter/material.dart';

class DeviceInfoWidget extends StatelessWidget {
  @override
  const DeviceInfoWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(10, 10, 10, 0),
      child: const Card(
        elevation: 4.0,
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Device Info', style: TextStyle(fontSize: 24)),
              Text('Device CPUs (2)', style: TextStyle(fontSize: 18)),
              Text('  AMD EPYC™ 9684X 96C 192T'),
              Text('  AMD EPYC™ 9684X 96C 192T'),
              Text('Device RAM', style: TextStyle(fontSize: 18)),
              Text('  308.2 GB Used'),
              Text('  1024.0 GB Total'),
              Text('  30 % Usage'),
              Text('Device GPUs (4)', style: TextStyle(fontSize: 18)),
              Text('  Nvidia RTX 4090 GDDR6X 24GB'),
              Text('  Nvidia RTX 4090 GDDR6X 24GB'),
              Text('  Nvidia RTX 4090 GDDR6X 24GB'),
              Text('  Nvidia RTX 4090 GDDR6X 24GB'),
            ],
          ),
        ),
      ),
    );
  }
}
