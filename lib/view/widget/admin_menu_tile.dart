import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AdminMenuTile extends StatelessWidget {
  final String namaMenu;
  final int harga;
  final bool isChecked;
  final Function(bool?) onCheckboxChanged;
  final VoidCallback onEditPressed;

  const AdminMenuTile({
    super.key,
    required this.namaMenu,
    required this.harga,
    required this.isChecked,
    required this.onCheckboxChanged,
    required this.onEditPressed,
  });

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    final formattedHarga = currencyFormatter.format(harga);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      elevation: 4,
      color: const Color(0xFF2A2A2A),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: Colors.grey,
          width: 1,
        ),
      ),
      child: ListTile(
        leading: Checkbox(
          value: isChecked,
          onChanged: onCheckboxChanged,
          activeColor: Colors.blue,
          checkColor: Colors.white,
          side: const BorderSide(color: Colors.grey),
        ),
        title: Text(
          namaMenu, 
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontSize: 16,
          ),
        ),
        subtitle: Text(
          formattedHarga,
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 14,
          ),
        ),
        trailing: TextButton(
          onPressed: onEditPressed,
          style: TextButton.styleFrom(
            foregroundColor: Colors.blue,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          ),
          child: const Text(
            'Edit',
            style: TextStyle(
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}