import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:mycafe/controller/cart_controller.dart';

class MenuCard extends StatelessWidget {
  final String menuName;
  final int price;
  final String? imagePath;

  const MenuCard({
    super.key,
    required this.menuName,
    required this.price,
    this.imagePath,
  });

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    return Obx(() {
      final cartController = Get.find<CartController>();
      final qty = cartController.getQuantityByName(menuName);

      return GestureDetector(
        onTap: () {
          if (qty == 0) {
            cartController.addToCartByName(menuName, price);
          } else {
            cartController.incrementQuantityByName(menuName);
          }
        },
        child: Container(
          decoration: BoxDecoration(
          color: const Color.fromARGB(255, 230, 217, 209),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: const Color.fromARGB(255, 78, 52, 46),
            width: 2,
          ),
          ),
          child: Column(
            children: [
              Expanded(
                flex: 6,
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 255, 248, 240),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(12),
                      topRight: Radius.circular(12),
                    ),
                  ),
                  child: imagePath != null 
                    ? ClipRRect(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(12),
                          topRight: Radius.circular(12),
                        ),
                        child: Image.asset(
                          imagePath!,
                          fit: BoxFit.cover,
                          cacheWidth: 200, 
                          cacheHeight: 200,
                          frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
                            if (wasSynchronouslyLoaded || frame != null) {
                              return child;
                            }
                            return Container(
                              color: const Color.fromARGB(255, 245, 235, 220),
                              child: const Center(
                                child: SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Color.fromARGB(255, 78, 52, 46),
                                  ),
                                ),
                              ),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: const Color.fromARGB(255, 245, 235, 220),
                              child: const Icon(
                                Icons.fastfood,
                                color: Color.fromARGB(255, 78, 52, 46),
                                size: 40,
                              ),
                            );
                          },
                        ),
                      )
                    : Icon(
                        Icons.fastfood,
                        color: const Color.fromARGB(255, 78, 52, 46),
                        size: 40,
                      ),
                ),
              ),
              
              Expanded(
                flex: 2,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: double.infinity,
                        child: Text(
                          menuName,
                          style: const TextStyle(
                            color: Color.fromARGB(255, 78, 52, 46),
                            fontSize: 16, 
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        formatter.format(price),
                        style: const TextStyle(
                          color: Color.fromARGB(255, 78, 52, 46),
                          fontSize: 14, 
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              Expanded(
                flex: 2,
                child: qty == 0
                    ? const SizedBox() 
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            onPressed: () => cartController.decrementQuantityByName(menuName),
                            icon: const Icon(
                              Icons.remove_circle_outline,
                              color: Color.fromARGB(255, 78, 52, 46),
                              size: 28,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            '$qty',
                            style: const TextStyle(
                              color: Color.fromARGB(255, 78, 52, 46),
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 12),
                          IconButton(
                            onPressed: () => cartController.incrementQuantityByName(menuName),
                            icon: const Icon(
                              Icons.add_circle_outline,
                              color: Color.fromARGB(255, 78, 52, 46),
                              size: 28,
                            ),
                          ),
                        ],
                    )            
              ),
            ],
          ),
        ),
      );
    });
  }
}

class MenuLainnyaCard extends StatelessWidget {
  final VoidCallback onTap;

  const MenuLainnyaCard({
    super.key,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 230, 217, 209),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: const Color.fromARGB(255, 78, 52, 46),
            width: 2,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.restaurant_menu,
              color: const Color.fromARGB(255, 78, 52, 46),
              size: 40,
            ),
            const SizedBox(height: 8),
            const Text(
              'Menu\nLainnya',
              style: TextStyle(
                color: Color.fromARGB(255, 78, 52, 46),
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            const Text(
              'Lihat Semua',
              style: TextStyle(
                color: Color.fromARGB(255, 78, 52, 46),
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
