import 'package:flutter/material.dart';
import 'package:mycafe/controller/pesanan_controller.dart';
import 'package:mycafe/model/pesanan_model.dart';
import 'package:mycafe/view/widget/confirmation_dialog.dart';
import 'package:mycafe/view/widget/primary_button.dart';
import 'package:mycafe/view/screen/admin/admin_dashboard_page.dart';
import 'package:intl/intl.dart';
import 'package:get/get.dart';

class DetailPesananPage extends StatefulWidget {
  final PesananModel order;

  const DetailPesananPage({
    super.key,
    required this.order,
  });

  @override
  State<DetailPesananPage> createState() => _DetailPesananPageState();
}

class _DetailPesananPageState extends State<DetailPesananPage> {
  bool _showConfirmation = false;

  // Tampilkan daftar item
  Widget _buildItemsList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: widget.order.items.map((item) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Text(
            '- ${item.namaMenu} x ${item.jumlah}',
            style: const TextStyle(color: Color.fromARGB(255, 78, 52, 46), fontSize: 18),
          ),
        );
      }).toList(),
    );
  }

  // Selesaikan pesanan
  void _completeOrder() {
    final pesananController = Get.find<PesananController>();
    pesananController.updateOrderStatus(docId: widget.order.id, newStatus: 'selesai');
    
    Get.off(() => const AdminDashboardPage());
    
    Get.snackbar(
      'Berhasil',
      'Pesanan telah diselesaikan',
      backgroundColor: Colors.green,
      colorText: Colors.white,
    );
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    final formattedTotal = currencyFormatter.format(widget.order.totalHarga);

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 248, 240),
      appBar: AppBar(
        title: const Text(
          'Detail Pesanan', 
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)
        ),
        backgroundColor: const Color.fromARGB(255, 78, 52, 46),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'No Meja: ${widget.order.noMeja}',
                        style: const TextStyle(
                          color: Color.fromARGB(255, 78, 52, 46), 
                          fontSize: 22, 
                          fontWeight: FontWeight.bold
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Pemesan: ${widget.order.namaPemesan}',
                        style: const TextStyle(
                          color: Color.fromARGB(255, 78, 52, 46), 
                          fontSize: 16
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: widget.order.statusPesanan == 'selesai' 
                              ? Colors.green 
                              : Colors.orange,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          'Status: ${widget.order.statusPesanan}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16.0),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: const Color.fromARGB(255, 78, 52, 46),
                            width: 1,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                             const Text(
                              'Pesanan:',
                              style: TextStyle(
                                color: Color.fromARGB(255, 78, 52, 46), 
                                fontSize: 22, 
                                fontWeight: FontWeight.bold
                              ),
                            ),
                            const SizedBox(height: 12),
                            _buildItemsList(),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 24),

                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: const Color.fromARGB(255, 78, 52, 46),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Total', 
                              style: TextStyle(
                                color: Color.fromARGB(255, 78, 52, 46), 
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              )
                            ),
                            Text(
                              formattedTotal,
                              style: const TextStyle(
                                color: Color.fromARGB(255, 78, 52, 46), 
                                fontSize: 22, 
                                fontWeight: FontWeight.bold
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
              
              // Tombol tetap di bawah
              if (widget.order.statusPesanan != 'selesai')
                Container(
                  padding: const EdgeInsets.all(24.0),
                  child: PrimaryButton(
                    text: 'Pesanan Selesai',
                    onPressed: () {
                      setState(() {
                        _showConfirmation = true;
                      });
                    },
                  ),
                ),
            ],
          ),
          if (_showConfirmation)
            Positioned.fill(
              child: Container(
                color: Colors.black54,
                child: Center(
                  child: ConfirmationDialog(
                    title: 'Konfirmasi Pesanan Selesai',
                    message: 'Apakah Anda yakin pesanan untuk meja ${widget.order.noMeja} sudah selesai?',
                    icon: Icons.check_circle,
                    confirmText: 'Selesai',
                    cancelText: 'Batal',
                    confirmColor: Colors.green,
                    onConfirm: _completeOrder,
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
}