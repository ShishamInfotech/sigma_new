class DateUtilsHelper {
  static String formatDate(String timestamp) {
    final dt = DateTime.tryParse(timestamp);
    if (dt == null) return "Unknown";

    final day = dt.day.toString().padLeft(2, '0');
    final month = dt.month.toString().padLeft(2, '0');
    final year = dt.year;

    final hour = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final minute = dt.minute.toString().padLeft(2, '0');
    final ampm = dt.hour >= 12 ? 'PM' : 'AM';

    return "$day-$month-$year  $hour:$minute $ampm";
  }

  static String formatDuration(dynamic raw) {
    if (raw == null) return "N/A";

    // Convert to number safely
    final duration = int.tryParse(raw.toString());
    if (duration == null) return "N/A";

    // If less than 60, show seconds
    if (duration < 60) {
      return "$duration sec";
    }

    // Convert seconds → minutes
    final minutes = duration ~/ 60;
    final seconds = duration % 60;

    if (seconds == 0) {
      return "$minutes min";
    }

    return "$minutes min $seconds sec";
  }
}
