import 'package:flutter/material.dart';

class ReviewStars extends StatefulWidget {
  const ReviewStars({
    super.key,
    required this.starsGiven,
    this.iconSize,
    this.onRatingChanged,
    this.isInteractive = false,
  });

  final int starsGiven;
  final double? iconSize;
  final Function(int)? onRatingChanged;
  final bool isInteractive;

  @override
  State<ReviewStars> createState() => _ReviewStarsState();
}

class _ReviewStarsState extends State<ReviewStars>
    with TickerProviderStateMixin {
  late List<AnimationController> _starControllers;
  int? _hoveredIndex;

  @override
  void initState() {
    super.initState();
    _starControllers = List.generate(
      5,
      (index) => AnimationController(
        duration: const Duration(milliseconds: 300),
        vsync: this,
      ),
    );
  }

  @override
  void dispose() {
    for (var controller in _starControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _triggerStarAnimation(int index) async {
    if (!widget.isInteractive) return;

    await _starControllers[index].forward().then((_) {
      _starControllers[index].reverse();
    });

    widget.onRatingChanged?.call(index + 1);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        ...List.generate(5, (index) {
          final isActive = widget.starsGiven > index;
          final scale = Tween<double>(begin: 1.0, end: 1.2).animate(
            CurvedAnimation(
              parent: _starControllers[index],
              curve: Curves.elasticOut,
            ),
          );

          return MouseRegion(
            onEnter: (_) {
              if (widget.isInteractive) {
                setState(() => _hoveredIndex = index);
              }
            },
            onExit: (_) {
              if (widget.isInteractive) {
                setState(() => _hoveredIndex = null);
              }
            },
            child: GestureDetector(
              onTap: () => _triggerStarAnimation(index),
              child: ScaleTransition(
                scale: scale,
                child: Padding(
                  padding: const EdgeInsets.only(right: 4.0),
                  child: Icon(
                    Icons.star_rounded,
                    color: isActive ? const Color(0xFFFFC107) : Colors.grey,
                    size:
                        (widget.iconSize ?? 24) *
                        (widget.isInteractive && _hoveredIndex == index
                            ? 1.1
                            : 1.0),
                  ),
                ),
              ),
            ),
          );
        }),
      ],
    );
  }
}
