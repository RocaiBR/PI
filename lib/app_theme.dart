import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFF7B1C3D);
  static const Color primaryDark = Color(0xFF4A0E23);
  static const Color primaryLight = Color(0xFF9B2248);
  static const Color accent = Color(0xFFE05C87);
  static const Color accentSoft = Color(0xFFF4C2D2);
  static const Color surface = Color(0xFF1A0F13);
  static const Color cardDark = Color(0xFF2A1520);
  static const Color textPrimary = Color(0xFFF5E6EC);
  static const Color textSecondary = Color(0xFFBFA0AD);
}

PreferredSizeWidget buildGradientAppBar(
    {required String title, List<Widget>? actions}) {
  return AppBar(
    title: Text(title, style: const TextStyle(color: Colors.white)),
    iconTheme: const IconThemeData(color: Colors.white),
    actions: actions,
    flexibleSpace: Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primaryDark, AppColors.primary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
    ),
  );
}

class AnimatedPressButton extends StatefulWidget {
  final VoidCallback onPressed;
  final Widget child;
  final bool isOutlined;

  const AnimatedPressButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.isOutlined = false,
  });

  @override
  State<AnimatedPressButton> createState() => _AnimatedPressButtonState();
}

class _AnimatedPressButtonState extends State<AnimatedPressButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 150));
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.94).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        widget.onPressed();
      },
      onTapCancel: () => _controller.reverse(),
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          width: double.infinity,
          height: 50,
          decoration: BoxDecoration(
            color: widget.isOutlined ? Colors.transparent : AppColors.primary,
            border: widget.isOutlined
                ? Border.all(color: AppColors.primary, width: 2)
                : null,
            borderRadius: BorderRadius.circular(8),
          ),
          alignment: Alignment.center,
          child: widget.child,
        ),
      ),
    );
  }
}
