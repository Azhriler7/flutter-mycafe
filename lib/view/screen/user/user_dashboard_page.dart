import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mycafe/controller/auth_controller.dart';
import 'package:mycafe/controller/cart_controller.dart';
import 'package:mycafe/controller/menu_controller.dart';
import 'package:mycafe/controller/pesanan_controller.dart';
import 'package:mycafe/model/menu_model.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:mycafe/view/screen/auth/auth_wrapper.dart';
import 'package:mycafe/view/screen/user/user_profile_page.dart';

class UserDashboardPage extends StatefulWidget {
  const UserDashboardPage({super.key});

  @override
  State<UserDashboardPage> createState() => _UserDashboardPageState();
}

class _UserDashboardPageState extends State<UserDashboardPage> {
  final _noMejaController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _noMejaController.dispose();
    super.dispose();
  }

  // Tampilkan dialog konfirmasi pesanan
  void _showPlaceOrderDialog(BuildContext context) {
    final cartController = Provider.of<CartController>(context, listen: false);
    if (cartController.items.isEmpty) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2C2C2C),
        title: const Text('Konfirmasi Pesanan', style: TextStyle(color: Colors.white)),
        content: Form(
          key: _formKey,
          child: TextFormField(
            controller: _noMejaController,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              labelText: 'Nomor Meja',
              labelStyle: TextStyle(color: Colors.white70),
            ),
            validator: (value) => (value == null || value.isEmpty) ? 'Nomor meja tidak boleh kosong' : null,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Batal', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () => _placeOrder(context),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: const Text('Pesan Sekarang'),
          ),
        ],
      ),
    );
  }

  // Proses pemesanan ke Firestore
  Future<void> _placeOrder(BuildContext context) async {
    if (!_formKey.currentState!.validate()) return;

    // Capture the context before the async gap
    final navigator = Navigator.of(context);
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    final cartController = Provider.of<CartController>(context, listen: false);
    final orderController = Provider.of<PesananController>(context, listen: false);
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
        _noMejaController.clear();
        navigator.pop();
        scaffoldMessenger.showSnackBar(
          const SnackBar(content: Text('Pesanan berhasil dibuat!'), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (mounted) {
        navigator.pop();
        scaffoldMessenger.showSnackBar(
          SnackBar(content: Text('Gagal membuat pesanan: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final menuController = context.watch<CafeMenuController>();
    final cartController = context.watch<CartController>();
    final currencyFormatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      appBar: AppBar(
        title: const Text('My Cafe', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF1A1A1A),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            onPressed: () async {
              final authController = Provider.of<AuthController>(context, listen: false);
              await authController.signOut();
              
              Get.offAll(() => const AuthWrapper());
            },
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
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
                'Menu User', 
                style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home_filled, color: Colors.white70),
              title: const Text('Dashboard', style: TextStyle(color: Colors.white)),
              onTap: () {
                Get.back();
              },
            ),
            ListTile(
              leading: const Icon(Icons.person, color: Colors.white70),
              title: const Text('Profil', style: TextStyle(color: Colors.white)),
              onTap: () {
                Get.back();
                Get.to(() => const UserProfilePage());
              },
            ),
            const Divider(color: Colors.white24),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.white70),
              title: const Text('Logout', style: TextStyle(color: Colors.white)),
              onTap: () async {
                final authController = Provider.of<AuthController>(context, listen: false);
                await authController.signOut();
                
                Get.offAll(() => const AuthWrapper());
              },
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<List<MenuModel>>(
              stream: menuController.getMenusStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('Tidak ada menu tersedia.', style: TextStyle(color: Colors.white70)));
                }

                final menuItems = snapshot.data!;
                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: menuItems.length,
                  itemBuilder: (context, index) {
                    final menu = menuItems[index];
                    return Card(
                      color: const Color(0xFF2C2C2C),
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        title: Text(menu.namaMenu, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        subtitle: Text(currencyFormatter.format(menu.harga), style: const TextStyle(color: Colors.white70)),
                        trailing: IconButton(
                          icon: const Icon(Icons.add_shopping_cart, color: Colors.green),
                          onPressed: () => cartController.addToCart(menu),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          
          if (cartController.items.isNotEmpty)
            Card(
              margin: EdgeInsets.zero,
              color: const Color(0xFF2C2C2C),
              shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    SizedBox(
                      height: 120, // Batasi tinggi daftar keranjang
                      child: ListView.builder(
                        itemCount: cartController.items.length,
                        itemBuilder: (context, index) {
                          final cartItem = cartController.items[index];
                          return ListTile(
                            dense: true,
                            title: Text(cartItem.menu.namaMenu, style: const TextStyle(color: Colors.white)),
                            subtitle: Text(currencyFormatter.format(cartItem.menu.harga), style: const TextStyle(color: Colors.white70)),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(onPressed: () => cartController.decrementQuantity(cartItem), icon: const Icon(Icons.remove, color: Colors.white70)),
                                Text(cartItem.quantity.toString(), style: const TextStyle(color: Colors.white, fontSize: 16)),
                                IconButton(onPressed: () => cartController.incrementQuantity(cartItem), icon: const Icon(Icons.add, color: Colors.white70)),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                    const Divider(color: Colors.white24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Total: ${currencyFormatter.format(cartController.totalPrice)}', style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                        ElevatedButton(
                          onPressed: () => _showPlaceOrderDialog(context),
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                          child: const Text('Pesan'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}