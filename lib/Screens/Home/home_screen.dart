import 'package:azyx/Controllers/anilist_auth.dart';
import 'package:azyx/Controllers/services/service_handler.dart';
import 'package:azyx/Screens/AI/ai_recommendations_page.dart';
import 'package:azyx/Screens/Home/Calender/calender.dart';
import 'package:azyx/Screens/Home/UserLists/user_lists.dart';
import 'package:azyx/Widgets/AzyXWidgets/azyx_gradient_container.dart';
import 'package:azyx/Widgets/AzyXWidgets/azyx_text.dart';
import 'package:azyx/Widgets/anime/anime_scrollable_list.dart';
import 'package:azyx/Widgets/header.dart';
import 'package:azyx/core/icons/icons_broken.dart';
import 'package:azyx/utils/Functions/multiplier_extension.dart';
import 'package:azyx/utils/constants.dart';
import 'package:azyx/utils/functions.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AzyXGradientContainer(
      child: Padding(
        padding: const EdgeInsets.only(top: 20),
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            const SliverToBoxAdapter(
              child: Header(),
            ),
            SliverToBoxAdapter(
              child: Obx(
                () => serviceHandler.userData.value.name == null
                    ? const SizedBox.shrink()
                    : Padding(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                        child: Container(
                          height: 215,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            gradient: const LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Color(0xFF6C63FF),
                                Color(0xFF3B3486),
                              ],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF6C63FF).withOpacity(0.3),
                                blurRadius: 15,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: Stack(
                              children: [
                                Positioned(
                                  right: -40,
                                  top: -40,
                                  child: Container(
                                    width: 120,
                                    height: 120,
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(60),
                                    ),
                                  ),
                                ),
                                Positioned(
                                    left: -30,
                                    bottom: -30,
                                    child: Container(
                                      width: 80,
                                      height: 80,
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(40),
                                      ),
                                    )),

                                // Content with proper font variants
                                Padding(
                                  padding: const EdgeInsets.all(20),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 12, vertical: 6),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.2),
                                          borderRadius:
                                              BorderRadius.circular(30),
                                          border: Border.all(
                                              color:
                                                  Colors.white.withOpacity(0.3),
                                              width: 1),
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
                                        text: "Your Anime Journey",
                                        fontSize: 22,
                                        color: Colors.white,
                                        fontVariant: FontVariant.bold,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 8),
                                      const AzyXText(
                                        text:
                                            "Explore your personalized recommendations from AI",
                                        fontSize: 14,
                                        color: Colors.white,
                                        fontVariant: FontVariant.regular,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 16),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          GestureDetector(
                                            onTap: () {
                                              Get.to(() =>
                                                  const AiRecommendationsPage(
                                                    isManga: false,
                                                  ));
                                            },
                                            child: Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 16,
                                                      vertical: 8),
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius:
                                                    BorderRadius.circular(30),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.black
                                                        .withOpacity(0.1),
                                                    blurRadius: 10,
                                                    offset: const Offset(0, 4),
                                                  ),
                                                ],
                                              ),
                                              child: const Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Text(
                                                    "Anime",
                                                    style: TextStyle(
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      color: Color(0xFF3B3486),
                                                    ),
                                                  ),
                                                  SizedBox(width: 8),
                                                  Icon(
                                                    Icons.arrow_forward_rounded,
                                                    size: 18,
                                                    color: Color(0xFF3B3486),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                          10.width,
                                          GestureDetector(
                                            onTap: () {
                                              Get.to(() =>
                                                  const AiRecommendationsPage(
                                                    isManga: true,
                                                  ));
                                            },
                                            child: Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 16,
                                                      vertical: 8),
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius:
                                                    BorderRadius.circular(30),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.black
                                                        .withOpacity(0.1),
                                                    blurRadius: 10,
                                                    offset: const Offset(0, 4),
                                                  ),
                                                ],
                                              ),
                                              child: const Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Text(
                                                    "Manga",
                                                    style: TextStyle(
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      color: Color(0xFF3B3486),
                                                    ),
                                                  ),
                                                  SizedBox(width: 8),
                                                  Icon(
                                                    Icons.arrow_forward_rounded,
                                                    size: 18,
                                                    color: Color(0xFF3B3486),
                                                  ),
                                                ],
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
            ),
            SliverToBoxAdapter(
              child: Obx(
                () => serviceHandler.userData.value.name == null ||
                        serviceHandler.userData.value.name!.isEmpty
                    ? const SizedBox.shrink()
                    : Padding(
                        padding: const EdgeInsets.fromLTRB(16, 20, 16, 20),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            gradient: const LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Color(0xFF4CAF50),
                                Color(0xFF2E7D32),
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
                                      horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(30),
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
                                      child: _buildModernButton(
                                        context: context,
                                        title: "Anime",
                                        icon: Icons.movie_filter,
                                        subtitle: "Your watched shows",
                                        onTap: () {
                                          Get.to(() => UserListPage(
                                              categories: animeCategories,
                                              isManga: false));
                                        },
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: _buildModernButton(
                                        context: context,
                                        title: "Manga",
                                        icon: Broken.book,
                                        subtitle: "Your reading list",
                                        onTap: () {
                                          Get.to(() => UserListPage(
                                                isManga: true,
                                                categories: mangaCategories,
                                              ));
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
            ),
            SliverToBoxAdapter(
              child: Obx(
                () => serviceHandler.userData.value.name == null
                    ? const SizedBox.shrink()
                    : Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            gradient: const LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Color(0xFFFF9800),
                                Color(0xFFFF5722),
                              ],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFFF9800).withOpacity(0.3),
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 12, vertical: 6),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.2),
                                          borderRadius:
                                              BorderRadius.circular(30),
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
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Material(
                                    color: Colors.transparent,
                                    child: InkWell(
                                      borderRadius: BorderRadius.circular(20),
                                      onTap: () {
                                        Get.to(() => const CalenderPage());
                                      },
                                      child: const Padding(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 16),
                                        child: Center(
                                          child: Text(
                                            "View All",
                                            style: TextStyle(
                                              color: Color(0xFFFF5722),
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
            ),
            SliverToBoxAdapter(
              child: Obx(() {
                // if (serviceHandler.userData.value.id == null) {
                //   return Container(
                //     alignment: Alignment.center,
                //     height: Get.height * 0.3,
                //     child: Column(
                //       mainAxisAlignment: MainAxisAlignment.center,
                //       children: [
                //         CircularProgressIndicator(
                //           color: Theme.of(context).colorScheme.secondary,
                //         ),
                //         const SizedBox(height: 16),
                //         AzyXText(
                //           text: "Loading your anime",
                //           fontSize: 16,
                //           fontVariant: FontVariant.regular,
                //           color: Theme.of(context).colorScheme.onBackground,
                //         ),
                //       ],
                //     ),
                //   );
                // }

                return Padding(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (serviceHandler
                          .userAnimeList.value.currentlyWatching.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: AnimeScrollableList(
                            varient: CarousaleVarient.userList,
                            isManga: false,
                            animeList: serviceHandler
                                .userAnimeList.value.currentlyWatching,
                            title: "Currently Watching",
                          ),
                        ),
                      ...serviceHandler.homeWidgets(context),
                      100.height
                    ],
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModernButton({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF4CAF50).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        icon,
                        color: const Color(0xFF4CAF50),
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: AzyXText(
                        text: title,
                        fontSize: 16,
                        fontVariant: FontVariant.bold,
                        color: Colors.black87,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                AzyXText(
                  text: subtitle,
                  fontSize: 12,
                  fontVariant: FontVariant.regular,
                  color: Colors.black54,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
