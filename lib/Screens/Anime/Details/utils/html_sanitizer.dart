class HtmlSanitizer {
  HtmlSanitizer._();

  static final RegExp _brTag = RegExp(r'<br\s*/?>', caseSensitive: false);
  static final RegExp _spoilerTag = RegExp(r'~!(.*?)!~', dotAll: true);
  static final RegExp _htmlTag = RegExp(r'<[^>]*>');

  static String clean(String? rawHtml) => sanitize(rawHtml);

  static String sanitize(String? rawHtml, {String fallback = 'No synopsis available for this title.'}) {
    if (rawHtml == null || rawHtml.trim().isEmpty) {
      return fallback;
    }

    String result = rawHtml;
    result = result.replaceAll(_spoilerTag, '');
    result = result.replaceAll(_brTag, '\n');
    result = result.replaceAll(_htmlTag, '');

    result = _decodeEntities(result);

    result = result.replaceAll(RegExp(r'\n{3,}'), '\n\n');
    result = result.trim();

    return result.isEmpty ? fallback : result;
  }

  static String _decodeEntities(String input) {
    return input
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&quot;', '"')
        .replaceAll('&#39;', "'")
        .replaceAll('&apos;', "'")
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&ndash;', '–')
        .replaceAll('&mdash;', '—')
        .replaceAll('&#8211;', '–')
        .replaceAll('&#8212;', '—')
        .replaceAll('&#8216;', "'")
        .replaceAll('&#8217;', "'")
        .replaceAll('&#8220;', '"')
        .replaceAll('&#8221;', '"');
  }
}
