import 'package:flutter/material.dart';
import 'package:opini_kopi/services/users_service.dart';

class AddUserDialog extends StatefulWidget {
  final VoidCallback onSuccess;
  final Map? user;

  const AddUserDialog({super.key, required this.onSuccess, this.user});

  @override
  State<AddUserDialog> createState() => _AddUserDialogState();
}

class _AddUserDialogState extends State<AddUserDialog> {
  final _formKey = GlobalKey<FormState>();

  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();

  String role = 'kasir';
  bool isActive = true;

  final service = UsersService();

  bool get isEdit => widget.user != null;

  @override
  void initState() {
    super.initState();

    if (isEdit) {
      _name.text = widget.user!['name'];
      _email.text = widget.user!['email'];
      role = widget.user!['role'];
      isActive = widget.user!['is_actived'];
    }
  }

  void submit() async {
    if (!_formKey.currentState!.validate()) {
      _showSnack("Periksa kembali input");
      return;
    }

    try {
      if (isEdit) {
        await service.updateUser(
          id: widget.user!['id_user'],
          name: _name.text,
          email: _email.text,
          role: role,
          isActived: isActive,
        );
      } else {
        await service.addUser(
          name: _name.text,
          email: _email.text,
          password: _password.text,
          role: role,
          isActived: isActive,
        );
      }

      widget.onSuccess();
      Navigator.pop(context);

      Future.delayed(const Duration(milliseconds: 100), () {
        _showSnack(
          isEdit
              ? "User berhasil diperbarui"
              : "User berhasil ditambahkan",
        );
      });
    } catch (e) {
      _showSnack("Terjadi kesalahan");
    }
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: const Color(0xFF4A2419),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(20),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Container(
        width: 420,
        padding: const EdgeInsets.all(24),

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
                        isEdit ? "Edit User" : "Tambah User",
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF4A2419),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        isEdit
                            ? "Perbarui informasi user"
                            : "Lengkapi informasi user baru",
                        style:
                            TextStyle(color: Colors.grey[600], fontSize: 13),
                      ),
                    ],
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, color: Color(0xFF4A2419)),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              _input("Nama Lengkap", _name),
              _input("Email", _email),

              if (!isEdit) _input("Password", _password, isPassword: true),

              const SizedBox(height: 16),

              _sectionTitle("Peran"),
              const SizedBox(height: 6),
              _radioChip(
                ["kasir", "owner"],
                role,
                (v) => setState(() => role = v),
              ),

              const SizedBox(height: 14),

              _sectionTitle("Status"),
              const SizedBox(height: 6),
              _radioChipBool(isActive, (v) => setState(() => isActive = v)),

              const SizedBox(height: 24),

              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF4A2419),
                        side: const BorderSide(color: Color(0xFF4A2419)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text("Batal"),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4A2419),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: Text(
                        isEdit ? "Simpan" : "Tambah",
                        style: const TextStyle(color: Colors.white),
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

  Widget _input(
    String hint,
    TextEditingController c, {
    bool isPassword = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: c,
        obscureText: isPassword,

        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return "$hint wajib diisi";
          }

          if (hint == "Nama Lengkap" &&
              RegExp(r'[0-9]').hasMatch(value)) {
            return "Nama tidak boleh mengandung angka";
          }

          if (hint == "Email" && !value.contains("@")) {
            return "Format email tidak valid";
          }

          if (hint == "Password" && value.length < 8) {
            return "Minimal 8 karakter";
          }

          return null;
        },

        decoration: InputDecoration(
          hintText: hint,
          filled: true,
          fillColor: const Color(0xFFF8F5F2),

          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),

          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(
              color: Color(0xFF4A2419),
              width: 1.5,
            ),
          ),

          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Colors.red),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide:
                const BorderSide(color: Colors.red, width: 1.5),
          ),
          errorStyle: const TextStyle(color: Colors.red, fontSize: 12),

          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontWeight: FontWeight.bold,
        color: Color(0xFF4A2419),
      ),
    );
  }

  Widget _radioChip(
    List<String> items,
    String group,
    Function(String) onChange,
  ) {
    return Row(
      children: items.map((e) {
        final selected = e == group;
        return GestureDetector(
          onTap: () => onChange(e),
          child: Container(
            margin: const EdgeInsets.only(right: 10),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color:
                  selected ? const Color(0xFF4A2419) : Colors.grey.shade200,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              e,
              style: TextStyle(
                  color: selected ? Colors.white : Colors.black87),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _radioChipBool(bool group, Function(bool) onChange) {
    return Row(
      children: [
        _boolChip("Aktif", true, group, onChange),
        const SizedBox(width: 10),
        _boolChip("Nonaktif", false, group, onChange),
      ],
    );
  }

  Widget _boolChip(
      String text, bool val, bool group, Function(bool) onChange) {
    final selected = val == group;
    return GestureDetector(
      onTap: () => onChange(val),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color:
              selected ? const Color(0xFF4A2419) : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          text,
          style: TextStyle(
              color: selected ? Colors.white : Colors.black87),
        ),
      ),
    );
  }
}