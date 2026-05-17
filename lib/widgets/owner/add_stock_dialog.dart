import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:opini_kopi/utils/input_sanitizer.dart';
import 'package:permission_handler/permission_handler.dart';

class AddStockDialog extends StatefulWidget {
  final Map<String, dynamic>? item;

  const AddStockDialog({super.key, this.item});

  @override
  State<AddStockDialog> createState() => _AddStockDialogState();
}

class _AddStockDialogState extends State<AddStockDialog> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameCtrl;
  late TextEditingController _stockCtrl;

  String _selectedUnit = "Kg";
  Uint8List? _imageBytes;
  String? _currentImageUrl;
  bool _isPickingImage = false;

  final primaryBrown = const Color(0xFF6D4C41);
  final darkBrown = const Color(0xFF4A2419);
  final softBg = const Color(0xFFF8F5F2);

  @override
  void initState() {
    super.initState();

    _nameCtrl = TextEditingController(text: widget.item?['product_name'] ?? "");

    _stockCtrl = TextEditingController(
      text: widget.item?['stock']?.toString() ?? "",
    );
    _currentImageUrl = widget.item?['image_url']?.toString();

    if (widget.item?['unit'] != null) {
      _selectedUnit = widget.item!['unit'];
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _stockCtrl.dispose();
    super.dispose();
  }

  InputDecoration inputDeco(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.grey),
      filled: true,
      fillColor: softBg,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFF4A2419)),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Colors.red),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Colors.red, width: 1.5),
      ),
      errorStyle: const TextStyle(color: Colors.red, fontSize: 12),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
    );
  }

  void _handleSave() {
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

    Navigator.pop(context, {
      'product_name': InputSanitizer.sanitizeName(_nameCtrl.text),
      'stock': double.parse(_stockCtrl.text),
      'unit': _selectedUnit,
      if (_imageBytes != null) '_imageBytes': _imageBytes,
    });
  }

  Future<void> _pickImage(ImageSource source) async {
    if (_isPickingImage) return;
    Navigator.pop(context);
    setState(() => _isPickingImage = true);

    try {
      if (!kIsWeb && source == ImageSource.camera) {
        final status = await Permission.camera.request();
        if (!status.isGranted) {
          _showSnack("Izin kamera diperlukan untuk mengambil foto");
          return;
        }
      }

      final picked = await ImagePicker().pickImage(
        source: source,
        maxWidth: 1200,
        maxHeight: 1200,
        imageQuality: 76,
      );
      if (picked == null) return;

      final bytes = await picked.readAsBytes();
      setState(() => _imageBytes = bytes);
    } catch (e) {
      _showSnack("Gagal mengambil gambar: $e");
    } finally {
      if (mounted) setState(() => _isPickingImage = false);
    }
  }

  void _showImageSourceSheet() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.photo_camera_outlined),
                  title: const Text("Ambil dari Kamera"),
                  onTap: () => _pickImage(ImageSource.camera),
                ),
                ListTile(
                  leading: const Icon(Icons.photo_library_outlined),
                  title: const Text("Pilih dari Galeri"),
                  onTap: () => _pickImage(ImageSource.gallery),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showSnack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFF4A2419),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isMobile = screenWidth < 600;

    return Dialog(
      backgroundColor: Colors.white,
      insetPadding: EdgeInsets.symmetric(
        horizontal: isMobile ? 16 : 24,
        vertical: isMobile ? 20 : 24,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: isMobile ? screenWidth - 32 : 500,
          maxHeight: screenHeight * 0.9,
        ),
        child: SingleChildScrollView(
          padding: EdgeInsets.all(isMobile ? 18 : 28),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.item == null
                                ? "Tambah Bahan"
                                : "Update Bahan",
                            style: TextStyle(
                              fontSize: isMobile ? 18 : 22,
                              fontWeight: FontWeight.bold,
                              color: darkBrown,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            "Lengkapi informasi bahan baku baru",
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      visualDensity: VisualDensity.compact,
                      constraints: const BoxConstraints(
                        minWidth: 40,
                        minHeight: 40,
                      ),
                      padding: EdgeInsets.zero,
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),

                SizedBox(height: isMobile ? 18 : 24),

                const Text(
                  "Nama Bahan",
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF4A2419),
                  ),
                ),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _nameCtrl,
                  inputFormatters: [InputSanitizer.safeTextFormatter],
                  decoration: inputDeco("Contoh: Susu Oat"),
                  validator: (v) =>
                      InputSanitizer.validateName(v, field: "Nama"),
                ),

                SizedBox(height: isMobile ? 16 : 20),
                _buildImagePicker(),

                SizedBox(height: isMobile ? 16 : 20),

                if (isMobile) ...[
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Jumlah",
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF4A2419),
                        ),
                      ),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _stockCtrl,
                        keyboardType: TextInputType.number,
                        inputFormatters: [InputSanitizer.numericFormatter],
                        decoration: inputDeco("0.00"),
                        validator: (v) =>
                            InputSanitizer.validateNonNegativeDouble(
                              v,
                              field: "Jumlah",
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Satuan",
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF4A2419),
                        ),
                      ),
                      const SizedBox(height: 6),
                      DropdownButtonFormField<String>(
                        value: _selectedUnit,
                        decoration: inputDeco("Pilih Satuan"),
                        items: ["Kg", "L", "Gram", "Pcs"]
                            .map(
                              (e) => DropdownMenuItem(value: e, child: Text(e)),
                            )
                            .toList(),
                        onChanged: (v) => setState(() => _selectedUnit = v!),
                      ),
                    ],
                  ),
                ] else ...[
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Jumlah",
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF4A2419),
                              ),
                            ),
                            const SizedBox(height: 6),
                            TextFormField(
                              controller: _stockCtrl,
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                InputSanitizer.numericFormatter,
                              ],
                              decoration: inputDeco("0.00"),
                              validator: (v) =>
                                  InputSanitizer.validateNonNegativeDouble(
                                    v,
                                    field: "Jumlah",
                                  ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Satuan",
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF4A2419),
                              ),
                            ),
                            const SizedBox(height: 6),
                            DropdownButtonFormField<String>(
                              value: _selectedUnit,
                              decoration: inputDeco("Pilih Satuan"),
                              items: ["Kg", "L", "Gram", "Pcs"]
                                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                                  .toList(),
                              onChanged: (v) => setState(() => _selectedUnit = v!),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],

                SizedBox(height: isMobile ? 22 : 28),

                if (isMobile) ...[
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _handleSave,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryBrown,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: const Text(
                        "Simpan Bahan",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: const BorderSide(color: Color(0xFFEFEBE9)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: const Text(
                        "Batal",
                        style: TextStyle(
                          color: Colors.grey,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ] else ...[
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 18),
                            side: const BorderSide(color: Color(0xFFEFEBE9)),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: const Text(
                            "Batal",
                            style: TextStyle(
                              color: Colors.grey,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _handleSave,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryBrown,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(vertical: 18),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: const Text(
                            "Simpan Bahan",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImagePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Foto Bahan",
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Color(0xFF4A2419),
          ),
        ),
        const SizedBox(height: 6),
        Container(
          height: 150,
          width: double.infinity,
          decoration: BoxDecoration(
            color: softBg,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE8DFD8)),
          ),
          clipBehavior: Clip.antiAlias,
          child: _imageBytes != null
              ? Image.memory(_imageBytes!, fit: BoxFit.cover)
              : (_currentImageUrl != null && _currentImageUrl!.isNotEmpty
                    ? Image.network(_currentImageUrl!, fit: BoxFit.cover)
                    : const Center(
                        child: Icon(
                          Icons.inventory_2_outlined,
                          size: 42,
                          color: Color(0xFF4A2419),
                        ),
                      )),
        ),
        const SizedBox(height: 10),
        OutlinedButton.icon(
          onPressed: _isPickingImage ? null : _showImageSourceSheet,
          icon: Icon(
            _isPickingImage
                ? Icons.hourglass_empty
                : Icons.add_a_photo_outlined,
            size: 18,
          ),
          label: Text(_isPickingImage ? "Memproses..." : "Pilih Foto"),
          style: OutlinedButton.styleFrom(
            foregroundColor: darkBrown,
            side: BorderSide(color: darkBrown),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ],
    );
  }
}
