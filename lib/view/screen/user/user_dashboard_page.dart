import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mycafe/view/screen/user/user_menu_lainnya_page.dart';
import 'package:mycafe/view/screen/user/user_cart_page.dart';
import 'package:mycafe/view/widget/drawer.dart';
import 'package:mycafe/view/widget/menu_card.dart';
import 'package:mycafe/controller/cart_controller.dart';

class UserDashboardPage extends StatefulWidget {
  const UserDashboardPage({super.key});

  @override
  State<UserDashboardPage> createState() => _UserDashboardPageState();
}

class _UserDashboardPageState extends State<UserDashboardPage> {
  final _noMejaController = TextEditingController();

  @override
  void dispose() {
    _noMejaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Menu statis best seller
    final List<Map<String, dynamic>> bestSellerMenus = [
      {
        'name': 'Cappuccino',
        'price': 25000,
        'image': 'assets/images/cappucino.jpg',
      },
      {
        'name': 'Iced Latte',
        'price': 28000,
        'image': 'assets/images/iced_latte.jpg',
      },
      {
        'name': 'Iced Americano',
        'price': 22000,
        'image': 'assets/images/iced-americano.jpg',
      },
      {
        'name': 'Cheese Cake',
        'price': 35000,
        'image': 'assets/images/cheese_cake.jpg',
      },
      {
        'name': 'French Fries',
        'price': 18000,
        'image': 'assets/images/fries.jpg',
      },
      {
        'name': 'Onion Rings',
        'price': 18000,
        'image': 'assets/images/onion_rings.jpg',
      },
    ];

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 248, 240),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 78, 52, 46),
        title: const Text('My Cafe', style: TextStyle(color: Colors.white)),
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: Colors.white),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
      ),
      drawer: const AppDrawer(userRole: UserRole.user),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Center(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Column(
                    children: [
                    const Text(
                      'Best Seller!!!',
                      style: TextStyle(
                      fontSize: 30,
                      color: Color.fromARGB(255, 78, 52, 46),
                      fontWeight: FontWeight.bold,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                      children: [
                        Expanded(
                        child: Container(
                          height: 3,
                          decoration: BoxDecoration(
                          color: Color.fromARGB(255, 78, 52, 46),
                          borderRadius: BorderRadius.circular(1.5),
                          ),
                        ),
                        ),
                        const SizedBox(width: 16),
                        const Icon(
                        Icons.coffee_maker,
                        size: 25,
                        color: Color.fromARGB(255, 78, 52, 46),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                        child: Container(
                          height: 3,
                          decoration: BoxDecoration(
                          color: Color.fromARGB(255, 78, 52, 46),
                          borderRadius: BorderRadius.circular(1.5),
                          ),
                        ),
                        ),
                      ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: bestSellerMenus.length + 1, 
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.8, 
              ),
              itemBuilder: (context, index) {
                if (index == bestSellerMenus.length) {
                  return MenuLainnyaCard(
                    onTap: () => Get.to(() => const UserMenuLainnyaPage()),
                  );
                }

                // Card menu statis
                final menu = bestSellerMenus[index];
                return MenuCard(
                  menuName: menu['name'],
                  price: menu['price'],
                  imagePath: menu['image'],
                );
              },
            ),
          ],
        ),
      ),
      floatingActionButton: Obx(() {
        final cartController = Get.find<CartController>();
        final totalItems = cartController.totalItems;
        
        return Stack(
          children: [
            FloatingActionButton(
              backgroundColor: const Color.fromARGB(255, 78, 52, 46),
              onPressed: () {
                Get.to(() => const CartPage());
              },
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
    );
  }
}