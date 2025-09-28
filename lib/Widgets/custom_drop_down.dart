import 'package:azyx/Widgets/AzyXWidgets/azyx_text.dart';
import 'package:azyx/utils/Functions/functions.dart';
import 'package:dartotsu_extension_bridge/ExtensionManager.dart';
import 'package:dartotsu_extension_bridge/Models/Source.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:get/get.dart';

class CustomSourceDropdown extends StatefulWidget {
  final RxList<Source> items;
  final Function(String?) onChanged;
  final String labelText;
  final dynamic sourceController;
  final Source? selectedSource;
  final Rx<Source>? customSelectedSource;

  const CustomSourceDropdown({
    super.key,
    required this.items,
    required this.onChanged,
    required this.sourceController,
    this.selectedSource,
    this.customSelectedSource,
    this.labelText = 'Choose Source',
  });

  @override
  State<CustomSourceDropdown> createState() => _CustomSourceDropdownState();
}

class _CustomSourceDropdownState extends State<CustomSourceDropdown>
    with SingleTickerProviderStateMixin {
  bool isOpen = false;
  late AnimationController _animationController;
  late Animation<double> _animation;
  OverlayEntry? _overlayEntry;
  final GlobalKey _dropdownKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 350),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _overlayEntry?.remove();
    super.dispose();
  }

  Source? get selectedSource {
    if (widget.customSelectedSource != null) {
      return widget.customSelectedSource!.value;
    }
    if (widget.selectedSource != null) {
      return widget.selectedSource;
    }
    if (widget.sourceController.activeSource?.value != null) {
      return widget.sourceController.activeSource.value;
    }
    return null;
  }

  String? get selectedValue {
    final source = selectedSource;
    if (source == null) return null;
    return "${source.name}_${source.extensionType}";
  }

  void _toggleDropdown() {
    if (isOpen) {
      _closeDropdown();
    } else {
      _openDropdown();
    }
  }

  void _openDropdown() {
    if (isOpen) return;
    final renderBox =
        _dropdownKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return;
    setState(() {
      isOpen = true;
    });
    _animationController.forward();
    _overlayEntry = _createOverlayEntry();
    Overlay.of(context).insert(_overlayEntry!);
  }

  void _closeDropdown() {
    if (!isOpen) return;
    setState(() {
      isOpen = false;
    });
    _animationController.reverse().then((_) {
      _overlayEntry?.remove();
      _overlayEntry = null;
    });
  }

  OverlayEntry _createOverlayEntry() {
    final RenderBox renderBox =
        _dropdownKey.currentContext!.findRenderObject() as RenderBox;
    final Size size = renderBox.size;
    final Offset offset = renderBox.localToGlobal(Offset.zero);
    final theme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return OverlayEntry(
      builder: (context) => GestureDetector(
        onTap: _closeDropdown,
        child: Container(
          width: double.infinity,
          height: double.infinity,
          color: Colors.transparent,
          child: Stack(
            children: [
              Positioned(
                left: offset.dx,
                top: offset.dy + size.height + 12,
                width: size.width,
                child: Material(
                  elevation: 0,
                  color: Colors.transparent,
                  child: AnimatedBuilder(
                    animation: _animation,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: 0.95 + (0.05 * _animation.value),
                        alignment: Alignment.topCenter,
                        child: Transform.translate(
                          offset: Offset(0, -10 * (1 - _animation.value)),
                          child: Opacity(
                            opacity: _animation.value,
                            child: Container(
                              constraints: BoxConstraints(
                                maxHeight:
                                    MediaQuery.of(context).size.height * 0.4,
                              ),
                              // Replace the gradient in the dropdown overlay container
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: isDark
                                      ? [
                                          Colors.grey[900]!.withOpacity(0.95),
                                          Colors.grey[850]!.withOpacity(0.90),
                                          Colors.grey[900]!.withOpacity(0.92),
                                        ]
                                      : [
                                          Colors.white.withOpacity(0.95),
                                          Colors.grey[50]!.withOpacity(0.90),
                                          Colors.white.withOpacity(0.92),
                                        ],
                                ),
                                borderRadius: BorderRadius.circular(24),
                                border: Border.all(
                                  color: Colors.white.withOpacity(
                                    isDark ? 0.2 : 0.4,
                                  ),
                                  width: 1.5,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: theme.shadow.withOpacity(
                                      isDark ? 0.4 : 0.2,
                                    ),
                                    blurRadius: 30,
                                    spreadRadius: 0,
                                    offset: const Offset(0, 15),
                                  ),
                                  BoxShadow(
                                    color: Colors.black.withOpacity(
                                      isDark ? 0.2 : 0.1,
                                    ),
                                    blurRadius: 20,
                                    spreadRadius: -10,
                                    offset: const Offset(0, -8),
                                  ),
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(24),
                                child: ListView.builder(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                  ),
                                  shrinkWrap: true,
                                  itemCount: widget.items.length,
                                  itemBuilder: (context, index) {
                                    final item = widget.items[index];
                                    final itemValue =
                                        "${item.name}_${item.extensionType}";
                                    final currentSelectedSource =
                                        selectedSource;
                                    final currentSelectedValue =
                                        currentSelectedSource != null
                                        ? "${currentSelectedSource.name}_${currentSelectedSource.extensionType}"
                                        : null;
                                    final isSelected =
                                        currentSelectedValue == itemValue;

                                    return GestureDetector(
                                      onTap: () {
                                        widget.onChanged(itemValue);
                                        _closeDropdown();
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 20,
                                          vertical: 16,
                                        ),
                                        margin: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 3,
                                        ),
                                        decoration: BoxDecoration(
                                          gradient: isSelected
                                              ? LinearGradient(
                                                  begin: Alignment.topLeft,
                                                  end: Alignment.bottomRight,
                                                  colors: [
                                                    theme.primary.withOpacity(
                                                      0.15,
                                                    ),
                                                    theme.primary.withOpacity(
                                                      0.05,
                                                    ),
                                                    theme.primary.withOpacity(
                                                      0.1,
                                                    ),
                                                  ],
                                                )
                                              : null,
                                          borderRadius: BorderRadius.circular(
                                            18,
                                          ),
                                          border: isSelected
                                              ? Border.all(
                                                  color: theme.primary
                                                      .withOpacity(0.4),
                                                  width: 1.5,
                                                )
                                              : null,
                                          boxShadow: isSelected
                                              ? [
                                                  BoxShadow(
                                                    color: theme.primary
                                                        .withOpacity(0.2),
                                                    blurRadius: 15,
                                                    spreadRadius: 0,
                                                    offset: const Offset(0, 5),
                                                  ),
                                                ]
                                              : null,
                                        ),
                                        child: Row(
                                          children: [
                                            Container(
                                              width: 40,
                                              height: 40,
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                                gradient: LinearGradient(
                                                  begin: Alignment.topLeft,
                                                  end: Alignment.bottomRight,
                                                  colors: [
                                                    Colors.white.withOpacity(
                                                      isDark ? 0.08 : 1,
                                                    ),
                                                    Colors.white.withOpacity(
                                                      isDark ? 0.02 : 1,
                                                    ),
                                                  ],
                                                ),
                                                border: Border.all(
                                                  color: Colors.white
                                                      .withOpacity(
                                                        isDark ? 0.1 : 1,
                                                      ),
                                                  width: 1,
                                                ),
                                              ),
                                              child: ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                                child: CachedNetworkImage(
                                                  imageUrl: item.iconUrl!,
                                                  width: 40,
                                                  height: 40,
                                                  fit: BoxFit.cover,
                                                  placeholder: (context, url) =>
                                                      Container(
                                                        decoration: BoxDecoration(
                                                          gradient: LinearGradient(
                                                            begin: Alignment
                                                                .topLeft,
                                                            end: Alignment
                                                                .bottomRight,
                                                            colors: [
                                                              Colors.white
                                                                  .withOpacity(
                                                                    isDark
                                                                        ? 0.05
                                                                        : 1,
                                                                  ),
                                                              Colors.white
                                                                  .withOpacity(
                                                                    isDark
                                                                        ? 0.01
                                                                        : 1,
                                                                  ),
                                                            ],
                                                          ),
                                                        ),
                                                        child: Icon(
                                                          Icons.extension,
                                                          color: theme
                                                              .onSurfaceVariant
                                                              .withOpacity(0.7),
                                                          size: 20,
                                                        ),
                                                      ),
                                                  errorWidget:
                                                      (
                                                        context,
                                                        url,
                                                        error,
                                                      ) => Container(
                                                        decoration: BoxDecoration(
                                                          gradient: LinearGradient(
                                                            begin: Alignment
                                                                .topLeft,
                                                            end: Alignment
                                                                .bottomRight,
                                                            colors: [
                                                              Colors.white
                                                                  .withOpacity(
                                                                    isDark
                                                                        ? 0.05
                                                                        : 1,
                                                                  ),
                                                              Colors.white
                                                                  .withOpacity(
                                                                    isDark
                                                                        ? 0.01
                                                                        : 1,
                                                                  ),
                                                            ],
                                                          ),
                                                        ),
                                                        child: Icon(
                                                          Icons.extension,
                                                          color: theme
                                                              .onSurfaceVariant
                                                              .withOpacity(0.7),
                                                          size: 20,
                                                        ),
                                                      ),
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 16),
                                            Expanded(
                                              child: AzyXText(
                                                text: item.name ?? '',
                                                fontSize: 15,
                                                fontVariant: isSelected
                                                    ? FontVariant.bold
                                                    : FontVariant.regular,
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            Container(
                                              width: 32,
                                              height: 32,
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                                gradient: LinearGradient(
                                                  begin: Alignment.topLeft,
                                                  end: Alignment.bottomRight,
                                                  colors: [
                                                    Colors.white.withOpacity(
                                                      isDark ? 0.06 : 0.18,
                                                    ),
                                                    Colors.white.withOpacity(
                                                      isDark ? 0.01 : 0.03,
                                                    ),
                                                  ],
                                                ),
                                                border: Border.all(
                                                  color: Colors.white
                                                      .withOpacity(
                                                        isDark ? 0.08 : 0.2,
                                                      ),
                                                  width: 1,
                                                ),
                                              ),
                                              child: ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                                child: CachedNetworkImage(
                                                  imageUrl: getExtensionIcon(
                                                    item.extensionType ??
                                                        ExtensionType.mangayomi,
                                                  ),
                                                  width: 32,
                                                  height: 32,
                                                  fit: BoxFit.cover,
                                                  placeholder: (context, url) =>
                                                      Container(
                                                        decoration: BoxDecoration(
                                                          gradient: LinearGradient(
                                                            begin: Alignment
                                                                .topLeft,
                                                            end: Alignment
                                                                .bottomRight,
                                                            colors: [
                                                              Colors.white
                                                                  .withOpacity(
                                                                    isDark
                                                                        ? 0.03
                                                                        : 1,
                                                                  ),
                                                              Colors.white
                                                                  .withOpacity(
                                                                    isDark
                                                                        ? 0.01
                                                                        : 1,
                                                                  ),
                                                            ],
                                                          ),
                                                        ),
                                                        child: Icon(
                                                          Icons.extension,
                                                          color: theme
                                                              .onSurfaceVariant
                                                              .withOpacity(0.6),
                                                          size: 16,
                                                        ),
                                                      ),
                                                  errorWidget:
                                                      (
                                                        context,
                                                        url,
                                                        error,
                                                      ) => Container(
                                                        decoration: BoxDecoration(
                                                          gradient: LinearGradient(
                                                            begin: Alignment
                                                                .topLeft,
                                                            end: Alignment
                                                                .bottomRight,
                                                            colors: [
                                                              Colors.white
                                                                  .withOpacity(
                                                                    isDark
                                                                        ? 0.03
                                                                        : 0.12,
                                                                  ),
                                                              Colors.white
                                                                  .withOpacity(
                                                                    isDark
                                                                        ? 0.01
                                                                        : 0.03,
                                                                  ),
                                                            ],
                                                          ),
                                                        ),
                                                        child: Icon(
                                                          Icons.extension,
                                                          color: theme
                                                              .onSurfaceVariant
                                                              .withOpacity(0.6),
                                                          size: 16,
                                                        ),
                                                      ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Obx(() {
      final Rxn<Source> selectedSource = Rxn(this.selectedSource);
      return GestureDetector(
        onTap: _toggleDropdown,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          key: _dropdownKey,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isOpen
                  ? [
                      Colors.white.withOpacity(isDark ? 0.12 : 0.3),
                      Colors.white.withOpacity(isDark ? 0.03 : 0.08),
                      Colors.white.withOpacity(isDark ? 0.08 : 0.18),
                    ]
                  : [
                      Colors.white.withOpacity(isDark ? 0.08 : 1),
                      Colors.white.withOpacity(isDark ? 0.02 : 1),
                      Colors.white.withOpacity(isDark ? 0.05 : 1),
                    ],
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: isOpen
                  ? theme.primary.withOpacity(0.6)
                  : Colors.white.withOpacity(isDark ? 0.15 : 0.3),
              width: isOpen ? 2 : 1.5,
            ),
            boxShadow: [
              if (isOpen) ...[
                BoxShadow(
                  color: theme.primary.withOpacity(0.15),
                  blurRadius: 25,
                  spreadRadius: 0,
                  offset: const Offset(0, 10),
                ),
                BoxShadow(
                  color: Colors.white.withOpacity(isDark ? 0.05 : 0.15),
                  blurRadius: 15,
                  spreadRadius: -8,
                  offset: const Offset(0, -4),
                ),
              ] else ...[
                BoxShadow(
                  color: theme.shadow.withOpacity(isDark ? 0.2 : 0.1),
                  blurRadius: 20,
                  spreadRadius: 0,
                  offset: const Offset(0, 8),
                ),
                BoxShadow(
                  color: Colors.white.withOpacity(isDark ? 0.03 : 0.1),
                  blurRadius: 12,
                  spreadRadius: -6,
                  offset: const Offset(0, -3),
                ),
              ],
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                if (!selectedSource.isNull) ...[
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.white.withOpacity(isDark ? 0.08 : 0.2),
                          Colors.white.withOpacity(isDark ? 0.02 : 0.05),
                        ],
                      ),
                      border: Border.all(
                        color: Colors.white.withOpacity(isDark ? 0.12 : 0.25),
                        width: 1,
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: CachedNetworkImage(
                        imageUrl: selectedSource.value!.iconUrl!,
                        width: 40,
                        height: 40,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Colors.white.withOpacity(isDark ? 0.05 : 0.15),
                                Colors.white.withOpacity(isDark ? 0.01 : 0.05),
                              ],
                            ),
                          ),
                          child: Icon(
                            Icons.extension,
                            color: theme.onSurfaceVariant.withOpacity(0.7),
                            size: 20,
                          ),
                        ),
                        errorWidget: (context, url, error) => Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Colors.white.withOpacity(isDark ? 0.05 : 0.15),
                                Colors.white.withOpacity(isDark ? 0.01 : 0.05),
                              ],
                            ),
                          ),
                          child: Icon(
                            Icons.extension,
                            color: theme.onSurfaceVariant.withOpacity(0.7),
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                ],
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AzyXText(
                        text: widget.labelText,
                        fontSize: 13,
                        fontVariant: FontVariant.regular,
                      ),
                      const SizedBox(height: 6),
                      AzyXText(
                        text: selectedSource.value?.name ?? 'Select source...',
                        fontSize: 17,
                        fontVariant: !selectedSource.isNull
                            ? FontVariant.bold
                            : FontVariant.regular,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.white.withOpacity(isDark ? 0.06 : 0.18),
                        Colors.white.withOpacity(isDark ? 0.01 : 0.03),
                      ],
                    ),
                    border: Border.all(
                      color: Colors.white.withOpacity(isDark ? 0.1 : 0.22),
                      width: 1,
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: selectedSource.value != null
                        ? CachedNetworkImage(
                            imageUrl: getExtensionIcon(
                              selectedSource.value!.extensionType ??
                                  ExtensionType.mangayomi,
                            ),
                            width: 36,
                            height: 36,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    Colors.white.withOpacity(
                                      isDark ? 0.03 : 0.12,
                                    ),
                                    Colors.white.withOpacity(
                                      isDark ? 0.01 : 0.03,
                                    ),
                                  ],
                                ),
                              ),
                              child: Icon(
                                Icons.extension,
                                color: theme.onSurfaceVariant.withOpacity(0.6),
                                size: 18,
                              ),
                            ),
                            errorWidget: (context, url, error) => Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    Colors.white.withOpacity(
                                      isDark ? 0.03 : 0.12,
                                    ),
                                    Colors.white.withOpacity(
                                      isDark ? 0.01 : 0.03,
                                    ),
                                  ],
                                ),
                              ),
                              child: Icon(
                                Icons.extension,
                                color: theme.onSurfaceVariant.withOpacity(0.6),
                                size: 18,
                              ),
                            ),
                          )
                        : Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  Colors.white.withOpacity(
                                    isDark ? 0.03 : 0.12,
                                  ),
                                  Colors.white.withOpacity(
                                    isDark ? 0.01 : 0.03,
                                  ),
                                ],
                              ),
                            ),
                            child: Icon(
                              Icons.extension,
                              color: theme.onSurfaceVariant.withOpacity(0.6),
                              size: 18,
                            ),
                          ),
                  ),
                ),
                const SizedBox(width: 12),
                AnimatedRotation(
                  turns: isOpen ? 0.5 : 0,
                  duration: const Duration(milliseconds: 350),
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.white.withOpacity(isDark ? 0.05 : 0.15),
                          Colors.white.withOpacity(isDark ? 0.01 : 0.03),
                        ],
                      ),
                      border: Border.all(
                        color: Colors.white.withOpacity(isDark ? 0.08 : 0.2),
                        width: 1,
                      ),
                    ),
                    child: Icon(
                      Icons.keyboard_arrow_down,
                      color: theme.onSurfaceVariant.withOpacity(0.8),
                      size: 22,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }
}
