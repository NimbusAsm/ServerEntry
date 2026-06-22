import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:server_entry_dashboard/data/api_resolver.dart';
import 'package:server_entry_dashboard/widgets/docker/container_logs.dart';

class ContainerCard extends StatefulWidget {
  final dynamic containerData;
  final VoidCallback onAction;

  const ContainerCard({
    super.key,
    required this.containerData,
    required this.onAction,
  });

  @override
  State<ContainerCard> createState() => _ContainerCardState();
}

class _ContainerCardState extends State<ContainerCard> {
  bool _actionInProgress = false;

  bool get _isRunning => widget.containerData['state'] == 'running';

  String get _id => widget.containerData['id']?.toString() ?? '';
  String get _name {
    var name = widget.containerData['name']?.toString() ?? '';
    if (name.startsWith('/')) name = name.substring(1);
    return name;
  }

  String get _image => widget.containerData['image']?.toString() ?? '?';
  String get _status => widget.containerData['status']?.toString() ?? 'unknown';

  Color _statusColor() {
    switch (widget.containerData['state']) {
      case 'running':
        return Colors.green;
      case 'paused':
        return Colors.orange;
      case 'exited':
        return Colors.red.shade400;
      case 'created':
        return Colors.blue.shade400;
      default:
        return Colors.grey;
    }
  }

  String _statusText() {
    switch (widget.containerData['state']) {
      case 'running':
        return 'DockerCard_Running'.tr;
      case 'paused':
        return 'DockerCard_Paused'.tr;
      case 'exited':
        return 'DockerCard_Exited'.tr;
      case 'created':
        return 'DockerCard_Created'.tr;
      default:
        return widget.containerData['state'] ?? '?';
    }
  }

  String _portsText() {
    var ports = widget.containerData['ports'] as List<dynamic>?;
    if (ports == null || ports.isEmpty) return '-';
    return ports
        .map((p) {
          var pubPort = p['publicPort'];
          var privPort = p['privatePort'];
          return pubPort != null ? '$pubPort:$privPort' : '$privPort';
        })
        .join(', ');
  }

  Future<void> _performAction(String action) async {
    setState(() => _actionInProgress = true);

    try {
      final resolver = ApiResolver().docker();
      String? result;

      switch (action) {
        case 'start':
          result = await resolver.startContainer(_id);
          break;
        case 'stop':
          result = await resolver.stopContainer(_id);
          break;
        case 'restart':
          result = await resolver.restartContainer(_id);
          break;
      }

      if (result != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${'DockerCard_ActionSuccess'.tr} ($action)'),
            duration: const Duration(seconds: 2),
          ),
        );
        widget.onAction();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${'DockerCard_ActionFailed'.tr}: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _actionInProgress = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3.0,
      margin: const EdgeInsets.only(bottom: 10),
      child: ExpansionTile(
        leading: Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: _statusColor(),
            shape: BoxShape.circle,
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                _name,
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        subtitle: Text(
          '$_image  •  ${_statusText()}',
          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
          overflow: TextOverflow.ellipsis,
        ),
        childrenPadding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
        expandedCrossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Status bar and quick info
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest.withAlpha(60),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _infoRow('ID', _id.length > 20 ? '${_id.substring(0, 12)}...' : _id),
                const SizedBox(height: 4),
                _infoRow('Image', _image),
                const SizedBox(height: 4),
                _infoRow('Status', _status),
                const SizedBox(height: 4),
                _infoRow('${'DockerCard_Ports'.tr}', _portsText()),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // Action buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (_isRunning) ...[
                _actionButton('DockerCard_Stop'.tr, 'stop', Colors.red, Icons.stop),
                const SizedBox(width: 8),
                _actionButton('DockerCard_Restart'.tr, 'restart', Colors.orange, Icons.restart_alt),
              ] else ...[
                _actionButton('DockerCard_Start'.tr, 'start', Colors.green, Icons.play_arrow),
              ],
              const SizedBox(width: 8),
              _actionButton('DockerCard_Logs'.tr, 'logs', Colors.blueGrey, Icons.terminal),
            ],
          ),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 50,
          child: Text(
            label,
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.grey.shade600),
          ),
        ),
        Expanded(
          child: Text(value, style: const TextStyle(fontSize: 12)),
        ),
      ],
    );
  }

  Widget _actionButton(String label, String action, Color color, IconData icon) {
    return TextButton.icon(
      onPressed: _actionInProgress
          ? null
          : () {
              if (action == 'logs') {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => ContainerLogsViewer(
                      containerId: _id,
                      containerName: _name,
                    ),
                  ),
                );
              } else {
                _performAction(action);
              }
            },
      icon: _actionInProgress && action != 'logs'
          ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2))
          : Icon(icon, size: 16),
      label: Text(label, style: TextStyle(fontSize: 12, color: color)),
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        minimumSize: Size.zero,
      ),
    );
  }
}
