import 'package:flutter/material.dart';
import 'package:mycafe/controller/auth_controller.dart';
import 'package:mycafe/controller/pesanan_controller.dart';
import 'package:mycafe/model/pesanan_model.dart';
import 'package:mycafe/view/screen/admin/admin_profile_page.dart';
import 'package:mycafe/view/screen/admin/detail_pesanan_page.dart';
import 'package:mycafe/view/screen/admin/manajemen_menu_page.dart';
import 'package:mycafe/view/widget/order_card.dart';
import 'package:provider/provider.dart';
import 'package:get/get.dart';
import 'package:mycafe/view/screen/auth/auth_wrapper.dart';

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  late Stream<List<PesananModel>> _ordersStream;
  bool _showAllOrders = false;

  @override
  void initState() {
    super.initState();
    _initOrdersStream();
  }

  // Inisialisasi stream untuk pesanan
  void _initOrdersStream() {
    final orderController = Provider.of<PesananController>(context, listen: false);
    setState(() {
      if (_showAllOrders) {
        _ordersStream = orderController.getAllOrdersStream();
      } else {
        _ordersStream = orderController.getNewOrdersStream();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: const Color(0xFF1A1A1A),
        elevation: 0,
        title: const Text(
          'Dashboard - Admin', 
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)
        ),
        actions: [
          IconButton(
            icon: Icon(_showAllOrders ? Icons.filter_list : Icons.filter_list_off),
            onPressed: () {
              setState(() {
                _showAllOrders = !_showAllOrders;
                _initOrdersStream();
              });
            },
            tooltip: _showAllOrders ? 'Show New Orders Only' : 'Show All Orders',
          ),
        ],
      ),
      drawer: Drawer(
        backgroundColor: const Color(0xFF2C2C2C),
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Color(0xFF4CAF50)),
              child: Text(
                'Menu Admin', 
                style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home_filled, color: Colors.white70),
              title: const Text('Dashboard', style: TextStyle(color: Colors.white)),
              onTap: () {
                Get.back();
                Get.to(() => const AdminDashboardPage());
              },
            ),
            ListTile(
              leading: const Icon(Icons.restaurant_menu, color: Colors.white70),
              title: const Text('Manajemen Menu', style: TextStyle(color: Colors.white)),
              onTap: () {
                Get.back();
                Get.to(() => const ManajemenMenuPage());
              },
            ),
            ListTile(
              leading: const Icon(Icons.person, color: Colors.white70),
              title: const Text('Profil', style: TextStyle(color: Colors.white)),
              onTap: () {
                Get.back();
                Get.to(() => const AdminProfilePage());
              },
            ),
            const Divider(color: Colors.white24),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.white70),
              title: const Text('Logout', style: TextStyle(color: Colors.white)),
              onTap: () async {
                final authController = Provider.of<AuthController>(context, listen: false);
                await authController.signOut();
                
                // Perintah ini melakukan hal yang sama: membuka halaman baru
                // dan menghapus semua halaman sebelumnya.
                Get.offAll(() => const AuthWrapper());
              },
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(8.0),
              child: Text(
                _showAllOrders ? 'Menampilkan: Semua Pesanan' : 'Menampilkan: Pesanan Baru',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                  color: _showAllOrders ? Colors.white : Colors.green,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Expanded(
              child: StreamBuilder<List<PesananModel>>(
                stream: _ordersStream,
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
                            style: const TextStyle(color: Colors.white70, fontSize: 12),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () => _initOrdersStream(),
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
                          const Icon(Icons.inbox, color: Colors.white70, size: 64),
                          const SizedBox(height: 16),
                          Text(
                            _showAllOrders ? 'Tidak ada pesanan.' : 'Tidak ada pesanan baru.',
                            style: const TextStyle(color: Colors.white70, fontSize: 18),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () {
                              setState(() {
                                _showAllOrders = true;
                                _initOrdersStream();
                              });
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                            ),
                            child: const Text('Lihat Semua Pesanan'),
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
              ),
            ),
          ],
        ),
      ),
    );
  }
}