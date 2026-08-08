import 'dart:math' as math;
import 'package:azyx/Providers/theme_provider.dart';
import 'package:azyx/Widgets/AzyXWidgets/azyx_text.dart';
import 'package:azyx/Widgets/theme_widgets/custom_color_template.dart';
import 'package:azyx/core/icons/icons_broken.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CustomColor extends StatefulWidget {
  const CustomColor({super.key});

  @override
  State<CustomColor> createState() => _ThemeModesState();
}

class _ThemeModesState extends State<CustomColor> {
  final List<Map<String, dynamic>> colors = [
    {"name": "Blue", "color": Colors.blue},
    {"name": "Red", "color": Colors.red},
    {"name": "Orange", "color": Colors.orange},
    {"name": "Pink", "color": Colors.pink},
    {"name": "Grey", "color": Colors.grey},
    {"name": "Brown", "color": Colors.brown},
    {"name": "Indigo", "color": Colors.indigo},
    {"name": "Green", "color": Colors.green},
    {"name": "Yellow", "color": Colors.yellow},
    {"name": "Purple", "color": Colors.purple},
    {"name": "Cyan", "color": Colors.cyan},
    {"name": "Teal", "color": Colors.teal},
    {"name": "Amber", "color": Colors.amber},
    {"name": "LightBlue", "color": Colors.lightBlue},
    {"name": "DeepOrange", "color": Colors.deepOrange},
    {"name": "Lime", "color": Colors.lime},
    {"name": "PinkAccent", "color": Colors.pinkAccent},
  ];

  void _showHexDialog(BuildContext context, ThemeProvider provider) {
    Color selectedColor = provider.colorFromHex(provider.customHexColor);
    final controller = TextEditingController(text: provider.customHexColor);

    showDialog(
      context: context,
      builder: (context) {
        final theme = Theme.of(context);
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final hexString =
                '#${selectedColor.value.toRadixString(16).substring(2).toUpperCase()}';

            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(28),
              ),
              backgroundColor: theme.colorScheme.surfaceContainerHighest
                  .withOpacity(0.95),
              child: Container(
                padding: const EdgeInsets.all(20),
                width: 320,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              width: 22,
                              height: 22,
                              decoration: BoxDecoration(
                                color: selectedColor,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white,
                                  width: 2,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: selectedColor.withOpacity(0.5),
                                    blurRadius: 6,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 10),
                            const AzyXText(
                              text: "Color Picker",
                              fontVariant: FontVariant.bold,
                              fontSize: 17,
                            ),
                          ],
                        ),
                        AzyXText(
                          text: hexString,
                          fontVariant: FontVariant.bold,
                          fontSize: 14,
                          color: selectedColor,
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    ColorWheelPicker(
                      initialColor: selectedColor,
                      size: 190,
                      onColorChanged: (newColor) {
                        setDialogState(() {
                          selectedColor = newColor;
                          controller.text =
                              '#${newColor.value.toRadixString(16).substring(2).toUpperCase()}';
                        });
                      },
                    ),
                    const SizedBox(height: 14),
                    TextField(
                      controller: controller,
                      style: TextStyle(
                        color: theme.colorScheme.onSurface,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                      onChanged: (val) {
                        final trimmed = val.trim();
                        if (trimmed.length >= 4) {
                          try {
                            final parsed = provider.colorFromHex(trimmed);
                            setDialogState(() {
                              selectedColor = parsed;
                            });
                          } catch (_) {}
                        }
                      },
                      decoration: InputDecoration(
                        hintText: "#6C5CE7",
                        labelText: "Hex Code",
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        filled: true,
                        fillColor: theme.colorScheme.surface.withOpacity(0.5),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none,
                        ),
                        prefixIcon: Icon(
                          Icons.tag_rounded,
                          size: 18,
                          color: selectedColor,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: TextButton(
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            onPressed: () => Navigator.pop(context),
                            child: AzyXText(
                              text: "Cancel",
                              color: theme.colorScheme.onSurfaceVariant,
                              fontVariant: FontVariant.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: selectedColor,
                              foregroundColor:
                                  selectedColor.computeLuminance() > 0.5
                                  ? Colors.black
                                  : Colors.white,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            onPressed: () {
                              final hex = controller.text.trim();
                              if (hex.isNotEmpty) {
                                provider.setCustomHexColor(hex);
                              }
                              Navigator.pop(context);
                            },
                            child: const AzyXText(
                              text: "Apply Theme",
                              fontVariant: FontVariant.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ThemeProvider>(context);
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.35),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.outline.withOpacity(0.08)),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.tertiary.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(9),
                  ),
                  child: Icon(
                    Broken.color_swatch,
                    size: 18,
                    color: theme.colorScheme.tertiary,
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: AzyXText(
                    text: "Custom Seed Color & Presets",
                    fontVariant: FontVariant.bold,
                    fontSize: 14,
                  ),
                ),
                TextButton.icon(
                  onPressed: () => _showHexDialog(context, provider),
                  icon: const Icon(Icons.colorize_rounded, size: 16),
                  label: const AzyXText(
                    text: "Color Wheel",
                    fontSize: 12,
                    fontVariant: FontVariant.bold,
                  ),
                ),
              ],
            ),
          ),
          Divider(
            height: 1,
            indent: 48,
            endIndent: 14,
            color: theme.colorScheme.outline.withOpacity(0.1),
          ),
          Padding(
            padding: const EdgeInsets.only(
              left: 14,
              right: 14,
              top: 12,
              bottom: 4,
            ),
            child: Row(
              children: [
                Icon(
                  Icons.style_outlined,
                  size: 14,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 6),
                const AzyXText(
                  text: "CURATED THEME PRESETS",
                  fontSize: 11,
                  fontVariant: FontVariant.bold,
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            child: SizedBox(
              height: 42,
              child: ListView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                children: ThemeProvider.presetThemes.entries.map((entry) {
                  final isSelected = provider.colorName == entry.key;
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: ChoiceChip(
                      selected: isSelected,
                      avatar: CircleAvatar(
                        backgroundColor: entry.value,
                        radius: 8,
                      ),
                      label: AzyXText(
                        text: entry.key,
                        fontSize: 11,
                        fontVariant: FontVariant.bold,
                        color: isSelected ? theme.colorScheme.onPrimary : null,
                      ),
                      selectedColor: theme.colorScheme.primary,
                      onSelected: (val) {
                        if (val) {
                          provider.setPresetTheme(entry.key);
                        }
                      },
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          Divider(
            height: 1,
            indent: 14,
            endIndent: 14,
            color: theme.colorScheme.outline.withOpacity(0.08),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: SizedBox(
              height: 160,
              child: ListView.builder(
                shrinkWrap: true,
                physics: const BouncingScrollPhysics(),
                scrollDirection: Axis.horizontal,
                itemCount: colors.length,
                itemBuilder: (context, index) {
                  final isSelected =
                      colors[index]['name'] == provider.colorName;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        provider.updateSeedColor(colors[index]['name']);
                      });
                    },
                    child: CustomColorTemplate(
                      color: colors[index]['color'],
                      isBorder: isSelected,
                      name: colors[index]['name'],
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ColorWheelPicker extends StatefulWidget {
  final Color initialColor;
  final ValueChanged<Color> onColorChanged;
  final double size;

  const ColorWheelPicker({
    super.key,
    required this.initialColor,
    required this.onColorChanged,
    this.size = 200,
  });

  @override
  State<ColorWheelPicker> createState() => _ColorWheelPickerState();
}

class _ColorWheelPickerState extends State<ColorWheelPicker> {
  late HSVColor _hsvColor;

  @override
  void initState() {
    super.initState();
    _hsvColor = HSVColor.fromColor(widget.initialColor);
  }

  void _updateColorFromOffset(Offset localOffset, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final dx = localOffset.dx - center.dx;
    final dy = localOffset.dy - center.dy;
    final radius = size.width / 2;
    final distance = math.sqrt(dx * dx + dy * dy);

    if (distance <= radius) {
      double angle = math.atan2(dy, dx) * 180 / math.pi;
      if (angle < 0) angle += 360;
      final saturation = (distance / radius).clamp(0.0, 1.0);
      setState(() {
        _hsvColor = HSVColor.fromAHSV(
          1.0,
          angle,
          saturation,
          _hsvColor.value.clamp(0.2, 1.0),
        );
      });
      widget.onColorChanged(_hsvColor.toColor());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: widget.size,
          height: widget.size,
          child: GestureDetector(
            onPanStart: (details) => _updateColorFromOffset(
              details.localPosition,
              Size(widget.size, widget.size),
            ),
            onPanUpdate: (details) => _updateColorFromOffset(
              details.localPosition,
              Size(widget.size, widget.size),
            ),
            onTapDown: (details) => _updateColorFromOffset(
              details.localPosition,
              Size(widget.size, widget.size),
            ),
            child: CustomPaint(
              size: Size(widget.size, widget.size),
              painter: _ColorWheelPainter(hsvColor: _hsvColor),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const AzyXText(
              text: "Brightness",
              fontSize: 11,
              fontVariant: FontVariant.bold,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  activeTrackColor: _hsvColor.toColor(),
                  thumbColor: _hsvColor.toColor(),
                  overlayColor: _hsvColor.toColor().withOpacity(0.2),
                  inactiveTrackColor: _hsvColor.toColor().withOpacity(0.2),
                ),
                child: Slider(
                  value: _hsvColor.value,
                  min: 0.1,
                  max: 1.0,
                  onChanged: (val) {
                    setState(() {
                      _hsvColor = _hsvColor.withValue(val);
                    });
                    widget.onColorChanged(_hsvColor.toColor());
                  },
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _ColorWheelPainter extends CustomPainter {
  final HSVColor hsvColor;

  _ColorWheelPainter({required this.hsvColor});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    final sweepGradient = SweepGradient(
      colors: List.generate(
        361,
        (i) => HSVColor.fromAHSV(1.0, i.toDouble(), 1.0, 1.0).toColor(),
      ),
    );
    final huePaint = Paint()
      ..shader = sweepGradient.createShader(
        Rect.fromCircle(center: center, radius: radius),
      );
    canvas.drawCircle(center, radius, huePaint);

    final radialGradient = RadialGradient(
      colors: [
        Colors.white.withOpacity(hsvColor.value),
        Colors.white.withOpacity(0.0),
      ],
    );
    final satPaint = Paint()
      ..shader = radialGradient.createShader(
        Rect.fromCircle(center: center, radius: radius),
      );
    canvas.drawCircle(center, radius, satPaint);

    final angleRad = hsvColor.hue * math.pi / 180;
    final distance = hsvColor.saturation * radius;
    final thumbOffset = Offset(
      center.dx + distance * math.cos(angleRad),
      center.dy + distance * math.sin(angleRad),
    );

    final thumbOutlinePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    final thumbFillPaint = Paint()
      ..color = hsvColor.toColor()
      ..style = PaintingStyle.fill;

    canvas.drawCircle(thumbOffset, 10, thumbFillPaint);
    canvas.drawCircle(thumbOffset, 10, thumbOutlinePaint);
  }

  @override
  bool shouldRepaint(covariant _ColorWheelPainter oldDelegate) {
    return oldDelegate.hsvColor != hsvColor;
  }
}
