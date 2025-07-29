import 'package:azyx/Controllers/services/service_handler.dart';
import 'package:azyx/Widgets/AzyXWidgets/azyx_container.dart';
import 'package:azyx/Widgets/AzyXWidgets/azyx_gradient_container.dart';
import 'package:azyx/Widgets/AzyXWidgets/azyx_text.dart';
import 'package:azyx/core/icons/icons_broken.dart';
import 'package:azyx/utils/Functions/multiplier_extension.dart';
import 'package:azyx/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class UserListPage extends StatefulWidget {
  final List<Map<String, dynamic>> categories;
  final bool isManga;
  const UserListPage(
      {super.key, required this.categories, required this.isManga});

  @override
  State<UserListPage> createState() => _UserListScreenState();
}

class _UserListScreenState extends State<UserListPage>
    with TickerProviderStateMixin {
  TabController? tabController;
  final RxList<Map<String, dynamic>> filterCategories = RxList();
  @override
  void initState() {
    super.initState();
    _initializeTabController();
    filterCategories.value = widget.categories;
  }

  void _initializeTabController() {
    tabController = TabController(
      length: 6,
      vsync: this,
    );
  }

  @override
  void dispose() {
    super.dispose();
    tabController?.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ListAppBar(
          ontap: () {
            filterCategories.value = filterCategories.reversed.toList();
          },
          subtitle: "Continue Where You Left Off",
          title: widget.isManga
              ? "${serviceHandler.userData.value.name}'s MangaList"
              : "${serviceHandler.userData.value.name}'s AnimeList"),
      body: AzyXGradientContainer(
        child: Column(
          children: [
            AzyXContainer(
              padding: const EdgeInsets.all(0),
              margin: const EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(30),
              ),
              child: Obx(
                () => TabBar(
                  controller: tabController,
                  isScrollable: true,
                  tabs: filterCategories.map((category) {
                    return Tab(
                      text: category['name'],
                    );
                  }).toList(),
                  labelStyle: const TextStyle(
                      fontSize: 14,
                      fontFamily: "Poppins-Bold",
                      color: Colors.black),
                  unselectedLabelStyle: TextStyle(
                      fontSize: 14,
                      fontFamily: "Poppins-Bold",
                      color: Theme.of(context)
                          .colorScheme
                          .primary
                          .withOpacity(0.6)),
                  indicator: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: Theme.of(context).colorScheme.primary,
                      boxShadow: [
                        BoxShadow(
                            color: Theme.of(context)
                                .colorScheme
                                .primary
                                .withOpacity(1.glowMultiplier()),
                            spreadRadius: 2.spreadMultiplier(),
                            blurRadius: 5.blurMultiplier())
                      ]),
                  indicatorSize: TabBarIndicatorSize.tab,
                  dividerColor: Colors.transparent,
                  tabAlignment: TabAlignment.start,
                  automaticIndicatorColorAdjustment: true,
                  indicatorAnimation: TabIndicatorAnimation.elastic,
                  indicatorPadding: const EdgeInsets.all(6),
                ),
              ),
            ),
            Expanded(
              child: Obx(
                () => TabBarView(
                    controller: tabController,
                    children: filterCategories.map((i) {
                      return i['view'] as Widget;
                    }).toList()),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ListAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final String subtitle;
  final VoidCallback ontap;
  const ListAppBar(
      {super.key,
      required this.title,
      required this.ontap,
      required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      leading: GestureDetector(
          onTap: () {
            Get.back();
          },
          child: const Icon(
            Broken.arrow_left_2,
          )),
      titleSpacing: 0,
      actions: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: IconButton(
              onPressed: ontap,
              style: ButtonStyle(
                backgroundColor: WidgetStatePropertyAll(
                    Theme.of(context).colorScheme.surfaceContainerHigh),
                padding: const WidgetStatePropertyAll(EdgeInsets.all(10)),
              ),
              icon: const Icon(Broken.arrow_2)),
        )
      ],
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AzyXText(
            text: title,
            fontVariant: FontVariant.bold,
            fontSize: 18,
          ),
          AzyXText(
            text: subtitle,
            color: Theme.of(context).colorScheme.primary,
            fontVariant: FontVariant.bold,
            fontSize: 12,
          ),
        ],
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
