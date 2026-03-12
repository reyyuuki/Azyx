import 'package:azyx/Models/anilist_user_data.dart';
import 'package:azyx/Screens/AI/ai_recommendations_page.dart';
import 'package:azyx/Screens/Home/Calender/calender.dart';
import 'package:azyx/Screens/Home/UserLists/user_lists.dart';
import 'package:azyx/Widgets/AzyXWidgets/azyx_text.dart';
import 'package:azyx/core/icons/icons_broken.dart';
import 'package:azyx/utils/Functions/multiplier_extension.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CalenderCard extends StatelessWidget {
  const CalenderCard({super.key, required this.userData});

  final Rx<User> userData;

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Obx(
        () => userData.value.name == null
            ? const SizedBox.shrink()
            : Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        context.theme.colorScheme.primary.withValues(
                          alpha: 0.2,
                        ),
                        context.theme.colorScheme.primary.withValues(
                          alpha: 0.5,
                        ),
                        context.theme.colorScheme.primary.withValues(
                          alpha: 0.2,
                        ),
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFFF9800).withOpacity(0.1),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(30),
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.3),
                                    width: 1,
                                  ),
                                ),
                                child: const AzyXText(
                                  text: "SPRING 2025",
                                  fontSize: 12,
                                  color: Colors.white,
                                  fontVariant: FontVariant.bold,
                                ),
                              ),
                              const SizedBox(height: 12),
                              const AzyXText(
                                text: "Season Highlights",
                                fontSize: 20,
                                color: Colors.white,
                                fontVariant: FontVariant.bold,
                              ),
                              const SizedBox(height: 8),
                              const AzyXText(
                                text: "Latest releases of the season",
                                fontSize: 14,
                                color: Colors.white,
                                fontVariant: FontVariant.regular,
                              ),
                            ],
                          ),
                        ),
                        Container(
                          height: 40,

                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(20),
                              onTap: () {
                                Get.to(() => const CalenderPage());
                              },
                              child: const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 16),
                                child: Center(
                                  child: Text(
                                    "View All",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
      ),
    );
  }
}

class UserListsCard extends StatelessWidget {
  const UserListsCard({super.key, required this.userData});

  final Rx<User> userData;

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Obx(
        () => userData.value.name == null || userData.value.name!.isEmpty
            ? const SizedBox.shrink()
            : Padding(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 20),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        context.theme.colorScheme.primary.withValues(
                          alpha: 0.2,
                        ),
                        context.theme.colorScheme.primary.withValues(
                          alpha: 0.5,
                        ),
                        context.theme.colorScheme.primary.withValues(
                          alpha: 0.2,
                        ),
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF4CAF50).withOpacity(0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                          child: const AzyXText(
                            text: "MY COLLECTIONS",
                            fontSize: 12,
                            color: Colors.white,
                            fontVariant: FontVariant.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        const AzyXText(
                          text: "Your Collections",
                          fontSize: 20,
                          color: Colors.white,
                          fontVariant: FontVariant.bold,
                        ),
                        const SizedBox(height: 8),
                        const AzyXText(
                          text:
                              "Access your personalized anime and manga lists",
                          fontSize: 14,
                          color: Colors.white,
                          fontVariant: FontVariant.regular,
                        ),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            Expanded(
                              child: buildModernButton(
                                context: context,
                                title: "Anime",
                                icon: Icons.movie_filter,
                                subtitle: "Your watched shows",
                                onTap: () {
                                  Get.to(() => UserListPage(isManga: false));
                                },
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: buildModernButton(
                                context: context,
                                title: "Manga",
                                icon: Broken.book,
                                subtitle: "Your reading list",
                                onTap: () {
                                  Get.to(() => UserListPage(isManga: true));
                                },
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
      ),
    );
  }
}

Widget buildModernButton({
  required BuildContext context,
  required String title,
  required String subtitle,
  required IconData icon,
  required VoidCallback onTap,
}) {
  return Material(
    color: Colors.transparent,
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.2), width: 0.5),
          boxShadow: [
            BoxShadow(
              color: Colors.white.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white.withOpacity(0.9), size: 24),
            const SizedBox(height: 12),
            AzyXText(
              text: title,
              fontSize: 16,
              fontVariant: FontVariant.bold,
              color: Colors.white,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            AzyXText(
              text: subtitle,
              fontSize: 12,
              fontVariant: FontVariant.regular,
              color: Colors.white.withOpacity(0.7),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    ),
  );
}

class AiSuggestionsCard extends StatelessWidget {
  const AiSuggestionsCard({super.key, required this.userData});

  final Rx<User> userData;

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Obx(
        () => userData.value.name == null
            ? const SizedBox.shrink()
            : Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: Container(
                  height: 220,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    gradient: LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [
                        context.theme.colorScheme.primary.withValues(
                          alpha: 0.2,
                        ),
                        context.theme.colorScheme.primary.withValues(
                          alpha: 0.5,
                        ),
                        context.theme.colorScheme.primary.withValues(
                          alpha: 0.2,
                        ),
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: context.theme.colorScheme.primary.withOpacity(
                          0.3,
                        ),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Stack(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(30),
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.3),
                                    width: 1,
                                  ),
                                ),
                                child: const AzyXText(
                                  text: "DISCOVER",
                                  fontSize: 12,
                                  color: Colors.white,
                                  fontVariant: FontVariant.bold,
                                ),
                              ),
                              const SizedBox(height: 12),
                              const AzyXText(
                                text: "AI Media Hub",
                                fontSize: 22,
                                color: Colors.white,
                                fontVariant: FontVariant.bold,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 8),
                              const AzyXText(
                                text:
                                    "Personalized recommendations powered by AI",
                                fontSize: 13,
                                color: Colors.white,
                                fontVariant: FontVariant.regular,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  Expanded(
                                    child: _SuggestionButton(
                                      label: "Anime",
                                      onTap: () => Get.to(
                                        () => const AiRecommendationsPage(
                                          isManga: false,
                                        ),
                                      ),
                                    ),
                                  ),
                                  8.width,
                                  Expanded(
                                    child: _SuggestionButton(
                                      label: "Manga",
                                      onTap: () => Get.to(
                                        () => const AiRecommendationsPage(
                                          isManga: true,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
      ),
    );
  }
}

class _SuggestionButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final IconData icon;

  const _SuggestionButton({
    required this.label,
    required this.onTap,
    this.icon = Icons.arrow_forward_rounded,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 42,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: Colors.white.withOpacity(0.3), width: 1),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Flexible(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 4),
            Icon(icon, size: 14, color: Colors.white),
          ],
        ),
      ),
    );
  }
}
