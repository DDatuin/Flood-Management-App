import 'package:floodmonitoring/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

void makeCall(BuildContext context, String? number) async {
  if (number == null) return;
  final Uri callUri = Uri(scheme: 'tel', path: number);
  if (await canLaunchUrl(callUri)) {
    await launchUrl(callUri);
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Cannot make a call at the moment.")),
    );
  }
}

Widget contactCard(BuildContext context, Map<String, String> contact) {
  return Container(
    padding: const EdgeInsets.all(16),
    margin: const EdgeInsets.only(bottom: 16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: const [
        BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 2)),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          contact['name'] ?? "",
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            fontFamily: 'AvenirNext',
          ),
        ),
        const SizedBox(height: 6),
        Text(
          contact['description'] ?? "",
          style: const TextStyle(
            fontSize: 15,
            color: Colors.black54,
            fontFamily: 'AvenirNext',
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              contact['number'] ?? "",
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                fontFamily: 'AvenirNext',
              ),
            ),
            ElevatedButton.icon(
              onPressed: () => makeCall(context, contact['number']),
              icon: const Icon(Icons.call, size: 18),
              label: const Text("Call"),
              style: ElevatedButton.styleFrom(
                backgroundColor: colorPrimary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 3,
              ),
            ),
          ],
        ),
      ],
    ),
  );
}
