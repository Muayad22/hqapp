import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:hqapp/localization/app_localizations.dart';
import 'package:hqapp/models/quiz_result.dart';
import 'package:hqapp/models/user_profile.dart';
import 'package:hqapp/services/firestore_service.dart';

class AdminAnalyticsChartsScreen extends StatelessWidget {
  const AdminAnalyticsChartsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: Text(
          l.t('admin_analytics_title'),
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        backgroundColor: const Color(0xFF6B4423),
        foregroundColor: Colors.white,
        elevation: 2,
        centerTitle: true,
      ),
      body: StreamBuilder<List<UserProfile>>(
        stream: FirestoreService.usersStream(),
        builder: (context, usersSnap) {
          if (usersSnap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (usersSnap.hasError) {
            return _ErrorState(message: usersSnap.error.toString());
          }

          final allUsers = usersSnap.data ?? const <UserProfile>[];
          final users = allUsers.where((u) => !u.isAdmin).toList();

          if (users.isEmpty) {
            return _EmptyState(message: l.t('admin_analytics_empty_users'));
          }

          final localCount = users
              .where((u) => (u.visitorType).toLowerCase().contains('local'))
              .length;
          final foreignCount = users.length - localCount;
          final allowedUserIds = users.map((u) => u.id).toSet();

          return StreamBuilder<List<QuizResult>>(
            stream: FirestoreService.leaderboardStream(),
            builder: (context, quizSnap) {
              if (quizSnap.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (quizSnap.hasError) {
                return _ErrorState(message: quizSnap.error.toString());
              }

              final results = quizSnap.data ?? const <QuizResult>[];
              final filtered =
                  results.where((r) => allowedUserIds.contains(r.userId)).toList();

              final attempts = filtered.length;
              final totalQuestions = filtered.fold<int>(
                0,
                (sum, r) => sum + r.totalQuestions,
              );
              final totalCorrect = filtered.fold<int>(0, (sum, r) => sum + r.score);
              final perfectScores = filtered
                  .where((r) => r.totalQuestions > 0 && r.score == r.totalQuestions)
                  .length;
              final avgPercent = totalQuestions == 0
                  ? 0.0
                  : (totalCorrect / totalQuestions).clamp(0.0, 1.0);

              final userCounts = <String, int>{};
              final nameByUser = <String, String>{for (final u in users) u.id: u.fullName};
              for (final r in filtered) {
                userCounts[r.userId] = (userCounts[r.userId] ?? 0) + 1;
              }
              final top = userCounts.entries.toList()
                ..sort((a, b) => b.value.compareTo(a.value));

              return SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _SectionTitle(title: l.t('admin_analytics_users_section')),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _MetricChip(
                            label: l.t('admin_analytics_total_users'),
                            value: users.length.toString(),
                            color: const Color(0xFF6B4423),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _MetricChip(
                            label: l.t('admin_analytics_local'),
                            value: localCount.toString(),
                            color: const Color(0xFF2E7D32),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _MetricChip(
                            label: l.t('admin_analytics_foreign'),
                            value: foreignCount.toString(),
                            color: const Color(0xFFB8860B),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l.t('admin_analytics_visitor_split'),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 14),
                            SizedBox(
                              height: 220,
                              child: PieChart(
                                PieChartData(
                                  sectionsSpace: 2,
                                  centerSpaceRadius: 52,
                                  sections: [
                                    PieChartSectionData(
                                      value: localCount.toDouble(),
                                      color: const Color(0xFF2E7D32),
                                      title: localCount == 0
                                          ? ''
                                          : '${(localCount / (users.length) * 100).round()}%',
                                      radius: 70,
                                      titleStyle: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    PieChartSectionData(
                                      value: foreignCount.toDouble(),
                                      color: const Color(0xFFB8860B),
                                      title: foreignCount == 0
                                          ? ''
                                          : '${(foreignCount / (users.length) * 100).round()}%',
                                      radius: 70,
                                      titleStyle: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            _LegendRow(
                              leftLabel: l.t('admin_analytics_local'),
                              leftColor: const Color(0xFF2E7D32),
                              rightLabel: l.t('admin_analytics_foreign'),
                              rightColor: const Color(0xFFB8860B),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    _SectionTitle(title: l.t('admin_analytics_quiz_section')),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _MetricChip(
                            label: l.t('admin_analytics_attempts'),
                            value: attempts.toString(),
                            color: const Color(0xFF6B4423),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _MetricChip(
                            label: l.t('admin_analytics_avg_score'),
                            value: '${(avgPercent * 100).round()}%',
                            color: const Color(0xFF8B4513),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _MetricChip(
                            label: l.t('admin_analytics_perfect_scores'),
                            value: perfectScores.toString(),
                            color: const Color(0xFFDAA520),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l.t('admin_analytics_quiz_overview_chart'),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 14),
                            SizedBox(
                              height: 200,
                              child: BarChart(
                                BarChartData(
                                  gridData: const FlGridData(show: false),
                                  borderData: FlBorderData(show: false),
                                  titlesData: FlTitlesData(
                                    topTitles: const AxisTitles(
                                      sideTitles: SideTitles(showTitles: false),
                                    ),
                                    rightTitles: const AxisTitles(
                                      sideTitles: SideTitles(showTitles: false),
                                    ),
                                    leftTitles: AxisTitles(
                                      sideTitles: SideTitles(
                                        showTitles: true,
                                        reservedSize: 34,
                                        getTitlesWidget: (value, meta) {
                                          return Text(
                                            value.toInt().toString(),
                                            style: TextStyle(
                                              color: Colors.grey[600],
                                              fontSize: 10,
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                    bottomTitles: AxisTitles(
                                      sideTitles: SideTitles(
                                        showTitles: true,
                                        getTitlesWidget: (value, meta) {
                                          final idx = value.toInt();
                                          final label = idx == 0
                                              ? l.t('admin_analytics_attempts')
                                              : idx == 1
                                                  ? l.t('admin_analytics_perfect_scores')
                                                  : l.t('admin_analytics_avg_score');
                                          return Padding(
                                            padding: const EdgeInsets.only(top: 6),
                                            child: Text(
                                              label,
                                              style: const TextStyle(fontSize: 10),
                                              textAlign: TextAlign.center,
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                  barGroups: [
                                    BarChartGroupData(
                                      x: 0,
                                      barRods: [
                                        BarChartRodData(
                                          toY: attempts.toDouble(),
                                          color: const Color(0xFF6B4423),
                                          width: 16,
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                      ],
                                    ),
                                    BarChartGroupData(
                                      x: 1,
                                      barRods: [
                                        BarChartRodData(
                                          toY: perfectScores.toDouble(),
                                          color: const Color(0xFFDAA520),
                                          width: 16,
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                      ],
                                    ),
                                    BarChartGroupData(
                                      x: 2,
                                      barRods: [
                                        BarChartRodData(
                                          toY: (avgPercent * 100),
                                          color: const Color(0xFF8B4513),
                                          width: 16,
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              l.t(
                                'admin_analytics_accuracy_detail',
                                params: {
                                  'correct': totalCorrect.toString(),
                                  'total': totalQuestions.toString(),
                                },
                              ),
                              style: TextStyle(color: Colors.grey[700]),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l.t('admin_analytics_top_users'),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 10),
                            if (top.isEmpty)
                              Text(
                                l.t('admin_analytics_empty_quiz'),
                                style: TextStyle(color: Colors.grey[700]),
                              )
                            else
                              ...top.take(5).map((e) {
                                final name = nameByUser[e.key] ?? e.key;
                                return ListTile(
                                  dense: true,
                                  contentPadding: EdgeInsets.zero,
                                  leading: CircleAvatar(
                                    backgroundColor: const Color(0xFF6B4423)
                                        .withOpacity(0.1),
                                    child: Text(
                                      name.isNotEmpty
                                          ? name[0].toUpperCase()
                                          : '?',
                                      style: const TextStyle(
                                        color: Color(0xFF6B4423),
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  title: Text(name, maxLines: 1),
                                  trailing: Text(
                                    l.t(
                                      'admin_analytics_attempts_label',
                                      params: {'value': e.value.toString()},
                                    ),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF6B4423),
                                    ),
                                  ),
                                );
                              }),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: const Color(0xFF6B4423),
          ),
    );
  }
}

class _MetricChip extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _MetricChip({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: Colors.grey[700], fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }
}

class _LegendRow extends StatelessWidget {
  final String leftLabel;
  final Color leftColor;
  final String rightLabel;
  final Color rightColor;

  const _LegendRow({
    required this.leftLabel,
    required this.leftColor,
    required this.rightLabel,
    required this.rightColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _LegendItem(label: leftLabel, color: leftColor),
        const SizedBox(width: 12),
        _LegendItem(label: rightLabel, color: rightColor),
      ],
    );
  }
}

class _LegendItem extends StatelessWidget {
  final String label;
  final Color color;
  const _LegendItem({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
      ],
    );
  }
}

class _EmptyState extends StatelessWidget {
  final String message;
  const _EmptyState({required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.insights, size: 72, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[700], fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  const _ErrorState({required this.message});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 72, color: Colors.red[300]),
            const SizedBox(height: 16),
            Text(
              l.t('admin_analytics_error'),
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}

