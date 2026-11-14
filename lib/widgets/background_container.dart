
import 'package:flutter/material.dart';

class BackgroundContainer extends StatelessWidget {
  final String image;
  final Widget child;

  const BackgroundContainer({
    super.key,
    required this.image,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage(image),
          fit: BoxFit.cover,
        ),
      ),
      child: Container(
        color: Colors.black.withOpacity(0.45),
        child: child,
      ),
    );
  }
}
