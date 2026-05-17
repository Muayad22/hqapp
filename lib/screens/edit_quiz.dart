import 'package:flutter/material.dart';
import 'package:hqapp/localization/app_localizations.dart';
import 'package:hqapp/models/quiz_question_entry.dart';
import 'package:hqapp/models/user_profile.dart';
import 'package:hqapp/services/firestore_service.dart';

/// Admin: view or manage quiz questions (English + Arabic) per category.
class EditQuizScreen extends StatefulWidget {
  final UserProfile viewer;

  const EditQuizScreen({super.key, required this.viewer});

  @override
  State<EditQuizScreen> createState() => _EditQuizScreenState();
}

class _EditQuizScreenState extends State<EditQuizScreen> {
  String _category = QuizCategories.general;

  bool get _canManage => widget.viewer.effectivePermissions.canManageQuiz;

  Future<void> _openQuestionForm({QuizQuestionEntry? existing}) async {
    if (!_canManage) return;
    final l = AppLocalizations.of(context);
    final result = await showDialog<QuizQuestionEntry>(
      context: context,
      builder: (ctx) => _QuestionFormDialog(
        existing: existing,
        category: _category,
        l: l,
      ),
    );
    if (result == null || !mounted) return;

    if (result.questionEn.isEmpty || result.questionAr.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l.t('manage_quiz_fill_required'))),
      );
      return;
    }

    try {
      if (existing == null) {
        await FirestoreService.addQuizQuestion(
          category: _category,
          entry: result,
        );
      } else {
        await FirestoreService.updateQuizQuestion(
          category: _category,
          entry: result,
        );
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l.t('manage_quiz_saved'))),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _deleteQuestion(QuizQuestionEntry q) async {
    if (!_canManage) return;
    final l = AppLocalizations.of(context);
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l.t('manage_quiz_delete_q')),
        content: Text(l.t('manage_quiz_delete_msg')),
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
    await FirestoreService.deleteQuizQuestion(
      category: _category,
      questionId: q.id,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: Text(
          l.t('manage_quiz_title'),
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
              onPressed: () => _openQuestionForm(),
              child: const Icon(Icons.add, size: 28),
            ),
      body: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: SegmentedButton<String>(
                    segments: [
                      ButtonSegment(
                        value: QuizCategories.general,
                        label: Text(l.t('quiz_category_general')),
                      ),
                      ButtonSegment(
                        value: QuizCategories.imamRoom,
                        label: Text(l.t('quiz_category_imam')),
                      ),
                    ],
                    selected: {_category},
                    onSelectionChanged: (s) =>
                        setState(() => _category = s.first),
                  ),
                ),
                if (!_canManage)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      l.t('manage_quiz_view_only_hint'),
                      style: TextStyle(color: Colors.grey[700], fontSize: 13),
                    ),
                  ),
                const SizedBox(height: 8),
                Expanded(
                  child: StreamBuilder<List<QuizQuestionEntry>>(
                    stream: FirestoreService.quizQuestionsStream(_category),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      }
                      final list = snapshot.data ?? [];
                      if (list.isEmpty) {
                        return Center(child: Text(l.t('manage_quiz_empty')));
                      }
                      return ListView.separated(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 88),
                        itemCount: list.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 8),
                        itemBuilder: (context, index) {
                          final q = list[index];
                          return Card(
                            child: ListTile(
                              title: Text(
                                q.questionEn,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              subtitle: Text(
                                q.questionAr,
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
                                              _openQuestionForm(existing: q),
                                        ),
                                        IconButton(
                                          icon: Icon(
                                            Icons.delete_outline,
                                            color: Colors.red.shade700,
                                          ),
                                          onPressed: () =>
                                              _deleteQuestion(q),
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

/// Dialog form; controllers live only here to avoid dispose-after-pop crashes.
class _QuestionFormDialog extends StatefulWidget {
  final QuizQuestionEntry? existing;
  final String category;
  final AppLocalizations l;

  const _QuestionFormDialog({
    required this.existing,
    required this.category,
    required this.l,
  });

  @override
  State<_QuestionFormDialog> createState() => _QuestionFormDialogState();
}

class _QuestionFormDialogState extends State<_QuestionFormDialog> {
  late final TextEditingController _qEn;
  late final TextEditingController _qAr;
  late final TextEditingController _expEn;
  late final TextEditingController _expAr;
  late final List<TextEditingController> _optEn;
  late final List<TextEditingController> _optAr;
  late int _correct;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _qEn = TextEditingController(text: e?.questionEn ?? '');
    _qAr = TextEditingController(text: e?.questionAr ?? '');
    _expEn = TextEditingController(text: e?.explanationEn ?? '');
    _expAr = TextEditingController(text: e?.explanationAr ?? '');
    _optEn = List.generate(
      4,
      (i) => TextEditingController(
        text: e != null && i < e.optionsEn.length ? e.optionsEn[i] : '',
      ),
    );
    _optAr = List.generate(
      4,
      (i) => TextEditingController(
        text: e != null && i < e.optionsAr.length ? e.optionsAr[i] : '',
      ),
    );
    _correct = e?.correctIndex ?? 0;
    if (_correct < 0 || _correct > 3) _correct = 0;
  }

  @override
  void dispose() {
    _qEn.dispose();
    _qAr.dispose();
    _expEn.dispose();
    _expAr.dispose();
    for (final c in _optEn) {
      c.dispose();
    }
    for (final c in _optAr) {
      c.dispose();
    }
    super.dispose();
  }

  void _submit() {
    Navigator.pop(
      context,
      QuizQuestionEntry(
        id: widget.existing?.id ?? '',
        category: widget.category,
        questionEn: _qEn.text.trim(),
        questionAr: _qAr.text.trim(),
        optionsEn: _optEn.map((c) => c.text.trim()).toList(),
        optionsAr: _optAr.map((c) => c.text.trim()).toList(),
        correctIndex: _correct,
        explanationEn: _expEn.text.trim(),
        explanationAr: _expAr.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = widget.l;
    return AlertDialog(
      title: Text(
        widget.existing == null
            ? l.t('manage_quiz_add_question')
            : l.t('manage_quiz_edit_question'),
      ),
      content: SingleChildScrollView(
        child: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _qEn,
                decoration: InputDecoration(
                  labelText: l.t('manage_quiz_question_en'),
                ),
              ),
              TextField(
                controller: _qAr,
                decoration: InputDecoration(
                  labelText: l.t('manage_quiz_question_ar'),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _expEn,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: l.t('manage_quiz_explanation_en'),
                ),
              ),
              TextField(
                controller: _expAr,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: l.t('manage_quiz_explanation_ar'),
                ),
              ),
              const SizedBox(height: 12),
              ...List.generate(4, (i) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Radio<int>(
                        value: i,
                        groupValue: _correct,
                        onChanged: (v) => setState(() => _correct = v!),
                      ),
                      Expanded(
                        child: Column(
                          children: [
                            TextField(
                              controller: _optEn[i],
                              decoration: InputDecoration(
                                labelText: l.t(
                                  'manage_quiz_option_en',
                                  params: {'n': '${i + 1}'},
                                ),
                              ),
                            ),
                            TextField(
                              controller: _optAr[i],
                              decoration: InputDecoration(
                                labelText: l.t(
                                  'manage_quiz_option_ar',
                                  params: {'n': '${i + 1}'},
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }),
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
