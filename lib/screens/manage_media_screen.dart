import 'package:flutter/material.dart';
import 'package:hqapp/localization/app_localizations.dart';
import 'package:hqapp/models/media_entry.dart';
import 'package:hqapp/models/user_profile.dart';
import 'package:hqapp/services/firestore_service.dart';

/// Admin: view or manage media items (name + URL).
class ManageMediaScreen extends StatefulWidget {
  final UserProfile viewer;

  const ManageMediaScreen({super.key, required this.viewer});

  @override
  State<ManageMediaScreen> createState() => _ManageMediaScreenState();
}

class _ManageMediaScreenState extends State<ManageMediaScreen> {
  bool get _canManage => widget.viewer.effectivePermissions.canManageMedia;

  Future<void> _openMediaForm({MediaEntry? existing}) async {
    if (!_canManage) return;
    final l = AppLocalizations.of(context);
    final result = await showDialog<MediaEntry>(
      context: context,
      builder: (ctx) => _MediaFormDialog(existing: existing, l: l),
    );
    if (result == null || !mounted) return;

    if (result.name.isEmpty || result.url.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l.t('manage_media_fill_required'))),
      );
      return;
    }

    try {
      if (existing == null) {
        await FirestoreService.addMediaItem(entry: result);
      } else {
        await FirestoreService.updateMediaItem(entry: result);
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l.t('manage_media_saved'))),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _deleteMedia(MediaEntry item) async {
    if (!_canManage) return;
    final l = AppLocalizations.of(context);
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l.t('manage_media_delete_q')),
        content: Text(l.t('manage_media_delete_msg')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l.t('cancel')),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l.t('admin_feedback_delete_btn')),
          ),
        ],
      ),
    );
    if (ok != true) return;
    await FirestoreService.deleteMediaItem(mediaId: item.id);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: Text(
          l.t('manage_media_title'),
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        backgroundColor: const Color(0xFF6B4423),
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      floatingActionButton: !_canManage
          ? null
          : FloatingActionButton(
              backgroundColor: Colors.white,
              foregroundColor: const Color(0xFF6B4423),
              elevation: 4,
              onPressed: () => _openMediaForm(),
              child: const Icon(Icons.add, size: 28),
            ),
      body: Column(
        children: [
          if (!_canManage)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Text(
                l.t('manage_media_view_only_hint'),
                style: TextStyle(color: Colors.grey[700], fontSize: 13),
              ),
            ),
          const SizedBox(height: 8),
          Expanded(
            child: StreamBuilder<List<MediaEntry>>(
              stream: FirestoreService.mediaItemsStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                final list = snapshot.data ?? [];
                if (list.isEmpty) {
                  return Center(child: Text(l.t('manage_media_empty')));
                }
                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 88),
                  itemCount: list.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final item = list[index];
                    return Card(
                      child: ListTile(
                        title: Text(
                          item.name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: Text(
                          item.url,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        trailing: _canManage
                            ? Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit),
                                    onPressed: () =>
                                        _openMediaForm(existing: item),
                                  ),
                                  IconButton(
                                    icon: Icon(
                                      Icons.delete_outline,
                                      color: Colors.red.shade700,
                                    ),
                                    onPressed: () => _deleteMedia(item),
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
          ),
        ],
      ),
    );
  }
}

class _MediaFormDialog extends StatefulWidget {
  final MediaEntry? existing;
  final AppLocalizations l;

  const _MediaFormDialog({required this.existing, required this.l});

  @override
  State<_MediaFormDialog> createState() => _MediaFormDialogState();
}

class _MediaFormDialogState extends State<_MediaFormDialog> {
  late final TextEditingController _name;
  late final TextEditingController _url;

  @override
  void initState() {
    super.initState();
    _name = TextEditingController(text: widget.existing?.name ?? '');
    _url = TextEditingController(text: widget.existing?.url ?? '');
  }

  @override
  void dispose() {
    _name.dispose();
    _url.dispose();
    super.dispose();
  }

  void _submit() {
    Navigator.pop(
      context,
      MediaEntry(
        id: widget.existing?.id ?? '',
        name: _name.text.trim(),
        url: _url.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = widget.l;
    return AlertDialog(
      title: Text(
        widget.existing == null
            ? l.t('manage_media_add')
            : l.t('manage_media_edit'),
      ),
      content: SingleChildScrollView(
        child: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _name,
                decoration: InputDecoration(
                  labelText: l.t('manage_media_name'),
                ),
              ),
              TextField(
                controller: _url,
                keyboardType: TextInputType.url,
                decoration: InputDecoration(
                  labelText: l.t('manage_media_url'),
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l.t('cancel')),
        ),
        FilledButton(
          onPressed: _submit,
          style: FilledButton.styleFrom(
            backgroundColor: const Color(0xFF6B4423),
          ),
          child: Text(l.t('save')),
        ),
      ],
    );
  }
}
