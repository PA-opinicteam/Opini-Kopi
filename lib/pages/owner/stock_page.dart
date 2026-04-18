import 'package:flutter/material.dart';
import 'package:opini_kopi/services/export_service.dart';
import 'package:opini_kopi/utils/responsive_helper.dart';
import 'package:opini_kopi/utils/snackbar_utils.dart';
import 'package:opini_kopi/widgets/common/app_search_bar.dart';

import '../../services/stock_service.dart';
import '../../widgets/owner/add_stock_dialog.dart';
import '../../widgets/owner/delete_stock_dialog.dart';

class StockPage extends StatefulWidget {
  const StockPage({super.key});

  @override
  State<StockPage> createState() => _StockPageState();
}

class _StockPageState extends State<StockPage> {
  final StockService _service = StockService();
  List<Map<String, dynamic>> _data = [];
  List<Map<String, dynamic>> _filtered = [];
  bool _isLoading = true;
  bool _isExporting = false;

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  Future<void> _refresh() async {
    setState(() => _isLoading = true);
    final list = await _service.getStock();
    setState(() {
      _data = list;
      _filtered = list;
      _isLoading = false;
    });
  }

  void _search(String q) {
    setState(() {
      _filtered = _data
          .where(
            (e) => e['product_name'].toString().toLowerCase().contains(
              q.toLowerCase(),
            ),
          )
          .toList();
    });
  }

  Future<void> _handleExportExcel() async {
    if (_isExporting) return;
    setState(() => _isExporting = true);
    try {
      final path = await ExportService.saveStockExcel(_filtered);
      if (!mounted) return;
      SnackbarUtils.info(context, 'Excel stok tersimpan: $path');
    } catch (e) {
      if (!mounted) return;
      SnackbarUtils.error(context, 'Ekspor stok gagal: $e');
    } finally {
      if (mounted) setState(() => _isExporting = false);
    }
  }

  String _normalizeUnit(dynamic value) {
    return value?.toString().toLowerCase().trim() ?? '';
  }

  double _toDouble(dynamic value) {
    if (value == null) return 0;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString()) ?? 0;
  }

  double _lowStockLimit(String unit) {
    switch (_normalizeUnit(unit)) {
      case 'g':
      case 'gr':
      case 'gram':
        return 500;
      case 'kg':
      case 'kilogram':
        return 1;
      case 'ml':
        return 1000;
      case 'l':
      case 'lt':
      case 'liter':
        return 2;
      case 'pcs':
      case 'pc':
      case 'piece':
      case 'pieces':
        return 10;
      default:
        return 5;
    }
  }

  String _stockStatus(double stock, String unit) {
    if (stock <= 0) return 'Habis';
    if (stock <= _lowStockLimit(unit)) return 'Menipis';
    return 'Aman';
  }

  bool _isLowStock(Map<String, dynamic> item) {
    final stock = _toDouble(item['stock']);
    final unit = _normalizeUnit(item['unit']);
    return stock > 0 && stock <= _lowStockLimit(unit);
  }

  @override
  Widget build(BuildContext context) {
    final habis = _data.where((e) => _toDouble(e['stock']) <= 0).length;
    final rendah = _data.where(_isLowStock).length;
    final aman = _data.where((e) {
      final stock = _toDouble(e['stock']);
      final unit = _normalizeUnit(e['unit']);
      return stock > _lowStockLimit(unit);
    }).length;

    return Scaffold(
      backgroundColor: const Color(0xFFF5EFE6),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isCompact =
                ResponsiveHelper.isMobile(context) || constraints.maxWidth < 900;

            return Padding(
              padding: EdgeInsets.all(
                isCompact ? 16 : ResponsiveHelper.pagePadding(context),
              ),
              child: isCompact
                  ? ListView(
                      children: [
                        _buildHeader(true),
                        const SizedBox(height: 24),
                        _buildStats(
                          true,
                          habis: habis,
                          rendah: rendah,
                          aman: aman,
                        ),
                        const SizedBox(height: 24),
                        _buildTableSection(true),
                      ],
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildHeader(false),
                        const SizedBox(height: 24),
                        _buildStats(
                          false,
                          habis: habis,
                          rendah: rendah,
                          aman: aman,
                        ),
                        const SizedBox(height: 24),
                        Expanded(child: _buildTableSection(false)),
                      ],
                    ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader(bool isCompact) {
    final title = const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Stok bahan",
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Color(0xFF4E342E),
          ),
        ),
        SizedBox(height: 4),
        Text(
          "Kelola ketersediaan bahan baku coffee shop.",
          style: TextStyle(color: Colors.black45, fontSize: 16),
        ),
      ],
    );

    final searchField = AppSearchBar(
      hintText: "Cari bahan...",
      onChanged: _search,
    );
    final addButton = ElevatedButton.icon(
      onPressed: () => _handleAddEdit(),
      icon: const Icon(Icons.add),
      label: const Text("Tambah Bahan"),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF4A2419),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
    final exportButton = OutlinedButton.icon(
      onPressed: _isExporting ? null : _handleExportExcel,
      icon: const Icon(Icons.table_chart_outlined),
      label: const Text("Ekspor Excel"),
      style: OutlinedButton.styleFrom(
        foregroundColor: const Color(0xFF4A2419),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );

    if (isCompact) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          title,
          const SizedBox(height: 16),
          searchField,
          const SizedBox(height: 12),
          SizedBox(width: double.infinity, child: addButton),
          const SizedBox(height: 12),
          SizedBox(width: double.infinity, child: exportButton),
        ],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: title),
        const SizedBox(width: 16),
        SizedBox(width: 280, child: searchField),
        const SizedBox(width: 12),
        addButton,
        const SizedBox(width: 12),
        exportButton,
      ],
    );
  }

  Widget _buildStats(
    bool isCompact, {
    required int habis,
    required int rendah,
    required int aman,
  }) {
    final cards = [
      _card(
        "Jumlah Bahan",
        _data.length.toString(),
        Icons.inventory_2_outlined,
        Colors.brown,
      ),
      _card(
        "Tingkat Optimal",
        aman.toString(),
        Icons.check_circle_outline,
        Colors.green,
      ),
      _card(
        "Stok Rendah",
        rendah.toString(),
        Icons.warning_amber_rounded,
        Colors.orange,
      ),
      _card(
        "Stok Habis",
        habis.toString(),
        Icons.error_outline,
        Colors.red,
      ),
    ];

    if (isCompact) {
      return Column(
        children: [
          for (var i = 0; i < cards.length; i++) ...[
            cards[i],
            if (i != cards.length - 1) const SizedBox(height: 12),
          ],
        ],
      );
    }

    return Row(
      children: [
        for (var i = 0; i < cards.length; i++) ...[
          Expanded(child: cards[i]),
          if (i != cards.length - 1) const SizedBox(width: 16),
        ],
      ],
    );
  }

  Widget _buildTableSection(bool isCompact) {
    return Container(
      padding: EdgeInsets.all(isCompact ? 16 : 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Daftar Bahan",
            style: TextStyle(
              fontSize: isCompact ? 18 : 20,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF4E342E),
            ),
          ),
          const SizedBox(height: 12),
          if (isCompact)
            _buildCompactTableContent()
          else
            Expanded(child: _buildDesktopTableContent()),
        ],
      ),
    );
  }

  Widget _buildCompactTableContent() {
    if (_isLoading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 32),
        child: Center(
          child: CircularProgressIndicator(color: Color(0xFF4E342E)),
        ),
      );
    }

    if (_filtered.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Center(
          child: Text(
            "Belum ada data bahan.",
            style: TextStyle(color: Colors.black54),
          ),
        ),
      );
    }

    return ListView.separated(
      itemCount: _filtered.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) => _buildMobileItem(_filtered[index]),
    );
  }

  Widget _buildDesktopTableContent() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFF4E342E)),
      );
    }

    if (_filtered.isEmpty) {
      return const Center(
        child: Text(
          "Belum ada data bahan.",
          style: TextStyle(color: Colors.black54),
        ),
      );
    }

    return Column(
      children: [
        _buildTableHeader(),
        const Divider(height: 24),
        Expanded(
          child: ListView.separated(
            itemCount: _filtered.length,
            separatorBuilder: (context, index) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Divider(
                height: 1,
                color: Colors.grey.withValues(alpha: 0.3),
              ),
            ),
            itemBuilder: (context, index) => _buildDesktopRow(_filtered[index]),
          ),
        ),
      ],
    );
  }

  Widget _buildTableHeader() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              "Nama Bahan Baku",
              style: TextStyle(color: Colors.black87, fontSize: 14),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              "Stok Tersedia",
              style: TextStyle(color: Colors.black87, fontSize: 14),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              "Status",
              style: TextStyle(color: Colors.black87, fontSize: 14),
            ),
          ),
          SizedBox(
            width: 100,
            child: Text(
              "Aksi",
              textAlign: TextAlign.right,
              style: TextStyle(color: Colors.black87, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _card(String title, String val, IconData icon, Color color) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: TextStyle(
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            val,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 32,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopRow(Map<String, dynamic> item) {
    final stock = _toDouble(item['stock']);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Expanded(flex: 3, child: _ingredientInfo(item, stock)),
          Expanded(
            flex: 2,
            child: Text(
              "$stock ${item['unit']}",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: stock == 0 ? Colors.red : Colors.black87,
              ),
            ),
          ),
          Expanded(flex: 2, child: _statusBadge(stock, item['unit'])),
          SizedBox(
            width: 100,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                _actionBtn(Icons.edit_outlined, () => _handleAddEdit(item: item)),
                const SizedBox(width: 8),
                _actionBtn(
                  Icons.delete_outline,
                  () => _handleDelete(item),
                  isDelete: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileItem(Map<String, dynamic> item) {
    final stock = _toDouble(item['stock']);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFCFAF8),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE8DFD8)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _ingredientInfo(item, stock)),
              const SizedBox(width: 12),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _actionBtn(Icons.edit_outlined, () => _handleAddEdit(item: item)),
                  _actionBtn(
                    Icons.delete_outline,
                    () => _handleDelete(item),
                    isDelete: true,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _infoChip("Stok", "$stock ${item['unit']}"),
              _statusBadge(stock, item['unit']),
            ],
          ),
        ],
      ),
    );
  }

  Widget _ingredientInfo(Map<String, dynamic> item, double stock) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          backgroundColor: Colors.grey[100],
          child: Icon(
            Icons.opacity,
            size: 18,
            color: stock == 0 ? Colors.red : Colors.green,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item['product_name'],
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: Color(0xFF2B1B18),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                item['category'] ?? "Bahan Baku",
                style: TextStyle(color: Colors.grey[500], fontSize: 12),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _infoChip(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF5EFEB),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        "$label: $value",
        style: const TextStyle(
          fontSize: 12,
          color: Color(0xFF4A2419),
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _actionBtn(
    IconData icon,
    VoidCallback onTap, {
    bool isDelete = false,
  }) {
    return IconButton(
      icon: Icon(
        icon,
        size: 20,
        color: isDelete ? Colors.red[400] : Colors.grey[700],
      ),
      onPressed: onTap,
    );
  }

  Widget _statusBadge(double stock, dynamic unit) {
    final status = _stockStatus(stock, unit.toString());
    final color = switch (status) {
      'Habis' => Colors.red,
      'Menipis' => Colors.orange,
      _ => Colors.green,
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 13,
        ),
      ),
    );
  }

  void _handleAddEdit({Map<String, dynamic>? item}) async {
    final res = await showDialog(
      context: context,
      builder: (_) => AddStockDialog(item: item),
    );
    if (res != null) {
      if (item == null) {
        await _service.addStock(res);
      } else {
        await _service.updateStock(item['id_inventory'], res);
      }
      _refresh();
    }
  }

  void _handleDelete(Map<String, dynamic> item) async {
    await showDialog(
      context: context,
      builder: (_) => DeleteStockDialog(
        onConfirm: () async {
          await _service.deleteStock(item['id_inventory']);
          _refresh();
        },
      ),
    );
  }
}
