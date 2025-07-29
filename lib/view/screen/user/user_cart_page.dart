import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:mycafe/controller/cart_controller.dart';
import 'package:mycafe/view/screen/user/user_payment_page.dart';
import 'package:mycafe/view/widget/confirmation_dialog.dart';
import 'package:mycafe/view/widget/bottom_summary_bar.dart';

class CartPage extends StatelessWidget {
  const CartPage({super.key});

  @override
  Widget build(BuildContext context) {
    final cartController = Get.find<CartController>();
    // Format mata uang
    final currencyFormatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 248, 240),
      appBar: AppBar(
        title: const Text('Keranjang', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: const Color.fromARGB(255, 78, 52, 46),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        actions: [
          Obx(() {
            if (cartController.items.isNotEmpty) {
              return Tooltip(
              message: 'Kosongkan keranjang',
              textStyle: const TextStyle(color: Colors.white),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(4),
              ),
              child: IconButton(
                icon: const Icon(Icons.delete_sweep, color: Colors.red),
                onPressed: () => _showClearCartDialog(context, cartController),
              ),
              );
            }
            return const SizedBox.shrink();
          }),
        ],
      ),
      body: Obx(() => cartController.items.isEmpty
          ? _buildEmptyCart()
          : Column(
              children: [
                Expanded(
                  child: _buildCartItems(cartController, currencyFormatter),
                ),
                BottomSummaryBar(
                  total: cartController.totalPrice,
                  totalItems: cartController.totalItems,
                  buttonText: 'Lanjut ke Pembayaran',
                  buttonIcon: Icons.payment,
                  onButtonPressed: () => Get.to(() => const PaymentPage()),
                ),
              ],
            )),
    );
  }

  // Widget keranjang kosong
  Widget _buildEmptyCart() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 230, 217, 209),
              borderRadius: BorderRadius.circular(60),
            ),
            child: Icon(
              Icons.shopping_cart_outlined,
              size: 60,
              color: const Color.fromARGB(255, 78, 52, 46),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Keranjang Kosong',
            style: TextStyle(
              color: Color.fromARGB(255, 78, 52, 46),
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Tambahkan beberapa item ke keranjang Anda',
            style: TextStyle(
              color: Color.fromARGB(255, 78, 52, 46),
              fontSize: 16,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () => Get.back(),
            icon: const Icon(Icons.restaurant_menu),
            label: const Text('Lihat Menu'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color.fromARGB(255, 78, 52, 46),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Widget daftar item keranjang
  Widget _buildCartItems(CartController cartController, NumberFormat currencyFormatter) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: cartController.items.length,
      itemBuilder: (context, index) {
        final cartItem = cartController.items[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: const Color.fromARGB(255, 230, 217, 209),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Item Image Placeholder
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 78, 52, 46),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.fastfood,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                
                // Item Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        cartItem.menu.namaMenu,
                        style: const TextStyle(
                          color: Color.fromARGB(255, 78, 52, 46),
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        currencyFormatter.format(cartItem.menu.harga),
                        style: const TextStyle(
                          color: Color.fromARGB(255, 78, 52, 46),
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Subtotal: ${currencyFormatter.format(cartItem.menu.harga * cartItem.quantity)}',
                        style: const TextStyle(
                          color: Color.fromARGB(255, 78, 52, 46),
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Quantity Controls
                Container(
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 230, 217, 209),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        onPressed: () => cartController.decrementQuantity(cartItem),
                        icon: const Icon(Icons.remove, color: Color.fromARGB(255, 78, 52, 46), size: 18),
                        constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Text(
                          cartItem.quantity.toString(),
                          style: const TextStyle(
                            color: Color.fromARGB(255, 78, 52, 46),
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () => cartController.incrementQuantity(cartItem),
                        icon: const Icon(Icons.add, color: Color.fromARGB(255, 78, 52, 46), size: 18),
                        constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // pop up kosongkan keranjang
  void _showClearCartDialog(BuildContext context, CartController cartController) {
    showDialog(
      context: context,
      builder: (context) => ConfirmationDialog(
        title: 'Kosongkan Keranjang?',
        message: 'Semua item di keranjang akan dihapus. Tindakan ini tidak dapat dibatalkan.',
        icon: Icons.delete_sweep,
        confirmText: 'Kosongkan',
        cancelText: 'Batal',
        confirmColor: Colors.red,
        onCancel: () => Navigator.of(context).pop(),
        onConfirm: () {
          cartController.clearCart();
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Keranjang berhasil dikosongkan'),
              backgroundColor: Color.fromARGB(255, 78, 52, 46),
            ),
          );
        },
      ),
    );
  }
}