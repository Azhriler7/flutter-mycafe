import 'package:flutter/material.dart';
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
    final menuController = Get.find<CafeMenuController>();
    final formatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 248, 240),
      floatingActionButton: Obx(() {
        final cartController = Get.find<CartController>();
        final totalItems = cartController.totalItems;
        
        return Stack(
          children: [
            FloatingActionButton(
              backgroundColor: const Color.fromARGB(255, 78, 52, 46),
              onPressed: () => Get.to(() => const CartPage()),
              shape: const CircleBorder(),
              child: const Icon(Icons.shopping_cart, color: Colors.white),
            ),
            if (totalItems > 0)
              Positioned(
                right: 0,
                top: 0,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 20,
                    minHeight: 20,
                  ),
                  child: Text(
                    '$totalItems',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        );
      }),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              color: const Color.fromARGB(255, 78, 52, 46),
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
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(
                      child: Text(
                        'Belum ada menu',
                        style: TextStyle(color: Color.fromARGB(255, 78, 52, 46)),
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
                      return Obx(() {
                        final cartController = Get.find<CartController>();
                        final qty = cartController.getQuantity(menu);

                          return Container(
                            padding: const EdgeInsets.symmetric(
                              vertical: 12,
                              horizontal: 12,
                            ),
                            decoration: BoxDecoration(
                              color: const Color.fromARGB(255, 230, 217, 209),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        menu.namaMenu,
                                        style: const TextStyle(
                                          color: Color.fromARGB(255, 78, 52, 46),
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        formatter.format(menu.harga),
                                        style: const TextStyle(
                                          color: Color.fromARGB(255, 78, 52, 46),
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
                                          color: Color.fromARGB(255, 78, 52, 46),
                                        ),
                                      )
                                    : Row(
                                        children: [
                                          IconButton(
                                            onPressed: () => cartController
                                                .decrementQuantityByMenu(menu),
                                            icon: const Icon(
                                              Icons.remove_circle_outline,
                                              color: Color.fromARGB(255, 78, 52, 46),
                                            ),
                                          ),
                                          Text(
                                            '$qty',
                                            style: const TextStyle(
                                              color: Color.fromARGB(255, 78, 52, 46),
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          IconButton(
                                            onPressed: () => cartController
                                                .incrementQuantityByMenu(menu),
                                            icon: const Icon(
                                              Icons.add_circle_outline,
                                              color: Color.fromARGB(255, 78, 52, 46),
                                            ),
                                          ),
                                        ],
                                      ),
                              ],
                            ),
                          );
                        });
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
