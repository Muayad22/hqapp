import 'package:flutter/material.dart';
import 'package:hqapp/models/user_profile.dart';
import 'package:hqapp/services/firestore_service.dart';
import 'package:hqapp/localization/app_localizations.dart';

class ManageUsersScreen extends StatefulWidget {
  final UserProfile viewer;

  const ManageUsersScreen({super.key, required this.viewer});

  @override
  State<ManageUsersScreen> createState() => _ManageUsersScreenState();
}

class _ManageUsersScreenState extends State<ManageUsersScreen> {
  Future<void> _deleteUser(BuildContext context, UserProfile profile) async {
    final l = AppLocalizations.of(context);
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l.t('admin_delete_user_q')),
        content: Text(
          l.t(
            'admin_delete_user_msg',
            params: {'name': profile.fullName},
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l.t('cancel')),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: Text(l.t('admin_delete')),
          ),
        ],
      ),
    );

    if (confirm != true) return;
    await FirestoreService.deleteUser(profile.id);
    if (!context.mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(
      SnackBar(
        content: Text(
          l.t('admin_user_removed', params: {'name': profile.fullName}),
        ),
      ),
    );
  }

  Future<void> _toggleAdminStatus(
    BuildContext context,
    UserProfile profile,
  ) async {
    final l = AppLocalizations.of(context);
    final grantStaff = !profile.hasStaffAccess;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          grantStaff ? l.t('admin_make_admin_q') : l.t('admin_remove_admin_q'),
        ),
        content: Text(
          grantStaff
              ? l.t(
                  'admin_make_admin_msg',
                  params: {'name': profile.fullName},
                )
              : l.t(
                  'admin_remove_admin_msg',
                  params: {'name': profile.fullName},
                ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l.t('cancel')),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              grantStaff
                  ? l.t('admin_make_admin_btn')
                  : l.t('admin_remove_admin_btn'),
            ),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await FirestoreService.updateUserAdminStatus(profile.id, grantStaff);
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              grantStaff
                  ? l.t('admin_now_admin', params: {'name': profile.fullName})
                  : l.t(
                      'admin_admin_removed',
                      params: {'name': profile.fullName},
                    ),
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
  }

  (IconData, Color) _roleIconStyle(UserProfile profile) {
    switch (profile.adminRole) {
      case AdminRole.none:
        return (Icons.person, Colors.blue);
      case AdminRole.admin:
        return (Icons.admin_panel_settings, Colors.orange);
      case AdminRole.superAdmin:
        return (Icons.admin_panel_settings, Colors.deepPurple);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final canManageAccounts = widget.viewer.isSuperAdmin;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          l.t('admin_users_title'),
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        backgroundColor: const Color(0xFF6B4423),
        foregroundColor: Colors.white,
        elevation: 2,
        centerTitle: true,
      ),
      body: StreamBuilder<List<UserProfile>>(
        stream: FirestoreService.usersStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 48, color: Colors.red[300]),
                  const SizedBox(height: 16),
                  Text(
                    l.t('admin_users_error_title'),
                    style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    snapshot.error.toString(),
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => setState(() {}),
                    child: Text(l.t('admin_retry')),
                  ),
                ],
              ),
            );
          }

          final users = snapshot.data ?? [];
          if (users.isEmpty) {
            return Center(child: Text(l.t('admin_no_users')));
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: users.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final profile = users[index];
              final isSelf = profile.id == widget.viewer.id;
              final (iconData, iconColor) = _roleIconStyle(profile);
              return Card(
                child: ListTile(
                  leading: CircleAvatar(
                    child: Text(
                      profile.fullName.isEmpty
                          ? '?'
                          : profile.fullName[0].toUpperCase(),
                    ),
                  ),
                  title: Text(profile.fullName),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(profile.email),
                      Text(
                        '${l.t('admin_contact')}: ${profile.contactNo.isEmpty ? '-' : profile.contactNo}',
                      ),
                      Text(
                        '${l.t('admin_role')}: ${l.t(profile.staffRoleL10nKey)}',
                      ),
                    ],
                  ),
                  trailing: canManageAccounts
                      ? Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(
                                iconData,
                                color: iconColor,
                              ),
                              onPressed: () =>
                                  _toggleAdminStatus(context, profile),
                              tooltip: profile.hasStaffAccess
                                  ? l.t('admin_remove_admin_btn')
                                  : l.t('admin_make_admin_btn'),
                            ),
                            IconButton(
                              icon: Icon(
                                Icons.delete,
                                color: isSelf ? Colors.grey : Colors.red,
                              ),
                              onPressed: isSelf
                                  ? null
                                  : () => _deleteUser(context, profile),
                              tooltip: isSelf ? null : l.t('admin_delete'),
                            ),
                          ],
                        )
                      : null,
                ),
              );
            },
          );
        },
      ),
    );
  }
}
