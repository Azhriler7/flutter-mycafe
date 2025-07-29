import 'package:flutter/material.dart';
import 'package:mycafe/controller/pesanan_controller.dart';
import 'package:mycafe/model/pesanan_model.dart';
import 'package:mycafe/view/screen/admin/detail_pesanan_page.dart';
import 'package:mycafe/view/widget/order_card.dart';
import 'package:get/get.dart';
import 'package:mycafe/view/widget/drawer.dart';

class AdminDashboardPage extends StatelessWidget {
  const AdminDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final RxBool showCompletedOrders = false.obs;
    
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 248, 240),
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: const Color.fromARGB(255, 78, 52, 46),
        elevation: 0,
        title: const Text(
          'Dashboard - Admin', 
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)
        ),
        actions: [
          Obx(() => IconButton(
            icon: Icon(showCompletedOrders.value ? Icons.assignment_turned_in : Icons.assignment),
            onPressed: () {
              showCompletedOrders.value = !showCompletedOrders.value;
            },
            tooltip: showCompletedOrders.value ? 'Show New Orders' : 'Show Completed Orders',
          )),
        ],
      ),
      drawer: const AppDrawer(userRole: UserRole.admin),

      body: SafeArea(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(8.0),
              child: Obx(() => Text(
                showCompletedOrders.value ? 'Menampilkan: Pesanan Selesai' : 'Menampilkan: Pesanan Baru',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 20,
                  color: Color.fromARGB(255, 78, 52, 46),
                  fontWeight: FontWeight.bold,
                ),
              )),
            ),
            Expanded(
              child: Obx(() {
                final orderController = Get.find<PesananController>();
                final ordersStream = showCompletedOrders.value 
                    ? orderController.getCompletedOrdersStream() 
                    : orderController.getNewOrdersStream();
                
                return StreamBuilder<List<PesananModel>>(
                  stream: ordersStream,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFF4CAF50),
                        ),
                      );
                    }
                    
                    if (snapshot.hasError) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.error, color: Colors.red, size: 64),
                            const SizedBox(height: 16),
                            const Text(
                              'Terjadi kesalahan saat memuat data',
                              style: TextStyle(color: Colors.red, fontSize: 18),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Error: ${snapshot.error}',
                              style: const TextStyle(color: Color.fromARGB(255, 78, 52, 46), fontSize: 12),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: () {
                                showCompletedOrders.value = !showCompletedOrders.value;
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF4CAF50),
                              ),
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      );
                    }
                    
                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.inbox, color: Color.fromARGB(255, 78, 52, 46), size: 64),
                            const SizedBox(height: 16),
                            Text(
                              showCompletedOrders.value ? 'Tidak ada pesanan selesai.' : 'Tidak ada pesanan baru.',
                              style: const TextStyle(color: Color.fromARGB(255, 78, 52, 46), fontSize: 18),
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: () {
                                showCompletedOrders.value = !showCompletedOrders.value;
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color.fromARGB(255, 78, 52, 46),
                                foregroundColor: Colors.white,
                              ),
                              child: Text(showCompletedOrders.value ? 'Lihat Pesanan Baru' : 'Lihat Pesanan Selesai'),
                            ),
                          ],
                        ),
                      );
                    }

                    final orders = snapshot.data!;

                    return ListView.builder(
                      padding: const EdgeInsets.all(16.0),
                      itemCount: orders.length,
                      itemBuilder: (context, index) {
                        final order = orders[index];
                        
                        return OrderCard(
                          noMeja: order.noMeja,
                          onLihatDetailPressed: () {
                            Get.to(() => DetailPesananPage(order: order));
                          },
                        );
                      },
                    );
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}