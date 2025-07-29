import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mycafe/controller/cart_controller.dart';
import 'package:mycafe/controller/pesanan_controller.dart';
import 'package:mycafe/view/widget/confirmation_dialog.dart';
import 'package:mycafe/view/widget/bottom_summary_bar.dart';

class PaymentPage extends StatefulWidget {
  const PaymentPage({super.key});

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  final _noMejaController = TextEditingController();
  final _resiController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isProcessing = false;
  bool _showConfirmation = false;

  @override
  void dispose() {
    _noMejaController.dispose();
    _resiController.dispose();
    super.dispose();
  }

  // Proses pembayaran
  Future<void> _processPayment() async {
    setState(() {
      _isProcessing = true;
    });

    final cartController = Get.find<CartController>();
    final orderController = Get.find<PesananController>();
    final User? currentUser = FirebaseAuth.instance.currentUser;
    final String namaPemesan = currentUser?.displayName ?? currentUser?.email ?? 'User';

    try {
      final itemsForFirestore = cartController.items.map((item) => {
        'namaMenu': item.menu.namaMenu,
        'harga': item.menu.harga,
        'jumlah': item.quantity,
      }).toList();

      await orderController.placeOrder(
        userId: currentUser!.uid,
        namaPemesan: namaPemesan,
        noMeja: _noMejaController.text,
        items: itemsForFirestore,
        totalHarga: cartController.totalPrice,
      );

      if (mounted) {
        cartController.clearCart();
        setState(() {
          _showConfirmation = false;
        });
        _showSuccessDialog();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _showConfirmation = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal memproses pembayaran: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  // Konfirmasi pembayaran
  void _showPaymentConfirmation() {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() {
      _showConfirmation = true;
    });
  }

  // pop up sukses pembayaran
  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: const Color.fromARGB(255, 255, 248, 240),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 78, 52, 46),
                borderRadius: BorderRadius.circular(40),
              ),
              child: const Icon(
                Icons.check,
                color: Colors.white,
                size: 40,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Pembayaran Berhasil!',
              style: TextStyle(
                color: Color.fromARGB(255, 78, 52, 46),
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            const Text(
              'Pesanan Anda sedang diproses.\nTerima kasih telah berbelanja!',
              style: TextStyle(color: Color.fromARGB(255, 78, 52, 46), fontSize: 14),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Get.back();
                  Get.back();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 78, 52, 46),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('Kembali ke Menu', style: TextStyle(color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cartController = Get.find<CartController>();
    final currencyFormatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 248, 240),
      appBar: AppBar(
        title: const Text('Pembayaran', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: const Color.fromARGB(255, 78, 52, 46),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Get.back(),
        ),
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildQRSection(),
                          const SizedBox(height: 24),

                          _buildPaymentForm(),
                          const SizedBox(height: 24),

                          _buildOrderSummary(cartController, currencyFormatter),
                          const SizedBox(height: 100),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              BottomSummaryBar(
                total: cartController.totalPrice,
                buttonText: 'Konfirmasi Pembayaran',
                isLoading: _isProcessing,
                onButtonPressed: _isProcessing ? null : _showPaymentConfirmation,
              ),
            ],
          ),
          if (_showConfirmation)
            Positioned.fill(
              child: Container(
                color: Colors.black54,
                child: Center(
                  child: ConfirmationDialog(
                    title: 'Konfirmasi Pembayaran',
                    message: 'Apakah Anda yakin ingin memproses pembayaran untuk meja ${_noMejaController.text}?\n\nTotal: ${currencyFormatter.format(cartController.totalPrice)}',
                    icon: Icons.payment,
                    confirmText: 'Bayar Sekarang',
                    cancelText: 'Batal',
                    confirmColor: const Color.fromARGB(255, 78, 52, 46),
                    onConfirm: _processPayment,
                    onCancel: () {
                      setState(() {
                        _showConfirmation = false;
                      });
                    },
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // Widget QR
  Widget _buildQRSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 230, 217, 209),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color.fromARGB(255, 78, 52, 46), width: 1),
      ),
      child: Column(
        children: [
          const Text(
            'Scan QR Code untuk Pembayaran',
            style: TextStyle(
              color: Color.fromARGB(255, 78, 52, 46),
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Container(
            width: 180,
            height: 180,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.qr_code,
                    size: 80,
                    color: Color.fromARGB(255, 78, 52, 46),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'QR Image',
                    style: TextStyle(
                      color: Color.fromARGB(255, 78, 52, 46),
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 78, 52, 46),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              'Gunakan aplikasi mobile banking atau e-wallet',
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Widget form pembayaran
  Widget _buildPaymentForm() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 230, 217, 209),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Detail Pembayaran',
            style: TextStyle(
              color: Color.fromARGB(255, 78, 52, 46),
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          
          // Input Resi Pembayaran
          TextFormField(
            controller: _resiController,
            style: const TextStyle(color: Color.fromARGB(255, 78, 52, 46)),
            decoration: InputDecoration(
              labelText: 'Input Resi Pembayaran',
              labelStyle: const TextStyle(color: Color.fromARGB(255, 78, 52, 46)),
              hintText: 'ex: (no resi)',
              hintStyle: const TextStyle(color: Color.fromARGB(255, 120, 90, 85)),
              helperStyle: const TextStyle(color: Color.fromARGB(255, 78, 52, 46), fontSize: 12),
              filled: true,
              fillColor: const Color.fromARGB(255, 255, 248, 240),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color.fromARGB(255, 78, 52, 46)),
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Resi pembayaran tidak boleh kosong';
              }
              return null;
            },
          ),
          
          const SizedBox(height: 16),
          
          // Input Nomor Meja
          TextFormField(
            controller: _noMejaController,
            style: const TextStyle(color: Color.fromARGB(255, 78, 52, 46)),
            decoration: InputDecoration(
              labelText: 'No Meja',
              labelStyle: const TextStyle(color: Color.fromARGB(255, 78, 52, 46)),
              hintText: 'ex: A04',
              hintStyle: const TextStyle(color: Color.fromARGB(255, 120, 90, 85)),
              helperStyle: const TextStyle(color: Color.fromARGB(255, 78, 52, 46), fontSize: 12),
              filled: true,
              fillColor: const Color.fromARGB(255, 255, 248, 240),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color.fromARGB(255, 78, 52, 46)),
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Nomor meja tidak boleh kosong';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  // Widget ringkasan pesanan
  Widget _buildOrderSummary(CartController cartController, NumberFormat currencyFormatter) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 230, 217, 209),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Ringkasan Pesanan',
            style: TextStyle(
              color: Color.fromARGB(255, 78, 52, 46),
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          
          ...cartController.items.map((item) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    '${item.menu.namaMenu} x${item.quantity}',
                    style: const TextStyle(color: Color.fromARGB(255, 78, 52, 46), fontSize: 14),
                  ),
                ),
                Text(
                  currencyFormatter.format(item.menu.harga * item.quantity),
                  style: const TextStyle(color: Color.fromARGB(255, 78, 52, 46), fontSize: 14),
                ),
              ],
            ),
          )),
          
          const Divider(color: Color.fromARGB(255, 78, 52, 46)),
          
          // Total
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total',
                style: TextStyle(
                  color: Color.fromARGB(255, 78, 52, 46),
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                currencyFormatter.format(cartController.totalPrice),
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
    );
  }
}