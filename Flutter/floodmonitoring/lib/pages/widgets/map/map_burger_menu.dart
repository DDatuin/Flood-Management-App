import 'package:flutter/material.dart';

class MapBurgerMenuButton extends StatelessWidget {
  final bool showMainSheet;
  final VoidCallback onTap;

  const MapBurgerMenuButton({
    super.key,
    required this.showMainSheet,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 20,
      left: 10,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 300),
        opacity: showMainSheet ? 0.0 : 1.0,
        curve: Curves.easeInOut,
        child: IgnorePointer(
          ignoring: showMainSheet,
          child: GestureDetector(
            onTap: onTap,
            child: Container(
              height: 40,
              width: 40,
              decoration: BoxDecoration(
                color: Colors.blue, // replace with your colorPrimaryMid
                borderRadius: BorderRadius.circular(50),
              ),
              child: Center(
                child: Image.asset(
                  'assets/images/icons/burger-bar.png',
                  width: 25,
                  height: 25,
                  fit: BoxFit.contain,
                  color: Colors.white,
                  colorBlendMode: BlendMode.srcIn,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
