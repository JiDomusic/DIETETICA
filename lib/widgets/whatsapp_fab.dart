import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class WhatsAppFAB extends StatelessWidget {
  final String phoneNumber;

  const WhatsAppFAB({super.key, required this.phoneNumber});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      backgroundColor: const Color(0xFF25D366),
      onPressed: () => launchUrl(Uri.parse('https://wa.me/$phoneNumber')),
      tooltip: 'WhatsApp',
      child: const Icon(Icons.chat, color: Colors.white, size: 28),
    );
  }
}
