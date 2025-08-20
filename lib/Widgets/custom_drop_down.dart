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
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
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
                top: offset.dy + size.height + 8,
                width: size.width,
                child: Material(
                  elevation: 0,
                  color: Colors.transparent,
                  child: AnimatedBuilder(
                    animation: _animation,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _animation.value,
                        alignment: Alignment.topCenter,
                        child: Opacity(
                          opacity: _animation.value,
                          child: Container(
                            constraints: BoxConstraints(
                              maxHeight:
                                  MediaQuery.of(context).size.height * 0.4,
                            ),
                            decoration: BoxDecoration(
                              color: theme.surface,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: theme.outline.withOpacity(0.2),
                                width: 1,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: theme.shadow.withOpacity(0.15),
                                  blurRadius: 20,
                                  spreadRadius: 2,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: ListView.builder(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 8),
                                shrinkWrap: true,
                                itemCount: widget.items.length,
                                itemBuilder: (context, index) {
                                  final item = widget.items[index];
                                  final itemValue =
                                      "${item.name}_${item.extensionType}";
                                  final currentSelectedSource = selectedSource;
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
                                        horizontal: 16,
                                        vertical: 12,
                                      ),
                                      margin: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: isSelected
                                            ? theme.primary.withOpacity(0.1)
                                            : Colors.transparent,
                                        borderRadius: BorderRadius.circular(12),
                                        border: isSelected
                                            ? Border.all(
                                                color: theme.primary
                                                    .withOpacity(0.3),
                                                width: 1,
                                              )
                                            : null,
                                      ),
                                      child: Row(
                                        children: [
                                          Container(
                                            width: 32,
                                            height: 32,
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              color:
                                                  theme.surfaceContainerHighest,
                                            ),
                                            child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              child: CachedNetworkImage(
                                                imageUrl: item.iconUrl!,
                                                width: 32,
                                                height: 32,
                                                fit: BoxFit.cover,
                                                placeholder: (context, url) =>
                                                    Container(
                                                  color: theme
                                                      .surfaceContainerHighest,
                                                  child: Icon(
                                                    Icons.extension,
                                                    color:
                                                        theme.onSurfaceVariant,
                                                    size: 16,
                                                  ),
                                                ),
                                                errorWidget:
                                                    (context, url, error) =>
                                                        Container(
                                                  color: theme
                                                      .surfaceContainerHighest,
                                                  child: Icon(
                                                    Icons.extension,
                                                    color:
                                                        theme.onSurfaceVariant,
                                                    size: 16,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: AzyXText(
                                              text: item.name ?? '',
                                              fontSize: 14,
                                              fontVariant: isSelected
                                                  ? FontVariant.bold
                                                  : FontVariant.regular,
                                            ),
                                          ),
                                          Container(
                                            width: 32,
                                            height: 32,
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              color:
                                                  theme.surfaceContainerHighest,
                                            ),
                                            child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              child: CachedNetworkImage(
                                                imageUrl: getExtensionIcon(item
                                                        .extensionType ??
                                                    ExtensionType.mangayomi),
                                                width: 32,
                                                height: 32,
                                                fit: BoxFit.cover,
                                                placeholder: (context, url) =>
                                                    Container(
                                                  color: theme
                                                      .surfaceContainerHighest,
                                                  child: Icon(
                                                    Icons.extension,
                                                    color:
                                                        theme.onSurfaceVariant,
                                                    size: 16,
                                                  ),
                                                ),
                                                errorWidget:
                                                    (context, url, error) =>
                                                        Container(
                                                  color: theme
                                                      .surfaceContainerHighest,
                                                  child: Icon(
                                                    Icons.extension,
                                                    color:
                                                        theme.onSurfaceVariant,
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
    return Obx(() {
      final Rxn<Source> selectedSource = Rxn(this.selectedSource);
      return GestureDetector(
        onTap: _toggleDropdown,
        child: Container(
          key: _dropdownKey,
          decoration: BoxDecoration(
            color: theme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isOpen ? theme.primary : theme.outline.withOpacity(0.2),
              width: isOpen ? 2 : 1,
            ),
            boxShadow: [
              if (isOpen)
                BoxShadow(
                  color: theme.primary.withOpacity(0.1),
                  blurRadius: 8,
                  spreadRadius: 1,
                ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                if (!selectedSource.isNull) ...[
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: theme.surfaceContainerHighest,
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: CachedNetworkImage(
                        imageUrl: selectedSource.value!.iconUrl!,
                        width: 32,
                        height: 32,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          color: theme.surfaceContainerHighest,
                          child: Icon(
                            Icons.extension,
                            color: theme.onSurfaceVariant,
                            size: 16,
                          ),
                        ),
                        errorWidget: (context, url, error) => Container(
                          color: theme.surfaceContainerHighest,
                          child: Icon(
                            Icons.extension,
                            color: theme.onSurfaceVariant,
                            size: 16,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                ],
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AzyXText(
                        text: widget.labelText,
                        fontSize: 12,
                        fontVariant: FontVariant.regular,
                      ),
                      const SizedBox(height: 4),
                      AzyXText(
                        text: selectedSource.value?.name ?? 'Select source...',
                        fontSize: 16,
                        fontVariant: !selectedSource.isNull
                            ? FontVariant.bold
                            : FontVariant.regular,
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: theme.surfaceContainerHighest,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: CachedNetworkImage(
                      imageUrl: getExtensionIcon(
                          selectedSource.value!.extensionType ??
                              ExtensionType.mangayomi),
                      width: 32,
                      height: 32,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        color: theme.surfaceContainerHighest,
                        child: Icon(
                          Icons.extension,
                          color: theme.onSurfaceVariant,
                          size: 16,
                        ),
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: theme.surfaceContainerHighest,
                        child: Icon(
                          Icons.extension,
                          color: theme.onSurfaceVariant,
                          size: 16,
                        ),
                      ),
                    ),
                  ),
                ),
                AnimatedRotation(
                  turns: isOpen ? 0.5 : 0,
                  duration: const Duration(milliseconds: 300),
                  child: Icon(
                    Icons.keyboard_arrow_down,
                    color: theme.onSurfaceVariant,
                    size: 24,
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
