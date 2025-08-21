import 'package:intl/intl.dart';

class DateFormatter {
  static final _formatter = DateFormat('dd-MM-yyyy HH:mm:ss');
  static final _timeFormatter = DateFormat('HH:mm');
  static final _dateFormatter = DateFormat('dd/MM/yyyy');
  
  // Cache for expensive date calculations
  static final Map<String, String> _formatCache = <String, String>{};
  static const int _maxCacheSize = 100;
  
  // Cache "now" for consistent relative time calculations
  static DateTime? _cachedNow;
  static int _lastCacheTime = 0;

  static String formatTimestamp(DateTime dateTime) {
    final key = 'ts_${dateTime.millisecondsSinceEpoch}';
    if (_formatCache.containsKey(key)) {
      return _formatCache[key]!;
    }
    
    final result = _formatter.format(dateTime);
    _cacheResult(key, result);
    return result;
  }

  static String formatTime(DateTime dateTime) {
    final key = 'time_${dateTime.hour}_${dateTime.minute}';
    if (_formatCache.containsKey(key)) {
      return _formatCache[key]!;
    }
    
    final result = _timeFormatter.format(dateTime);
    _cacheResult(key, result);
    return result;
  }

  static String formatDate(DateTime dateTime) {
    final key = 'date_${dateTime.year}_${dateTime.month}_${dateTime.day}';
    if (_formatCache.containsKey(key)) {
      return _formatCache[key]!;
    }
    
    final result = _dateFormatter.format(dateTime);
    _cacheResult(key, result);
    return result;
  }

  static String formatMessageTime(DateTime dateTime) {
    // Use cached "now" for consistent calculations within the same second
    final currentTime = DateTime.now().millisecondsSinceEpoch;
    if (currentTime - _lastCacheTime > 1000) { // Refresh every second
      _cachedNow = DateTime.now();
      _lastCacheTime = currentTime;
    }
    
    final now = _cachedNow!;
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
  
  static void _cacheResult(String key, String result) {
    if (_formatCache.length >= _maxCacheSize) {
      _formatCache.clear();
    }
    _formatCache[key] = result;
  }
  
  static void clearCache() {
    _formatCache.clear();
    _cachedNow = null;
  }

  static String getCurrentTimestamp() {
    return formatTimestamp(DateTime.now());
  }
}