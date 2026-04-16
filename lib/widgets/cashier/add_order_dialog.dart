import 'package:fancy_shimmer_image/fancy_shimmer_image.dart';
import 'package:flutter/material.dart';
import 'package:opini_kopi/utils/currency_formatter.dart';
import '../../services/menu_service.dart';

class AddOrderDialog extends StatefulWidget {
  final Map<String, dynamic> menu;
  final void Function(Map<String, dynamic> item) onAddToCart;
  final Map<String, dynamic>? initialItem;

  const AddOrderDialog({
    super.key,
    required this.menu,
    required this.onAddToCart,
    this.initialItem,
  });

  @override
  State<AddOrderDialog> createState() => _AddOrderDialogState();
}

class _AddOrderDialogState extends State<AddOrderDialog> {
  final MenuService _service = MenuService();

  List<Map<String, dynamic>> _variants = [];
  List<Map<String, dynamic>> _addons = [];

  String _selectedVariantId = 'hot';
  final Set<String> _selectedAddonIds = {};

  late TextEditingController _noteController;
  int _qty = 1;
  bool _loading = true;

  String _text(dynamic v) => v?.toString() ?? '';

  int _toInt(dynamic v) {
    if (v == null) return 0;
    if (v is int) return v;
    if (v is double) return v.toInt();
    return int.tryParse(v.toString().replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
  }

  String get _category => _text(widget.menu['category']).toLowerCase().trim();
  String get _section => _text(widget.menu['section']).toLowerCase().trim();

  bool get _canUseVariants =>
      _category.contains('cof') && _section == 'espresso series';

  bool get _canUseAddons =>
      _category.contains('cof') || _category.contains('non');

  int get _basePrice => _toInt(widget.menu['price']);

  String formatRupiah(int value) {
    return CurrencyFormatter.idr(value);
  }

  Map<String, dynamic>? get _selectedVariant {
    for (final v in _variants) {
      if (v['id_variant'].toString() == _selectedVariantId) return v;
    }
    return null;
  }

  int get _variantPrice => _toInt(_selectedVariant?['price']);

  int get _addonsTotal {
    var total = 0;
    for (final a in _addons) {
      if (_selectedAddonIds.contains(a['id_addson'].toString())) {
        total += _toInt(a['price']);
      }
    }
    return total;
  }

  int get _unitPrice => _basePrice + _variantPrice + _addonsTotal;
  int get _totalPrice => _unitPrice * _qty;

  @override
  void initState() {
    super.initState();
    _noteController = TextEditingController(
      text: _text(widget.initialItem?['note']),
    );
    _qty = _toInt(widget.initialItem?['qty']) > 0
        ? _toInt(widget.initialItem?['qty'])
        : 1;
    _selectedVariantId = _text(widget.initialItem?['variantId']).isNotEmpty
        ? _text(widget.initialItem?['variantId'])
        : 'hot';
    _load();
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final menuId = _text(widget.menu['id_menu']);

      final results = await Future.wait([
        _service.getVariants(menuId),
        _service.getAddons(),
      ]);

      final dbVariants = List<Map<String, dynamic>>.from(results[0]);
      _addons = List<Map<String, dynamic>>.from(results[1]);

      _variants = [
        {'id_variant': 'hot', 'name': 'HOT', 'price': 0},
        ...dbVariants,
      ];

      final editVariantId = _text(widget.initialItem?['variantId']);
      final editVariantName = _text(
        widget.initialItem?['variantName'],
      ).toLowerCase().trim();

      if (editVariantId.isNotEmpty) {
        _selectedVariantId = editVariantId;
      } else if (editVariantName.isNotEmpty) {
        final match = _variants.where((v) {
          final name = _text(v['name']).toLowerCase().trim();
          return name == editVariantName;
        }).toList();

        _selectedVariantId = match.isNotEmpty
            ? match.first['id_variant'].toString()
            : 'hot';
      } else {
        _selectedVariantId = 'hot';
      }

      final initialAddonIds = widget.initialItem?['addonIds'];
      if (initialAddonIds is List) {
        for (final id in initialAddonIds) {
          _selectedAddonIds.add(id.toString());
        }
      }

      if (!mounted) return;
      setState(() => _loading = false);
    } catch (_) {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  String _itemKey() {
    final addonIds = (_selectedAddonIds.toList()..sort()).join(',');
    return '${_text(widget.menu['id_menu'])}|$_selectedVariantId|$addonIds';
  }

  void _submit() {
    final menuName = _text(widget.menu['menu_name']).isNotEmpty
        ? _text(widget.menu['menu_name'])
        : _text(widget.menu['title']);

    widget.onAddToCart({
      'menuId': _text(widget.menu['id_menu']),
      'menuCode': _text(widget.menu['menu_code']),
      'title': menuName,
      'subtitle': _text(widget.menu['section']).isNotEmpty
          ? _text(widget.menu['section'])
          : _text(widget.menu['category']),
      'category': _text(widget.menu['category']),
      'section': _text(widget.menu['section']),
      'imageUrl': _text(widget.menu['image_url']).isNotEmpty
          ? _text(widget.menu['image_url'])
          : _text(widget.menu['imageUrl']),
      'isFeatured': widget.menu['is_featured'] == true,
      'basePrice': _basePrice,
      'variantId': _selectedVariantId,
      'variantName': _text(_selectedVariant?['name']),
      'addonIds': _selectedAddonIds.toList()..sort(),
      'addonNames': _addons
          .where((a) => _selectedAddonIds.contains(a['id_addson'].toString()))
          .map((e) => e['name'].toString())
          .toList(),
      'addonPrices': _addons
          .where((a) => _selectedAddonIds.contains(a['id_addson'].toString()))
          .map<int>((a) => _toInt(a['price']))
          .toList(),
      'note': _noteController.text.trim(),
      'qty': _qty,
      'unitPrice': _unitPrice,
      'price': _unitPrice.toString(),
      'itemKey': _itemKey(),
    });

    Navigator.pop(context);
  }

  Widget _menuImage(String imageUrl) {
    if (imageUrl.startsWith('http')) {
      return FancyShimmerImage(
        imageUrl: imageUrl,
        boxFit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        errorWidget: Container(
          color: const Color(0xFFEDE9E6),
          child: const Icon(Icons.image_not_supported),
        ),
      );
    }

    if (imageUrl.isNotEmpty) {
      return Image.asset(imageUrl, fit: BoxFit.cover);
    }

    return Container(
      color: const Color(0xFFEDE9E6),
      child: const Icon(Icons.image_not_supported),
    );
  }

  @override
  Widget build(BuildContext context) {
    final imageUrl = _text(widget.menu['image_url']).isNotEmpty
        ? _text(widget.menu['image_url'])
        : _text(widget.menu['imageUrl']);
    final title = _text(widget.menu['menu_name']).isNotEmpty
        ? _text(widget.menu['menu_name'])
        : _text(widget.menu['title']);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Container(
        width: 430,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
        ),
        child: _loading
            ? const Padding(
                padding: EdgeInsets.all(32),
                child: Center(
                  child: CircularProgressIndicator(color: Color(0xFF4A2419)),
                ),
              )
            : SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(14),
                          child: SizedBox(
                            width: 68,
                            height: 68,
                            child: _menuImage(imageUrl),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                title,
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF2B1B18),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                formatRupiah(_basePrice),
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Color(0xFF6B5B57),
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.close),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    if (_canUseVariants) ...[
                      const Text(
                        'Pilih Varian',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: _variants.map((variant) {
                          final id = variant['id_variant'].toString();
                          final name = _text(variant['name']);
                          final price = _toInt(variant['price']);
                          final selected = _selectedVariantId == id;

                          return Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: _variantButton(
                                label: price > 0
                                    ? '$name (+${formatRupiah(price)})'
                                    : name,
                                isSelected: selected,
                                onTap: () =>
                                    setState(() => _selectedVariantId = id),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 10),
                    ],
                    if (_canUseAddons) ...[
                      const Text(
                        'Tambahan',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ..._addons.map((addon) {
                        final id = addon['id_addson'].toString();
                        final name = _text(addon['name']);
                        final price = _toInt(addon['price']);
                        final selected = _selectedAddonIds.contains(id);

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: _addonTile(
                            title: name,
                            price: '+${formatRupiah(price)}',
                            value: selected,
                            onChanged: (value) {
                              setState(() {
                                if (value ?? false) {
                                  _selectedAddonIds.add(id);
                                } else {
                                  _selectedAddonIds.remove(id);
                                }
                              });
                            },
                          ),
                        );
                      }),
                      const SizedBox(height: 10),
                    ],
                    const Text(
                      'Catatan (Optional)',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _noteController,
                      maxLines: 2,
                      decoration: InputDecoration(
                        hintText: 'Ketik catatan di sini...',
                        filled: true,
                        fillColor: const Color(0xFFF5F1EE),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.all(14),
                      ),
                    ),
                    const SizedBox(height: 18),
                    Row(
                      children: [
                        _qtyButton(
                          icon: Icons.remove,
                          onTap: () {
                            if (_qty > 1) {
                              setState(() => _qty--);
                            }
                          },
                        ),
                        const SizedBox(width: 12),
                        Text(
                          '$_qty',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(width: 12),
                        _qtyButton(
                          icon: Icons.add,
                          onTap: () => setState(() => _qty++),
                        ),
                        const Spacer(),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            const Text(
                              'Total',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                            Text(
                              formatRupiah(_totalPrice),
                              style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF2B1B18),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4A2419),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: Text(
                          widget.initialItem == null
                              ? 'Tambah Pesanan'
                              : 'Simpan Perubahan',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _variantButton({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 46,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFF5E3DD) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF4A2419)
                : const Color(0xFFE5D9D4),
          ),
        ),
        child: Row(
          children: [
            Icon(
              isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
              size: 18,
              color: isSelected ? const Color(0xFF4A2419) : Colors.grey,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isSelected
                      ? const Color(0xFF4A2419)
                      : Colors.grey[700],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _addonTile({
    required String title,
    required String price,
    required bool value,
    required ValueChanged<bool?> onChanged,
  }) {
    final isSelected = value;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFFF5E3DD) : const Color(0xFFF8F5F3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected ? const Color(0xFF4A2419) : Colors.transparent,
        ),
      ),
      child: Row(
        children: [
          Checkbox(
            value: value,
            onChanged: onChanged,
            activeColor: const Color(0xFF4A2419),
          ),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: isSelected ? const Color(0xFF4A2419) : Colors.black,
              ),
            ),
          ),
          Text(
            price,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: isSelected ? const Color(0xFF4A2419) : Colors.black,
            ),
          ),
        ],
      ),
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
}
