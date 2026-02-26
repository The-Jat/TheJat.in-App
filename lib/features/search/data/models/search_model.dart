import 'dart:convert';

/// The Model that is used for getting search history
class SearchModel {
  String query;
  DateTime time;
  SearchModel({
    required this.query,
    required this.time,
  });

  Map<String, dynamic> toMap() {
    return {
      'query': query,
      'time': time.millisecondsSinceEpoch,
    };
  }

  factory SearchModel.fromMap(Map<String, dynamic> map) {
    return SearchModel(
      query: map['query'],
      time: DateTime.fromMillisecondsSinceEpoch(map['time']),
    );
  }

  String toJson() => json.encode(toMap());

  factory SearchModel.fromJson(String source) =>
      SearchModel.fromMap(json.decode(source));

  @override
  String toString() => 'SearchModel(query: $query, time: $time)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is SearchModel && other.query == query && other.time == time;
  }

  @override
  int get hashCode => query.hashCode ^ time.hashCode;
}
