import 'dart:ui' as ui;
class CoordinateTransformer {
  final double scale;
  final ui.Offset vTranslate;
  final int rotation; 
  final int sWidth; 
  final int sHeight; 
  CoordinateTransformer({
    required this.scale,
    required this.vTranslate,
    required this.rotation,
    required this.sWidth,
    required this.sHeight,
  });
  ui.Offset viewToSource(ui.Offset vCoord) {
    final double sx = (vCoord.dx - vTranslate.dx) / scale;
    final double sy = (vCoord.dy - vTranslate.dy) / scale;
    return ui.Offset(sx, sy);
  }
  ui.Offset vCoordToSCoord(ui.Offset vCoord) => viewToSource(vCoord);
  ui.Offset sourceToView(ui.Offset sCoord) {
    final double vx = (sCoord.dx * scale) + vTranslate.dx;
    final double vy = (sCoord.dy * scale) + vTranslate.dy;
    return ui.Offset(vx, vy);
  }
  ui.Offset sCoordToVCoord(ui.Offset sCoord) => sourceToView(sCoord);
  ui.Rect sourceToViewRect(ui.Rect sRect) {
    final ui.Offset topLeft = sourceToView(sRect.topLeft);
    final ui.Offset bottomRight = sourceToView(sRect.bottomRight);
    return ui.Rect.fromPoints(topLeft, bottomRight);
  }
  ui.Rect fileSRect(ui.Rect sRect) {
    switch (rotation) {
      case 90:
        return ui.Rect.fromLTRB(
          sRect.top,
          sHeight - sRect.right,
          sRect.bottom,
          sHeight - sRect.left,
        );
      case 180:
        return ui.Rect.fromLTRB(
          sWidth - sRect.right,
          sHeight - sRect.bottom,
          sWidth - sRect.left,
          sHeight - sRect.top,
        );
      case 270:
        return ui.Rect.fromLTRB(
          sWidth - sRect.bottom,
          sRect.left,
          sWidth - sRect.top,
          sRect.right,
        );
      case 0:
      default:
        return sRect;
    }
  }
  int get effectiveSWidth {
    return (rotation == 90 || rotation == 270) ? sHeight : sWidth;
  }
  int get effectiveSHeight {
    return (rotation == 90 || rotation == 270) ? sWidth : sHeight;
  }
}
