import 'dart:convert';

class AuthorData {
  String name;
  String avatarUrl;
  String avatarUrlHD;
  int userID;
  String description;
  String url;
  List<String> savedArticles;
  List<String> savedCategories;
  List<String> savedTags;
  List<String> savedAuthors;
  AuthorData({
    required this.name,
    required this.avatarUrl,
    required this.userID,
    required this.description,
    required this.url,
    required this.avatarUrlHD,
    required this.savedArticles,
    required this.savedCategories,
    required this.savedTags,
    required this.savedAuthors,
  });

  factory AuthorData.fromMap(Map<String, dynamic> map) {
    return AuthorData(
      name: map['name'] ?? '',
      avatarUrl: map['avatar_urls']['24'] ?? '',
      avatarUrlHD: map['avatar_urls']['96'] ?? '',
      userID: map['id']?.toInt() ?? 0,
      description: map['description'],
      url: map['url'],
      savedArticles: map['saved_articles'] != null
          ? List<String>.from(map['saved_articles'])
          : [],
      savedCategories: map['saved_categories'] != null
          ? List<String>.from(map['saved_categories'])
          : [],
      savedTags:
          map['saved_tags'] != null ? List<String>.from(map['saved_tags']) : [],
      savedAuthors: map['saved_authors'] != null
          ? List<String>.from(map['saved_authors'])
          : [],
    );
  }

  factory AuthorData.fromJson(String source) =>
      AuthorData.fromMap(json.decode(source));

  @override
  String toString() {
    return 'AuthorData(name: $name, avatarUrl: $avatarUrl, avatarUrlHD: $avatarUrlHD, userID: $userID, description: $description, url: $url, savedArticles: $savedArticles, savedCategories: $savedCategories, savedTags: $savedTags, savedAuthors: $savedAuthors)';
  }
}
