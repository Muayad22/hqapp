
class MediaEntry {
  final String id;
  final String name;
  final String url;

  const MediaEntry({
    required this.id,
    required this.name,
    required this.url,
  });

  factory MediaEntry.fromMap({
    required String key,
    required Map<String, dynamic> data,
  }) {
    return MediaEntry(
      id: data['id']?.toString() ?? key,
      name: data['name']?.toString() ?? '',
      url: data['url']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'url': url,
  };
}
