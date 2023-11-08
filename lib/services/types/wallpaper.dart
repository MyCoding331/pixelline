class Wallpaper {
  final String id;
  final String url;

  Wallpaper({
    required this.id,
    required this.url,
  });

  factory Wallpaper.fromJson(Map<String, dynamic> json) {
    return Wallpaper(
      id: json['id'],
      url: json['image'] ?? json['url'],
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'url': url,
    };
  }
}

class Tag {
  final String id;
  final String title;

  Tag({required this.id, required this.title});

  factory Tag.fromJson(Map<String, dynamic> json) {
    return Tag(id: json['id'], title: json['title']);
  }
}
