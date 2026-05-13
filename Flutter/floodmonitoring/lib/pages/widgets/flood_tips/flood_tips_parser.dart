import 'package:flutter/material.dart';

// ----- PARSE **bold** -----
Widget parseBoldText(String text) {
  List<TextSpan> spans = [];
  RegExp exp = RegExp(r'\*\*(.*?)\*\*');
  int start = 0;

  for (final match in exp.allMatches(text)) {
    if (match.start > start) {
      spans.add(
        TextSpan(
          text: text.substring(start, match.start),
          style: const TextStyle(
            fontFamily: 'AvenirNext',
            fontSize: 16,
            height: 1.6,
            color: Colors.black87,
          ),
        ),
      );
    }

    spans.add(
      TextSpan(
        text: match.group(1),
        style: const TextStyle(
          fontFamily: 'AvenirNext',
          fontSize: 16,
          fontWeight: FontWeight.bold,
          height: 1.6,
          color: Colors.black87,
        ),
      ),
    );

    start = match.end;
  }

  if (start < text.length) {
    spans.add(
      TextSpan(
        text: text.substring(start),
        style: const TextStyle(
          fontFamily: 'AvenirNext',
          fontSize: 16,
          height: 1.6,
          color: Colors.black87,
        ),
      ),
    );
  }

  return RichText(text: TextSpan(children: spans));
}
