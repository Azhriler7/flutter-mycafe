import 'package:get/get.dart';

class MenuSelectionController extends GetxController {
  final RxList<String> selectedItemIds = <String>[].obs;
  final RxBool isDeleteMode = false.obs;

  // Toggle pilihan item
  void toggleSelection(String itemId) {
    if (selectedItemIds.contains(itemId)) {
      selectedItemIds.remove(itemId);
    } else {
      selectedItemIds.add(itemId);
    }
  }

  // Cek item terpilih
  bool isSelected(String itemId) {
    return selectedItemIds.contains(itemId);
  }

  // Hapus semua pilihan
  void clearSelection() {
    selectedItemIds.clear();
    isDeleteMode.value = false;
  }

  // Set mode hapus
  void setDeleteMode(bool value) {
    isDeleteMode.value = value;
  }

  // Getter
  int get selectedCount => selectedItemIds.length;
  bool get hasSelection => selectedItemIds.isNotEmpty;
}
