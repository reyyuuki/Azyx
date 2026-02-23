import 'package:azyx/Widgets/AzyXWidgets/azyx_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CustomInputField extends StatefulWidget {
  final TextEditingController controller;
  final String labelText;
  final String? hintText;
  final int? maxValue;
  final Function(int?)? onChanged;
  final TextInputType keyboardType;
  final String? suffixText;

  const CustomInputField({
    super.key,
    required this.controller,
    required this.labelText,
    this.hintText,
    this.maxValue,
    this.onChanged,
    this.keyboardType = TextInputType.number,
    this.suffixText,
  });

  @override
  State<CustomInputField> createState() => _CustomInputFieldState();
}

class _CustomInputFieldState extends State<CustomInputField> {
  bool _isFocused = false;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      setState(() {
        _isFocused = _focusNode.hasFocus;
      });
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: theme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _isFocused ? theme.primary : theme.outline.withOpacity(0.2),
          width: _isFocused ? 2 : 1,
        ),
        boxShadow: [
          if (_isFocused)
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
                  TextField(
                    controller: widget.controller,
                    focusNode: _focusNode,
                    keyboardType: widget.keyboardType,
                    inputFormatters: widget.keyboardType == TextInputType.number
                        ? [
                            FilteringTextInputFormatter.digitsOnly,
                            if (widget.maxValue != null)
                              _MaxValueInputFormatter(widget.maxValue!),
                          ]
                        : null,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: widget.hintText ?? 'Enter value...',
                      hintStyle: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.normal,
                        color: theme.onSurfaceVariant.withOpacity(0.6),
                      ),
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                    onChanged: (value) {
                      final intValue = int.tryParse(value);
                      widget.onChanged?.call(intValue);
                    },
                  ),
                ],
              ),
            ),
            if (widget.suffixText != null) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: theme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: AzyXText(
                  text: widget.suffixText!,
                  fontSize: 12,
                  fontVariant: FontVariant.regular,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _MaxValueInputFormatter extends TextInputFormatter {
  final int maxValue;

  _MaxValueInputFormatter(this.maxValue);

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) {
      return newValue;
    }

    final intValue = int.tryParse(newValue.text);
    if (intValue == null || intValue > maxValue) {
      return oldValue;
    }

    return newValue;
  }
}
