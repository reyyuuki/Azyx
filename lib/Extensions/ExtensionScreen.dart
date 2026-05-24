import 'dart:io';

import 'package:anymex_extension_runtime_bridge/Models/Source.dart';
import 'package:azyx/Controllers/settings_controller.dart';
import 'package:azyx/Controllers/source/source_controller.dart';
import 'package:azyx/Extensions/extensionList.dart';
import 'package:azyx/Extensions/ExtensionManagerScreen.dart';
import 'package:azyx/Widgets/ScrollConfig.dart';
import 'package:azyx/Widgets/language.dart';
import 'package:azyx/core/icons/icons_broken.dart';
import 'package:azyx/Widgets/AzyXWidgets/azyx_gradient_container.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../main.dart';
import '../storage_provider.dart';

class ExtensionScreen extends StatefulWidget {
  const ExtensionScreen({super.key});

  @override
  State<ExtensionScreen> createState() => _BrowseScreenState();
}

class _BrowseScreenState extends State<ExtensionScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabBarController;

  @override
  void initState() {
    super.initState();
    _checkPermission();
    _tabBarController = TabController(length: 4, vsync: this);
    sourceController.checkRuntimeHost();
  }

  @override
  void dispose() {
    _tabBarController.dispose();
    super.dispose();
  }

  Future<void> _checkPermission() async {
    await StorageProvider().requestPermission();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return ScrollConfig(
      context,
      child: Scaffold(
        backgroundColor: cs.surface,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Broken.arrow_left_2, color: cs.onSurface, size: 28),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => HomePage()),
              );
            },
          ),
          title: Text(
            'Extensions',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: cs.onSurface,
              letterSpacing: -0.5,
            ),
          ),
          actions: [
            IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ExtensionManagerScreen(),
                  ),
                );
              },
              icon: Icon(Broken.setting_2, color: cs.onSurface, size: 24),
            ),
          ],
          bottom: TabBar(
            controller: _tabBarController,
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            dividerColor: Colors.transparent,
            indicatorColor: cs.primary,
            indicatorSize: TabBarIndicatorSize.tab,
            labelColor: cs.primary,
            unselectedLabelColor: cs.onSurfaceVariant,
            labelStyle: const TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 14,
            ),
            unselectedLabelStyle: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
            tabs: const [
              Tab(text: 'Installed Anime'),
              Tab(text: 'Available Anime'),
              Tab(text: 'Installed Manga'),
              Tab(text: 'Available Manga'),
            ],
          ),
        ),
        body: AzyXGradientContainer(
          child: TabBarView(
            controller: _tabBarController,
            children: [
              Extension(installed: true, query: '', itemType: ItemType.anime),
              Extension(installed: false, query: '', itemType: ItemType.anime),
              Extension(installed: true, query: '', itemType: ItemType.manga),
              Extension(installed: false, query: '', itemType: ItemType.manga),
            ],
          ),
        ),
      ),
    );
  }
}
