import 'dart:ui' as ui;
import 'coordinate_transformer.dart';
import 'ffi_image_decoder.dart';
class Tile {
  final ui.Rect sRect;
  final int sampleSize;
  bool visible = false;
  bool loading = false;
  ui.Image? image;
  Tile({required this.sRect, required this.sampleSize});
  void dispose() {
    image?.dispose();
    image = null;
    if (loading) {
      ffiImageDecoder.cancel(this);
      loading = false;
    }
  }
}
class TilingEngine {
  Map<int, List<Tile>> tileMap = {};
  int fullImageSampleSize = 1;
  void initialiseTileMap({
    required int sWidth,
    required int sHeight,
    required double maxTileWidth,
    required double maxTileHeight,
    required int baseSampleSize,
    required double viewWidth,
    required double viewHeight,
  }) {
    dispose();
    tileMap = {};
    fullImageSampleSize = baseSampleSize;
    int sampleSize = fullImageSampleSize;
    while (true) {
      int xTiles = 1;
      int yTiles = 1;
      int sTileWidth = sWidth ~/ xTiles;
      int sTileHeight = sHeight ~/ yTiles;
      int subTileWidth = sTileWidth ~/ sampleSize;
      int subTileHeight = sTileHeight ~/ sampleSize;
      while (subTileWidth + xTiles + 1 > maxTileWidth ||
          (subTileWidth > viewWidth * 1.25 &&
              sampleSize < fullImageSampleSize)) {
        xTiles += 1;
        sTileWidth = sWidth ~/ xTiles;
        subTileWidth = sTileWidth ~/ sampleSize;
      }
      while (subTileHeight + yTiles + 1 > maxTileHeight ||
          (subTileHeight > viewHeight * 1.25 &&
              sampleSize < fullImageSampleSize)) {
        yTiles += 1;
        sTileHeight = sHeight ~/ yTiles;
        subTileHeight = sTileHeight ~/ sampleSize;
      }
      List<Tile> tileGrid = [];
      for (int x = 0; x < xTiles; x++) {
        for (int y = 0; y < yTiles; y++) {
          final tileLeft = x * sTileWidth;
          final tileTop = y * sTileHeight;
          final tileRight = (x == xTiles - 1) ? sWidth : (x + 1) * sTileWidth;
          final tileBottom = (y == yTiles - 1)
              ? sHeight
              : (y + 1) * sTileHeight;
          final tile = Tile(
            sRect: ui.Rect.fromLTRB(
              tileLeft.toDouble(),
              tileTop.toDouble(),
              tileRight.toDouble(),
              tileBottom.toDouble(),
            ),
            sampleSize: sampleSize,
          );
          tile.visible = (sampleSize == fullImageSampleSize);
          tileGrid.add(tile);
        }
      }
      tileMap[sampleSize] = tileGrid;
      if (sampleSize == 1) {
        break;
      } else {
        sampleSize = sampleSize ~/ 2;
      }
    }
  }
  void refreshRequiredTiles({
    required double scale,
    required ui.Offset vTranslate,
    required ui.Size viewSize,
    required int rotation,
    required int sWidth,
    required int sHeight,
    required int targetSampleSize,
    required Function(Tile tile) loadTileCallback,
  }) {
    final transformer = CoordinateTransformer(
      scale: scale,
      vTranslate: vTranslate,
      rotation: rotation,
      sWidth: sWidth,
      sHeight: sHeight,
    );
    final viewRect = ui.Rect.fromLTWH(0, 0, viewSize.width, viewSize.height);
    for (final entry in tileMap.entries) {
      final _ = entry.key;
      final tiles = entry.value;
      for (final tile in tiles) {
        if (tile.sampleSize < targetSampleSize ||
            (tile.sampleSize > targetSampleSize &&
                tile.sampleSize != fullImageSampleSize)) {
          tile.visible = false;
          tile.dispose();
          continue;
        }
        if (tile.sampleSize == targetSampleSize) {
          final tileViewRect = transformer.sourceToViewRect(tile.sRect);
          final isVisibleOnScreen = viewRect.overlaps(tileViewRect);
          if (isVisibleOnScreen) {
            tile.visible = true;
            if (!tile.loading && tile.image == null) {
              loadTileCallback(tile);
            }
          } else if (tile.sampleSize != fullImageSampleSize) {
            tile.visible = false;
            tile.dispose();
          }
        } else if (tile.sampleSize == fullImageSampleSize) {
          tile.visible = true;
        }
      }
    }
  }
  bool isBaseLayerReady() {
    final baseGrid = tileMap[fullImageSampleSize];
    if (baseGrid == null || baseGrid.isEmpty) return false;
    for (final tile in baseGrid) {
      if (tile.image == null) return false;
    }
    return true;
  }
  void dispose() {
    for (final grid in tileMap.values) {
      for (final tile in grid) {
        tile.dispose();
      }
    }
    tileMap.clear();
  }
}
