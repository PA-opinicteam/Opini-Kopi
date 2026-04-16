import 'package:flutter/material.dart';

class SidebarWidget extends StatelessWidget {
  final String selectedCategory;
  final VoidCallback onCoffeeTap;
  final VoidCallback onNonCoffeeTap;
  final VoidCallback onSnackTap;
  final VoidCallback onExitTap;

  const SidebarWidget({
    super.key,
    required this.selectedCategory,
    required this.onCoffeeTap,
    required this.onNonCoffeeTap,
    required this.onSnackTap,
    required this.onExitTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 260,
      child: Container(
        height: double.infinity,
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Opinic Cashier',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2B1B18),
              ),
            ),

            const SizedBox(height: 28),

            const Text(
              'Main Menu',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),

            const SizedBox(height: 16),

            _SidebarMenuItem(
              icon: Icons.local_cafe_outlined,
              title: 'Coffee',
              isActive: selectedCategory.toLowerCase() == 'coffee',
              onTap: onCoffeeTap,
            ),

            const SizedBox(height: 12),

            _SidebarMenuItem(
              icon: Icons.emoji_food_beverage_outlined,
              title: 'Non-Coffee',
              isActive: selectedCategory.toLowerCase() == 'non-coffee',
              onTap: onNonCoffeeTap,
            ),

            const SizedBox(height: 12),

            _SidebarMenuItem(
              icon: Icons.fastfood_outlined,
              title: 'Snack',
              isActive: selectedCategory.toLowerCase() == 'snack',
              onTap: onSnackTap,
            ),

            const Spacer(),

            SizedBox(
              width: double.infinity,
              child: _BottomMenuItem(
                icon: Icons.logout,
                title: 'Keluar',
                onTap: onExitTap,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SidebarMenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool isActive;
  final VoidCallback onTap;

  const _SidebarMenuItem({
    required this.icon,
    required this.title,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFFF2E8E3) : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 20,
              color: isActive ? const Color(0xFF4A2419) : Colors.grey,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                  color: isActive ? const Color(0xFF4A2419) : Colors.grey,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BottomMenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _BottomMenuItem({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            Icon(icon, size: 18, color: Color(0xFF4A2419)),
            const SizedBox(width: 10),
            const Text(
              'Logout',
              style: TextStyle(fontSize: 14, color: Color(0xFF4A2419)),
            ),
          ],
        ),
      ),
    );
  }
}
