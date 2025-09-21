import 'package:flutter/material.dart';

import '../../../../core/models/article.dart';
import '../components/normal_post.dart';

/// ClassicPost is a wrapper around the existing NormalPost to maintain consistency
/// with the new post style system while keeping the original design intact
class ClassicPost extends StatelessWidget {
  const ClassicPost({
    super.key,
    required this.article,
  });
  final ArticleModel article;

  @override
  Widget build(BuildContext context) {
    return NormalPost(article: article);
  }
}
