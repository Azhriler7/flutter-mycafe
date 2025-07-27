import 'package:flutter/material.dart';
import 'package:mycafe/model/cart_model.dart';
import 'package:mycafe/model/menu_model.dart';

class CartController with ChangeNotifier {
  final List<CartItemModel> _items = [];

  List<CartItemModel> get items => _items;

  int get totalItems => _items.fold(0, (sum, item) => sum + item.quantity);

  double get totalPrice =>
      _items.fold(0, (sum, item) => sum + (item.menu.harga * item.quantity));

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

  // Ambil jumlah berdasarkan menu
  int getQuantity(MenuModel menu) {
    final item = _items.firstWhere(
      (element) => element.menu.id == menu.id,
      orElse: () => CartItemModel(menu: menu, quantity: 0),
    );
    return item.quantity;
  }

  // Tambah jumlah berdasarkan menu
  void incrementQuantityByMenu(MenuModel menu) {
    final index = _items.indexWhere((element) => element.menu.id == menu.id);
    if (index != -1) {
      _items[index].quantity++;
      notifyListeners();
    }
  }

  // Kurangi jumlah berdasarkan menu
  void decrementQuantityByMenu(MenuModel menu) {
    final index = _items.indexWhere((element) => element.menu.id == menu.id);
    if (index != -1) {
      if (_items[index].quantity > 1) {
        _items[index].quantity--;
      } else {
        _items.removeAt(index);
      }
      notifyListeners();
    }
  }
}
