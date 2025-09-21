import 'package:flutter/material.dart';

import '../../core/components/webview_widget.dart';

class ViewOnWebPage extends StatelessWidget {
  const ViewOnWebPage({
    super.key,
    this.title,
    required this.url,
  });

  final String? title;
  final String url;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: title != null ? Text(title!) : null,
      ),
      body: AppWebView(
        url: url,
      ),
    );
  }
}
