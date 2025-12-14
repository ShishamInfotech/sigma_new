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

    // Convert safely to integer
    final minutes = int.tryParse(raw.toString());
    if (minutes == null) return "N/A";

    // If less than 1 minute (should not normally happen)
    if (minutes == 0) {
      return "0 min";
    }

    // If only minutes
    if (minutes < 60) {
      return "$minutes min";
    }

    // Convert minutes → hours + minutes
    final hours = minutes ~/ 60;
    final remainingMinutes = minutes % 60;

    if (remainingMinutes == 0) {
      return "$hours hr";
    }

    return "$hours hr $remainingMinutes min";
  }

}
