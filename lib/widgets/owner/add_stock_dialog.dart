import 'package:flutter/material.dart';

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

    if (widget.item?['unit'] != null) {
      _selectedUnit = widget.item!['unit'];
    }
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
      'product_name': _nameCtrl.text.trim(),
      'stock': double.parse(_stockCtrl.text),
      'unit': _selectedUnit,
    });

    Future.delayed(const Duration(milliseconds: 100), () {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Data berhasil ditambahkan"),
          backgroundColor: const Color(0xFF4A2419),
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Container(
        width: 500,
        padding: const EdgeInsets.all(28),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.item == null ? "Tambah Bahan" : "Update Bahan",
                        style: TextStyle(
                          fontSize: 22,
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
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),

              const SizedBox(height: 24),

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
                decoration: inputDeco("Contoh: Susu Oat"),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return "Nama wajib diisi";
                  if (v.length < 3) return "Minimal 3 karakter";
                  return null;
                },
              ),

              const SizedBox(height: 20),

              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Jumlah Awal",
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF4A2419),
                          ),
                        ),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: _stockCtrl,
                          keyboardType: TextInputType.number,
                          decoration: inputDeco("0"),
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) {
                              return "Jumlah wajib diisi";
                            }
                            if (double.tryParse(v) == null) {
                              return "Harus angka";
                            }
                            if (double.parse(v) < 0) {
                              return "Tidak boleh minus";
                            }
                            return null;
                          },
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
                              .map(
                                (e) =>
                                    DropdownMenuItem(value: e, child: Text(e)),
                              )
                              .toList(),
                          onChanged: (v) => setState(() => _selectedUnit = v!),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 28),

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
          ),
        ),
      ),
    );
  }
}
