import 'package:flutter/material.dart';
import 'package:opini_kopi/services/menu_service.dart';
import 'package:opini_kopi/utils/currency_formatter.dart';
import 'package:opini_kopi/utils/responsive_helper.dart';
import 'package:opini_kopi/widgets/common/app_search_bar.dart';
import 'package:opini_kopi/widgets/common/filter_bar.dart';
import 'package:opini_kopi/widgets/owner/add_menu_dialog.dart';
import 'package:opini_kopi/widgets/owner/delete_menu_dialog.dart';
import 'package:fancy_shimmer_image/fancy_shimmer_image.dart';

class MenuPage extends StatefulWidget {
  const MenuPage({super.key});

  @override
  State<MenuPage> createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  final _service = MenuService();
  List<Map<String, dynamic>> _allData = [];
  List<Map<String, dynamic>> _filteredData = [];
  bool _isLoading = true;
  String _search = "";
  String _category = "Semua";

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  void _fetch() async {
    setState(() => _isLoading = true);
    final data = await _service.getAllMenus();
    setState(() {
      _allData = data;
      _applyFilter();
      _isLoading = false;
    });
  }

  void _applyFilter() {
    setState(() {
      _filteredData = _allData.where((item) {
        final matchesName = (item['menu_name'] ?? "").toLowerCase().contains(
          _search.toLowerCase(),
        );
        final matchesCat =
            _category == "Semua" || item['category'] == _category;
        return matchesName && matchesCat;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
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
              child: Column(
                children: [
                  _buildHeader(isCompact),
                  SizedBox(height: isCompact ? 20 : 32),
                  _buildSearchFilter(isCompact),
                  SizedBox(height: isCompact ? 16 : 24),
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: isCompact ? 12 : 20,
                        vertical: isCompact ? 12 : 16,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.03),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          if (!isCompact) ...[
                            _buildTableHeader(),
                            const Divider(height: 1),
                          ],
                          Expanded(
                            child: _isLoading
                                ? const Center(
                                    child: CircularProgressIndicator(
                                      color: Color(0xFF4E342E),
                                    ),
                                  )
                                : isCompact
                                ? _buildMobileMenuList()
                                : _buildTableBody(),
                          ),
                        ],
                      ),
                    ),
                  ),
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
          "Manajemen Menu",
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Color(0xFF4E342E),
          ),
        ),
        SizedBox(height: 4),
        Text(
          "Atur daftar menu makanan dan minuman anda.",
          style: TextStyle(color: Colors.black45, fontSize: 16),
        ),
      ],
    );
    final button = ElevatedButton.icon(
      onPressed: () async {
        final res = await showDialog(
          context: context,
          builder: (_) => const AddMenuDialog(),
        );
        if (res == true) _fetch();
      },
      icon: const Icon(Icons.add, size: 18),
      label: const Text("Tambah Menu"),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF4A2419),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );

    if (isCompact) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          title,
          const SizedBox(height: 16),
          SizedBox(width: double.infinity, child: button),
        ],
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [title, button],
    );
  }

  Widget _buildSearchFilter(bool isCompact) {
    final search = AppSearchBar(
      hintText: "Cari Menu...",
      onChanged: (v) {
        _search = v;
        _applyFilter();
      },
    );
    final filter = FilterBar<String>(
      value: _category,
      items: const ["Semua", "Coffee", "Non Coffee", "Snack"],
      labelBuilder: (value) => value,
      onChanged: (v) {
        setState(() {
          _category = v;
          _applyFilter();
        });
      },
    );

    if (isCompact) {
      return Column(
        children: [
          search,
          const SizedBox(height: 12),
          Align(alignment: Alignment.centerLeft, child: filter),
        ],
      );
    }

    return Row(
      children: [
        Expanded(child: search),
        const SizedBox(width: 16),
        filter,
      ],
    );
  }

  Widget _buildTableHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: const [
          Expanded(
            flex: 3,
            child: Text(
              "Nama",
              style: TextStyle(fontSize: 14, color: Colors.black87),
            ),
          ),
          Expanded(
            child: Text(
              "Harga",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.black87),
            ),
          ),
          Expanded(
            child: Text(
              "Kategori",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.black87),
            ),
          ),
          Expanded(
            child: Text(
              "Status",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.black87),
            ),
          ),
          SizedBox(
            width: 100,
            child: Text(
              "Aksi",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTableBody() {
    return ListView.separated(
      itemCount: _filteredData.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (context, i) {
        final item = _filteredData[i];
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Row(
            children: [
              Expanded(
                flex: 3,
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: FancyShimmerImage(
                        imageUrl: item['image_url'] ?? '',
                        width: 50,
                        height: 50,
                        boxFit: BoxFit.cover,
                        errorWidget: const Icon(Icons.coffee),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item['menu_name'],
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Text(
                  CurrencyFormatter.idr(item['price'] ?? 0),
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              Expanded(child: Center(child: _badge(item['category']))),
              Expanded(
                child: Center(child: _status(item['is_available'] ?? true)),
              ),
              SizedBox(
                width: 100,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit_outlined, size: 20),
                      onPressed: () => _openForm(item),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.delete_outline,
                        color: Colors.red,
                        size: 20,
                      ),
                      onPressed: () => _confirmDelete(item),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMobileMenuList() {
    return ListView.separated(
      itemCount: _filteredData.length,
      separatorBuilder: (_, __) => const Divider(height: 20),
      itemBuilder: (context, i) => _buildMobileMenuItem(_filteredData[i]),
    );
  }

  Widget _buildMobileMenuItem(Map<String, dynamic> item) {
    final menuName = (item['menu_name'] ?? '').toString();
    final imageUrl = (item['image_url'] ?? '').toString();
    final category = (item['category'] ?? '-').toString();
    final isAvailable = item['is_available'] ?? true;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: FancyShimmerImage(
              imageUrl: imageUrl,
              width: 64,
              height: 64,
              boxFit: BoxFit.cover,
              errorWidget: Container(
                width: 64,
                height: 64,
                color: const Color(0xFFF5EFEB),
                child: const Icon(Icons.coffee, color: Color(0xFF4A2419)),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  menuName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Color(0xFF2B1B18),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  CurrencyFormatter.idr(item['price'] ?? 0),
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF4A2419),
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [_badge(category), _status(isAvailable)],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                visualDensity: VisualDensity.compact,
                icon: const Icon(Icons.edit_outlined, size: 20),
                onPressed: () => _openForm(item),
              ),
              IconButton(
                visualDensity: VisualDensity.compact,
                icon: const Icon(
                  Icons.delete_outline,
                  color: Colors.red,
                  size: 20,
                ),
                onPressed: () => _confirmDelete(item),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _badge(String text) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
    decoration: BoxDecoration(
      color: const Color(0xFFF5EFEB),
      borderRadius: BorderRadius.circular(20),
    ),
    child: Text(
      text,
      style: const TextStyle(
        fontSize: 11,
        color: Color(0xFF4A2419),
        fontWeight: FontWeight.bold,
      ),
    ),
  );
  Widget _status(bool active) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(Icons.circle, size: 8, color: active ? Colors.green : Colors.red),
      const SizedBox(width: 6),
      Text(
        active ? "Aktif" : "Nonaktif",
        style: TextStyle(
          fontSize: 13,
          color: active ? Colors.green : Colors.red,
          fontWeight: FontWeight.w500,
        ),
      ),
    ],
  );

  void _openForm(Map<String, dynamic> item) async {
    final res = await showDialog(
      context: context,
      builder: (_) => AddMenuDialog(item: item),
    );
    if (res == true) _fetch();
  }

  void _confirmDelete(Map<String, dynamic> item) {
    showDialog(
      context: context,
      builder: (_) => DeleteMenuDialog(
        onConfirm: () async {
          await _service.deleteMenu(item['id_menu'].toString());
          _fetch();
        },
      ),
    );
  }
}
