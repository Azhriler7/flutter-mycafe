import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'primary_button.dart';

class BottomSummaryBar extends StatelessWidget {
  final int total;
  final String buttonText;
  final VoidCallback onButtonPressed;
  final bool isLoading;

  const BottomSummaryBar({
    super.key,
    required this.total,
    required this.buttonText,
    required this.onButtonPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    final formattedTotal = currencyFormatter.format(total);

    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A2A),
        boxShadow: [
          BoxShadow(
            color: Colors.black,
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
        border: Border(
          top: BorderSide(
            color: Colors.grey,
            width: 1,
          ),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total:',
                style: TextStyle(
                  fontSize: 18, 
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
              Text(
                formattedTotal,
                style: const TextStyle(
                  fontSize: 20, 
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          PrimaryButton(
            text: buttonText,
            onPressed: onButtonPressed,
            isLoading: isLoading,
          ),
        ],
      ),
    );
  }
}