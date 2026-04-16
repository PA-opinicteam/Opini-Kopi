import 'package:flutter/material.dart';
import 'package:opini_kopi/constants/app_colors.dart';

class OwnerSidebarWidget extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onTap;
  final VoidCallback onLogout;

  const OwnerSidebarWidget({
    super.key,
    required this.selectedIndex,
    required this.onTap,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      child: SizedBox(
        width: 260,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 14, 14, 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE8DFD8)),
                ),
                child: const Row(
                  children: [
                    CircleAvatar(
                      radius: 18,
                      backgroundColor: Color(0xFF4A2419),
                      child: Icon(Icons.coffee_outlined, color: Colors.white),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Opini Kopi',
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF4A2419),
                            ),
                          ),
                          Text(
                            'SHOP MANAGEMENT',
                            style: TextStyle(fontSize: 10),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              Expanded(
                child: ListView(
                  children: [
                    _item(0, "Dashboard", Icons.dashboard_outlined),
                    _item(1, "Menu", Icons.restaurant_menu_outlined),
                    _item(2, "Laporan", Icons.receipt_long_outlined),
                    _item(3, "Stok", Icons.inventory_2_outlined),
                    _item(4, "User", Icons.people_alt_outlined),
                  ],
                ),
              ),

              InkWell(
                onTap: onLogout,
                borderRadius: BorderRadius.circular(10),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 10,
                    horizontal: 6,
                  ),
                  child: Row(
                    children: const [
                      Icon(Icons.logout, color: Color(0xFF4A2419), size: 20),
                      SizedBox(width: 8),
                      Text(
                        "Keluar",
                        style: TextStyle(
                          color: Color(0xFF4A2419),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _item(int index, String title, IconData icon) {
    final isSelected = selectedIndex == index;

    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: InkWell(
        onTap: () => onTap(index),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF7A5240) : null,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(icon, color: isSelected ? Colors.white : Colors.grey),
              const SizedBox(width: 10),
              Text(
                title,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class OwnerBottomNavigationBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onTap;

  const OwnerBottomNavigationBar({
    super.key,
    required this.selectedIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      selectedIndex: selectedIndex,
      onDestinationSelected: onTap,
      backgroundColor: AppColors.surface,
      indicatorColor: AppColors.primarySoft,
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.dashboard_outlined),
          selectedIcon: Icon(Icons.dashboard),
          label: 'Dashboard',
        ),
        NavigationDestination(
          icon: Icon(Icons.restaurant_menu_outlined),
          selectedIcon: Icon(Icons.restaurant_menu),
          label: 'Menu',
        ),
        NavigationDestination(
          icon: Icon(Icons.receipt_long_outlined),
          selectedIcon: Icon(Icons.receipt_long),
          label: 'Laporan',
        ),
        NavigationDestination(
          icon: Icon(Icons.inventory_2_outlined),
          selectedIcon: Icon(Icons.inventory_2),
          label: 'Stok',
        ),
        NavigationDestination(
          icon: Icon(Icons.people_alt_outlined),
          selectedIcon: Icon(Icons.people_alt),
          label: 'User',
        ),
      ],
    );
  }
}
