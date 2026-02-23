import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_acrylic/flutter_acrylic.dart';

class AcrylicTestScreen extends StatefulWidget {
  const AcrylicTestScreen({Key? key}) : super(key: key);

  @override
  State<AcrylicTestScreen> createState() => _AcrylicTestScreenState();
}

class _AcrylicTestScreenState extends State<AcrylicTestScreen> {
  WindowEffect selectedEffect = WindowEffect.disabled;
  Color selectedColor = const Color(0xCC222222);
  bool isDark = true;
  double opacity = 0.8;

  void applyEffect() async {
    await Window.setEffect(
      effect: selectedEffect,
      color: selectedColor.withOpacity(opacity),
      dark: isDark,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter Acrylic Test'),
        backgroundColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Window Effects
            const Text(
              'Window Effects',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: WindowEffect.values.map((effect) {
                return ChoiceChip(
                  label: Text(effect.toString().split('.').last),
                  selected: selectedEffect == effect,
                  onSelected: (selected) {
                    if (selected) {
                      setState(() => selectedEffect = effect);
                      applyEffect();
                    }
                  },
                );
              }).toList(),
            ),

            const SizedBox(height: 24),
            const Divider(),

            // Color Picker
            const Text(
              'Background Color',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _colorButton(Colors.black, 'Black'),
                _colorButton(const Color(0xFF222222), 'Dark Gray'),
                _colorButton(const Color(0xFF1a1a1a), 'Very Dark'),
                _colorButton(Colors.white, 'White'),
                _colorButton(const Color(0xFFDDDDDD), 'Light Gray'),
                _colorButton(Colors.blue.shade900, 'Blue'),
                _colorButton(Colors.purple.shade900, 'Purple'),
                _colorButton(Colors.red.shade900, 'Red'),
              ],
            ),

            const SizedBox(height: 24),
            const Divider(),

            // Opacity Slider
            const Text(
              'Opacity',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Slider(
              value: opacity,
              min: 0.0,
              max: 1.0,
              divisions: 10,
              label: opacity.toStringAsFixed(1),
              onChanged: (value) {
                setState(() => opacity = value);
              },
              onChangeEnd: (value) => applyEffect(),
            ),

            const SizedBox(height: 24),
            const Divider(),

            // Dark Mode Toggle
            SwitchListTile(
              title: const Text('Dark Mode'),
              value: isDark,
              onChanged: (value) {
                setState(() => isDark = value);
                applyEffect();
              },
            ),

            const SizedBox(height: 24),
            const Divider(),

            // Window Controls
            const Text(
              'Window Controls',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ElevatedButton(
                  onPressed: () => Window.hideWindowControls(),
                  child: const Text('Hide Controls'),
                ),
                ElevatedButton(
                  onPressed: () => Window.showWindowControls(),
                  child: const Text('Show Controls'),
                ),
                ElevatedButton(
                  onPressed: () => Window.makeTitlebarTransparent(),
                  child: const Text('Transparent Titlebar'),
                ),
                ElevatedButton(
                  onPressed: () => Window.makeTitlebarOpaque(),
                  child: const Text('Opaque Titlebar'),
                ),
                ElevatedButton(
                  onPressed: () => Window.enterFullscreen(),
                  child: const Text('Enter Fullscreen'),
                ),
                ElevatedButton(
                  onPressed: () => Window.exitFullscreen(),
                  child: const Text('Exit Fullscreen'),
                ),
              ],
            ),

            const SizedBox(height: 24),
            const Divider(),

            // Quick Presets
            const Text(
              'Quick Presets',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () async {
                if (Platform.isWindows) {
                  Window.makeTitlebarTransparent();
                  await Window.setEffect(effect: WindowEffect.disabled);
                }
              },
              child: const Text('Preset 1: Transparent Title + No Effect'),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () async {
                if (Platform.isWindows) {
                  Window.makeTitlebarTransparent();
                  await Window.setEffect(
                    effect: WindowEffect.solid,
                    color: const Color(0xFF1a1a1a),
                    dark: true,
                  );
                }
              },
              child: const Text('Preset 2: Solid Dark Background'),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () async {
                if (Platform.isWindows) {
                  Window.makeTitlebarTransparent();
                  await Window.setEffect(
                    effect: WindowEffect.acrylic,
                    color: const Color(0xCC222222),
                    dark: true,
                  );
                }
              },
              child: const Text('Preset 3: Acrylic Dark'),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () async {
                if (Platform.isWindows) {
                  Window.makeTitlebarTransparent();
                  await Window.setEffect(effect: WindowEffect.mica, dark: true);
                }
              },
              child: const Text('Preset 4: Mica (Windows 11)'),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _colorButton(Color color, String label) {
    return InkWell(
      onTap: () {
        setState(() => selectedColor = color);
        applyEffect();
      },
      child: Container(
        width: 80,
        height: 60,
        decoration: BoxDecoration(
          color: color,
          border: Border.all(
            color: selectedColor == color ? Colors.blue : Colors.grey,
            width: selectedColor == color ? 3 : 1,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: color.computeLuminance() > 0.5
                  ? Colors.black
                  : Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
