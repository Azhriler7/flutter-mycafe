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
import 'package:mycafe/view/screen/user/user_cart_page.dart';
import 'package:mycafe/view/screen/user/user_payment_page.dart';

class UserDashboardPage extends StatefulWidget {
  const UserDashboardPage({super.key});

  @override
  State<UserDashboardPage> createState() => _UserDashboardPageState();
}

class _UserDashboardPageState extends State<UserDashboardPage> {
  final _noMejaController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  // Dummy menu items for testing
  final List<MenuModel> _dummyMenus = [
    MenuModel(
      id: 'dummy_1',
      namaMenu: 'Nasi Goreng Special',
      harga: 25000,
      kategori: 'makanan',
      isTersedia: true,
    ),
    MenuModel(
      id: 'dummy_2',
      namaMenu: 'Es Teh Manis',
      harga: 8000,
      kategori: 'minuman',
      isTersedia: true,
    ),
  ];

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

                // Use dummy data if no data from Firestore or if data is empty
                List<MenuModel> menuItems;
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  menuItems = _dummyMenus;
                } else {
                  // Combine Firestore data with dummy data
                  menuItems = [...snapshot.data!, ..._dummyMenus];
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: menuItems.length,
                  itemBuilder: (context, index) {
                    final menu = menuItems[index];
                    final isDummy = menu.id.startsWith('dummy_');
                    
                    return Card(
                      color: const Color(0xFF2C2C2C),
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: isDummy 
                          ? Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: const Color(0xFF4CAF50).withOpacity(0.2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.fastfood,
                                color: Color(0xFF4CAF50),
                                size: 20,
                              ),
                            )
                          : null,
                        title: Row(
                          children: [
                            Expanded(
                              child: Text(
                                menu.namaMenu, 
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)
                              ),
                            ),
                            if (isDummy)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.orange.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: Colors.orange, width: 1),
                                ),
                                child: const Text(
                                  'DEMO',
                                  style: TextStyle(
                                    color: Colors.orange,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              currencyFormatter.format(menu.harga), 
                              style: const TextStyle(color: Colors.white70)
                            ),
                            Text(
                              'Kategori: ${menu.kategori}',
                              style: const TextStyle(color: Colors.white54, fontSize: 12),
                            ),
                          ],
                        ),
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
      floatingActionButton: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF66BB6A),
              Color(0xFF4CAF50),
            ],
          ),
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF4CAF50).withOpacity(0.4),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(30),
                onTap: () => Get.to(() => const CartPage()),
                child: const Center(
                  child: Icon(
                    Icons.shopping_cart_outlined,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
              ),
            ),
            if (cartController.totalItems > 0)
              Positioned(
                right: 4,
                top: 4,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 20,
                    minHeight: 20,
                  ),
                  child: Text(
                    cartController.totalItems > 99 ? '99+' : cartController.totalItems.toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}