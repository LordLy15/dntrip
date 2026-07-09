import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../data/models/activity_model.dart';

/// Animated checkmark widget with elastic animation
class AnimatedCheckmark extends StatefulWidget {
  final VoidCallback? onComplete;
  final double size;

  const AnimatedCheckmark({
    super.key,
    this.onComplete,
    this.size = 100,
  });

  @override
  State<AnimatedCheckmark> createState() => _AnimatedCheckmarkState();
}

class _AnimatedCheckmarkState extends State<AnimatedCheckmark>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _checkAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.0, end: 1.2)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.2, end: 1.0)
            .chain(CurveTween(curve: Curves.elasticOut)),
        weight: 50,
      ),
    ]).animate(_controller);

    _checkAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.3, 1.0, curve: Curves.easeOut),
      ),
    );

    _controller.forward().then((_) {
      widget.onComplete?.call();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              color: Colors.green.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: CustomPaint(
              painter: _CheckmarkPainter(
                progress: _checkAnimation.value,
                color: Colors.green,
                strokeWidth: 6,
              ),
            ),
          ),
        );
      },
    );
  }
}

class _CheckmarkPainter extends CustomPainter {
  final double progress;
  final Color color;
  final double strokeWidth;

  _CheckmarkPainter({
    required this.progress,
    required this.color,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - strokeWidth;

    // Draw circle
    canvas.drawCircle(center, radius, paint);

    if (progress > 0) {
      // Draw checkmark
      final path = Path();
      final startX = size.width * 0.28;
      final startY = size.height * 0.52;
      final midX = size.width * 0.42;
      final midY = size.height * 0.66;
      final endX = size.width * 0.72;
      final endY = size.height * 0.36;

      path.moveTo(startX, startY);

      if (progress <= 0.5) {
        final t = progress * 2;
        path.lineTo(
          startX + (midX - startX) * t,
          startY + (midY - startY) * t,
        );
      } else {
        path.lineTo(midX, midY);
        final t = (progress - 0.5) * 2;
        path.lineTo(
          midX + (endX - midX) * t,
          midY + (endY - midY) * t,
        );
      }

      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _CheckmarkPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

class ActivityCompleteSheet extends StatefulWidget {
  final ActivityModel activity;
  final Function(int actualCost) onComplete;

  const ActivityCompleteSheet({
    super.key,
    required this.activity,
    required this.onComplete,
  });

  @override
  State<ActivityCompleteSheet> createState() => _ActivityCompleteSheetState();
}

class _ActivityCompleteSheetState extends State<ActivityCompleteSheet> {
  late final TextEditingController _costController;
  final NumberFormat _currency = NumberFormat.currency(symbol: 'Rp ', decimalDigits: 0);
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _costController = TextEditingController(
      text: widget.activity.estimatedCost.toString(),
    );
  }

  @override
  void dispose() {
    _costController.dispose();
    super.dispose();
  }

  void _handleSave() {
    setState(() {
      _isSaving = true;
    });
  }

  void _onAnimationComplete() {
    final cost = int.tryParse(_costController.text) ?? 0;
    widget.onComplete(cost);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    if (_isSaving) {
      return Container(
        color: Colors.white,
        child: Center(
          child: AnimatedCheckmark(
            onComplete: _onAnimationComplete,
            size: 120,
          ),
        ),
      );
    }

    return Padding(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Mark Activity Complete',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          Text(
            widget.activity.title ?? 'Activity',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text('Estimated: ${_currency.format(widget.activity.estimatedCost)}'),
          const SizedBox(height: 16),
          TextField(
            controller: _costController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Actual Cost',
              prefixText: 'Rp ',
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _handleSave,
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }
}
