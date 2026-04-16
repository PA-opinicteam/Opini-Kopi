import 'package:fancy_shimmer_image/fancy_shimmer_image.dart';
import 'package:flutter/material.dart';
import 'package:opini_kopi/utils/currency_formatter.dart';
import 'package:opini_kopi/utils/responsive_helper.dart';
import 'package:opini_kopi/widgets/common/app_search_bar.dart';
import '../../services/menu_service.dart';
import 'add_order_dialog.dart';

class MenuContentWidget extends StatefulWidget {
  final String selectedCategory;
  final void Function(Map<String, dynamic>) onAddToCart;

  const MenuContentWidget({
    super.key,
    required this.selectedCategory,
    required this.onAddToCart,
  });

  @override
  State<MenuContentWidget> createState() => _MenuContentWidgetState();
}

class _MenuContentWidgetState extends State<MenuContentWidget> {
  final MenuService _service = MenuService();
  final TextEditingController _searchController = TextEditingController();

  List<Map<String, dynamic>> _menus = [];
  List<Map<String, dynamic>> _filtered = [];
  bool _loading = true;

  String _text(dynamic v) => v?.toString() ?? '';
  String _norm(String v) => v.toLowerCase().trim();

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didUpdateWidget(covariant MenuContentWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedCategory != widget.selectedCategory) {
      _load();
    }
  }

  Future<void> _load() async {
    setState(() => _loading = true);

    final allMenus = await _service.getMenusByCategory(widget.selectedCategory);

    final selected = widget.selectedCategory.toLowerCase();

    if (selected == 'coffee') {
      _menus = allMenus.where((menu) {
        final section = _text(menu['section']).toLowerCase().trim();
        return section.isNotEmpty && section != 'null';
      }).toList();
    } else if (selected == 'non-coffee') {
      _menus = allMenus.where((menu) {
        final section = _text(menu['section']).toLowerCase().trim();
        return section.isEmpty || section == 'null';
      }).toList();
    } else {
      _menus = allMenus;
    }

    _applyFilter();

    if (!mounted) return;
    setState(() => _loading = false);
  }

  void _applyFilter() {
    final keyword = _searchController.text.toLowerCase().trim();

    _filtered = _menus.where((menu) {
      final title = _norm(_text(menu['menu_name']));
      final section = _norm(_text(menu['section']));
      final category = _norm(_text(menu['category']));

      return keyword.isEmpty ||
          title.contains(keyword) ||
          section.contains(keyword) ||
          category.contains(keyword);
    }).toList();
  }

  String _priceText(dynamic price) {
    final value = price is int
        ? price
        : int.tryParse(price.toString().replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;

    return CurrencyFormatter.idr(value);
  }

  void _openAddDialog(Map<String, dynamic> menu) {
    showDialog(
      context: context,
      builder: (_) =>
          AddOrderDialog(menu: menu, onAddToCart: widget.onAddToCart),
    );
  }

  Widget _menuCard(Map<String, dynamic> menu) {
    final title = _text(menu['menu_name']);
    final price = menu['price'];
    final imageUrl = _text(menu['image_url']);
    final isMobile = ResponsiveHelper.isMobile(context);

    return GestureDetector(
      onTap: () => _openAddDialog(menu),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(18),
              ),
              child: FancyShimmerImage(
                imageUrl: imageUrl,
                height: isMobile ? 110 : 140,
                width: double.infinity,
                boxFit: BoxFit.cover,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: isMobile ? 15 : 18,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _priceText(price),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGrid(List<Map<String, dynamic>> data) {
    final columns = ResponsiveHelper.menuGridColumns(context);
    final isMobile = ResponsiveHelper.isMobile(context);
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: data.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        mainAxisExtent: isMobile ? 180 : 230,
      ),
      itemBuilder: (context, index) {
        return _menuCard(data[index]);
      },
    );
  }

  List<Widget> _buildCoffeeSections() {
    final grouped = <String, List<Map<String, dynamic>>>{};

    for (final menu in _filtered) {
      final section = _text(menu['section']);
      grouped.putIfAbsent(section, () => []);
      grouped[section]!.add(menu);
    }

    return grouped.entries.map((e) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(width: 4, height: 18, color: Colors.brown),
              const SizedBox(width: 8),
              Text(
                e.key,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildGrid(e.value),
          const SizedBox(height: 20),
        ],
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final isCoffee = widget.selectedCategory.toLowerCase() == 'coffee';

    return Column(
      children: [
        AppSearchBar(
          controller: _searchController,
          hintText: 'Cari menu...',
          onChanged: (_) => setState(_applyFilter),
        ),

        const SizedBox(height: 16),

        Expanded(
          child: _loading
              ? const Center(
                  child: CircularProgressIndicator(color: Color(0xFF4A2419)),
                )
              : _filtered.isEmpty
              ? const Center(child: Text('Menu tidak ditemukan'))
              : isCoffee
              ? ListView(children: _buildCoffeeSections())
              : GridView.builder(
                  itemCount: _filtered.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: ResponsiveHelper.menuGridColumns(context),
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    mainAxisExtent: ResponsiveHelper.isMobile(context)
                        ? 180
                        : 230,
                  ),
                  itemBuilder: (context, index) {
                    return _menuCard(_filtered[index]);
                  },
                ),
        ),
      ],
    );
  }
}
