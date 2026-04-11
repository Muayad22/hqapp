import 'package:flutter/material.dart';
import 'package:hqapp/models/leaderboard_entry.dart';
import 'package:hqapp/services/firestore_service.dart';
import 'package:hqapp/localization/app_localizations.dart';

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String _getRankIcon(int rank) {
    if (rank == 1) return '🥇';
    if (rank == 2) return '🥈';
    if (rank == 3) return '🥉';
    return '🏅';
  }

  Color _getRankColor(int rank) {
    if (rank <= 3) return Colors.amber;
    if (rank <= 10) return Colors.grey[600]!;
    return Colors.grey[400]!;
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          l.t('leaderboard_title'),
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        backgroundColor: const Color(0xFF6B4423),
        foregroundColor: Colors.white,
        elevation: 2,
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: l.t('leaderboard_search_hint'),
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey[100],
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder<List<LeaderboardEntry>>(
              stream: FirestoreService.pointsLeaderboardStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 48,
                          color: Colors.red[300],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          l.t('leaderboard_error_title'),
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[700],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          snapshot.error.toString(),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () => setState(() {}),
                          child: Text(l.t('leaderboard_retry')),
                        ),
                      ],
                    ),
                  );
                }

                var entries = snapshot.data ?? [];
                final query = _searchController.text.trim().toLowerCase();
                if (query.isNotEmpty) {
                  entries = entries
                      .where(
                        (entry) => entry.userName.toLowerCase().contains(query),
                      )
                      .toList();
                }

                if (entries.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.emoji_events,
                          size: 64,
                          color: Colors.grey[300],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          l.t('leaderboard_empty_title'),
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          l.t('leaderboard_empty_message'),
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[500],
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: entries.length,
                  itemBuilder: (context, index) {
                    final entry = entries[index];
                    final rank = index + 1;
                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 4,
                      ),
                      elevation: rank <= 3 ? 4 : 1,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: rank <= 3
                            ? BorderSide(
                                color: const Color(0xFFB8860B).withOpacity(0.3),
                                width: 2,
                              )
                            : BorderSide.none,
                      ),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: _getRankColor(rank).withOpacity(0.1),
                          radius: 28,
                          child: Text(
                            _getRankIcon(rank),
                            style: const TextStyle(fontSize: 24),
                          ),
                        ),
                        title: Text(
                          entry.userName,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                        subtitle: Row(
                          children: [
                            const Icon(
                              Icons.stars,
                              size: 16,
                              color: Color(0xFFB8860B),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              l.t(
                                'leaderboard_points_label',
                                params: {
                                  'value': entry.totalPoints.toString(),
                                },
                              ),
                              style: TextStyle(
                                color: Colors.grey[700],
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                        trailing: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            gradient: rank <= 3
                                ? LinearGradient(
                                    colors: [
                                      const Color(0xFFB8860B),
                                      const Color(0xFF6B4423),
                                    ],
                                  )
                                : null,
                            color: rank > 3
                                ? _getRankColor(rank).withOpacity(0.1)
                                : null,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            '#$rank',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: rank <= 3
                                  ? Colors.white
                                  : _getRankColor(rank),
                              fontSize: 16,
                            ),
                          ),
                        ),
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
