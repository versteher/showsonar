import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class BrandedLoadingIndicator extends StatelessWidget {
  final double width;
  final double height;
  final String? message;

  const BrandedLoadingIndicator({
    super.key,
    this.width = 150,
    this.height = 150,
    this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Lottie.asset(
            'assets/animations/loading.json',
            width: width,
            height: height,
            fit: BoxFit.contain,
          ),
          if (message != null) ...[
            const SizedBox(height: 16),
            Text(
              message!,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.primary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}
