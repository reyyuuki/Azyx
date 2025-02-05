// ignore_for_file: file_names

import 'package:azyx/Extensions/ExtensionList.dart';
import 'package:azyx/Widgets/ScrollConfig.dart';
import 'package:azyx/api/Mangayomi/Model/Source.dart';
import 'package:azyx/core/icons/icons_broken.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ionicons/ionicons.dart';
import 'package:isar/isar.dart';

import '../../Preferences/PrefManager.dart';
import '../../Preferences/Preferences.dart';
import '../../StorageProvider.dart';
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
                    "https://kodjodevf.github.io/mangayomi-extensions/anime_index.json";

                    "https://kodjodevf.github.io/mangayomi-extensions/index.json";
                    showBottom(context, (name) {});
                  },
                  icon: const Icon(Ionicons.logo_github))
            ],
            leading: IconButton(
                onPressed: () {
                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const HomePage()));
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

void showBottom(BuildContext context, Function(String) onAddRepository) {
  TextEditingController controller = TextEditingController();

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
    ),
    builder: (context) {
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Add Repository",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: controller,
              decoration: const InputDecoration(
                labelText: "Repository URL",
                border: OutlineInputBorder(),
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
                  onAddRepository(controller.text);
                  Navigator.pop(context);
                }
              },
              child: Text(
                "Add Repository",
                style: TextStyle(
                    color: Theme.of(context).colorScheme.inversePrimary,
                    fontFamily: "Poppins-Bold"),
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
}
