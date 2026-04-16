import 'package:flutter/material.dart';

class DeleteMenuDialog extends StatelessWidget {
  final VoidCallback onConfirm;
  const DeleteMenuDialog({super.key, required this.onConfirm});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: SizedBox(
        width: 400,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Hapus Menu",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF4A2419),
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                "Apakah anda yakin ingin menghapus menu ini?",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.black54, fontSize: 13),
              ),
              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    onConfirm();

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text("Menu berhasil dihapus"),
                        backgroundColor: const Color(0xFF4A2419),
                        behavior: SnackBarBehavior.floating,
                        margin: const EdgeInsets.all(20),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4A2419),
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 44),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    "Hapus",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),

              const SizedBox(height: 8),

              TextButton(
                onPressed: () => Navigator.pop(context),
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFF4A2419),
                ),
                child: const Text("Batal", style: TextStyle(fontSize: 13)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
