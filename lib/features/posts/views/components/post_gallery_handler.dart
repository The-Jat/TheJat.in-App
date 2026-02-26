import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

import '../../../../core/routes/app_routes.dart';

class PostGalleryRenderer extends StatefulWidget {
  const PostGalleryRenderer({
    super.key,
    required this.imagesUrl,
  });

  final List<String> imagesUrl;

  @override
  State<PostGalleryRenderer> createState() => _PostGalleryRendererState();
}

class _PostGalleryRendererState extends State<PostGalleryRenderer> {
  List<String> images = [];
  List<Image> imagesRaw = [];

  _viewImageFullScreen(String url) {
    Navigator.pushNamed(context, AppRoutes.viewImageFullScreen, arguments: url);
  }

  @override
  void initState() {
    images.addAll(widget.imagesUrl);
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (images.isEmpty) {
      return const SizedBox();
    }

    return Material(
      color: Colors.transparent,
      child: StaggeredGrid.count(
        crossAxisCount: 2,
        mainAxisSpacing: 4,
        crossAxisSpacing: 4,
        children: List.generate(
          images.length,
          (index) => StaggeredGridTile.fit(
            crossAxisCellCount: 1,
            child: InkWell(
              onTap: () => _viewImageFullScreen(images[index]),
              child: CachedNetworkImage(
                imageUrl: images[index],
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  height: 200,
                  color: Colors.grey[200],
                  child: const Center(child: CircularProgressIndicator()),
                ),
                errorWidget: (context, url, error) => Container(
                  height: 200,
                  color: Colors.grey[200],
                  child: const Center(child: Icon(Icons.error)),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
