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

class DocumentData {
  final String email;
  final String name;
  final String imageUrl;
  final String date;
  final bool isNSFW;

  DocumentData({
    required this.email,
    required this.name,
    required this.imageUrl,
    required this.date,
    required this.isNSFW,
  });

  factory DocumentData.fromJson(Map<String, dynamic> json) {
    return DocumentData(
      email: json['userEmail'] as String,
      name: json['userName'] as String,
      imageUrl: json['url'] as String,
      date: json['date'] as String,
      isNSFW: json['isNSFW'] as bool, // Convert the value to bool
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userEmail': email,
      'userName': name,
      'url': imageUrl,
      'date': date,
      'isNSFW': isNSFW,
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
