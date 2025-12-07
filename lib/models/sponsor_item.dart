// lib/models/sponsor_item.dart
import 'package:flutter/foundation.dart';
import '../utility/guess_type.dart';


class SponsorItem {
  final String id;
  final String title;
  final String url; // file://... or absolute path
  final SponsorMediaType type;

  SponsorItem({
    required this.id,
    required this.title,
    required this.url,
    required this.type,
  });

  @override
  String toString() =>
      'SponsorItem(id: $id, title: $title, url: $url, type: $type)';
}
