import 'package:azyx/Widgets/AzyXWidgets/azyx_text.dart';
import 'package:azyx/Models/media.dart';
import 'package:flutter/material.dart';
class RecommendSheet extends StatefulWidget {
  final Media media;
  final String? initialReason;
  final bool isEdit;
  const RecommendSheet({
    super.key,
    required this.media,
    this.initialReason,
    this.isEdit = false,
  });
  @override
  State<RecommendSheet> createState() => _RecommendSheetState();
}
class _RecommendSheetState extends State<RecommendSheet> {
  late final TextEditingController _controller;
  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialReason);
  }
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: colors.surfaceContainer,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 8,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: colors.outline.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            AzyXText(
              text: widget.isEdit ? "Edit Recommendation" : "Recommend Title",
              fontSize: 16,
              fontVariant: FontVariant.bold,
            ),
            const SizedBox(height: 6),
            AzyXText(
              text: widget.isEdit
                  ? "Update your reason why this deserves attention."
                  : "Tell the community why this title deserves attention.",
              fontSize: 12,
              color: colors.onSurfaceVariant.withOpacity(0.7),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _controller,
              maxLines: 5,
              maxLength: 500,
              style: TextStyle(
                color: colors.onSurface,
                fontSize: 13,
              ),
              decoration: InputDecoration(
                hintText: "Write your reason here (min 30 characters)...",
                hintStyle: TextStyle(
                  color: colors.onSurfaceVariant.withOpacity(0.5),
                  fontSize: 13,
                ),
                filled: true,
                fillColor: colors.surfaceContainerLow,
                counterStyle: TextStyle(
                  color: colors.onSurfaceVariant.withOpacity(0.6),
                  fontSize: 10,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: colors.primary, width: 1.5),
                ),
                contentPadding: const EdgeInsets.all(16),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Cancel"),
                ),
                const SizedBox(width: 8),
                FilledButton(
                  onPressed: () {
                    final reason = _controller.text.trim();
                    if (reason.length < 30) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Please write at least 30 characters")),
                      );
                      return;
                    }
                    Navigator.pop(context, reason);
                  },
                  child: Text(widget.isEdit ? "Update" : "Submit"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
