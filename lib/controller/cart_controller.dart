import 'package:flutter/material.dart';
import 'package:mycafe/model/cart_model.dart';
import 'package:mycafe/model/menu_model.dart';

class CartController with ChangeNotifier {
  final List<CartItemModel> _items = [];

  List<CartItemModel> get items => _items;

  int get totalItems => _items.fold(0, (sum, item) => sum + item.quantity);

  double get totalPrice => _items.fold(0, (sum, item) => sum + (item.menu.harga * item.quantity));

  // Tambah item ke keranjang
  void addToCart(MenuModel menu) {
    for (var item in _items) {
      if (item.menu.id == menu.id) {
        item.quantity++;
        notifyListeners();
        return;
      }
    }
    _items.add(CartItemModel(menu: menu));
    notifyListeners();
  }

  // Hapus item dari keranjang
  void removeFromCart(CartItemModel cartItem) {
    _items.remove(cartItem);
    notifyListeners();
  }

  // Tambah jumlah item
  void incrementQuantity(CartItemModel cartItem) {
    cartItem.quantity++;
    notifyListeners();
  }

  // Kurangi jumlah item
  void decrementQuantity(CartItemModel cartItem) {
    if (cartItem.quantity > 1) {
      cartItem.quantity--;
    } else {
      _items.remove(cartItem);
    }
    notifyListeners();
  }

  // Kosongkan keranjang
  void clearCart() {
    _items.clear();
    notifyListeners();
  }
}