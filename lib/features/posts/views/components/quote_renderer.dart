import 'package:flutter/material.dart';
import 'package:html/parser.dart' show parse;
import 'package:html_unescape/html_unescape.dart';

class QuoteRenderer extends StatelessWidget {
  final String quote;

  const QuoteRenderer({super.key, required this.quote});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: IntrinsicHeight(
        child: Row(
          children: [
            VerticalDivider(
                color: Theme.of(context).primaryColor, width: 20, thickness: 2),
            Expanded(
                child: Text(
              HtmlUnescape().convert(parse(quote).documentElement!.text),
              style: TextStyle(
                fontSize: 16,
                color: Theme.of(context).colorScheme.secondary,
              ),
            )),
          ],
        ),
      ),
    );
  }
}
