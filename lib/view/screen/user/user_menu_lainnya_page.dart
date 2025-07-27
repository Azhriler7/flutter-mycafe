import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:get/get.dart';

import 'package:mycafe/controller/cart_controller.dart';
import 'package:mycafe/controller/menu_controller.dart';
import 'package:mycafe/model/menu_model.dart';
import 'package:mycafe/view/screen/user/user_cart_page.dart';

class UserMenuLainnyaPage extends StatelessWidget {
  const UserMenuLainnyaPage({super.key});

  @override
  Widget build(BuildContext context) {
    final menuController = context.watch<CafeMenuController>();
    final cartController = context.watch<CartController>();
    final formatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    return Scaffold(
      backgroundColor: const Color(0xFFFFF7F1),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.green,
        onPressed: () => Get.to(() => const CartPage()),
        shape: const CircleBorder(),
        child: const Icon(Icons.shopping_cart),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // AppBar Custom Floating
            Container(
              color: const Color(0xFFA65A3D),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Menu Lainnya',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),
            Expanded(
              child: StreamBuilder<List<MenuModel>>(
                stream: menuController.getMenusStream(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting)
                    return const Center(child: CircularProgressIndicator());

                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(
                      child: Text(
                        'Belum ada menu',
                        style: TextStyle(color: Colors.black54),
                      ),
                    );
                  }

                  final menus = snapshot.data!;
                  return ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: menus.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final menu = menus[index];
                      final qty = cartController.getQuantity(menu);

                      return Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 12,
                          horizontal: 12,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE6D9D1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    menu.namaMenu,
                                    style: const TextStyle(
                                      color: Colors.black,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    formatter.format(menu.harga),
                                    style: const TextStyle(
                                      color: Colors.black87,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            qty == 0
                                ? IconButton(
                                    onPressed: () =>
                                        cartController.addToCart(menu),
                                    icon: const Icon(
                                      Icons.add_circle_outline,
                                      color: Colors.green,
                                    ),
                                  )
                                : Row(
                                    children: [
                                      IconButton(
                                        onPressed: () => cartController
                                            .decrementQuantityByMenu(menu),
                                        icon: const Icon(
                                          Icons.remove_circle_outline,
                                          color: Colors.black87,
                                        ),
                                      ),
                                      Text(
                                        '$qty',
                                        style: const TextStyle(
                                          color: Colors.black87,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      IconButton(
                                        onPressed: () => cartController
                                            .incrementQuantityByMenu(menu),
                                        icon: const Icon(
                                          Icons.add_circle_outline,
                                          color: Colors.black87,
                                        ),
                                      ),
                                    ],
                                  ),
                          ],
                        ),
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
