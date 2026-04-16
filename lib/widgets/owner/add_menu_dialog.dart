import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:opini_kopi/services/menu_service.dart';

class AddMenuDialog extends StatefulWidget {
  final Map<String, dynamic>? item;
  const AddMenuDialog({super.key, this.item});

  @override
  State<AddMenuDialog> createState() => _AddMenuDialogState();
}

class _AddMenuDialogState extends State<AddMenuDialog> {
  final _formKey = GlobalKey<FormState>();
  final _menuService = MenuService();

  late TextEditingController _nameCtrl, _priceCtrl;
  String _category = 'Coffee';
  bool _isActive = true;

  Uint8List? _webImage;
  String? _currentImageUrl;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.item?['menu_name']);
    _priceCtrl = TextEditingController(text: widget.item?['price']?.toString());
    _category = widget.item?['category'] ?? 'Coffee';
    _isActive = widget.item?['is_available'] ?? true;
    _currentImageUrl = widget.item?['image_url'];
  }

  Future<void> _pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      final bytes = await picked.readAsBytes();
      setState(() => _webImage = bytes);
    }
  }

  void _handleSave() async {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Periksa kembali input"),
          backgroundColor: const Color(0xFF4A2419),
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      String? imageUrl = _currentImageUrl;

      if (_webImage != null) {
        final fileName = "${DateTime.now().millisecondsSinceEpoch}.png";
        imageUrl = await _menuService.uploadImage(_webImage!, fileName);
      }

      final data = {
        'menu_name': _nameCtrl.text.trim(),
        'price': int.parse(_priceCtrl.text),
        'category': _category,
        'is_available': _isActive,
        'image_url': imageUrl,
      };

      if (widget.item == null) {
        await _menuService.insertMenu(data);
      } else {
        await _menuService.updateMenu(widget.item!['id_menu'].toString(), data);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text("Berhasil disimpan"),
            backgroundColor: const Color(0xFF4A2419),
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.all(20),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error: $e"),
            backgroundColor: const Color(0xFF4A2419),
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.all(20),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        colorScheme: const ColorScheme.light(primary: Color(0xFF4A2419)),
      ),
      child: Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isCompact = constraints.maxWidth < 640;

            return ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 700),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(28),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildHeader(),
                      const SizedBox(height: 24),
                      if (isCompact) ...[
                        _buildFormFields(isCompact: true),
                        const SizedBox(height: 24),
                        _buildImagePicker(),
                      ] else ...[
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 3,
                              child: _buildFormFields(isCompact: false),
                            ),
                            const SizedBox(width: 32),
                            Expanded(flex: 2, child: _buildImagePicker()),
                          ],
                        ),
                      ],
                      const SizedBox(height: 32),
                      _buildActions(isCompact: isCompact),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader() => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.item == null ? "Tambah Menu" : "Edit Menu",
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: Color(0xFF4A2419),
            ),
          ),
          const Text(
            "Lengkapi detail menu untuk ditampilkan.",
            style: TextStyle(color: Colors.black45, fontSize: 13),
          ),
        ],
      ),
      IconButton(
        onPressed: () => Navigator.pop(context),
        icon: const Icon(Icons.close, color: Color(0xFF4A2419)),
      ),
    ],
  );

  Widget _buildFormFields({required bool isCompact}) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _label("Nama Menu"),
      TextFormField(
        controller: _nameCtrl,
        decoration: _inputDeco("Cappuccino"),
        validator: (v) {
          if (v == null || v.trim().isEmpty) return "Nama wajib diisi";
          if (v.length < 3) return "Minimal 3 karakter";
          return null;
        },
      ),
      const SizedBox(height: 16),
      if (isCompact)
        Column(
          children: [
            _buildPriceField(),
            const SizedBox(height: 16),
            _buildCategoryField(),
          ],
        )
      else
        Row(
          children: [
            Expanded(child: _buildPriceField()),
            const SizedBox(width: 12),
            Expanded(child: _buildCategoryField()),
          ],
        ),
      const SizedBox(height: 16),
      _label("Status"),
      if (isCompact)
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _radio(true, "Aktif"),
            _radio(false, "Nonaktif"),
          ],
        )
      else
        Row(
          children: [
            _radio(true, "Aktif"),
            const SizedBox(width: 20),
            _radio(false, "Nonaktif"),
          ],
        ),
    ],
  );

  Widget _buildPriceField() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _label("Harga (Rp)"),
      TextFormField(
        controller: _priceCtrl,
        keyboardType: TextInputType.number,
        decoration: _inputDeco("18000"),
        validator: (v) {
          if (v == null || v.trim().isEmpty) return "Harga wajib diisi";
          if (int.tryParse(v) == null) return "Harus angka";
          if (int.parse(v) <= 0) return "Harus lebih dari 0";
          return null;
        },
      ),
    ],
  );

  Widget _buildCategoryField() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _label("Kategori"),
      DropdownButtonFormField<String>(
        value: _category,
        decoration: _inputDeco(""),
        items: ['Coffee', 'Non Coffee', 'Snack']
            .map((e) => DropdownMenuItem(value: e, child: Text(e)))
            .toList(),
        onChanged: (v) => setState(() => _category = v!),
      ),
    ],
  );

  Widget _buildImagePicker() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _label("Gambar Produk"),
      Container(
        height: 240,
        width: double.infinity,
        decoration: BoxDecoration(
          color: const Color(0xFFF8F5F2),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFF4A2419).withOpacity(0.2)),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: _webImage != null
              ? Image.memory(_webImage!, fit: BoxFit.cover)
              : (_currentImageUrl != null
                    ? Image.network(_currentImageUrl!, fit: BoxFit.cover)
                    : const Center(
                        child: Icon(
                          Icons.coffee_rounded,
                          size: 50,
                          color: Color(0xFF4A2419),
                        ),
                      )),
        ),
      ),
      const SizedBox(height: 16),
      OutlinedButton.icon(
        onPressed: _pickImage,
        icon: const Icon(Icons.camera_alt_outlined, size: 18),
        label: const Text("Ganti Gambar"),
        style: OutlinedButton.styleFrom(
          foregroundColor: const Color(0xFF4A2419),
          side: const BorderSide(color: Color(0xFF4A2419)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    ],
  );

  Widget _buildActions({required bool isCompact}) => isCompact
      ? Column(
          children: [
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _handleSave,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4A2419),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: _isSaving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        "Simpan",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => Navigator.pop(context),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text(
                  "Batal",
                  style: TextStyle(
                    color: Color(0xFF4A2419),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        )
      : Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            OutlinedButton(
              onPressed: () => Navigator.pop(context),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 36,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Text(
                "Batal",
                style: TextStyle(
                  color: Color(0xFF4A2419),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 12),
            ElevatedButton(
              onPressed: _isSaving ? null : _handleSave,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4A2419),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 40,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: _isSaving
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text(
                      "Simpan",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
            ),
          ],
        );

  Widget _label(String t) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(
      t,
      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
    ),
  );

  InputDecoration _inputDeco(String h) => InputDecoration(
    hintText: h,
    filled: true,
    fillColor: const Color(0xFFF8F5F2),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide.none,
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide.none,
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: Color(0xFF4A2419)),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: Colors.red),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: Colors.red, width: 1.5),
    ),
    errorStyle: const TextStyle(color: Colors.red, fontSize: 12),
    contentPadding: const EdgeInsets.all(16),
  );

  Widget _radio(bool val, String label) => Row(
    children: [
      Radio(
        value: val,
        groupValue: _isActive,
        activeColor: const Color(0xFF4A2419),
        onChanged: (v) => setState(() => _isActive = v as bool),
      ),
      Text(label, style: const TextStyle(fontSize: 14)),
    ],
  );
}
