import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:opini_kopi/services/menu_service.dart';
import 'package:opini_kopi/utils/input_sanitizer.dart';
import 'package:permission_handler/permission_handler.dart';

class AddMenuDialog extends StatefulWidget {
  final Map<String, dynamic>? item;

  const AddMenuDialog({super.key, this.item});

  @override
  State<AddMenuDialog> createState() => _AddMenuDialogState();
}

class _AddMenuDialogState extends State<AddMenuDialog> {
  final _formKey = GlobalKey<FormState>();
  final _menuService = MenuService();

  late TextEditingController _nameCtrl;
  late TextEditingController _priceCtrl;

  String _category = 'Coffee';
  String? _section;
  bool _isActive = true;

  final List<String> _coffeeSections = const [
    'Milk Based Coffee',
    'Espresso Series',
  ];

  Uint8List? _webImage;
  String? _currentImageUrl;

  bool _isSaving = false;
  bool _isPickingImage = false;

  bool get _isCoffeeCategory =>
      _category.toLowerCase() == 'coffee';

  @override
  void initState() {
    super.initState();

    _nameCtrl = TextEditingController(
      text: widget.item?['menu_name'],
    );

    _priceCtrl = TextEditingController(
      text: widget.item?['price']?.toString(),
    );

    _category = widget.item?['category'] ?? 'Coffee';

    if (_isCoffeeCategory) {
      _section = widget.item?['section'];
    }

    _isActive = widget.item?['is_available'] ?? true;
    _currentImageUrl = widget.item?['image_url'];
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _priceCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    if (_isPickingImage) return;

    Navigator.pop(context);

    setState(() => _isPickingImage = true);

    try {
      if (!kIsWeb && source == ImageSource.camera) {
        final status = await Permission.camera.request();

        if (!status.isGranted) {
          _showSnack("Izin kamera diperlukan");
          return;
        }
      }

      final picked = await ImagePicker().pickImage(
        source: source,
        maxWidth: 1400,
        maxHeight: 1400,
        imageQuality: 78,
      );

      if (picked != null) {
        final bytes = await picked.readAsBytes();

        setState(() {
          _webImage = bytes;
        });
      }
    } catch (e) {
      _showSnack("Gagal mengambil gambar: $e");
    } finally {
      if (mounted) {
        setState(() => _isPickingImage = false);
      }
    }
  }

  void _showImageSourceSheet() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(22),
        ),
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
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) {
      _showSnack("Periksa kembali input");
      return;
    }

    setState(() => _isSaving = true);

    try {
      String? imageUrl = _currentImageUrl;

      if (_webImage != null) {
        final fileName =
            "${DateTime.now().millisecondsSinceEpoch}.png";

        imageUrl = await _menuService.uploadImage(
          _webImage!,
          fileName,
        );
      }

      final data = {
        'menu_name': InputSanitizer.sanitizeName(
          _nameCtrl.text,
        ),
        'price': int.parse(_priceCtrl.text),
        'category': _category,
        'section': _isCoffeeCategory ? _section : null,
        'is_available': _isActive,
        'image_url': imageUrl,
      };

      if (widget.item == null) {
        await _menuService.insertMenu(data);
      } else {
        await _menuService.updateMenu(
          widget.item!['id_menu'].toString(),
          data,
        );
      }

      if (mounted) {
        _showSnack("Berhasil disimpan");
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        _showSnack("Error: $e");
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Theme(
      data: Theme.of(context).copyWith(
        colorScheme: const ColorScheme.light(
          primary: Color(0xFF4A2419),
        ),
      ),
      child: Dialog(
        insetPadding: EdgeInsets.symmetric(
          horizontal: screenWidth < 600 ? 16 : 24,
          vertical: screenWidth < 600 ? 20 : 24,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(28),
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isCompact = constraints.maxWidth < 640;

            return ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: 700,
                maxHeight: screenHeight * 0.9,
              ),
              child: SingleChildScrollView(
                padding: EdgeInsets.all(
                  isCompact ? 18 : 28,
                ),
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
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 3,
                              child: _buildFormFields(
                                isCompact: false,
                              ),
                            ),
                            const SizedBox(width: 32),
                            Expanded(
                              flex: 2,
                              child: _buildImagePicker(),
                            ),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  widget.item == null
                      ? "Tambah Menu"
                      : "Edit Menu",
                  style: TextStyle(
                    fontSize:
                        MediaQuery.of(context).size.width <
                                600
                            ? 20
                            : 26,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF4A2419),
                  ),
                ),
                const Text(
                  "Lengkapi detail menu untuk ditampilkan.",
                  style: TextStyle(
                    color: Colors.black45,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(
              Icons.close,
              color: Color(0xFF4A2419),
            ),
          ),
        ],
      );

  Widget _buildFormFields({
    required bool isCompact,
  }) =>
      Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          _label("Nama Menu"),

          TextFormField(
            controller: _nameCtrl,
            inputFormatters: [
              InputSanitizer.safeTextFormatter,
            ],
            decoration: _inputDeco("Cappuccino"),
            validator: (v) =>
                InputSanitizer.validateName(
              v,
              field: "Nama",
            ),
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

          if (_isCoffeeCategory) ...[
            const SizedBox(height: 16),

            _label("Section"),

            DropdownButtonFormField<String>(
              value: _section,
              decoration: _inputDeco(
                "Pilih Section",
              ),
              icon: const Icon(
                Icons.keyboard_arrow_down_rounded,
                color: Color(0xFF4A2419),
              ),
              items: _coffeeSections
                  .map(
                    (e) => DropdownMenuItem(
                      value: e,
                      child: Text(e),
                    ),
                  )
                  .toList(),
              onChanged: (v) {
                setState(() {
                  _section = v;
                });
              },
              validator: (v) {
                if (_isCoffeeCategory &&
                    (v == null || v.isEmpty)) {
                  return "Section wajib dipilih";
                }
                return null;
              },
            ),
          ],

          const SizedBox(height: 16),

          _label("Status"),

          if (isCompact)
            Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
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
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          _label("Harga (Rp)"),
          TextFormField(
            controller: _priceCtrl,
            keyboardType: TextInputType.number,
            inputFormatters: [
              InputSanitizer.numericFormatter,
            ],
            decoration: _inputDeco("18000"),
            validator: (v) =>
                InputSanitizer.validatePositiveInt(
              v,
              field: "Harga",
            ),
          ),
        ],
      );

  Widget _buildCategoryField() => Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          _label("Kategori"),

          DropdownButtonFormField<String>(
            value: _category,
            decoration: _inputDeco(""),
            icon: const Icon(
              Icons.keyboard_arrow_down_rounded,
              color: Color(0xFF4A2419),
            ),
            items: [
              'Coffee',
              'Non Coffee',
              'Snack',
            ]
                .map(
                  (e) => DropdownMenuItem(
                    value: e,
                    child: Text(e),
                  ),
                )
                .toList(),
            onChanged: (v) {
              if (v == null) return;

              setState(() {
                _category = v;

                if (!_isCoffeeCategory) {
                  _section = null;
                }
              });
            },
          ),
        ],
      );

  Widget _buildImagePicker() => Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          _label("Gambar Produk"),

          Container(
            height: 240,
            width: double.infinity,
            decoration: BoxDecoration(
              color: const Color(0xFFF8F5F2),
              borderRadius:
                  BorderRadius.circular(20),
              border: Border.all(
                color: const Color(0xFF4A2419)
                    .withOpacity(0.2),
              ),
            ),
            child: ClipRRect(
              borderRadius:
                  BorderRadius.circular(20),
              child: _webImage != null
                  ? Image.memory(
                      _webImage!,
                      fit: BoxFit.cover,
                    )
                  : (_currentImageUrl != null
                      ? Image.network(
                          _currentImageUrl!,
                          fit: BoxFit.cover,
                        )
                      : const Center(
                          child: Icon(
                            Icons.coffee_rounded,
                            size: 50,
                            color:
                                Color(0xFF4A2419),
                          ),
                        )),
            ),
          ),

          const SizedBox(height: 16),

          OutlinedButton.icon(
            onPressed: _isPickingImage
                ? null
                : _showImageSourceSheet,
            icon: Icon(
              _isPickingImage
                  ? Icons.hourglass_empty
                  : Icons.add_a_photo_outlined,
            ),
            label: Text(
              _isPickingImage
                  ? "Memproses..."
                  : "Pilih Gambar",
            ),
          ),
        ],
      );

  Widget _buildActions({
    required bool isCompact,
  }) =>
      Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          OutlinedButton(
            onPressed: () =>
                Navigator.pop(context),
            child: const Text("Batal"),
          ),

          const SizedBox(width: 12),

          ElevatedButton(
            onPressed:
                _isSaving ? null : _handleSave,
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  const Color(0xFF4A2419),
              foregroundColor: Colors.white,
            ),
            child: _isSaving
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child:
                        CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Text("Simpan"),
          ),
        ],
      );

  Widget _label(String t) => Padding(
        padding:
            const EdgeInsets.only(bottom: 8),
        child: Text(
          t,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      );

  InputDecoration _inputDeco(String h) =>
      InputDecoration(
        hintText: h,
        filled: true,
        fillColor: const Color(0xFFF8F5F2),
        border: OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: Color(0xFF4A2419),
          ),
        ),
        contentPadding:
            const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
      );

  Widget _radio(bool val, String label) =>
      Row(
        children: [
          Radio(
            value: val,
            groupValue: _isActive,
            activeColor:
                const Color(0xFF4A2419),
            onChanged: (v) {
              setState(() {
                _isActive = v as bool;
              });
            },
          ),
          Text(label),
        ],
      );
}