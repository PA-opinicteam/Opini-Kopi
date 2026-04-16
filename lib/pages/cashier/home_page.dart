import 'package:flutter/material.dart';
import 'package:opini_kopi/constants/app_colors.dart';
import 'package:opini_kopi/utils/currency_formatter.dart';
import 'package:opini_kopi/utils/responsive_helper.dart';
import 'package:opini_kopi/utils/snackbar_utils.dart';
import '../../services/supabase_service.dart';
import '../../widgets/cashier/add_order_dialog.dart';
import '../../widgets/cashier/menu_content_widget.dart';
import '../../widgets/cashier/order_summary_widget.dart';
import '../../widgets/cashier/menu_sidebar_widget.dart';
import '../auth/login_page.dart';
import 'payment_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String selectedCategory = 'coffee';
  final List<Map<String, dynamic>> cart = [];
  final TextEditingController customerController = TextEditingController();

  int _toInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    return int.tryParse(value.toString().replaceAll(RegExp(r'[^0-9]'), '')) ??
        0;
  }

  String _text(dynamic value) => value?.toString() ?? '';

  String formatRupiah(int value) {
    return CurrencyFormatter.idr(value);
  }

  void _showMessage(String message) {
    SnackbarUtils.info(context, message);
  }

  String _cartKey(Map<String, dynamic> item) {
    final menuId = _text(item['menuId']);
    final variantId = _text(item['variantId']);
    final addonIds = item['addonIds'] is List
        ? (() {
            final list = List<String>.from(
              (item['addonIds'] as List).map((e) => e.toString()),
            );
            list.sort();
            return list;
          })()
        : <String>[];
    return '$menuId|$variantId|${addonIds.join(',')}';
  }

  int get subtotal {
    var totalValue = 0;
    for (final item in cart) {
      final unitPrice = _toInt(item['unitPrice'] ?? item['price']);
      final qty = _toInt(item['qty']);
      totalValue += unitPrice * qty;
    }
    return totalValue;
  }

  int get tax => (subtotal * 0.1).round();
  int get total => subtotal + tax;

  void _handleAddToCart(Map<String, dynamic> item) {
    final newItem = Map<String, dynamic>.from(item);
    final key = _cartKey(newItem);
    newItem['itemKey'] = key;

    final existingIndex = cart.indexWhere((e) => _cartKey(e) == key);

    if (existingIndex >= 0) {
      cart[existingIndex]['qty'] =
          _toInt(cart[existingIndex]['qty']) + _toInt(newItem['qty']);
      cart[existingIndex]['unitPrice'] = newItem['unitPrice'];
      cart[existingIndex]['price'] = newItem['price'];
      cart[existingIndex]['note'] = newItem['note'];
      cart[existingIndex]['variantId'] = newItem['variantId'];
      cart[existingIndex]['variantName'] = newItem['variantName'];
      cart[existingIndex]['addonIds'] = newItem['addonIds'];
      cart[existingIndex]['addonNames'] = newItem['addonNames'];
      cart[existingIndex]['addonPrices'] = newItem['addonPrices'];
    } else {
      cart.add(newItem);
    }

    setState(() {});
    _showMessage('Item ditambahkan');
  }

  void _handleEditItem(int index) {
    final item = cart[index];

    showDialog(
      context: context,
      builder: (context) {
        return AddOrderDialog(
          menu: item,
          initialItem: item,
          onAddToCart: (updatedItem) {
            setState(() {
              cart[index] = updatedItem;
            });
            _showMessage('Item berhasil diupdate');
          },
        );
      },
    );
  }

  void _handleDeleteItem(int index) {
    setState(() {
      cart.removeAt(index);
    });
    _showMessage('Item berhasil dihapus');
  }

  void _handleClearAll() {
    setState(cart.clear);
    _showMessage('Semua pesanan dihapus');
  }

  void _handleDecreaseQty(int index) {
    setState(() {
      final qty = _toInt(cart[index]['qty']);
      if (qty > 1) {
        cart[index]['qty'] = qty - 1;
      } else {
        cart.removeAt(index);
      }
    });
  }

  void _handleIncreaseQty(int index) {
    setState(() {
      cart[index]['qty'] = _toInt(cart[index]['qty']) + 1;
    });
  }

  Future<void> _handleLogout() async {
    try {
      await SupabaseService.client.auth.signOut();

      if (!mounted) return;

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginPage()),
        (route) => false,
      );
    } catch (_) {
      _showMessage('Gagal logout');
    }
  }

  void _handlePay() {
    if (cart.isEmpty) {
      _showMessage('Cart masih kosong');
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PaymentPage(
          cart: cart,
          subtotal: subtotal,
          tax: tax,
          total: total,
          formatRupiah: formatRupiah,
          customerName: customerController.text.trim().isEmpty
              ? "Guest"
              : customerController.text.trim(),
        ),
      ),
    );
  }

  void _openCartPage() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => _MobileCartPage(
          cart: cart,
          subtotal: subtotal,
          tax: tax,
          total: total,
          formatRupiah: formatRupiah,
          onPay: _handlePay,
          onDecreaseQty: _handleDecreaseQty,
          onIncreaseQty: _handleIncreaseQty,
          onEditItem: _handleEditItem,
          onDeleteItem: _handleDeleteItem,
          onClearAll: _handleClearAll,
          qtyButtonBuilder: _qtyButton,
          priceRowBuilder: _buildPriceRow,
          customerController: customerController,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveHelper.isMobile(context);

    return Scaffold(
      backgroundColor: AppColors.cashierBackground,
      appBar: isMobile
          ? AppBar(
              title: const Text('Opini Kopi Kasir'),
              backgroundColor: AppColors.surface,
              foregroundColor: AppColors.primary,
              leading: IconButton(
                onPressed: _handleLogout,
                icon: const Icon(Icons.logout),
              ),
              actions: [
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      IconButton(
                        onPressed: _openCartPage,
                        icon: const Icon(Icons.shopping_cart_outlined),
                      ),
                      if (cart.isNotEmpty)
                        Positioned(
                          right: 6,
                          top: 6,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              '${cart.length}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            )
          : null,
      body: SafeArea(
        child: isMobile
            ? Padding(
                padding: const EdgeInsets.all(16),
                child: MenuContentWidget(
                  selectedCategory: selectedCategory,
                  onAddToCart: _handleAddToCart,
                ),
              )
            : Row(
                children: [
                  SidebarWidget(
                    selectedCategory: selectedCategory,
                    onCoffeeTap: () =>
                        setState(() => selectedCategory = 'coffee'),
                    onNonCoffeeTap: () =>
                        setState(() => selectedCategory = 'non-coffee'),
                    onSnackTap: () =>
                        setState(() => selectedCategory = 'snack'),
                    onExitTap: _handleLogout,
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: MenuContentWidget(
                        selectedCategory: selectedCategory,
                        onAddToCart: _handleAddToCart,
                      ),
                    ),
                  ),
                  OrderSummaryWidget(
                    cart: cart,
                    subtotal: subtotal,
                    tax: tax,
                    total: total,
                    formatRupiah: formatRupiah,
                    onPay: _handlePay,
                    onDecreaseQty: _handleDecreaseQty,
                    onIncreaseQty: _handleIncreaseQty,
                    onEditItem: _handleEditItem,
                    onDeleteItem: _handleDeleteItem,
                    onClearAll: _handleClearAll,
                    qtyButtonBuilder: _qtyButton,
                    priceRowBuilder: _buildPriceRow,
                    customerController: customerController,
                  ),
                ],
              ),
      ),
      bottomNavigationBar: isMobile
          ? NavigationBar(
              selectedIndex: switch (selectedCategory) {
                'non-coffee' => 1,
                'snack' => 2,
                _ => 0,
              },
              backgroundColor: AppColors.surface,
              indicatorColor: AppColors.primarySoft,
              onDestinationSelected: (index) {
                setState(() {
                  selectedCategory = switch (index) {
                    1 => 'non-coffee',
                    2 => 'snack',
                    _ => 'coffee',
                  };
                });
              },
              destinations: const [
                NavigationDestination(
                  icon: Icon(Icons.local_cafe_outlined),
                  selectedIcon: Icon(Icons.local_cafe),
                  label: 'Coffee',
                ),
                NavigationDestination(
                  icon: Icon(Icons.emoji_food_beverage_outlined),
                  selectedIcon: Icon(Icons.emoji_food_beverage),
                  label: 'Non-Coffee',
                ),
                NavigationDestination(
                  icon: Icon(Icons.fastfood_outlined),
                  selectedIcon: Icon(Icons.fastfood),
                  label: 'Snack',
                ),
              ],
            )
          : null,
    );
  }

  Widget _qtyButton({required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: const Color(0xFFF1ECE9),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, size: 18, color: const Color(0xFF4A2419)),
      ),
    );
  }

  Widget _buildPriceRow(String title, String value, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: isTotal ? 18 : 15,
            fontWeight: isTotal ? FontWeight.w700 : FontWeight.w400,
          ),
        ),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w700)),
      ],
    );
  }
}

class _MobileCartPage extends StatelessWidget {
  final List<Map<String, dynamic>> cart;
  final int subtotal;
  final int tax;
  final int total;
  final String Function(int) formatRupiah;
  final VoidCallback onPay;
  final void Function(int index) onDecreaseQty;
  final void Function(int index) onIncreaseQty;
  final void Function(int index) onEditItem;
  final void Function(int index) onDeleteItem;
  final VoidCallback onClearAll;
  final Widget Function({required IconData icon, required VoidCallback onTap})
  qtyButtonBuilder;
  final Widget Function(String title, String value, {bool isTotal})
  priceRowBuilder;
  final TextEditingController customerController;

  const _MobileCartPage({
    required this.cart,
    required this.subtotal,
    required this.tax,
    required this.total,
    required this.formatRupiah,
    required this.onPay,
    required this.onDecreaseQty,
    required this.onIncreaseQty,
    required this.onEditItem,
    required this.onDeleteItem,
    required this.onClearAll,
    required this.qtyButtonBuilder,
    required this.priceRowBuilder,
    required this.customerController,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cashierBackground,
      appBar: AppBar(
        title: const Text('Keranjang'),
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.primary,
      ),
      body: OrderSummaryWidget(
        width: double.infinity,
        margin: const EdgeInsets.all(16),
        cart: cart,
        subtotal: subtotal,
        tax: tax,
        total: total,
        formatRupiah: formatRupiah,
        onPay: onPay,
        onDecreaseQty: onDecreaseQty,
        onIncreaseQty: onIncreaseQty,
        onEditItem: onEditItem,
        onDeleteItem: onDeleteItem,
        onClearAll: onClearAll,
        qtyButtonBuilder: qtyButtonBuilder,
        priceRowBuilder: priceRowBuilder,
        customerController: customerController,
      ),
    );
  }
}
