import 'package:flutter/material.dart';

/// One question from the bundled FAQ (`assets/content/faq.json`).
class FaqEntry {
  const FaqEntry({required this.topic, required this.question, required this.answer});

  factory FaqEntry.fromJson(Map<String, dynamic> j) =>
      FaqEntry(topic: '${j['topic'] ?? 'Other'}', question: '${j['q'] ?? ''}', answer: '${j['a'] ?? ''}');

  final String topic;
  final String question;
  final String answer;

  /// Case-insensitive match on every word of [query], anywhere in the question, answer or topic.
  bool matches(String query) {
    final haystack = '$question $answer $topic'.toLowerCase();
    return query.toLowerCase().split(RegExp(r'\s+')).where((w) => w.isNotEmpty).every(haystack.contains);
  }
}

/// A "Popular topics" tile on Help & Support. [title] is also the `topic` value in faq.json.
class HelpTopic {
  const HelpTopic(this.title, this.subtitle, this.icon);

  final String title;
  final String subtitle;
  final IconData icon;
}

/// The six tiles, in the mockup's order (two across, three down).
const helpTopics = [
  HelpTopic('Using Commuttr', 'Get started and learn the basics', Icons.phone_iphone_outlined),
  HelpTopic('Routes & Planning', 'Find routes, plan and explore', Icons.alt_route_outlined),
  HelpTopic('Payments & Wallet', 'Top up, payments and refunds', Icons.account_balance_wallet_outlined),
  HelpTopic('Account & Profile', 'Manage your account and preferences', Icons.person_outline),
  HelpTopic('Alerts & Updates', 'Notifications and service updates', Icons.notifications_none_outlined),
  HelpTopic('Accessibility', 'Features to support everyone', Icons.accessibility_new_outlined),
];
