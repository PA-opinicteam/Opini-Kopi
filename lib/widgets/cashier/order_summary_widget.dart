import 'package:fancy_shimmer_image/fancy_shimmer_image.dart';
import 'package:flutter/material.dart';

class OrderSummaryWidget extends StatelessWidget {
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
  final bool readOnly;
  final TextEditingController customerController;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry margin;

  const OrderSummaryWidget({
    super.key,
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
    this.readOnly = false,
    this.width = 360,
    this.height,
    this.margin = const EdgeInsets.all(16),
  });

  int _toInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    return int.tryParse(value.toString().replaceAll(RegExp(r'[^0-9]'), '')) ??
        0;
  }

  String _text(dynamic value) => value?.toString() ?? '';

  Widget _menuImage(String imageUrl) {
    if (imageUrl.startsWith('http')) {
      return FancyShimmerImage(
        imageUrl: imageUrl,
        boxFit: BoxFit.cover,
        width: 56,
        height: 56,
        errorWidget: Container(
          width: 56,
          height: 56,
          color: const Color(0xFFEDE9E6),
          child: const Icon(Icons.image_not_supported),
        ),
      );
    }

    if (imageUrl.isNotEmpty) {
      return Image.asset(imageUrl, width: 56, height: 56, fit: BoxFit.cover);
    }

    return Container(
      width: 56,
      height: 56,
      color: const Color(0xFFEDE9E6),
      child: const Icon(Icons.image_not_supported),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height ?? MediaQuery.of(context).size.height,
      child: Container(
        margin: margin,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Ringkasan Pesanan ',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E1E1E),
                    ),
                  ),
                ),
                if (cart.isNotEmpty && !readOnly)
                  TextButton(
                    onPressed: onClearAll,
                    child: const Text(
                      'Hapus Semua',
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 20),
            Expanded(
              child: cart.isEmpty
                  ? const Center(
                      child: Text(
                        'Belum ada pesanan',
                        style: TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                    )
                  : ListView.builder(
                      itemCount: cart.length,
                      itemBuilder: (context, index) {
                        final item = cart[index];
                        final imageUrl = _text(item['imageUrl']);
                        final title = _text(item['title']);
                        final subtitle = _text(item['subtitle']);
                        final note = _text(item['note']);
                        final variantName = _text(item['variantName']);
                        final addonNames = item['addonNames'] is List
                            ? List<String>.from(
                                (item['addonNames'] as List).map(
                                  (e) => e.toString(),
                                ),
                              )
                            : <String>[];
                        final unitPrice = _toInt(
                          item['unitPrice'] ?? item['price'],
                        );
                        final qty = _toInt(item['qty']).clamp(1, 9999);

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8F5F3),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Column(
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
                                      child: _menuImage(imageUrl),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            title,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w700,
                                              fontSize: 16,
                                            ),
                                          ),
                                          if (subtitle.isNotEmpty) ...[
                                            const SizedBox(height: 4),
                                            Text(
                                              subtitle,
                                              style: const TextStyle(
                                                color: Colors.grey,
                                                fontSize: 13,
                                              ),
                                            ),
                                          ],
                                          if (variantName.isNotEmpty) ...[
                                            const SizedBox(height: 4),
                                            Text(
                                              'Varian: $variantName',
                                              style: const TextStyle(
                                                color: Color(0xFF4A2419),
                                                fontSize: 12,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ],
                                          if (addonNames.isNotEmpty) ...[
                                            const SizedBox(height: 4),
                                            Text(
                                              'Tambahan: ${addonNames.join(', ')}',
                                              style: const TextStyle(
                                                color: Colors.grey,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ],
                                          if (note.isNotEmpty) ...[
                                            const SizedBox(height: 4),
                                            Text(
                                              'Catatan: $note',
                                              style: const TextStyle(
                                                color: Colors.grey,
                                                fontSize: 12,
                                                fontStyle: FontStyle.italic,
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      formatRupiah(unitPrice),
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 15,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                if (!readOnly) ...[
                                  Row(
                                    children: [
                                      qtyButtonBuilder(
                                        icon: Icons.remove,
                                        onTap: () => onDecreaseQty(index),
                                      ),
                                      const SizedBox(width: 10),
                                      Text(
                                        '$qty',
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      qtyButtonBuilder(
                                        icon: Icons.add,
                                        onTap: () => onIncreaseQty(index),
                                      ),
                                      const Spacer(),
                                      TextButton(
                                        onPressed: () => onEditItem(index),
                                        child: const Text(
                                          'Edit',
                                          style: TextStyle(
                                            color: Color(0xFF4A2419),
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                      TextButton(
                                        onPressed: () async {
                                          final confirm = await showDialog<bool>(
                                            context: context,
                                            builder: (context) {
                                              return AlertDialog(
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(16),
                                                ),
                                                title: const Text(
                                                  'Konfirmasi',
                                                  style: TextStyle(
                                                    color: Color(0xFF4A2419),
                                                  ),
                                                ),
                                                content: const Text(
                                                  'Yakin mau hapus item ini?',
                                                  style: TextStyle(
                                                    color: Color(0xFF4A2419),
                                                  ),
                                                ),
                                                actions: [
                                                  TextButton(
                                                    onPressed: () =>
                                                        Navigator.pop(
                                                          context,
                                                          false,
                                                        ),
                                                    child: const Text(
                                                      'Batal',
                                                      style: TextStyle(
                                                        color: Color(
                                                          0xFF4A2419,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  TextButton(
                                                    onPressed: () =>
                                                        Navigator.pop(
                                                          context,
                                                          true,
                                                        ),
                                                    child: const Text(
                                                      'Hapus',
                                                      style: TextStyle(
                                                        color: Colors.red,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              );
                                            },
                                          );
                                          if (confirm == true) {
                                            onDeleteItem(index);
                                          }
                                        },
                                        child: const Text(
                                          'Hapus',
                                          style: TextStyle(
                                            color: Colors.red,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Nama Pelanggan',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: customerController,
              decoration: InputDecoration(
                hintText: 'Masukkan nama pelanggan',
                filled: true,
                fillColor: Color(0xFFF5EAE5),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const Divider(),
            const SizedBox(height: 8),
            priceRowBuilder('Subtotal', formatRupiah(subtotal)),
            const SizedBox(height: 12),
            priceRowBuilder('Pajak (10%)', formatRupiah(tax)),
            const SizedBox(height: 16),
            priceRowBuilder('Total', formatRupiah(total), isTotal: true),
            const SizedBox(height: 24),
            if (!readOnly) ...[
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: onPay,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4A2419),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    'Bayar',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
