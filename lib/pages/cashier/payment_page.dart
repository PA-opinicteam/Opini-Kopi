import 'package:flutter/material.dart';
import '../../services/payment_service.dart';
import 'receipt_page.dart';

class PaymentPage extends StatefulWidget {
  final List<Map<String, dynamic>> cart;
  final int subtotal;
  final int tax;
  final int total;
  final String Function(int) formatRupiah;
  final String customerName;
  final VoidCallback onOrderCompleted;

  const PaymentPage({
    super.key,
    required this.cart,
    required this.subtotal,
    required this.tax,
    required this.total,
    required this.formatRupiah,
    required this.customerName,
    required this.onOrderCompleted,
  });

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  String paymentMethod = 'cash';
  final TextEditingController cashController = TextEditingController();
  bool isLoading = false;
  bool _isFormattingCash = false;

  @override
  void initState() {
    super.initState();
    _setCashValue(widget.total);
  }

  int _parseCash(String value) {
    return int.tryParse(value.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
  }

  void _setCashValue(int amount) {
    cashController.value = TextEditingValue(
      text: widget.formatRupiah(amount),
      selection: TextSelection.collapsed(
        offset: widget.formatRupiah(amount).length,
      ),
    );
  }

  void _handleCashChanged(String value) {
    if (_isFormattingCash) return;
    _isFormattingCash = true;
    final parsed = _parseCash(value);
    cashController.value = TextEditingValue(
      text: parsed == 0 && value.isEmpty ? '' : widget.formatRupiah(parsed),
      selection: TextSelection.collapsed(
        offset: parsed == 0 && value.isEmpty
            ? 0
            : widget.formatRupiah(parsed).length,
      ),
    );
    _isFormattingCash = false;
    setState(() {});
  }

  int get cashReceived => _parseCash(cashController.text);

  int get change {
    if (paymentMethod == 'qris') return 0;
    final value = cashReceived - widget.total;
    return value < 0 ? 0 : value;
  }

  bool get isPaymentValid {
    if (paymentMethod == 'cash') {
      return cashReceived >= widget.total;
    }
    return true;
  }

  Future<void> _confirmPayment() async {
    if (!isPaymentValid) return;

    setState(() => isLoading = true);

    try {
      final result = await PaymentService().processPayment(
        cart: widget.cart,
        subtotal: widget.subtotal,
        tax: widget.tax,
        total: widget.total,
        cashReceived: paymentMethod == 'cash' ? cashReceived : widget.total,
        change: paymentMethod == 'cash' ? change : 0,
        paymentMethod: paymentMethod,
        customerName: widget.customerName,
      );

      if (!mounted) return;

      final completed = await Navigator.push<bool>(
        context,
        MaterialPageRoute(
          builder: (_) => ReceiptPage(
            cart: widget.cart,
            subtotal: widget.subtotal,
            tax: widget.tax,
            total: widget.total,
            cashReceived: cashReceived,
            change: change,
            paymentMethod: paymentMethod,
            formatRupiah: widget.formatRupiah,
            order: result['order'],
            payment: result['payment'],
            onOrderCompleted: widget.onOrderCompleted,
          ),
        ),
      );

      if (completed == true && mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal pembayaran: $e'),
          backgroundColor: const Color(0xFF4A2419),
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  Widget _quickCashButton(int amount) {
    return OutlinedButton(
      onPressed: () {
        setState(() {
          _setCashValue(amount);
        });
      },
      style: OutlinedButton.styleFrom(
        backgroundColor: const Color(0xFFF5EAE5),
        side: const BorderSide(color: Color(0xFF4A2419)),
        foregroundColor: const Color(0xFF4A2419),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      ),
      child: Text(
        widget.formatRupiah(amount),
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _method(String title, String value) {
    final selected = paymentMethod == value;

    return InkWell(
      onTap: () {
        setState(() {
          paymentMethod = value;

          if (value == 'qris') {
            cashController.clear();
          } else {
            _setCashValue(widget.total);
          }
        });
      },
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFEADDD7) : const Color(0xFFF4F0ED),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: selected ? const Color(0xFF6B3A2E) : const Color(0xFFD8CEC8),
          ),
        ),
        child: Center(
          child: Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: selected ? const Color(0xFF6B3A2E) : Colors.black87,
            ),
          ),
        ),
      ),
    );
  }

  Widget _input(String label, Widget child) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
        const SizedBox(height: 6),
        Container(
          height: 52,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: const Color(0xFFEDE7E3),
            borderRadius: BorderRadius.circular(16),
          ),
          alignment: Alignment.centerLeft,
          child: child,
        ),
      ],
    );
  }

  Widget _row(String title, String value, [bool bold = false]) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title),
        Text(
          value,
          style: TextStyle(
            fontWeight: bold ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.sizeOf(context).width < 720;

    return Scaffold(
      backgroundColor: const Color(0xFFF6F3F1),
      body: SafeArea(
        child: isMobile
            ? SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _summaryPanel(double.infinity, isCompact: true),
                    const SizedBox(height: 16),
                    _paymentPanel(),
                  ],
                ),
              )
            : Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    _summaryPanel(320),
                    const SizedBox(width: 20),
                    Expanded(child: _paymentPanel(expanded: true)),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _summaryPanel(double width, {bool isCompact = false}) {
    return Container(
      width: width,
      padding: EdgeInsets.all(isCompact ? 16 : 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Ringkasan Pesanan',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: isCompact ? 6 : 8),
          Text(
            'Nama Pelanggan: ${widget.customerName}',
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: Color(0xFF4A2419),
            ),
          ),
          SizedBox(height: isCompact ? 14 : 20),
          if (isCompact)
            SizedBox(height: 220, child: _orderList(isCompact))
          else
            Expanded(child: _orderList(isCompact)),
          Divider(height: isCompact ? 18 : 24),
          _row('Subtotal', widget.formatRupiah(widget.subtotal)),
          SizedBox(height: isCompact ? 6 : 8),
          _row('Pajak (10%)', widget.formatRupiah(widget.tax)),
          SizedBox(height: isCompact ? 6 : 8),
          _row('TOTAL', widget.formatRupiah(widget.total), true),
        ],
      ),
    );
  }

  Widget _orderList(bool isCompact) {
    return ListView.separated(
      itemCount: widget.cart.length,
      separatorBuilder: (_, __) => SizedBox(height: isCompact ? 10 : 14),
      itemBuilder: (context, index) {
        final item = widget.cart[index];
        final imageUrl = (item['imageUrl'] ?? '').toString();
        final title = (item['title'] ?? '').toString();
        final qty = item['qty'];
        final price = int.tryParse(item['price'].toString()) ?? 0;
        final variant = (item['variantName'] ?? '').toString();
        final note = (item['note'] ?? item['notes'] ?? '').toString().trim();

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: imageUrl.startsWith('http')
                  ? Image.network(
                      imageUrl,
                      width: 56,
                      height: 56,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _imageFallback(),
                    )
                  : _imageFallback(),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'JMLH $qty',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  if (variant.isNotEmpty)
                    Text(
                      variant.toUpperCase(),
                      style: const TextStyle(fontSize: 11, color: Colors.grey),
                    ),
                  if (note.isNotEmpty)
                    Text(
                      'Catatan: $note',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFF6B3A2E),
                      ),
                    ),
                ],
              ),
            ),
            Text(
              widget.formatRupiah(price),
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ],
        );
      },
    );
  }

  Widget _paymentPanel({bool expanded = false}) {
    return Container(
      padding: EdgeInsets.all(MediaQuery.sizeOf(context).width < 720 ? 18 : 24),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F2EF),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: expanded ? MainAxisSize.max : MainAxisSize.min,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              color: const Color(0xFF6B3A2E),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                const Text(
                  'TOTAL PEMBAYARAN',
                  style: TextStyle(
                    color: Colors.white70,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  widget.formatRupiah(widget.total),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Metode Pembayaran',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(child: _method('QRIS', 'qris')),
              const SizedBox(width: 14),
              Expanded(child: _method('TUNAI', 'cash')),
            ],
          ),
          const SizedBox(height: 24),
          if (paymentMethod == 'cash') ...[
            LayoutBuilder(
              builder: (context, constraints) {
                final isNarrow = constraints.maxWidth < 520;
                final cashInput = _input(
                  'Uang Diterima',
                  TextField(
                    controller: cashController,
                    keyboardType: TextInputType.number,
                    onChanged: _handleCashChanged,
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Masukkan nominal',
                    ),
                  ),
                );
                final changeBox = _input(
                  'Kembalian',
                  Text(
                    widget.formatRupiah(change),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                );

                if (isNarrow) {
                  return Column(
                    children: [
                      cashInput,
                      const SizedBox(height: 12),
                      changeBox,
                    ],
                  );
                }

                return Row(
                  children: [
                    Expanded(child: cashInput),
                    const SizedBox(width: 16),
                    Expanded(child: changeBox),
                  ],
                );
              },
            ),
            const SizedBox(height: 12),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              childAspectRatio: 2.8,
              children: [
                _quickCashButton(20000),
                _quickCashButton(50000),
                _quickCashButton(100000),
                _quickCashButton(150000),
              ],
            ),
          ] else
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFEDE7E3),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'Pembayaran QRIS dikonfirmasi sesuai nominal total.',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          if (expanded) const Spacer() else const SizedBox(height: 28),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFF6B3A2E)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 18),
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    'Batal',
                    style: TextStyle(
                      color: Color(0xFF6B3A2E),
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  onPressed: isPaymentValid && !isLoading
                      ? _confirmPayment
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6B3A2E),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 18),
                  ),
                  child: isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: Colors.white,
                      ),
                    )
                  : const Text(
                      'Konfirmasi Pembayaran',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                   ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _imageFallback() {
    return Container(
      width: 56,
      height: 56,
      color: const Color(0xFFEDE9E6),
      child: const Icon(Icons.image),
    );
  }
}
