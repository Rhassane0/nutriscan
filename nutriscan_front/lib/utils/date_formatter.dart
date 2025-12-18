import 'package:intl/intl.dart';

class DateFormatter {
  // Locale courante (mise à jour par l'app)
  static String _currentLocale = 'fr_FR';

  static void setLocale(String locale) {
    _currentLocale = locale;
  }

  static String get currentLocale => _currentLocale;

  // Format: yyyy-MM-dd (pour l'API)
  static String formatForApi(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }

  // Format: dd/MM/yyyy (pour l'affichage)
  static String formatForDisplay(DateTime date) {
    return DateFormat('dd/MM/yyyy').format(date);
  }

  // Format court: dd/MM (ex: 30/11)
  static String formatShort(DateTime date) {
    return DateFormat('dd/MM').format(date);
  }

  // Format: dd MMM yyyy (ex: 30 Nov 2025)
  static String formatLong(DateTime date) {
    return DateFormat('dd MMM. yyyy', _currentLocale).format(date);
  }

  // Format: EEE dd MMM (ex: Lun 30 Nov)
  static String formatWithDay(DateTime date) {
    return DateFormat('EEE dd MMM', _currentLocale).format(date);
  }

  // Parse from API format
  static DateTime? parseFromApi(String? dateString) {
    if (dateString == null || dateString.isEmpty) return null;
    try {
      return DateTime.parse(dateString);
    } catch (e) {
      return null;
    }
  }

  // Check if date is today
  static bool isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
           date.month == now.month &&
           date.day == now.day;
  }

  // Get today
  static DateTime getToday() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  // Get date range for week
  static List<DateTime> getWeekDates(DateTime startDate) {
    return List.generate(7, (index) => startDate.add(Duration(days: index)));
  }

  // Get day abbreviation (ex: mar.)
  static String getDayAbbr(DateTime date) {
    return DateFormat('EEE', _currentLocale).format(date).toLowerCase();
  }

  // Get day number (ex: 09)
  static String getDayNumber(DateTime date) {
    return DateFormat('dd').format(date);
  }
}

