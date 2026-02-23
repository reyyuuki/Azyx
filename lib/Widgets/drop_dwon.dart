import 'package:azyx/Widgets/AzyXWidgets/azyx_text.dart';
import 'package:flutter/material.dart';

class CustomDropdown<T> extends StatefulWidget {
  final List<T> items;
  final T? selectedValue;
  final Function(T?) onChanged;
  final String labelText;
  final String Function(T) displayText;
  final String hintText;

  const CustomDropdown({
    super.key,
    required this.items,
    required this.onChanged,
    required this.labelText,
    required this.displayText,
    this.selectedValue,
    this.hintText = 'Select option...',
  });

  @override
  State<CustomDropdown<T>> createState() => _CustomDropdownState<T>();
}

class _CustomDropdownState<T> extends State<CustomDropdown<T>>
    with SingleTickerProviderStateMixin {
  bool isOpen = false;
  late AnimationController _animationController;
  late Animation<double> _animation;
  late ScrollController _scrollController;
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
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _scrollController.dispose();
    _overlayEntry?.remove();
    super.dispose();
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

    FocusScope.of(context).unfocus();

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
    final screenHeight = MediaQuery.of(context).size.height;
    final spaceBelow = screenHeight - offset.dy - size.height - 16;
    final spaceAbove = offset.dy - 16;
    final maxDropdownHeight = screenHeight * 0.4;

    final shouldShowAbove =
        spaceBelow < maxDropdownHeight && spaceAbove > spaceBelow;
    final availableSpace = shouldShowAbove ? spaceAbove : spaceBelow;
    final dropdownHeight = (widget.items.length * 48.0 + 16)
        .clamp(0.0, availableSpace.clamp(100.0, maxDropdownHeight));

    return OverlayEntry(
      builder: (context) => Stack(
        children: [
          Positioned.fill(
            child: GestureDetector(
              onTap: _closeDropdown,
              behavior: HitTestBehavior.translucent,
              child: Container(color: Colors.transparent),
            ),
          ),
          Positioned(
            left: offset.dx,
            top: shouldShowAbove
                ? offset.dy - dropdownHeight - 8
                : offset.dy + size.height + 8,
            width: size.width,
            child: Material(
              elevation: 0,
              color: Colors.transparent,
              child: AnimatedBuilder(
                animation: _animation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _animation.value,
                    alignment: shouldShowAbove
                        ? Alignment.bottomCenter
                        : Alignment.topCenter,
                    child: Opacity(
                      opacity: _animation.value,
                      child: Container(
                        height: dropdownHeight,
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
                          child: widget.items.length <= 5
                              ? Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children:
                                      widget.items.asMap().entries.map((entry) {
                                    final index = entry.key;
                                    final item = entry.value;
                                    final isSelected =
                                        widget.selectedValue == item;

                                    return GestureDetector(
                                      behavior: HitTestBehavior.opaque,
                                      onTap: () {
                                        widget.onChanged(item);
                                        _closeDropdown();
                                      },
                                      child: Container(
                                        width: double.infinity,
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 16,
                                          vertical: 12,
                                        ),
                                        margin: EdgeInsets.only(
                                          left: 8,
                                          right: 8,
                                          top: index == 0 ? 8 : 2,
                                          bottom:
                                              index == widget.items.length - 1
                                                  ? 8
                                                  : 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color: isSelected
                                              ? theme.primary.withOpacity(0.1)
                                              : Colors.transparent,
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          border: isSelected
                                              ? Border.all(
                                                  color: theme.primary
                                                      .withOpacity(0.3),
                                                  width: 1,
                                                )
                                              : null,
                                        ),
                                        child: AzyXText(
                                          text: widget.displayText(item),
                                          fontSize: 14,
                                          fontVariant: isSelected
                                              ? FontVariant.bold
                                              : FontVariant.regular,
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                )
                              : RawScrollbar(
                                  controller: _scrollController,
                                  thumbVisibility: true,
                                  thickness: 4,
                                  radius: const Radius.circular(2),
                                  thumbColor: theme.outline.withOpacity(0.3),
                                  child: ListView.builder(
                                    controller: _scrollController,
                                    padding:
                                        const EdgeInsets.symmetric(vertical: 8),
                                    physics: const ClampingScrollPhysics(),
                                    itemCount: widget.items.length,
                                    itemBuilder: (context, index) {
                                      final item = widget.items[index];
                                      final isSelected =
                                          widget.selectedValue == item;

                                      return GestureDetector(
                                        behavior: HitTestBehavior.opaque,
                                        onTap: () {
                                          widget.onChanged(item);
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
                                            borderRadius:
                                                BorderRadius.circular(12),
                                            border: isSelected
                                                ? Border.all(
                                                    color: theme.primary
                                                        .withOpacity(0.3),
                                                    width: 1,
                                                  )
                                                : null,
                                          ),
                                          child: AzyXText(
                                            text: widget.displayText(item),
                                            fontSize: 14,
                                            fontVariant: isSelected
                                                ? FontVariant.bold
                                                : FontVariant.regular,
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
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).colorScheme;

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
                      text: widget.selectedValue != null
                          ? widget.displayText(widget.selectedValue!)
                          : widget.hintText,
                      fontSize: 16,
                      fontVariant: widget.selectedValue != null
                          ? FontVariant.bold
                          : FontVariant.regular,
                    ),
                  ],
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
  }
}
