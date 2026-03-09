import 'package:intl/intl.dart';

class DateFormatter {
  // Format date to 'MMM dd, yyyy' (e.g., Jan 01, 2023 or ene 01, 2023)
  static String formatDate(DateTime date, [String? locale]) {
    return DateFormat('MMM dd, yyyy', locale).format(date);
  }

  // Format date to 'yyyy-MM-dd' (e.g., 2023-01-01)
  static String formatDateForApi(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }

  // Format date and time to 'MMM dd, yyyy HH:mm' (e.g., Jan 01, 2023 14:30)
  static String formatDateTime(DateTime dateTime, [String? locale]) {
    return DateFormat('MMM dd, yyyy HH:mm', locale).format(dateTime);
  }

  // Parse string date in format 'yyyy-MM-dd' to DateTime
  static DateTime parseDate(String date) {
    return DateFormat('yyyy-MM-dd').parse(date);
  }

  // Get relative time (e.g., "2 days ago", "Just now")
  // Pass justNow parameter for localization (e.g., AppLocalizations.of(context).justNow)
  static String getRelativeTime(DateTime dateTime, {String justNow = 'Just now'}) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 365) {
      return '${(difference.inDays / 365).floor()} ${(difference.inDays / 365).floor() == 1 ? 'year' : 'years'} ago';
    } else if (difference.inDays > 30) {
      return '${(difference.inDays / 30).floor()} ${(difference.inDays / 30).floor() == 1 ? 'month' : 'months'} ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} ${difference.inDays == 1 ? 'day' : 'days'} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} ${difference.inHours == 1 ? 'hour' : 'hours'} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} ${difference.inMinutes == 1 ? 'minute' : 'minutes'} ago';
    } else {
      return justNow;
    }
  }
}
