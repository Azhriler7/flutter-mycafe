import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:mycafe/controller/auth_controller.dart';
import 'package:mycafe/controller/cart_controller.dart';
import 'package:mycafe/controller/menu_controller.dart';
import 'package:mycafe/controller/pesanan_controller.dart';
import 'package:mycafe/model/menu_model.dart';
import 'package:mycafe/view/screen/auth/auth_wrapper.dart';
import 'package:mycafe/view/screen/user/user_menu_lainnya_page.dart';
import 'package:mycafe/view/screen/user/user_profile_page.dart';
import 'package:mycafe/view/screen/user/user_cart_page.dart';

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

  @override
  Widget build(BuildContext context) {
    final menuController = context.watch<CafeMenuController>();
    final cartController = context.watch<CartController>();

    return Scaffold(
      backgroundColor: const Color(0xFFFFF7F1),
      appBar: AppBar(
        backgroundColor: const Color(0xFFA65A3D),
        title: const Text('My Cafe', style: TextStyle(color: Colors.white)),
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: Colors.white),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
      ),
      drawer: Drawer(
        backgroundColor: const Color(0xFF2C2C2C),
        child: ListView(
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Color(0xFF4CAF50)),
              child: Text(
                'Menu User',
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.person, color: Colors.white),
              title: const Text(
                'Profil',
                style: TextStyle(color: Colors.white),
              ),
              onTap: () => Get.to(() => const UserProfilePage()),
            ),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.white),
              title: const Text(
                'Logout',
                style: TextStyle(color: Colors.white),
              ),
              onTap: () async {
                final auth = Provider.of<AuthController>(
                  context,
                  listen: false,
                );
                await auth.signOut();
                Get.offAll(() => const AuthWrapper());
              },
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Center(
              child: Padding(
                padding: EdgeInsets.only(bottom: 12),
                child: Text(
                  'Best Seller!!!',
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            StreamBuilder<List<MenuModel>>(
              stream: menuController.getMenusStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(
                    child: Text(
                      'Menu kosong',
                      style: TextStyle(color: Colors.black54),
                    ),
                  );
                }

                final menus = snapshot.data!.take(4).toList();

                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: menus.length + 1,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemBuilder: (context, index) {
                    if (index == menus.length) {
                      return GestureDetector(
                        onTap: () => Get.to(() => const UserMenuLainnyaPage()),
                        child: Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFFE6D9D1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Center(
                            child: Text(
                              'Menu Lainnya',
                              style: TextStyle(
                                color: Colors.black87,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      );
                    }

                    final menu = menus[index];
                    final qty = cartController.getQuantity(menu);
                    final hasQty = qty > 0;

                    return GestureDetector(
                      onTap: () => cartController.addToCart(menu),
                      child: Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFFE6D9D1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: [
                            Expanded(
                              flex: 8,
                              child: Container(
                                alignment: Alignment.center,
                                child: const Icon(
                                  Icons.fastfood,
                                  color: Colors.brown,
                                  size: 48,
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: hasQty
                                  ? Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        IconButton(
                                          icon: const Icon(
                                            Icons.remove,
                                            color: Colors.black,
                                          ),
                                          onPressed: () => cartController
                                              .decrementQuantityByMenu(menu),
                                        ),
                                        Text(
                                          '$qty',
                                          style: const TextStyle(
                                            color: Colors.black,
                                          ),
                                        ),
                                        IconButton(
                                          icon: const Icon(
                                            Icons.add,
                                            color: Colors.black,
                                          ),
                                          onPressed: () => cartController
                                              .incrementQuantityByMenu(menu),
                                        ),
                                      ],
                                    )
                                  : Center(
                                      child: Text(
                                        menu.namaMenu,
                                        style: const TextStyle(
                                          color: Colors.black,
                                        ),
                                      ),
                                    ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.green,
        onPressed: () {
          Get.to(() => const CartPage());
        },
        shape: const CircleBorder(),
        child: const Icon(Icons.shopping_cart),
      ),
    );
  }
}
