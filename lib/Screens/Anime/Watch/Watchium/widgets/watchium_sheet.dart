import 'package:azyx/Models/anime_all_data.dart';
import 'package:azyx/Screens/Anime/Watch/Watchium/watchium_model.dart';
import 'package:azyx/Screens/Anime/Watch/Watchium/watchium_service.dart';
import 'package:azyx/Screens/Anime/Watch/controller/watch_controller.dart';
import 'package:azyx/Widgets/AzyXWidgets/azyx_gradient_container.dart';
import 'package:azyx/Widgets/AzyXWidgets/azyx_snack_bar.dart';
import 'package:azyx/Widgets/AzyXWidgets/azyx_text.dart';
import 'package:azyx/core/icons/icons_broken.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

void showWatchiumSheet(BuildContext context, {AnimeAllData? animeData}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => WatchiumSheet(animeData: animeData),
  );
}

class WatchiumSheet extends StatefulWidget {
  final AnimeAllData? animeData;
  const WatchiumSheet({super.key, this.animeData});

  @override
  State<WatchiumSheet> createState() => _WatchiumSheetState();
}

class _WatchiumSheetState extends State<WatchiumSheet> {
  final WatchiumService service = Get.find<WatchiumService>();
  final TextEditingController joinController = TextEditingController();
  final TextEditingController chatController = TextEditingController();

  @override
  void dispose() {
    joinController.dispose();
    chatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        border: Border.all(color: colors.outline.withOpacity(0.08)),
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        child: AzyXGradientContainer(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Center(
                  child: Container(
                    width: 36,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: colors.outline.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: colors.primary.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            Broken.people,
                            color: colors.primary,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const AzyXText(
                          text: 'Watch Together',
                          fontSize: 18,
                          fontVariant: FontVariant.bold,
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, size: 20),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: Obx(() {
                    final state = service.roomState.value;
                    final isConnected = service.isConnected.value;
                    if (state != null && isConnected) {
                      return _buildActiveRoomView(context);
                    }
                    return _buildJoinCreateView(context);
                  }),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildJoinCreateView(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (widget.animeData != null) ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colors.surfaceContainerHighest.withOpacity(0.35),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: colors.outline.withOpacity(0.08)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.tv_rounded, size: 18, color: colors.primary),
                      const SizedBox(width: 8),
                      Expanded(
                        child: AzyXText(
                          text: widget.animeData?.title ?? 'Current Anime',
                          fontSize: 15,
                          fontVariant: FontVariant.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Padding(
                    padding: const EdgeInsets.only(left: 26),
                    child: AzyXText(
                      text: 'Episode ${widget.animeData?.number ?? 1}',
                      fontSize: 12,
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        int? currentProgress;
                        if (Get.isRegistered<WatchController>()) {
                          currentProgress = Get.find<WatchController>()
                              .position
                              .value
                              .inSeconds;
                        }
                        currentProgress ??= widget.animeData?.startFromSeconds;
                        final servers =
                            widget.animeData?.episodeUrls.asMap().entries.map((entry) {
                          final v = entry.value;
                          return WatchiumAnimeServer(
                            serverId: v.url,
                            serverName: v.quality,
                            quality: v.quality,
                            type: WatchiumService.getStreamType(v.url),
                            url: v.url,
                            originalUrl: v.url,
                            headers: v.headers,
                          );
                        }).toList();
                        final code = await service.createRoom(
                          animeTitle: widget.animeData?.title ?? 'Anime',
                          episodeNumber:
                              int.tryParse(widget.animeData?.number ?? '1') ??
                              1,
                          animeId: widget.animeData?.id?.toString(),
                          anilistId: widget.animeData?.id != null
                              ? int.tryParse(widget.animeData!.id.toString())
                              : null,
                          animeCoverImage: widget.animeData?.image,
                          initialPositionSec: currentProgress?.toDouble(),
                          availableServers: servers,
                          videoUrl: widget.animeData?.url,
                          sourceName: widget.animeData?.source,
                        );
                        if (code != null) {
                          azyxSnackBar('Room Created! Code: $code');
                        } else if (service.error.isNotEmpty) {
                          azyxSnackBar(service.error.value);
                        }
                      },
                      icon: const Icon(
                        Icons.add_circle_outline_rounded,
                        size: 18,
                      ),
                      label: const AzyXText(
                        text: 'Create Watch Room',
                        fontVariant: FontVariant.bold,
                      ),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        backgroundColor: colors.primary,
                        foregroundColor: colors.onPrimary,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colors.surfaceContainerHighest.withOpacity(0.35),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: colors.outline.withOpacity(0.08)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Broken.login, size: 18, color: colors.secondary),
                    const SizedBox(width: 8),
                    const AzyXText(
                      text: 'Join Existing Room',
                      fontSize: 15,
                      fontVariant: FontVariant.bold,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: joinController,
                  textCapitalization: TextCapitalization.characters,
                  inputFormatters: [
                    TextInputFormatter.withFunction(
                      (oldVal, newVal) => TextEditingValue(
                        text: newVal.text.toUpperCase(),
                        selection: newVal.selection,
                      ),
                    ),
                  ],
                  style: TextStyle(color: colors.onSurface, fontSize: 14),
                  decoration: InputDecoration(
                    hintText: 'Enter Room Code or Join Link',
                    filled: true,
                    fillColor: colors.surface.withOpacity(0.5),
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                    prefixIcon: Icon(
                      Icons.key_rounded,
                      size: 18,
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      final text = joinController.text.trim().toUpperCase();
                      if (text.isEmpty) {
                        azyxSnackBar('Please enter a room code or link');
                        return;
                      }
                      final ok = await service.joinRoom(text);
                      if (ok) {
                        azyxSnackBar('Joined Room!');
                        if (context.mounted) {
                          Navigator.pop(context);
                        }
                      } else if (service.error.isNotEmpty) {
                        azyxSnackBar(service.error.value);
                      }
                    },
                    icon: const Icon(Broken.login, size: 18),
                    label: const AzyXText(
                      text: 'Join Room',
                      fontVariant: FontVariant.bold,
                    ),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      backgroundColor: colors.secondaryContainer,
                      foregroundColor: colors.onSecondaryContainer,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Obx(
            () => service.error.value.isNotEmpty
                ? Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: AzyXText(
                      text: service.error.value,
                      color: colors.error,
                      fontSize: 13,
                    ),
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveRoomView(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final roomState = service.roomState.value;
    final code = roomState?.code ?? service.roomCode.value;
    final inviteUrl = service.getInviteUrl(code);

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: colors.surfaceContainerHighest.withOpacity(0.35),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: colors.outline.withOpacity(0.08)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AzyXText(
                    text: 'ROOM CODE',
                    fontSize: 10,
                    fontVariant: FontVariant.bold,
                    color: colors.onSurfaceVariant,
                  ),
                  const SizedBox(height: 2),
                  AzyXText(
                    text: code,
                    fontSize: 18,
                    fontVariant: FontVariant.bold,
                    color: colors.primary,
                  ),
                ],
              ),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.copy_rounded, size: 18),
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: code));
                      azyxSnackBar('Room Code Copied!');
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.share_rounded, size: 18),
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: inviteUrl));
                      azyxSnackBar('Invite Link Copied!');
                    },
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.logout_rounded,
                      color: colors.error,
                      size: 18,
                    ),
                    onPressed: () {
                      service.leaveRoom();
                      azyxSnackBar('Left Room');
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        if (roomState?.members != null && roomState!.members.isNotEmpty)
          SizedBox(
            height: 38,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              itemCount: roomState.members.length,
              itemBuilder: (context, index) {
                final member = roomState.members[index];
                final isHost = member.userId == roomState.hostUserId;
                return Container(
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: isHost
                        ? colors.primary.withOpacity(0.15)
                        : colors.surfaceContainerHighest.withOpacity(0.35),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: isHost
                          ? colors.primary.withOpacity(0.4)
                          : colors.outline.withOpacity(0.08),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        isHost ? Icons.star_rounded : Icons.person_rounded,
                        size: 14,
                        color: isHost
                            ? colors.primary
                            : colors.onSurfaceVariant,
                      ),
                      const SizedBox(width: 6),
                      AzyXText(
                        text: member.username,
                        fontSize: 12,
                        fontVariant: isHost
                            ? FontVariant.bold
                            : FontVariant.regular,
                        color: isHost ? colors.primary : null,
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        const SizedBox(height: 10),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: colors.surfaceContainerHighest.withOpacity(0.25),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: colors.outline.withOpacity(0.08)),
            ),
            child: Obx(() {
              return ListView.builder(
                physics: const BouncingScrollPhysics(),
                itemCount: service.chatMessages.length,
                itemBuilder: (context, index) {
                  final msg = service.chatMessages[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: '${msg.username}: ',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: colors.primary,
                              fontSize: 13,
                            ),
                          ),
                          TextSpan(
                            text: msg.text,
                            style: TextStyle(
                              color: colors.onSurface,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            }),
          ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: ['❤️', '🔥', '😂', '😮', '👏'].map((emoji) {
            return InkWell(
              onTap: () => service.sendReaction(emoji),
              borderRadius: BorderRadius.circular(16),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                child: Text(emoji, style: const TextStyle(fontSize: 22)),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: chatController,
                style: TextStyle(color: colors.onSurface, fontSize: 14),
                decoration: InputDecoration(
                  hintText: 'Send message...',
                  filled: true,
                  fillColor: colors.surfaceContainerHighest.withOpacity(0.35),
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide.none,
                  ),
                ),
                onSubmitted: (val) {
                  if (val.trim().isNotEmpty) {
                    service.sendChat(val.trim());
                    chatController.clear();
                  }
                },
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: Icon(Icons.send_rounded, color: colors.primary),
              onPressed: () {
                final val = chatController.text.trim();
                if (val.isNotEmpty) {
                  service.sendChat(val);
                  chatController.clear();
                }
              },
            ),
          ],
        ),
      ],
    );
  }
}
