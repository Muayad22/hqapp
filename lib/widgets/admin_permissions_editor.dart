import 'package:flutter/material.dart';
import 'package:hqapp/localization/app_localizations.dart';
import 'package:hqapp/models/adminrole.dart';
import 'package:hqapp/models/user_profile.dart';

/// Bottom sheet for super admins to configure another admin's page access.
class AdminPermissionsEditor extends StatefulWidget {
  final UserProfile target;
  final AdminPermissions initial;

  const AdminPermissionsEditor({
    super.key,
    required this.target,
    required this.initial,
  });

  static Future<AdminPermissions?> show(
    BuildContext context, {
    required UserProfile target,
    required AdminPermissions initial,
  }) {
    return showModalBottomSheet<AdminPermissions>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(ctx).bottom),
        child: AdminPermissionsEditor(target: target, initial: initial),
      ),
    );
  }

  @override
  State<AdminPermissionsEditor> createState() => _AdminPermissionsEditorState();
}

class _AdminPermissionsEditorState extends State<AdminPermissionsEditor> {
  late AdminFeedbackAccess _feedback;
  late bool _leaderboard;
  late AdminUserSupportAccess _userSupport;
  late bool _analytics;
  late AdminManageUsersAccess _manageUsers;
  late AdminQuizAccess _manageQuiz;

  @override
  void initState() {
    super.initState();
    _feedback = widget.initial.feedback;
    _leaderboard = widget.initial.leaderboard;
    _userSupport = widget.initial.userSupport;
    _analytics = widget.initial.analytics;
    _manageUsers = widget.initial.manageUsers;
    _manageQuiz = widget.initial.manageQuiz;
  }

  AdminPermissions get _draft => AdminPermissions(
    feedback: _feedback,
    leaderboard: _leaderboard,
    userSupport: _userSupport,
    analytics: _analytics,
    manageUsers: _manageUsers,
    manageQuiz: _manageQuiz,
  );

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              l.t(
                'admin_permissions_title',
                params: {'name': widget.target.fullName},
              ),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF6B4423),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l.t('admin_permissions_subtitle'),
              style: TextStyle(color: Colors.grey[600], fontSize: 13),
            ),
            const SizedBox(height: 20),
            _sectionTitle(l.t('admin_perm_feedback')),
            _feedbackSelector(l),
            const SizedBox(height: 16),
            _sectionTitle(l.t('admin_perm_user_support')),
            _userSupportSelector(l),
            const SizedBox(height: 16),
            _toggleRow(
              label: l.t('admin_perm_leaderboard'),
              value: _leaderboard,
              onChanged: (v) => setState(() => _leaderboard = v),
            ),
            _toggleRow(
              label: l.t('admin_perm_analytics'),
              value: _analytics,
              onChanged: (v) => setState(() => _analytics = v),
            ),
            _sectionTitle(l.t('admin_perm_manage_users')),
            _manageUsersSelector(l),
            const SizedBox(height: 16),
            _sectionTitle(l.t('admin_perm_manage_quiz')),
            _manageQuizSelector(l),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(l.t('cancel')),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    onPressed: () => Navigator.pop(context, _draft),
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF6B4423),
                    ),
                    child: Text(l.t('admin_permissions_save')),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
      ),
    );
  }

  Widget _toggleRow({
    required String label,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return SwitchListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(label, style: const TextStyle(fontSize: 14)),
      value: value,
      activeTrackColor: const Color(0xFF6B4423).withValues(alpha: 0.5),
      thumbColor: WidgetStateProperty.all(const Color(0xFF6B4423)),
      onChanged: onChanged,
    );
  }

  Widget _feedbackSelector(AppLocalizations l) {
    return SegmentedButton<AdminFeedbackAccess>(
      segments: [
        ButtonSegment(
          value: AdminFeedbackAccess.hidden,
          label: Text(l.t('admin_perm_hidden'), style: _segStyle),
        ),
        ButtonSegment(
          value: AdminFeedbackAccess.view,
          label: Text(l.t('admin_perm_view_only'), style: _segStyle),
        ),
        ButtonSegment(
          value: AdminFeedbackAccess.delete,
          label: Text(l.t('admin_perm_can_delete'), style: _segStyle),
        ),
      ],
      selected: {_feedback},
      onSelectionChanged: (s) => setState(() => _feedback = s.first),
    );
  }

  Widget _userSupportSelector(AppLocalizations l) {
    return SegmentedButton<AdminUserSupportAccess>(
      segments: [
        ButtonSegment(
          value: AdminUserSupportAccess.hidden,
          label: Text(l.t('admin_perm_hidden'), style: _segStyle),
        ),
        ButtonSegment(
          value: AdminUserSupportAccess.view,
          label: Text(l.t('admin_perm_view_only'), style: _segStyle),
        ),
        ButtonSegment(
          value: AdminUserSupportAccess.manage,
          label: Text(l.t('admin_perm_can_enable'), style: _segStyle),
        ),
      ],
      selected: {_userSupport},
      onSelectionChanged: (s) => setState(() => _userSupport = s.first),
    );
  }

  Widget _manageUsersSelector(AppLocalizations l) {
    return SegmentedButton<AdminManageUsersAccess>(
      segments: [
        ButtonSegment(
          value: AdminManageUsersAccess.hidden,
          label: Text(l.t('admin_perm_hidden'), style: _segStyle),
        ),
        ButtonSegment(
          value: AdminManageUsersAccess.view,
          label: Text(l.t('admin_perm_view_only'), style: _segStyle),
        ),
      ],
      selected: {_manageUsers},
      onSelectionChanged: (s) => setState(() => _manageUsers = s.first),
    );
  }

  Widget _manageQuizSelector(AppLocalizations l) {
    return SegmentedButton<AdminQuizAccess>(
      segments: [
        ButtonSegment(
          value: AdminQuizAccess.hidden,
          label: Text(l.t('admin_perm_hidden'), style: _segStyle),
        ),
        ButtonSegment(
          value: AdminQuizAccess.view,
          label: Text(l.t('admin_perm_view_only'), style: _segStyle),
        ),
        ButtonSegment(
          value: AdminQuizAccess.manage,
          label: Text(l.t('admin_perm_can_manage_quiz'), style: _segStyle),
        ),
      ],
      selected: {_manageQuiz},
      onSelectionChanged: (s) => setState(() => _manageQuiz = s.first),
    );
  }

  TextStyle get _segStyle => const TextStyle(fontSize: 11);
}
