import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'primary_button.dart';

class BottomSummaryBar extends StatelessWidget {
  final double total;
  final String buttonText;
  final VoidCallback? onButtonPressed;
  final bool isLoading;
  final int? totalItems;
  final IconData? buttonIcon;

  const BottomSummaryBar({
    super.key,
    required this.total,
    required this.buttonText,
    this.onButtonPressed,
    this.isLoading = false,
    this.totalItems,
    this.buttonIcon,
  });

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    return Container(
      decoration: const BoxDecoration(
        color: Color.fromARGB(255, 230, 217, 209),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 255, 248, 240),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  if (totalItems != null) ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Total Item:',
                          style: TextStyle(color: Color.fromARGB(255, 78, 52, 46), fontSize: 14),
                        ),
                        Text(
                          '$totalItems item',
                          style: const TextStyle(color: Color.fromARGB(255, 78, 52, 46), fontSize: 14),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                  ],
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Total Harga:',
                        style: TextStyle(
                          color: Color.fromARGB(255, 78, 52, 46),
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        currencyFormatter.format(total),
                        style: const TextStyle(
                          color: Color.fromARGB(255, 78, 52, 46),
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            
            SizedBox(
              width: double.infinity,
              height: 50,
              child: buttonIcon != null 
                ? ElevatedButton.icon(
                    onPressed: isLoading ? null : onButtonPressed,
                    icon: isLoading 
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Icon(buttonIcon, size: 20),
                    label: Text(
                      isLoading ? 'Memproses...' : buttonText,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 78, 52, 46),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                      elevation: 2,
                    ),
                  )
                : PrimaryButton(
                    text: buttonText,
                    onPressed: onButtonPressed,
                    isLoading: isLoading,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}