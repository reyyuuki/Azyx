import 'dart:developer';

import 'package:daizy_tv/Hive_Data/appDatabase.dart';
import 'package:daizy_tv/auth/auth_provider.dart';
import 'package:daizy_tv/components/Favrouite/favourite_list.dart';
import 'package:daizy_tv/components/Favrouite/favrouite_List.dart';
import 'package:daizy_tv/utils/helper/migrating_favortes.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class FavrouitePage extends StatefulWidget {
  const FavrouitePage({super.key});

  @override
  State<FavrouitePage> createState() => _FavrouitePageState();
}

class _FavrouitePageState extends State<FavrouitePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  dynamic data;
  bool isLoogedIn = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<Data>(context, listen: false);
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Manga'),
            Tab(text: 'Anime'),
            Tab(
              text: 'Novel',
            )
          ],
        ),
        title: const Text(
          'Favorites',
          style: TextStyle(fontFamily: "Poppins-Bold"),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 15),
        child: TabBarView(
          controller: _tabController,
          children: [
            provider.favoriteManga!.isNotEmpty
                ? FavrouiteList(data: provider.favoriteManga, route: "/mangaFavorite",)
                : const Center(
                    child: Text("No favorites manga"),
                  ),
            provider.favoriteAnime!.isNotEmpty
                ? AnimeFavrouiteList(data: provider.favoriteAnime)
                : const Center(
                    child: Text("No favorites manga"),
                  ),
        
        provider.favoriteNovel!.isNotEmpty ?
            FavrouiteList(data: provider.favoriteNovel,route: "/novelFavorite",) : const Center(child: Text("No favorite Novels"),)
          ],
        ),
      ),
    );
  }
}
