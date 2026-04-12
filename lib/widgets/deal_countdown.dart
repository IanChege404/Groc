import 'dart:async';
import 'package:flutter/material.dart';

/// Real-time countdown widget for flash deals
class DealCountdown extends StatefulWidget {
  final DateTime endTime;
  final TextStyle? style;
  final VoidCallback? onExpired;

  const DealCountdown({
    super.key,
    required this.endTime,
    this.style,
    this.onExpired,
  });

  @override
  State<DealCountdown> createState() => _DealCountdownState();
}

class _DealCountdownState extends State<DealCountdown> {
  late Timer _timer;
  late Duration _remaining;

  @override
  void initState() {
    super.initState();
    _remaining = widget.endTime.difference(DateTime.now());
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      final remaining = widget.endTime.difference(DateTime.now());
      if (remaining.isNegative) {
        _timer.cancel();
        widget.onExpired?.call();
        if (mounted) setState(() => _remaining = Duration.zero);
      } else {
        if (mounted) setState(() => _remaining = remaining);
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  String _pad(int n) => n.toString().padLeft(2, '0');

  @override
  Widget build(BuildContext context) {
    if (_remaining == Duration.zero) {
      return Text('Expired', style: widget.style);
    }

    final hours = _remaining.inHours;
    final minutes = _remaining.inMinutes.remainder(60);
    final seconds = _remaining.inSeconds.remainder(60);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _CountdownUnit(value: _pad(hours), label: 'HRS', style: widget.style),
        _Separator(style: widget.style),
        _CountdownUnit(
          value: _pad(minutes),
          label: 'MIN',
          style: widget.style,
        ),
        _Separator(style: widget.style),
        _CountdownUnit(
          value: _pad(seconds),
          label: 'SEC',
          style: widget.style,
        ),
      ],
    );
  }
}

class _Separator extends StatelessWidget {
  final TextStyle? style;

  const _Separator({this.style});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Text(
        ':',
        style: style ??
            const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 18,
            ),
      ),
    );
  }
}

class _CountdownUnit extends StatelessWidget {
  final String value;
  final String label;
  final TextStyle? style;

  const _CountdownUnit({
    required this.value,
    required this.label,
    this.style,
  });

  @override
  Widget build(BuildContext context) {
    final textStyle = style ??
        const TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 18,
        );

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(value, style: textStyle),
        Text(
          label,
          style: TextStyle(
            fontSize: 9,
            color: textStyle.color?.withValues(alpha: 0.6),
          ),
        ),
      ],
    );
  }
}
