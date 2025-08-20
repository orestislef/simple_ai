import 'package:intl/intl.dart';

class DateFormatter {
  static final _formatter = DateFormat('dd-MM-yyyy HH:mm:ss');
  static final _timeFormatter = DateFormat('HH:mm');
  static final _dateFormatter = DateFormat('dd/MM/yyyy');

  static String formatTimestamp(DateTime dateTime) {
    return _formatter.format(dateTime);
  }

  static String formatTime(DateTime dateTime) {
    return _timeFormatter.format(dateTime);
  }

  static String formatDate(DateTime dateTime) {
    return _dateFormatter.format(dateTime);
  }

  static String formatMessageTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays == 0) {
      return formatTime(dateTime);
    } else if (difference.inDays == 1) {
      return 'Yesterday ${formatTime(dateTime)}';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return formatDate(dateTime);
    }
  }

  static String getCurrentTimestamp() {
    return formatTimestamp(DateTime.now());
  }
}