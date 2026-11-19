import 'package:azyx/Screens/Anime/Details/tokens/az_tones.dart';
import 'package:azyx/Screens/Anime/Details/utils/formatters.dart';
import 'package:azyx/Screens/Anime/Details/utils/html_sanitizer.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('HtmlSanitizer Tests', () {
    test('converts br tags to newlines and strips formatting tags', () {
      const input = 'First line<br>Second line<br />Third line<i>italic</i><b>bold</b>';
      final output = HtmlSanitizer.sanitize(input);
      expect(output, 'First line\nSecond line\nThird lineitalicbold');
    });

    test('removes spoiler markers and contained text', () {
      const input = 'Safe text ~!spoiler content that should be hidden!~ and more safe text.';
      final output = HtmlSanitizer.sanitize(input);
      expect(output, 'Safe text  and more safe text.');
    });

    test('decodes html entities', () {
      const input = 'Attack &amp; Titan &lt;Season 1&gt; &#39;Special&#39; &quot;Final&quot;';
      final output = HtmlSanitizer.sanitize(input);
      expect(output, 'Attack & Titan <Season 1> \'Special\' "Final"');
    });

    test('returns fallback when input is empty or null', () {
      expect(HtmlSanitizer.sanitize(null), 'No synopsis available for this title.');
      expect(HtmlSanitizer.sanitize('   '), 'No synopsis available for this title.');
    });
  });

  group('AzFormatters Tests', () {
    test('compact numbers format correctly', () {
      expect(AzFormatters.compactNumber(1100000), '1.1M');
      expect(AzFormatters.compactNumber(1000000), '1M');
      expect(AzFormatters.compactNumber(12300), '12.3K');
      expect(AzFormatters.compactNumber(500), '500');
      expect(AzFormatters.compactNumber(0), '0');
      expect(AzFormatters.compactNumber(null), '0');
    });

    test('date range formats correctly', () {
      final range = AzFormatters.formatDateRange(
        startYear: 2013,
        startMonth: 4,
        startDay: 7,
        endYear: 2013,
        endMonth: 9,
        endDay: 29,
      );
      expect(range, 'Apr 7, 2013 – Sep 29, 2013');

      final yearOnly = AzFormatters.formatDateRange(startYear: 2021);
      expect(yearOnly, '2021');
    });

    test('airing eta formats correctly', () {
      expect(AzFormatters.airingEta(273600), '3d 4h');
      expect(AzFormatters.airingEta(8100), '2h 15m');
      expect(AzFormatters.airingEta(900), '15m');
    });

    test('format and status casing', () {
      expect(AzFormatters.formatFormat('TV'), 'TV');
      expect(AzFormatters.formatFormat('tv_short'), 'TV Short');
      expect(AzFormatters.formatFormat('movie'), 'Movie');
      expect(AzFormatters.formatStatus('NOT_YET_RELEASED'), 'Not yet released');
      expect(AzFormatters.formatStatus('FINISHED'), 'Finished');
    });

    test('score badge', () {
      expect(AzFormatters.scoreBadge(85), '★ 8.5');
      expect(AzFormatters.scoreBadge(null), '');
    });
  });

  group('AzTones Tests', () {
    test('derives valid tones from real hex', () {
      final tones = AzTones.fromHex('#e4a15d');
      expect(tones.accent, isNotNull);
      expect(tones.onAccent, isNotNull);
      expect(tones.soft, isNotNull);
      expect(tones.glow, isNotNull);
    });

    test('handles fallback when hex is null or invalid', () {
      final fallbackTones = AzTones.fromHex(null);
      expect(fallbackTones.accent, isNotNull);

      final invalidTones = AzTones.fromHex('invalid');
      expect(invalidTones.accent, isNotNull);
    });
  });
}
