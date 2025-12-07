// lib/utils/guess_type.dart
import 'dart:core';

enum SponsorMediaType {
  image,
  video,
  pdf,
  unknown,
}

/// Simple helper to guess media type by file extension / path.
/// Extend this list if your app supports more types.
SponsorMediaType guessTypeFromUrl(String urlOrPath) {
  final lower = urlOrPath.toLowerCase();
  // remove query params if any (defensive)
  final clean = lower.split('?').first.split('#').first;

  if (clean.endsWith('.png') ||
      clean.endsWith('.jpg') ||
      clean.endsWith('.jpeg') ||
      clean.endsWith('.gif') ||
      clean.endsWith('.webp') ||
      clean.endsWith('.bmp')) {
    return SponsorMediaType.image;
  }

  if (clean.endsWith('.mp4') ||
      clean.endsWith('.mov') ||
      clean.endsWith('.mkv') ||
      clean.endsWith('.webm') ||
      clean.endsWith('.3gp')) {
    return SponsorMediaType.video;
  }

  if (clean.endsWith('.pdf')) {
    return SponsorMediaType.pdf;
  }

  return SponsorMediaType.unknown;
}
