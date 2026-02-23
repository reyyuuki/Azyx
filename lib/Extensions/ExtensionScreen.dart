// ignore_for_file: file_names

import 'dart:io';

import 'package:azyx/Controllers/source/source_controller.dart';
import 'package:azyx/Extensions/ExtensionList.dart';
import 'package:azyx/Extensions/add_repo_sheet.dart';
import 'package:azyx/Widgets/ScrollConfig.dart';
import 'package:azyx/Widgets/language.dart';
import 'package:azyx/core/icons/icons_broken.dart';
import 'package:dartotsu_extension_bridge/Models/Source.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';

import '../storage_provider.dart';
import '../../main.dart';

class ExtensionScreen extends StatefulWidget {
  const ExtensionScreen({super.key});

  @override
  State<ExtensionScreen> createState() => _BrowseScreenState();
}

class _BrowseScreenState extends State<ExtensionScreen>
    with TickerProviderStateMixin {
  late TabController _tabBarController;

  @override
  void initState() {
    super.initState();
    _checkPermission();
    _fetchdata();
    _tabBarController = TabController(length: 4, vsync: this);
    _tabBarController.animateTo(0);
    _tabBarController.addListener(() {
      setState(() {
        _textEditingController.clear();
      });
    });
  }

  Future<void> _fetchdata() async {
    await sourceController.fetchRepos();
    setState(() {});
  }

  _checkPermission() async {
    await StorageProvider().requestPermission();
  }

  final _textEditingController = TextEditingController();
  late final _selectedLanguage = 'all';

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context).colorScheme;
    return ScrollConfig(
      context,
      child: DefaultTabController(
        length: 4,
        child: Padding(
          padding: EdgeInsets.only(
            top: Platform.isAndroid || Platform.isIOS ? 0 : 20,
          ),
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
                    showBottom(context, (name) {});
                  },
                  tooltip: '',
                  icon: const Icon(Ionicons.logo_github),
                ),
              ],
              leading: IconButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => HomePage()),
                  );
                },
                tooltip: '',
                icon: const Icon(Broken.arrow_left_2),
              ),
              iconTheme: IconThemeData(color: theme.primary),
              bottom: TabBar(
                indicatorSize: TabBarIndicatorSize.label,
                isScrollable: true,
                controller: _tabBarController,
                dragStartBehavior: DragStartBehavior.start,
                tabs: [
                  _buildTab(
                    context,
                    'INSTALLED ANIME',
                    false,
                    true,
                    ItemType.anime,
                  ),
                  _buildTab(
                    context,
                    'AVAILABLE ANIME',
                    false,
                    false,
                    ItemType.anime,
                  ),
                  _buildTab(
                    context,
                    'INSTALLED MANGA',
                    true,
                    true,
                    ItemType.manga,
                  ),
                  _buildTab(
                    context,
                    'AVAILABLE MANGA',
                    true,
                    false,
                    ItemType.manga,
                  ),
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
                  itemType: ItemType.anime,
                ),
                Extension(
                  installed: false,
                  query: _textEditingController.text,
                  isManga: false,
                  itemType: ItemType.anime,
                ),
                Extension(
                  installed: true,
                  query: _textEditingController.text,
                  isManga: true,
                  itemType: ItemType.manga,
                ),
                Extension(
                  installed: false,
                  query: _textEditingController.text,
                  isManga: true,
                  itemType: ItemType.manga,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTab(
    BuildContext context,
    String label,
    bool isManga,
    bool installed,
    ItemType itemType,
  ) {
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
          _extensionUpdateNumbers(
            context,
            isManga,
            installed,
            itemType,
            _selectedLanguage,
          ),
        ],
      ),
    );
  }
}

Widget _extensionUpdateNumbers(
  BuildContext context,
  bool isManga,
  bool installed,
  ItemType itemType,
  String selectedLanguage,
) {
  List<Source> getExtensionsList() {
    if (installed) {
      return sourceController.getInstalledExtensions(itemType);
    } else {
      return sourceController.getAvailableExtensions(itemType);
    }
  }

  return StreamBuilder(
    stream: Stream.periodic(
      const Duration(seconds: 1),
      (_) => getExtensionsList(),
    ),
    initialData: getExtensionsList(),
    builder: (context, snapshot) {
      if (snapshot.hasData && snapshot.data!.isNotEmpty) {
        final entries = snapshot.data!
            .where(
              (element) => selectedLanguage != 'all'
                  ? element.lang!.toLowerCase() ==
                        completeLanguageCode(selectedLanguage)
                  : true,
            )
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
    },
  );
}
