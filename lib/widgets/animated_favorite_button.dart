import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// An interactive heart button with spring pulse animation and haptic feedback.
class AnimatedFavoriteButton extends StatefulWidget {
  final bool initialIsFavorite;
  final ValueChanged<bool>? onChanged;
  final double size;
  final Color activeColor;
  final Color inactiveColor;

  const AnimatedFavoriteButton({
    super.key,
    this.initialIsFavorite = false,
    this.onChanged,
    this.size = 16,
    this.activeColor = const Color(0xFFEF4444),
    this.inactiveColor = Colors.white,
  });

  @override
  State<AnimatedFavoriteButton> createState() => _AnimatedFavoriteButtonState();
}

class _AnimatedFavoriteButtonState extends State<AnimatedFavoriteButton>
    with SingleTickerProviderStateMixin {
  late bool _isFavorite;
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _isFavorite = widget.initialIsFavorite;
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 260),
    );

    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 1.35)
            .chain(CurveTween(curve: Curves.easeOutCubic)),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.35, end: 1.0)
            .chain(CurveTween(curve: Curves.bounceOut)),
        weight: 50,
      ),
    ]).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggle() {
    HapticFeedback.lightImpact();
    setState(() {
      _isFavorite = !_isFavorite;
    });
    _controller.forward(from: 0.0);
    widget.onChanged?.call(_isFavorite);
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: GestureDetector(
          onTap: _toggle,
          child: Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.35),
              shape: BoxShape.circle,
            ),
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: Icon(
                _isFavorite ? CupertinoIcons.heart_fill : CupertinoIcons.heart,
                size: widget.size,
                color: _isFavorite ? widget.activeColor : widget.inactiveColor,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
