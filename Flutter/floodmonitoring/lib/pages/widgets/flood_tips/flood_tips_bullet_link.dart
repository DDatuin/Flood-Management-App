import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

/// ----- BULLET LINK WIDGET -----
Widget bulletLink(String text, String url) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 2),
    child: InkWell(
      onTap: () async {
        final Uri uri = Uri.parse(url);
        try {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        } catch (e) {
          debugPrint("Could not launch $url: $e");
        }
      },
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "• ",
            style: TextStyle(
              fontFamily: 'AvenirNext',
              fontSize: 16,
              height: 1.6,
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontFamily: 'AvenirNext',
                fontSize: 16,
                height: 1.6,
                color: Colors.blueAccent,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
