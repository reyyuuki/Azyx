import 'dart:io';
import 'package:flutter/material.dart';
import 'package:anymex_extension_runtime_bridge/anymex_extension_runtime_bridge.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'subsampling_scale_image_view.dart';
class SubsamplingImageProvider extends StatefulWidget {
  final PageUrl page;
  final BoxFit fit;
  final Alignment alignment;
  final bool cropBorders;
  final bool isContinuousMode;
  final Widget? placeholder;
  final Function(double width, double height)? onImageLoaded;
  const SubsamplingImageProvider({
    super.key,
    required this.page,
    this.fit = BoxFit.contain,
    this.alignment = Alignment.center,
    required this.cropBorders,
    this.isContinuousMode = false,
    this.placeholder,
    this.onImageLoaded,
  });
  @override
  State<SubsamplingImageProvider> createState() =>
      _SubsamplingImageProviderState();
}
class _SubsamplingImageProviderState extends State<SubsamplingImageProvider> {
  Future<File>? _loadFuture;
  @override
  void initState() {
    super.initState();
    _initLoad();
  }
  @override
  void didUpdateWidget(SubsamplingImageProvider oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.page.url != widget.page.url) {
      _initLoad();
    }
  }
  void _initLoad() {
    final url = widget.page.url;
    if (url.startsWith('http')) {
      _loadFuture = Future.error('HTTP loading not supported without cache manager');
    } else {
      _loadFuture = Future.value(File(url));
    }
  }
  @override
  Widget build(BuildContext context) {
    if (widget.isContinuousMode) {
      final url = widget.page.url;
      if (url.startsWith('http')) {
        return CachedNetworkImage(
          imageUrl: url,
          httpHeaders: widget.page.headers,
          fit: widget.fit,
          alignment: widget.alignment,
          placeholder: (context, url) =>
              widget.placeholder ?? const Center(child: CircularProgressIndicator()),
          errorWidget: (context, url, error) => const Icon(Icons.error),
        );
      } else {
        final file = File(url);
        if (file.existsSync()) {
          final imageStream =
              FileImage(file).resolve(const ImageConfiguration());
          imageStream.addListener(ImageStreamListener((info, _) {
            widget.onImageLoaded?.call(
                info.image.width.toDouble(), info.image.height.toDouble());
          }));
        }
        return Image.file(
          file,
          fit: widget.fit,
          alignment: widget.alignment,
        );
      }
    }
    if (Platform.isLinux) {
      final url = widget.page.url;
      if (url.startsWith('http')) {
        return CachedNetworkImage(
          imageUrl: url,
          httpHeaders: widget.page.headers,
          fit: widget.fit,
          alignment: widget.alignment,
          placeholder: (context, url) =>
              widget.placeholder ?? const Center(child: CircularProgressIndicator()),
          errorWidget: (context, url, error) => const Icon(Icons.error),
        );
      } else {
        final file = File(url);
        FileImage(file).evict();
        final lastMod = file.existsSync() ? file.lastModifiedSync().millisecondsSinceEpoch : 0;
        return Image.file(
          file,
          key: ValueKey('${url}_$lastMod'),
          fit: widget.fit,
          alignment: widget.alignment,
        );
      }
    }
    return FutureBuilder<File>(
      future: _loadFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return widget.placeholder ??
              const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasData && snapshot.data != null) {
          final file = snapshot.data!;
          if (file.existsSync()) {
            final scaleType = widget.fit == BoxFit.fitWidth
                ? ScaleType.fitWidth
                : ScaleType.centerInside;
            return SubsamplingScaleImageView(
              key: ValueKey(file.path),
              image: FileImage(file),
              resolvedFilePath: file.path,
              cropBorders: widget.cropBorders,
              minimumScaleType: scaleType,
              panEnabled: false,
              zoomEnabled: false,
              quickScaleEnabled: false,
            );
          }
        }
        return widget.placeholder ??
            const Center(
              child: Text(
                'Failed to load page',
                style: TextStyle(color: Colors.white),
              ),
            );
      },
    );
  }
}
