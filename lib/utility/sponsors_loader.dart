// -------------------- SponsorsRepository + Loader --------------------
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:sigma_new/utility/sd_card_utility.dart';

import '../pages/home/home_with_sponsors.dart';

// Make sure SdCardUtility is imported from wherever you defined it:
// import 'package:your_app/utils/sdcard_utility.dart';

class SponsorsRepository {
  /// Reads local sponsor files from the SD card path:
  /// <sigma_base>/sponsors
  Future<List<SponsorItem>> fetchSponsorsFromSdCard() async {
    try {
      // Get Sigma base path (your utility)
      final sigmaPath = await SdCardUtility.getBasePath();

      // Your sponsors directory: <sigmaPath>/sponsors
      final baseDir = Directory("$sigmaPath/sponsors");

      if (!await baseDir.exists()) {
        print("⚠️ Sponsor directory not found: $baseDir");
        return [];
      }

      // Read all files inside the directory
      final entries = await baseDir.list().toList();
      final files = entries.whereType<File>().toList();

      // Optional: sort alphabetically
      files.sort((a, b) => p.basename(a.path).compareTo(p.basename(b.path)));

      final sponsors = <SponsorItem>[];

      for (final file in files) {
        final ext = p.extension(file.path).toLowerCase();
        if (ext.isEmpty) continue;

        final types = guessTypeFromUrl(file.path);
        if (types == SponsorMediaType.unknown) {
          // Skip unsupported file types
          continue;
        }

        // Title = file name without extension
        final title = p.basenameWithoutExtension(file.path);

        // Local file URL (used by viewers)
        final url = "file://${file.path}";

        sponsors.add(
          SponsorItem(
            id: title,
            title: title,
            url: url,
            type: types,
          ),
        );
      }

      return sponsors;
    } catch (e, st) {
      print("ERROR while reading sponsors: $e\n$st");
      return [];
    }
  }
}

/// A small reusable loader widget — shows spinner while fetching and builds
/// the default SponsorsSection with the result.
class SponsorsLoader extends StatelessWidget {
  final Future<List<SponsorItem>> Function() fetcher;
  final String? sectionTitle;
  final Widget? loadingWidget;
  final Widget Function(List<SponsorItem>)? builderOnData;

  const SponsorsLoader({
    Key? key,
    required this.fetcher,
    this.sectionTitle,
    this.loadingWidget,
    this.builderOnData,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<SponsorItem>>(
      future: fetcher(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return loadingWidget ??
              const SizedBox(height: 120, child: Center(child: CircularProgressIndicator()));
        }
        if (snapshot.hasError) {
          return SizedBox(height: 120, child: Center(child: Text('Failed to load sponsors')));
        }
        final list = snapshot.data ?? <SponsorItem>[];
        if (builderOnData != null) return builderOnData!(list);
        return SponsorsSection(sectionTitle: sectionTitle ?? 'Sponsors', sponsors: list);
      },
    );
  }
}
