import 'package:flutter/material.dart';

enum ButtonType { primary, secondary }

class PrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final ButtonType buttonType; 

  const PrimaryButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.buttonType = ButtonType.primary, 
  });

  @override
  Widget build(BuildContext context) {
    const Color brownColor = Color(0xFF4E342E);
    const Color lightBackgroundColor = Color(0xFFFFF8F0); 

    final loadingWidget = const SizedBox(
      width: 24,
      height: 24,
      child: CircularProgressIndicator(
        color: Colors.white,
        strokeWidth: 2,
      ),
    );

    final secondaryLoadingWidget = const SizedBox(
      width: 24,
      height: 24,
      child: CircularProgressIndicator(
        color: brownColor,
        strokeWidth: 2,
      ),
    );

    final textWidget = Text(
      text,
      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
    );

    if (buttonType == ButtonType.secondary) {
      return SizedBox(
        width: double.infinity,
        height: 50,
        child: OutlinedButton(
          onPressed: isLoading ? null : onPressed,
          style: OutlinedButton.styleFrom(
            backgroundColor: lightBackgroundColor,
            foregroundColor: brownColor,
            side: const BorderSide(color: brownColor, width: 2), 
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: isLoading ? secondaryLoadingWidget : textWidget,
        ),
      );
    }

    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: brownColor, 
          foregroundColor: Colors.white, 
          disabledBackgroundColor: Colors.grey.shade400,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
        ),
        child: isLoading ? loadingWidget : textWidget,
      ),
    );
  }
}
