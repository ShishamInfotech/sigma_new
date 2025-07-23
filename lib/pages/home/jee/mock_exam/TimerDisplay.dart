
import 'package:flutter/cupertino.dart';

class TimerDisplay extends StatefulWidget {
  static final _stateKey = GlobalKey<_TimerDisplayState>();

  final Duration initialDuration;

  TimerDisplay({required this.initialDuration, Key? key})
      : super(key: _stateKey);

  static void update(Duration newDuration) {
    _stateKey.currentState?.updateDuration(newDuration);
  }

  @override
  _TimerDisplayState createState() => _TimerDisplayState();
}

class _TimerDisplayState extends State<TimerDisplay> {
  late Duration duration;

  @override
  void initState() {
    super.initState();
    duration = widget.initialDuration;
  }

  void updateDuration(Duration newDuration) {
    if (mounted) {
      setState(() {
        duration = newDuration;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      'Time Left: ${_formatDuration(duration)}',
      style: const TextStyle(fontSize: 18),
    );
  }

  String _formatDuration(Duration d) {
    return '${d.inHours.toString().padLeft(2, '0')}:${(d.inMinutes % 60).toString().padLeft(2, '0')}:${(d.inSeconds % 60).toString().padLeft(2, '0')}';
  }
}
