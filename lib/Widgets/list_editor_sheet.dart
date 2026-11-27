import 'dart:async';
import 'package:azyx/Controllers/anilist_auth.dart';
import 'package:azyx/Widgets/AzyXWidgets/azyx_text.dart';
import 'package:azyx/Widgets/common/slider_bar.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ListEditorResult {
  final String status;
  final double score;
  final int progress;
  final DateTime? startedAt;
  final DateTime? completedAt;
  final bool isPrivate;
  final int repeat;

  const ListEditorResult({
    required this.status,
    required this.score,
    required this.progress,
    this.startedAt,
    this.completedAt,
    required this.isPrivate,
    required this.repeat,
  });
}

class ListEditorSheet extends StatefulWidget {
  final String title;
  final String image;
  final int totalCount;
  final bool isManga;
  final String initialStatus;
  final double initialScore;
  final int initialProgress;
  final DateTime? initialStartedAt;
  final DateTime? initialCompletedAt;
  final bool initialIsPrivate;
  final int initialRepeat;
  final bool canDelete;
  final FutureOr<void> Function(ListEditorResult result) onSave;
  final FutureOr<void> Function()? onDelete;

  const ListEditorSheet({
    super.key,
    required this.title,
    required this.image,
    required this.totalCount,
    required this.isManga,
    required this.initialStatus,
    required this.initialScore,
    required this.initialProgress,
    this.initialStartedAt,
    this.initialCompletedAt,
    this.initialIsPrivate = false,
    this.initialRepeat = 0,
    this.canDelete = false,
    required this.onSave,
    this.onDelete,
  });

  @override
  State<ListEditorSheet> createState() => _ListEditorSheetState();
}

class _ListEditorSheetState extends State<ListEditorSheet> {
  late String _status;
  late double _score;
  late int _progress;
  DateTime? _startedAt;
  DateTime? _completedAt;
  late bool _isPrivate;
  late int _repeat;
  bool _saving = false;
  late final TextEditingController _progressController;

  static const _statusKeys = [
    'PLANNING',
    'CURRENT',
    'COMPLETED',
    'REPEATING',
    'PAUSED',
    'DROPPED',
  ];

  String _statusLabel(String key) {
    switch (key) {
      case 'PLANNING':
        return widget.isManga ? 'Plan to Read' : 'Plan to Watch';
      case 'CURRENT':
        return widget.isManga ? 'Reading' : 'Watching';
      case 'COMPLETED':
        return 'Completed';
      case 'REPEATING':
        return widget.isManga ? 'Rereading' : 'Rewatching';
      case 'PAUSED':
        return 'Paused';
      case 'DROPPED':
        return 'Dropped';
      default:
        return key;
    }
  }

  String get _scoreFormat {
    final fmt = anilistAuthController.userData.value.scoreFormat;
    if (fmt != null && fmt.isNotEmpty) return fmt;
    return 'POINT_10_DECIMAL';
  }

  double get _minScore => 0.0;

  double get _maxScore {
    switch (_scoreFormat) {
      case 'POINT_100':
        return 100.0;
      case 'POINT_10_DECIMAL':
      case 'POINT_10':
        return 10.0;
      case 'POINT_5':
        return 5.0;
      case 'POINT_3':
        return 3.0;
      default:
        return 10.0;
    }
  }

  int get _divisions {
    switch (_scoreFormat) {
      case 'POINT_100':
        return 100;
      case 'POINT_10_DECIMAL':
        return 100;
      case 'POINT_10':
        return 10;
      case 'POINT_5':
        return 5;
      case 'POINT_3':
        return 3;
      default:
        return 100;
    }
  }

  String _scoreDisplay(double score) {
    if (score <= 0) return 'Not Rated';
    switch (_scoreFormat) {
      case 'POINT_100':
        return '${score.round()} / 100';
      case 'POINT_10_DECIMAL':
        return '${score.toStringAsFixed(1)} / 10';
      case 'POINT_10':
        return '${score.round()} / 10';
      case 'POINT_5':
        return '${score.round()} / 5 ★';
      case 'POINT_3':
        final v = score.round();
        if (v >= 3) return ':) Good';
        if (v == 2) return ':| Okay';
        return ':( Bad';
      default:
        return '${score.toStringAsFixed(1)} / 10';
    }
  }

  @override
  void initState() {
    super.initState();
    _status = widget.initialStatus.isEmpty
        ? 'CURRENT'
        : widget.initialStatus.toUpperCase();
    if (!_statusKeys.contains(_status)) {
      _status = 'CURRENT';
    }
    _progress = widget.initialProgress.clamp(
      0,
      widget.totalCount > 0 ? widget.totalCount : 99999,
    );
    _score = widget.initialScore.clamp(_minScore, _maxScore);
    _startedAt = widget.initialStartedAt;
    _completedAt = widget.initialCompletedAt;
    _isPrivate = widget.initialIsPrivate;
    _repeat = widget.initialRepeat < 0 ? 0 : widget.initialRepeat;
    if (_status == 'CURRENT' && _startedAt == null) {
      _startedAt = DateTime.now();
    } else if (_status == 'COMPLETED') {
      _startedAt ??= DateTime.now();
      _completedAt ??= DateTime.now();
    }
    _progressController = TextEditingController(text: _progress.toString());
  }

  @override
  void dispose() {
    _progressController.dispose();
    super.dispose();
  }

  void _setProgress(int next) {
    final maxVal = widget.totalCount > 0 ? widget.totalCount : 99999;
    final clamped = next.clamp(0, maxVal);
    setState(() {
      _progress = clamped;
      _progressController.text = clamped.toString();
      if (widget.totalCount > 0 && clamped >= widget.totalCount) {
        _status = 'COMPLETED';
        _completedAt ??= DateTime.now();
      }
    });
  }

  String _formatDate(DateTime? dt) {
    if (dt == null) return 'Not set';
    final y = dt.year.toString().padLeft(4, '0');
    final m = dt.month.toString().padLeft(2, '0');
    final d = dt.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  Future<void> _pickDate(bool isStart) async {
    final initial = (isStart ? _startedAt : _completedAt) ?? DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(1970),
      lastDate: DateTime(2100),
    );
    if (picked != null && mounted) {
      setState(() {
        if (isStart) {
          _startedAt = picked;
        } else {
          _completedAt = picked;
        }
      });
    }
  }

  Widget _buildSectionHeader(ColorScheme cs, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 14, 4, 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 11.5,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.9,
          color: cs.primary,
        ),
      ),
    );
  }

  Widget _buildGroupedCard(ColorScheme cs, List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest.withValues(alpha: 0.32),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: cs.outlineVariant.withValues(alpha: 0.2),
          width: 0.8,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: children,
      ),
    );
  }

  Widget _buildDivider(ColorScheme cs) {
    return Divider(
      height: 1,
      thickness: 0.8,
      indent: 56,
      color: cs.outlineVariant.withValues(alpha: 0.16),
    );
  }

  Widget _buildIconBadge(IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(7),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(9),
      ),
      child: Icon(icon, size: 18, color: color),
    );
  }

  Widget _buildSettingTile(
    ColorScheme cs, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required Widget trailing,
    VoidCallback? onTap,
  }) {
    final content = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          _buildIconBadge(icon, iconColor),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AzyXText(
                  text: title,
                  fontVariant: FontVariant.bold,
                  fontSize: 14,
                  color: cs.onSurface,
                ),
                const SizedBox(height: 2),
                AzyXText(
                  text: subtitle,
                  fontSize: 11,
                  color: cs.onSurfaceVariant,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          trailing,
        ],
      ),
    );
    if (onTap == null) return content;
    return InkWell(onTap: onTap, child: content);
  }

  Widget _buildCircleAction(
    ColorScheme cs,
    IconData icon,
    VoidCallback? onPressed,
  ) {
    final enabled = onPressed != null;
    return Material(
      color: cs.surfaceContainerHighest.withValues(alpha: enabled ? 0.55 : 0.2),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onPressed,
        child: SizedBox(
          width: 30,
          height: 30,
          child: Icon(
            icon,
            size: 16,
            color: enabled
                ? cs.onSurface
                : cs.onSurfaceVariant.withValues(alpha: 0.35),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final size = MediaQuery.of(context).size;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final unitLabel = widget.isManga ? 'Chapters' : 'Episodes';
    final repeatLabel = widget.isManga ? 'Rereads' : 'Rewatches';

    return Container(
      constraints: BoxConstraints(maxHeight: size.height * 0.88, maxWidth: 560),
      padding: EdgeInsets.fromLTRB(
        16,
        12,
        16,
        16 + MediaQuery.of(context).padding.bottom + bottomInset,
      ),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        border: Border(
          top: BorderSide(
            color: cs.outlineVariant.withValues(alpha: 0.2),
            width: 0.8,
          ),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 34,
            height: 4,
            margin: const EdgeInsets.only(bottom: 14),
            decoration: BoxDecoration(
              color: cs.onSurfaceVariant.withValues(alpha: 0.35),
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: SizedBox(
                  width: 48,
                  height: 64,
                  child: widget.image.startsWith('http')
                      ? CachedNetworkImage(
                          imageUrl: widget.image,
                          fit: BoxFit.cover,
                          errorWidget: (_, __, ___) => Container(
                            color: cs.surfaceContainerHighest,
                            child: Icon(
                              Icons.movie_rounded,
                              color: cs.onSurfaceVariant,
                            ),
                          ),
                        )
                      : Container(
                          color: cs.surfaceContainerHighest,
                          child: Icon(
                            Icons.movie_rounded,
                            color: cs.onSurfaceVariant,
                          ),
                        ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AzyXText(
                      text: widget.title,
                      fontVariant: FontVariant.bold,
                      fontSize: 15.5,
                      color: cs.onSurface,
                      maxLines: 2,
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: cs.primary.withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        widget.totalCount > 0
                            ? '${widget.totalCount} $unitLabel'
                            : 'Ongoing',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: cs.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              IconButton.filledTonal(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.close_rounded, size: 20),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Flexible(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildSectionHeader(cs, 'STATUS'),
                  _buildGroupedCard(cs, [
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _statusKeys.map((key) {
                          final selected = _status == key;
                          return Material(
                            color: selected
                                ? cs.primary
                                : cs.surfaceContainerHighest.withValues(
                                    alpha: 0.45,
                                  ),
                            borderRadius: BorderRadius.circular(12),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(12),
                              onTap: () {
                                setState(() {
                                  _status = key;
                                  if (key == 'CURRENT' && _startedAt == null) {
                                    _startedAt = DateTime.now();
                                  } else if (key == 'COMPLETED') {
                                    _startedAt ??= DateTime.now();
                                    _completedAt ??= DateTime.now();
                                    if (widget.totalCount > 0) {
                                      _progress = widget.totalCount;
                                      _progressController.text = _progress
                                          .toString();
                                    }
                                  }
                                });
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: selected
                                        ? cs.primary
                                        : cs.outlineVariant.withValues(
                                            alpha: 0.2,
                                          ),
                                    width: 0.8,
                                  ),
                                ),
                                child: Text(
                                  _statusLabel(key),
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: selected
                                        ? FontWeight.w700
                                        : FontWeight.w500,
                                    color: selected
                                        ? cs.onPrimary
                                        : cs.onSurface,
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ]),
                  _buildSectionHeader(cs, 'PROGRESS & RATING'),
                  _buildGroupedCard(cs, [
                    _buildSettingTile(
                      cs,
                      title: widget.isManga
                          ? 'Chapters Read'
                          : 'Episodes Watched',
                      subtitle: widget.totalCount > 0
                          ? 'Tap Max to mark all ${widget.totalCount}'
                          : 'Track your current progress',
                      icon: Icons.playlist_play_rounded,
                      iconColor: cs.primary,
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildCircleAction(
                            cs,
                            Icons.remove_rounded,
                            _progress > 0
                                ? () => _setProgress(_progress - 1)
                                : null,
                          ),
                          const SizedBox(width: 6),
                          SizedBox(
                            width: 64,
                            child: TextField(
                              controller: _progressController,
                              keyboardType: TextInputType.number,
                              textAlign: TextAlign.center,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                              ],
                              style: TextStyle(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w700,
                                color: cs.onSurface,
                              ),
                              decoration: InputDecoration(
                                isDense: true,
                                filled: true,
                                fillColor: cs.surfaceContainerHighest
                                    .withValues(alpha: 0.45),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 7,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                              onChanged: (val) {
                                final parsed = int.tryParse(val) ?? 0;
                                final maxVal = widget.totalCount > 0
                                    ? widget.totalCount
                                    : 99999;
                                setState(() {
                                  _progress = parsed.clamp(0, maxVal);
                                });
                              },
                            ),
                          ),
                          if (widget.totalCount > 0) ...[
                            const SizedBox(width: 4),
                            GestureDetector(
                              onTap: () => _setProgress(widget.totalCount),
                              child: Text(
                                '/ ${widget.totalCount}',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: cs.primary,
                                ),
                              ),
                            ),
                          ],
                          const SizedBox(width: 6),
                          _buildCircleAction(
                            cs,
                            Icons.add_rounded,
                            (widget.totalCount <= 0 ||
                                    _progress < widget.totalCount)
                                ? () => _setProgress(_progress + 1)
                                : null,
                          ),
                        ],
                      ),
                    ),
                    _buildDivider(cs),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              _buildIconBadge(Icons.star_rounded, cs.secondary),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    AzyXText(
                                      text: 'Score',
                                      fontVariant: FontVariant.bold,
                                      fontSize: 14,
                                      color: cs.onSurface,
                                    ),
                                    const SizedBox(height: 2),
                                    AzyXText(
                                      text: 'AniList rating',
                                      fontSize: 11,
                                      color: cs.onSurfaceVariant,
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: cs.secondary.withValues(alpha: 0.14),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  _scoreDisplay(_score),
                                  style: TextStyle(
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w700,
                                    color: cs.secondary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          CustomSlider(
                            value: _score.clamp(_minScore, _maxScore),
                            min: _minScore,
                            max: _maxScore,
                            divisions: _divisions,
                            onChanged: (val) {
                              setState(() {
                                if (_scoreFormat == 'POINT_10_DECIMAL') {
                                  _score = (val * 10).round() / 10.0;
                                } else {
                                  _score = val.roundToDouble();
                                }
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                  ]),
                  _buildSectionHeader(cs, 'DATES & PREFERENCES'),
                  _buildGroupedCard(cs, [
                    _buildSettingTile(
                      cs,
                      title: 'Start Date',
                      subtitle: 'When you started',
                      icon: Icons.event_available_rounded,
                      iconColor: cs.primary,
                      onTap: () => _pickDate(true),
                      trailing: _DatePill(
                        value: _formatDate(_startedAt),
                        onClear: _startedAt != null
                            ? () => setState(() => _startedAt = null)
                            : null,
                      ),
                    ),
                    _buildDivider(cs),
                    _buildSettingTile(
                      cs,
                      title: 'Finish Date',
                      subtitle: 'When you completed',
                      icon: Icons.event_rounded,
                      iconColor: cs.tertiary,
                      onTap: () => _pickDate(false),
                      trailing: _DatePill(
                        value: _formatDate(_completedAt),
                        onClear: _completedAt != null
                            ? () => setState(() => _completedAt = null)
                            : null,
                      ),
                    ),
                    _buildDivider(cs),
                    _buildSettingTile(
                      cs,
                      title: repeatLabel,
                      subtitle: 'Total times completed',
                      icon: Icons.repeat_rounded,
                      iconColor: cs.secondary,
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildCircleAction(
                            cs,
                            Icons.remove_rounded,
                            _repeat > 0
                                ? () => setState(() => _repeat--)
                                : null,
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: Text(
                              '$_repeat',
                              style: TextStyle(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w700,
                                color: cs.onSurface,
                              ),
                            ),
                          ),
                          _buildCircleAction(
                            cs,
                            Icons.add_rounded,
                            () => setState(() => _repeat++),
                          ),
                        ],
                      ),
                    ),
                    _buildDivider(cs),
                    _buildSettingTile(
                      cs,
                      title: 'Private Entry',
                      subtitle: 'Hide from public AniList activity',
                      icon: Icons.visibility_off_rounded,
                      iconColor: cs.onSurfaceVariant,
                      trailing: Switch(
                        value: _isPrivate,
                        onChanged: (v) => setState(() => _isPrivate = v),
                      ),
                    ),
                  ]),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              if (widget.canDelete && widget.onDelete != null) ...[
                OutlinedButton.icon(
                  onPressed: _saving
                      ? null
                      : () async {
                          setState(() => _saving = true);
                          await widget.onDelete!();
                          if (mounted) {
                            Navigator.of(context).pop();
                          }
                        },
                  icon: Icon(Icons.delete_outline_rounded, color: cs.error),
                  label: Text(
                    'Remove',
                    style: TextStyle(
                      color: cs.error,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: cs.error.withValues(alpha: 0.45)),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 13,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
              ],
              Expanded(
                child: FilledButton(
                  onPressed: _saving
                      ? null
                      : () async {
                          setState(() => _saving = true);
                          await widget.onSave(
                            ListEditorResult(
                              status: _status,
                              score: _score,
                              progress: _progress,
                              startedAt: _startedAt,
                              completedAt: _completedAt,
                              isPrivate: _isPrivate,
                              repeat: _repeat,
                            ),
                          );
                          if (mounted) {
                            Navigator.of(context).pop();
                          }
                        },
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: _saving
                      ? SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: cs.onPrimary,
                          ),
                        )
                      : const Text(
                          'Save Entry',
                          style: TextStyle(fontWeight: FontWeight.w700),
                        ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DatePill extends StatelessWidget {
  final String value;
  final VoidCallback? onClear;

  const _DatePill({required this.value, this.onClear});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: cs.onSurface,
            ),
          ),
          if (onClear != null) ...[
            const SizedBox(width: 6),
            GestureDetector(
              onTap: onClear,
              child: Icon(
                Icons.close_rounded,
                size: 14,
                color: cs.onSurfaceVariant,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
