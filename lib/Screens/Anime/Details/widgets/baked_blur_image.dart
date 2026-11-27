import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

class BakedBlurImage extends StatefulWidget {
  final String url;
  final String? fallbackUrl;
  final double blurSigma;
  final double opacity;
  final BoxFit fit;

  const BakedBlurImage({
    super.key,
    required this.url,
    this.fallbackUrl,
    this.blurSigma = 14.0,
    this.opacity = 0.52,
    this.fit = BoxFit.cover,
  });

  static final Map<String, ui.Image> _cache = <String, ui.Image>{};
  static final Map<String, Future<ui.Image?>> _pending =
      <String, Future<ui.Image?>>{};
  static const int _maxEntries = 60;

  static void _putCache(String key, ui.Image image) {
    _cache.remove(key);
    if (_cache.length >= _maxEntries) {
      _cache.remove(_cache.keys.first);
    }
    _cache[key] = image;
  }

  static Future<ui.Image?> loadBaked(
    String url, {
    required double blurSigma,
  }) {
    if (url.isEmpty) return Future.value(null);
    final key = '$blurSigma|$url';
    final cached = _cache[key];
    if (cached != null) return Future.value(cached);
    final inflight = _pending[key];
    if (inflight != null) return inflight;

    final future = _fetchAndBake(url, blurSigma).then((img) {
      if (img != null) {
        _putCache(key, img);
      }
      _pending.remove(key);
      return img;
    }).catchError((_) {
      _pending.remove(key);
      return null;
    });

    _pending[key] = future;
    return future;
  }

  static Future<ui.Image?> _fetchAndBake(String url, double blurSigma) async {
    final bytes = await _loadBytes(url);
    if (bytes == null || bytes.isEmpty) return null;

    final codec = await ui.instantiateImageCodec(
      bytes,
      targetWidth: 160,
    );
    final frame = await codec.getNextFrame();
    final downscaled = frame.image;

    final width = downscaled.width;
    final height = downscaled.height;
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);

    final sigma = blurSigma.clamp(1.5, 25.0);
    final paint = Paint()
      ..imageFilter = ui.ImageFilter.blur(
        sigmaX: sigma,
        sigmaY: sigma,
        tileMode: TileMode.clamp,
      )
      ..filterQuality = FilterQuality.low;

    canvas.drawImage(downscaled, Offset.zero, paint);
    final picture = recorder.endRecording();
    final baked = await picture.toImage(width, height);
    downscaled.dispose();
    picture.dispose();
    codec.dispose();
    return baked;
  }

  static Future<Uint8List?> _loadBytes(String url) async {
    try {
      if (url.startsWith('http://') || url.startsWith('https://')) {
        final resp = await http
            .get(Uri.parse(url))
            .timeout(const Duration(seconds: 10));
        if (resp.statusCode == 200) {
          return resp.bodyBytes;
        }
        return null;
      }
      if (url.startsWith('file://')) {
        final file = File(url.replaceFirst('file://', ''));
        if (await file.exists()) return await file.readAsBytes();
        return null;
      }
      if (url.startsWith('assets/')) {
        final data = await rootBundle.load(url);
        return data.buffer.asUint8List();
      }
      final file = File(url);
      if (await file.exists()) return await file.readAsBytes();
    } catch (_) {}
    return null;
  }

  @override
  State<BakedBlurImage> createState() => _BakedBlurImageState();
}

class _BakedBlurImageState extends State<BakedBlurImage> {
  ui.Image? _image;
  int _requestId = 0;

  @override
  void initState() {
    super.initState();
    _resolveImage();
  }

  @override
  void didUpdateWidget(covariant BakedBlurImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.url != widget.url ||
        oldWidget.fallbackUrl != widget.fallbackUrl ||
        oldWidget.blurSigma != widget.blurSigma) {
      _resolveImage();
    }
  }

  Future<void> _resolveImage() async {
    final reqId = ++_requestId;
    final primaryKey = '${widget.blurSigma}|${widget.url}';
    final instant = BakedBlurImage._cache[primaryKey];
    if (instant != null) {
      if (_image != instant) {
        setState(() => _image = instant);
      }
      return;
    }

    var loaded = await BakedBlurImage.loadBaked(
      widget.url,
      blurSigma: widget.blurSigma,
    );

    if (loaded == null &&
        widget.fallbackUrl != null &&
        widget.fallbackUrl!.isNotEmpty &&
        widget.fallbackUrl != widget.url) {
      loaded = await BakedBlurImage.loadBaked(
        widget.fallbackUrl!,
        blurSigma: widget.blurSigma,
      );
    }

    if (!mounted || reqId != _requestId) return;
    if (loaded != null && _image != loaded) {
      setState(() => _image = loaded);
    }
  }

  @override
  Widget build(BuildContext context) {
    final img = _image;
    return AnimatedOpacity(
      opacity: img == null ? 0.0 : widget.opacity,
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOut,
      child: img == null
          ? const SizedBox.expand()
          : RawImage(
              image: img,
              fit: widget.fit,
              width: double.infinity,
              height: double.infinity,
              filterQuality: FilterQuality.medium,
            ),
    );
  }
}
