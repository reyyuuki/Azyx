class AzFormatters {
  AzFormatters._();

  static const List<String> _months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
  ];

  static String compactNumber(num? value) {
    if (value == null || value == 0) return '0';
    final n = value.toDouble();
    if (n >= 1000000) {
      final formatted = (n / 1000000).toStringAsFixed(1);
      return formatted.endsWith('.0')
          ? '${formatted.substring(0, formatted.length - 2)}M'
          : '${formatted}M';
    }
    if (n >= 1000) {
      final formatted = (n / 1000).toStringAsFixed(1);
      return formatted.endsWith('.0')
          ? '${formatted.substring(0, formatted.length - 2)}K'
          : '${formatted}K';
    }
    return value.toString();
  }

  static String formatDate(int? year, int? month, int? day) {
    if (year == null || year == 0) return '';
    final buffer = StringBuffer();
    if (month != null && month >= 1 && month <= 12) {
      buffer.write(_months[month - 1]);
      if (day != null && day > 0) {
        buffer.write(' $day, ');
      } else {
        buffer.write(' ');
      }
    }
    buffer.write(year.toString());
    return buffer.toString().trim();
  }

  static String formatDateRange({
    int? startYear,
    int? startMonth,
    int? startDay,
    int? endYear,
    int? endMonth,
    int? endDay,
  }) {
    final start = formatDate(startYear, startMonth, startDay);
    final end = formatDate(endYear, endMonth, endDay);
    if (start.isNotEmpty && end.isNotEmpty) {
      return '$start – $end';
    }
    if (start.isNotEmpty) return start;
    if (end.isNotEmpty) return end;
    return '–';
  }

  static String airingEta(int? seconds) {
    if (seconds == null || seconds <= 0) return '0m';
    final d = seconds ~/ 86400;
    final h = (seconds % 86400) ~/ 3600;
    final m = (seconds % 3600) ~/ 60;
    if (d > 0) {
      return '${d}d ${h}h';
    }
    if (h > 0) {
      return '${h}h ${m}m';
    }
    return '${m}m';
  }

  static String formatStatus(String? status) {
    if (status == null || status.trim().isEmpty) return '–';
    final cleaned = status.replaceAll('_', ' ').toLowerCase().trim();
    if (cleaned.isEmpty) return '–';
    return cleaned[0].toUpperCase() + cleaned.substring(1);
  }

  static String capitalize(String? status) => formatStatus(status);

  static String formatFormat(String? format) {
    if (format == null || format.trim().isEmpty) return '–';
    final upper = format.trim().toUpperCase();
    if (upper == 'TV' || upper == 'OVA' || upper == 'ONA') {
      return upper;
    }
    final words = upper.replaceAll('_', ' ').toLowerCase().split(' ');
    return words.map((w) {
      if (w.isEmpty) return '';
      if (w == 'tv' || w == 'ova' || w == 'ona') return w.toUpperCase();
      return w[0].toUpperCase() + w.substring(1);
    }).join(' ');
  }

  static String formatLabel(String? format) => formatFormat(format);

  static String dateRange({
    int? startYear,
    int? startMonth,
    int? startDay,
    int? endYear,
    int? endMonth,
    int? endDay,
  }) {
    return formatDateRange(
      startYear: startYear,
      startMonth: startMonth,
      startDay: startDay,
      endYear: endYear,
      endMonth: endMonth,
      endDay: endDay,
    );
  }

  static String scoreBadge(num? score) {
    if (score == null || score == 0) return '';
    final val = (score / 10.0).toStringAsFixed(1);
    return '★ $val';
  }
}
