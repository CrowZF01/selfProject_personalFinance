import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import '../database/db_helper.dart';

class AppFormatters {
  static final ValueNotifier<String> currencyNotifier = ValueNotifier<String>('IDR (Rp)');

  static String get currentCurrency => currencyNotifier.value;

  static bool get isIdr =>
      currentCurrency.contains('IDR') || currentCurrency.contains('Rp');

  static String get currencySymbol => isIdr ? 'Rp ' : r'$';

  /// Initialize and load saved currency from SQLite settings.
  static Future<void> init() async {
    try {
      final saved = await DbHelper.instance.getSetting('currency');
      if (saved != null && saved.isNotEmpty) {
        currencyNotifier.value = saved;
      } else {
        currencyNotifier.value = 'IDR (Rp)';
      }
    } catch (_) {
      currencyNotifier.value = 'IDR (Rp)';
    }
  }

  /// Set and update currency across the entire app.
  static void setCurrency(String currencyCode) {
    currencyNotifier.value = currencyCode;
  }

  /// Format currency with symbol prefix:
  /// e.g. IDR -> "Rp 150.000" (no decimals)
  /// e.g. USD -> "$150.00" (2 decimals)
  static String formatCurrency(double? amount) {
    if (amount == null || amount.isNaN || amount.isInfinite) {
      return isIdr ? 'Rp 0' : r'$0.00';
    }
    if (isIdr) {
      final formatter = NumberFormat('#,##0', 'id_ID');
      return 'Rp ${formatter.format(amount.round())}';
    } else {
      final formatter = NumberFormat('#,##0.00', 'en_US');
      return '\$${formatter.format(amount)}';
    }
  }

  /// Format pure numeric amount without currency symbol:
  /// e.g. IDR -> "150.000"
  /// e.g. USD -> "150.00"
  static String formatAmount(double? amount) {
    if (amount == null || amount.isNaN || amount.isInfinite) {
      return isIdr ? '0' : '0.00';
    }
    if (isIdr) {
      final formatter = NumberFormat('#,##0', 'id_ID');
      return formatter.format(amount.round());
    } else {
      final formatter = NumberFormat('#,##0.00', 'en_US');
      return formatter.format(amount);
    }
  }

  /// Format compact for charts, badges, and chips:
  /// e.g. IDR 1.500.000 -> "Rp 1,5M" or "Rp 1,5jt"
  /// e.g. USD 1,500 -> "$1.5K"
  static String formatCompact(double? amount) {
    if (amount == null || amount.isNaN || amount.isInfinite) {
      return isIdr ? 'Rp 0' : r'$0';
    }
    if (isIdr) {
      final val = amount.abs();
      final sign = amount < 0 ? '-' : '';
      if (val >= 1000000000) {
        final num = (val / 1000000000).toStringAsFixed(1).replaceAll('.0', '');
        return '${sign}Rp ${num}M';
      } else if (val >= 1000000) {
        final num = (val / 1000000).toStringAsFixed(1).replaceAll('.0', '');
        return '${sign}Rp ${num}jt';
      } else if (val >= 1000) {
        final num = (val / 1000).toStringAsFixed(0);
        return '${sign}Rp ${num}rb';
      } else {
        return '${sign}Rp ${val.round()}';
      }
    } else {
      final formatter = NumberFormat.compact(locale: 'en_US');
      return '\$${formatter.format(amount)}';
    }
  }

  static String formatDate(DateTime date) {
    return DateFormat('d MMM yyyy', isIdr ? 'id_ID' : 'en_US').format(date);
  }

  static String formatMonthYear(DateTime date) {
    return DateFormat('MMMM yyyy', isIdr ? 'id_ID' : 'en_US').format(date);
  }
}
