import 'package:flutter/material.dart';
import 'package:hqapp/localization/app_localizations.dart';
import 'package:hqapp/models/disabled_account_appeal.dart';
import 'package:hqapp/models/user_profile.dart';
import 'package:hqapp/services/firestore_service.dart';

/// Lists messages from disabled users; super admins can re-enable accounts.
class AdminUserSupportScreen extends StatelessWidget {
  final UserProfile viewer;

  const AdminUserSupportScreen({super.key, required this.viewer});

  String _formatTime(int? millis) {
    if (millis == null) return '—';
    final dt = DateTime.fromMillisecondsSinceEpoch(millis);
    return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')} '
        '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _enableFromAppeal(
    BuildContext context,
    DisabledAccountAppeal appeal,
  ) async {
    final l = AppLocalizations.of(context);
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l.t('admin_enable_user_q')),
        content: Text(
          l.t(
            'admin_user_support_enable_confirm',
            params: {'name': appeal.fullName},
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l.t('cancel')),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
            child: Text(l.t('admin_enable')),
          ),
        ],
      ),
    );
    if (confirm != true || !context.mounted) return;
    try {
      await FirestoreService.resolveAppealAndEnableAccount(
        appealId: appeal.id,
        userId: appeal.userId,
      );
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            l.t('admin_user_enabled', params: {'name': appeal.fullName}),
          ),
        ),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            l.t('admin_update_user_error', params: {'error': e.toString()}),
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final canEnable = viewer.effectivePermissions.canEnableFromUserSupport;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          l.t('admin_user_support_title'),
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        backgroundColor: const Color(0xFF6B4423),
        foregroundColor: Colors.white,
        elevation: 2,
        centerTitle: true,
      ),
      body: StreamBuilder<List<DisabledAccountAppeal>>(
        stream: FirestoreService.disabledAccountAppealsStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, size: 48, color: Colors.red[300]),
                    const SizedBox(height: 16),
                    Text(snapshot.error.toString(), textAlign: TextAlign.center),
                  ],
                ),
              ),
            );
          }
          final appeals = snapshot.data ?? [];
          if (appeals.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  l.t('admin_user_support_empty'),
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey[700]),
                ),
              ),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: appeals.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final a = appeals[index];
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        a.fullName.isEmpty ? a.email : a.fullName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        a.email,
                        style: TextStyle(
                          color: Colors.grey[700],
                          fontSize: 13,
                        ),
                      ),
                      Text(
                        _formatTime(a.createdAt),
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        l.t('admin_user_support_message_label'),
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[800],
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 4),
                      SelectableText(
                        a.message,
                        style: const TextStyle(height: 1.35),
                      ),
                      if (!a.resolved && canEnable) ...[
                        const SizedBox(height: 14),
                        FilledButton.icon(
                          onPressed: () => _enableFromAppeal(context, a),
                          icon: const Icon(Icons.person_outline, size: 20),
                          label: Text(l.t('admin_user_support_enable_account')),
                          style: FilledButton.styleFrom(
                            backgroundColor: Colors.green.shade700,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
