import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:opini_kopi/constants/app_colors.dart';
import 'package:opini_kopi/providers/notification_provider.dart';
import 'package:opini_kopi/utils/responsive_helper.dart';
import 'package:provider/provider.dart';

class NotificationPage extends StatelessWidget {
  const NotificationPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isCompact = ResponsiveHelper.isMobile(context);
    final padding = isCompact ? 16.0 : ResponsiveHelper.pagePadding(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(padding),
          child: Consumer<NotificationProvider>(
            builder: (context, provider, _) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _Header(
                    unread: provider.unreadCount,
                    onReadAll: provider.items.isEmpty
                        ? null
                        : provider.markAllRead,
                  ),
                  SizedBox(height: isCompact ? 16 : 24),
                  Expanded(
                    child: provider.items.isEmpty
                        ? const _EmptyState()
                        : ListView.separated(
                            itemCount: provider.items.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 10),
                            itemBuilder: (context, index) {
                              final item = provider.items[index];
                              return _NotificationTile(
                                item: item,
                                onTap: () => provider.markRead(item.id),
                              );
                            },
                          ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final int unread;
  final VoidCallback? onReadAll;

  const _Header({required this.unread, required this.onReadAll});

  @override
  Widget build(BuildContext context) {
    final isCompact = ResponsiveHelper.isMobile(context);
    final title = Row(
      children: [
        if (isCompact) ...[
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back, color: AppColors.textBrown),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
          const SizedBox(width: 12),
        ],
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Notifikasi Stok',
              style: TextStyle(
                fontSize: isCompact ? 20 : 28,
                fontWeight: FontWeight.bold,
                color: AppColors.textBrown,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '$unread belum dibaca',
              style: TextStyle(color: Colors.black45, fontSize: isCompact ? 13 : 15),
            ),
          ],
        ),
      ],
    );

    final action = OutlinedButton.icon(
      onPressed: onReadAll,
      icon: const Icon(Icons.done_all, size: 18),
      label: const Text('Tandai dibaca'),
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.primary,
        side: const BorderSide(color: AppColors.primary),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );

    if (isCompact) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          title,
          const SizedBox(height: 12),
          SizedBox(width: double.infinity, child: action),
        ],
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [title, action],
    );
  }
}

class _NotificationTile extends StatelessWidget {
  final StockNotificationItem item;
  final VoidCallback onTap;

  const _NotificationTile({required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final date = DateFormat(
      'dd MMM yyyy HH:mm',
      'id_ID',
    ).format(item.createdAt);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        constraints: const BoxConstraints(minHeight: 100),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: item.isRead ? AppColors.border : AppColors.warning,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.warning.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.warning_amber_rounded,
                color: AppColors.warning,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          item.title,
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            color: AppColors.textDark,
                          ),
                        ),
                      ),
                      if (!item.isRead)
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    item.message,
                    style: const TextStyle(color: Colors.black54, height: 1.35),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    date,
                    style: const TextStyle(color: Colors.black38, fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: const Text(
          'Belum ada notifikasi stok.',
          style: TextStyle(color: Colors.black54),
        ),
      ),
    );
  }
}
