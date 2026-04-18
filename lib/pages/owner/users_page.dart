import 'package:flutter/material.dart';
import 'package:opini_kopi/services/users_service.dart';
import 'package:opini_kopi/utils/responsive_helper.dart';
import 'package:opini_kopi/widgets/common/app_search_bar.dart';
import 'package:opini_kopi/widgets/owner/add_user_dialog.dart';
import 'package:opini_kopi/widgets/owner/delete_user_dialog.dart';

class UsersPage extends StatefulWidget {
  const UsersPage({super.key});

  @override
  State<UsersPage> createState() => _UsersPageState();
}

class _UsersPageState extends State<UsersPage> {
  final service = UsersService();

  List users = [];
  List filtered = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    load();
  }

  void load() async {
    setState(() => isLoading = true);
    final data = await service.getUsers();
    setState(() {
      users = data;
      filtered = data;
      isLoading = false;
    });
  }

  void search(String value) {
    setState(() {
      filtered = users.where((u) {
        return u['name'].toLowerCase().contains(value.toLowerCase()) ||
            u['email'].toLowerCase().contains(value.toLowerCase());
      }).toList();
    });
  }

  int total() => users.length;
  int active() => users.where((e) => e['is_actived']).length;
  int inactive() => users.where((e) => !e['is_actived']).length;

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
              child: isCompact
                  ? ListView(
                      children: [
                        header(true),
                        const SizedBox(height: 24),
                        stats(true),
                        const SizedBox(height: 24),
                        tableSection(true),
                      ],
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        header(false),
                        const SizedBox(height: 24),
                        stats(false),
                        const SizedBox(height: 24),
                        Expanded(child: tableSection(false)),
                      ],
                    ),
            );
          },
        ),
      ),
    );
  }

  Widget header(bool isCompact) {
    final title = const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Manajemen Pengguna",
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Color(0xFF4E342E),
          ),
        ),
        SizedBox(height: 4),
        Text(
          "Kelola akun staff coffee shop.",
          style: TextStyle(color: Colors.black45, fontSize: 16),
        ),
      ],
    );
    final searchField = AppSearchBar(hintText: "Cari Pengguna...", onChanged: search);
    final addButton = ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF4A2419),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      onPressed: () {
        showDialog(
          context: context,
          builder: (_) => AddUserDialog(onSuccess: load),
        );
      },
      icon: const Icon(Icons.add, size: 18, color: Colors.white),
      label: const Text("Tambah Pengguna", style: TextStyle(color: Colors.white)),
    );

    if (isCompact) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          title,
          const SizedBox(height: 16),
          searchField,
          const SizedBox(height: 12),
          SizedBox(width: double.infinity, child: addButton),
        ],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: title),
        const SizedBox(width: 16),
        SizedBox(width: 260, child: searchField),
        const SizedBox(width: 12),
        addButton,
      ],
    );
  }

  Widget stats(bool isCompact) {
    final cards = [
      statCard("Total Pengguna Terdaftar", total(), Icons.people, Colors.brown),
      statCard("Jumlah Pengguna Aktif", active(), Icons.check, Colors.green),
      statCard("Jumlah Pengguna Non-Aktif", inactive(), Icons.close, Colors.red),
    ];

    if (isCompact) {
      return Column(
        children: [
          for (var i = 0; i < cards.length; i++) ...[
            cards[i],
            if (i != cards.length - 1) const SizedBox(height: 12),
          ],
        ],
      );
    }

    return Row(
      children: [
        for (var i = 0; i < cards.length; i++) ...[
          Expanded(child: cards[i]),
          if (i != cards.length - 1) const SizedBox(width: 12),
        ],
      ],
    );
  }

  Widget statCard(String title, int value, IconData icon, Color color) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: TextStyle(
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value.toString(),
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget tableSection(bool isCompact) {
    return Container(
      padding: EdgeInsets.all(isCompact ? 16 : 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Daftar Pengguna",
            style: TextStyle(
              fontSize: isCompact ? 18 : 20,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF4E342E),
            ),
          ),
          const SizedBox(height: 12),
          if (isCompact)
            _buildCompactTableContent()
          else
            Expanded(child: _buildDesktopTableContent()),
        ],
      ),
    );
  }

  Widget _buildCompactTableContent() {
    if (isLoading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 32),
        child: Center(
          child: SizedBox(
            width: 28,
            height: 28,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              color: Color(0xFF4A2419),
            ),
          ),
        ),
      );
    }

    if (filtered.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Center(
          child: Text(
            "Belum ada Pengguna.",
            style: TextStyle(color: Colors.black54),
          ),
        ),
      );
    }

    return ListView.separated(
      itemCount: filtered.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, i) => mobileRow(filtered[i]),
    );
  }

  Widget _buildDesktopTableContent() {
    if (isLoading) {
      return const Center(
        child: SizedBox(
          width: 28,
          height: 28,
          child: CircularProgressIndicator(
            strokeWidth: 3,
            color: Color(0xFF4A2419),
          ),
        ),
      );
    }

    if (filtered.isEmpty) {
      return const Center(
        child: Text(
          "Belum ada Pengguna.",
          style: TextStyle(color: Colors.black54),
        ),
      );
    }

    return Column(
      children: [
        tableHeader(),
        const SizedBox(height: 12),
        const Divider(),
        Expanded(
          child: ListView.builder(
            itemCount: filtered.length,
            itemBuilder: (context, i) => tableRow(filtered[i]),
          ),
        ),
      ],
    );
  }

  Widget tableHeader() {
    return const Row(
      children: [
        Expanded(flex: 2, child: Text("Nama")),
        Expanded(flex: 3, child: Text("Email")),
        Expanded(flex: 1, child: Center(child: Text("Peran"))),
        Expanded(flex: 1, child: Center(child: Text("Status"))),
        SizedBox(width: 90, child: Text("Aksi")),
      ],
    );
  }

  Widget tableRow(Map u) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(flex: 2, child: _identity(u)),
            Expanded(
              flex: 3,
              child: Text(
                u['email'],
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Expanded(flex: 1, child: Center(child: tag(u['role']))),
            Expanded(
              flex: 1,
              child: Center(
                child: tag(
                  u['is_actived'] ? "Aktif" : "Nonaktif",
                  u['is_actived'] ? Colors.green : Colors.grey,
                ),
              ),
            ),
            SizedBox(width: 90, child: _actions(u)),
          ],
        ),
        const Divider(height: 28),
      ],
    );
  }

  Widget mobileRow(Map u) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFCFAF8),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE8DFD8)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _identity(u)),
              const SizedBox(width: 12),
              _actions(u),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            u['email'],
            style: const TextStyle(color: Colors.black87),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              tag(u['role']),
              tag(
                u['is_actived'] ? "Aktif" : "Nonaktif",
                u['is_actived'] ? Colors.green : Colors.grey,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _identity(Map u) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          radius: 18,
          backgroundColor: const Color(0xFF4A2419).withOpacity(0.15),
          child: Text(
            u['name'][0].toUpperCase(),
            style: const TextStyle(
              color: Color(0xFF4A2419),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            u['name'],
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: Color(0xFF2B1B18),
            ),
          ),
        ),
      ],
    );
  }

  Widget _actions(Map u) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        action(Icons.edit_outlined, () {
          showDialog(
            context: context,
            builder: (_) => AddUserDialog(user: u, onSuccess: load),
          );
        }),
        const SizedBox(width: 6),
        action(Icons.delete_outline, () {
          showDialog(
            context: context,
            builder: (_) => DeleteUserDialog(
              onConfirm: () async {
                await service.deleteUser(u['id_user']);
                load();
              },
            ),
          );
        }, Colors.red),
      ],
    );
  }

  Widget tag(String text, [Color? color]) {
    final c = color ?? const Color(0xFF4A2419);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: c.withOpacity(0.12),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        text,
        style: TextStyle(color: c, fontSize: 11, fontWeight: FontWeight.w500),
      ),
    );
  }

  Widget action(IconData icon, VoidCallback onTap, [Color? color]) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.all(7),
        child: Icon(icon, size: 18, color: color ?? Colors.black),
      ),
    );
  }
}
