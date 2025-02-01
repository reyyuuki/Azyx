// ignore_for_file: file_names, unused_result

import 'package:azyx/Extensions/ExtensionList.dart';
import 'package:azyx/api/Mangayomi/Extensions/fetch_anime_sources.dart';
import 'package:azyx/api/Mangayomi/Extensions/fetch_manga_sources.dart';
import 'package:azyx/api/Mangayomi/Model/Source.dart';
import 'package:azyx/auth/auth_provider.dart';
import 'package:azyx/auth/sources_controller.dart';
import 'package:azyx/components/Common/ScrollConfig.dart';
import 'package:azyx/core/icons/icons_broken.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:ionicons/ionicons.dart';
import 'package:isar/isar.dart';

import '../../Preferences/PrefManager.dart';
import '../../Preferences/Preferences.dart';
import '../../StorageProvider.dart';
import 'package:provider/provider.dart' as p;
import '../../main.dart';

class ExtensionScreen extends ConsumerStatefulWidget {
  const ExtensionScreen({super.key});

  @override
  ConsumerState<ExtensionScreen> createState() => _BrowseScreenState();
}

class _BrowseScreenState extends ConsumerState<ExtensionScreen>
    with TickerProviderStateMixin {
  late TabController _tabBarController;

  @override
  void initState() {
    super.initState();
    _checkPermission();
    _tabBarController = TabController(length: 4, vsync: this);
    _tabBarController.animateTo(0);
    _tabBarController.addListener(() {
      setState(() {
        _textEditingController.clear();
        //_isSearch = false;
      });
    });
  }

  _checkPermission() async {
    await StorageProvider().requestPermission();
  }

  final _textEditingController = TextEditingController();

  Future<void> _fetchData() async {
    ref.read(fetchMangaSourcesListProvider(id: null, reFresh: false).future);
    ref.read(fetchAnimeSourcesListProvider(id: null, reFresh: false).future);
  }

  Future<void> _refreshData() async {
    await ref
        .refresh(fetchMangaSourcesListProvider(id: null, reFresh: true).future);
    await ref
        .refresh(fetchAnimeSourcesListProvider(id: null, reFresh: true).future);
  }

  //bool _isSearch = false;
  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context).colorScheme;
    return ScrollConfig(
      context,
      child: DefaultTabController(
        length: 4,
        child: Scaffold(
          appBar: AppBar(
            elevation: 0,
            backgroundColor: Colors.transparent,
            title: Text(
              'Extensions',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.bold,
                fontSize: 16.0,
                color: theme.primary,
              ),
            ),
            actions: [
              IconButton(
                  onPressed: () {
                    final controller = Get.put(SourcesController());
                    showBottom(context, (name, isAnime) {
                      isAnime
                          ? controller.updateAnimeRepo(name)
                          : controller.updateMangaRepo(name);

                      _fetchData();
                      _refreshData();
                    });
                  },
                  icon: const Icon(Ionicons.logo_github))
            ],
            leading: IconButton(
                onPressed: () {
                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const HomeScreen()));
                },
                icon: const Icon(Broken.arrow_left_2)),
            iconTheme: IconThemeData(color: theme.primary),
            bottom: TabBar(
              indicatorSize: TabBarIndicatorSize.label,
              isScrollable: true,
              controller: _tabBarController,
              dragStartBehavior: DragStartBehavior.start,
              tabs: [
                _buildTab(context, 'INSTALLED ANIME', false, true),
                _buildTab(context, 'AVAILABLE ANIME', false, false),
                _buildTab(context, 'INSTALLED MANGA', true, true),
                _buildTab(context, 'AVAILABLE MANGA', true, false),
              ],
            ),
          ),
          body: TabBarView(
            controller: _tabBarController,
            children: [
              Extension(
                installed: true,
                query: _textEditingController.text,
                isManga: false,
              ),
              Extension(
                installed: false,
                query: _textEditingController.text,
                isManga: false,
              ),
              Extension(
                installed: true,
                query: _textEditingController.text,
                isManga: true,
              ),
              Extension(
                installed: false,
                query: _textEditingController.text,
                isManga: true,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTab(
      BuildContext context, String label, bool isManga, bool installed) {
    return Tab(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.bold,
              fontSize: 14.0,
            ),
          ),
          const SizedBox(width: 8),
          _extensionUpdateNumbers(context, isManga, installed),
        ],
      ),
    );
  }
}

Widget _extensionUpdateNumbers(
    BuildContext context, bool isManga, bool installed) {
  return StreamBuilder(
      stream: isar.sources
          .filter()
          .idIsNotNull()
          .and()
          .isAddedEqualTo(installed)
          .isActiveEqualTo(true)
          .isMangaEqualTo(isManga)
          .watch(fireImmediately: true),
      builder: (context, snapshot) {
        if (snapshot.hasData && snapshot.data!.isNotEmpty) {
          final entries = snapshot.data!
              .where((element) => PrefManager.getVal(PrefName.NSFWExtensions)
                  ? true
                  : element.isNsfw == false)
              .toList();

          return entries.isEmpty
              ? Container()
              : Text(
                  "(${entries.length.toString()})",
                  style: const TextStyle(
                    fontSize: 12,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.bold,
                  ),
                );
        }
        return Container();
      });
}

void showBottom(BuildContext context, Function(String, bool) onAddRepository) {
  TextEditingController controller = TextEditingController();
  bool isAnimeSelected = true;

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
    ),
    builder: (context) {
      return StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
          return Padding(
            padding: EdgeInsets.fromLTRB(
              15,
              15,
              15,
              MediaQuery.of(context).viewInsets.bottom,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          isAnimeSelected = true;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 15, vertical: 10),
                        decoration: BoxDecoration(
                            color: isAnimeSelected
                                ? Theme.of(context).colorScheme.primary
                                : Colors.grey,
                            boxShadow: [
                              BoxShadow(
                                  color: isAnimeSelected
                                      ? Theme.of(context).colorScheme.primary
                                      : Colors.grey,
                                  blurRadius: 10)
                            ],
                            borderRadius: BorderRadius.circular(20)),
                        child: Row(
                          children: [
                            Icon(
                              Icons.movie_filter,
                              color: isAnimeSelected
                                  ? Theme.of(context).colorScheme.inversePrimary
                                  : Colors.black,
                            ),
                            Text(
                              "Anime",
                              style: TextStyle(
                                fontFamily: "Poppins-Bold",
                                color: isAnimeSelected
                                    ? Theme.of(context)
                                        .colorScheme
                                        .inversePrimary
                                    : Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          isAnimeSelected = false;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 15, vertical: 10),
                        decoration: BoxDecoration(
                            color: !isAnimeSelected
                                ? Theme.of(context).colorScheme.primary
                                : Colors.grey,
                            boxShadow: [
                              BoxShadow(
                                  color: !isAnimeSelected
                                      ? Theme.of(context).colorScheme.primary
                                      : Colors.grey,
                                  blurRadius: 10)
                            ],
                            borderRadius: BorderRadius.circular(20)),
                        child: Row(
                          children: [
                            Icon(
                              Broken.book,
                              color: !isAnimeSelected
                                  ? Theme.of(context).colorScheme.inversePrimary
                                  : Colors.black,
                            ),
                            const SizedBox(
                              width: 5,
                            ),
                            Text(
                              "Manga",
                              style: TextStyle(
                                fontFamily: "Poppins-Bold",
                                color: !isAnimeSelected
                                    ? Theme.of(context)
                                        .colorScheme
                                        .inversePrimary
                                    : Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: controller,
                  decoration: InputDecoration(
                    labelText: isAnimeSelected
                        ? "Repository URL Anime"
                        : "Repository URL Manga",
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor: WidgetStatePropertyAll(
                        Theme.of(context).colorScheme.primary),
                    shadowColor: WidgetStatePropertyAll(
                        Theme.of(context).colorScheme.primary),
                  ),
                  onPressed: () {
                    if (controller.text.isNotEmpty) {
                      onAddRepository(controller.text, isAnimeSelected);
                      Navigator.pop(context);
                    }
                  },
                  child: Text(
                    "Add Repository",
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.inversePrimary,
                      fontFamily: "Poppins-Bold",
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  "Disclaimer: This app does not promote piracy. Please add only legal and authorized repositories.",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, fontFamily: "Poppins"),
                ),
              ],
            ),
          );
        },
      );
    },
  );
}
