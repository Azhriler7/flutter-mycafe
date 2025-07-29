import 'package:get/get.dart';
import 'package:mycafe/model/cart_model.dart';
import 'package:mycafe/model/menu_model.dart';

class CartController extends GetxController {
  final RxList<CartItemModel> _items = <CartItemModel>[].obs;

  List<CartItemModel> get items => _items;

  // Hitung total item
  int get totalItems => _items.fold(0, (sum, item) => sum + item.quantity);

  // Hitung total harga
  double get totalPrice =>
      _items.fold(0, (sum, item) => sum + (item.menu.harga * item.quantity));

  // Tambah item ke keranjang
  void addToCart(MenuModel menu) {
    for (var item in _items) {
      if (item.menu.id == menu.id) {
        item.quantity++;
        _items.refresh(); 
        return;
      }
    }
    _items.add(CartItemModel(menu: menu));
  }

  // Hapus item dari keranjang
  void removeFromCart(CartItemModel cartItem) {
    _items.remove(cartItem);
  }

  // Tambah jumlah item
  void incrementQuantity(CartItemModel cartItem) {
    cartItem.quantity++;
    _items.refresh(); 
  }

  // Kurangi jumlah item
  void decrementQuantity(CartItemModel cartItem) {
    if (cartItem.quantity > 1) {
      cartItem.quantity--;
      _items.refresh(); 
    } else {
      _items.remove(cartItem);
    }
  }

  // Kosongkan keranjang
  void clearCart() {
    _items.clear();
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
      _items.refresh(); 
    }
  }

  // Kurangi jumlah berdasarkan menu
  void decrementQuantityByMenu(MenuModel menu) {
    final index = _items.indexWhere((element) => element.menu.id == menu.id);
    if (index != -1) {
      if (_items[index].quantity > 1) {
        _items[index].quantity--;
        _items.refresh(); 
      } else {
        _items.removeAt(index);
      }
    }
  }

  // Ambil jumlah berdasarkan nama menu
  int getQuantityByName(String menuName) {
    final item = _items.firstWhere(
      (element) => element.menu.namaMenu == menuName,
      orElse: () => CartItemModel(
        menu: MenuModel(
          id: menuName, 
          namaMenu: menuName, 
          harga: 0, 
          kategori: 'static',
          isTersedia: true,
          gambar: ''
        ), 
        quantity: 0
      ),
    );
    return item.quantity;
  }

  // Tambah item berdasarkan nama menu
  void addToCartByName(String menuName, int price) {
    for (var item in _items) {
      if (item.menu.namaMenu == menuName) {
        item.quantity++;
        _items.refresh();
        return;
      }
    }
    _items.add(CartItemModel(
      menu: MenuModel(
        id: menuName,
        namaMenu: menuName,
        harga: price,
        kategori: 'static',
        isTersedia: true,
        gambar: ''
      )
    ));
  }

  // Tambah jumlah berdasarkan nama menu
  void incrementQuantityByName(String menuName) {
    final index = _items.indexWhere((element) => element.menu.namaMenu == menuName);
    if (index != -1) {
      _items[index].quantity++;
      _items.refresh();
    }
  }

  // Kurangi jumlah berdasarkan nama menu
  void decrementQuantityByName(String menuName) {
    final index = _items.indexWhere((element) => element.menu.namaMenu == menuName);
    if (index != -1) {
      if (_items[index].quantity > 1) {
        _items[index].quantity--;
        _items.refresh();
      } else {
        _items.removeAt(index);
      }
    }
  }
}
