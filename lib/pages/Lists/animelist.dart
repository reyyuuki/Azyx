import 'package:daizy_tv/auth/auth_provider.dart';
import 'package:daizy_tv/components/Anime/all_anime_lists.dart';
import 'package:daizy_tv/components/Anime/anime_lists.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';

class Animelist extends StatefulWidget {
  const Animelist({super.key});

  @override
  _AnimelistState createState() => _AnimelistState();
}

class _AnimelistState extends State<Animelist> {
  int _selectedIndex = 0; 
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {

    return Consumer<AniListProvider>(
    builder: (context, provide, child) {
      final provider = provide.userData;
      
      if (provider['animeList'] == null) {
        return const Center(child: CircularProgressIndicator());
      }
    final List<Map<String, dynamic>> categories = [
      {"name": "All", "view": AllAnimeLists(data: provider['animeList'])},
      {"name": "Completed", "view": AnimeLists(data: provider['animeList'], status: "COMPLETED")},
      {"name": "Planning", "view": AnimeLists(data: provider['animeList'], status: "PLANNING")},
      {"name": "Continue", "view": AnimeLists(data: provider['animeList'], status: "CONTINUE")},
      {"name": "Watched", "view": AnimeLists(data: provider['animeList'], status: "WATCHED")},
      {"name": "Scheduled", "view": AnimeLists(data: provider['animeList'], status: "SCHEDULED")},
      {"name": "Paused", "view": AnimeLists(data: provider['animeList'], status: "PAUSED")},
    ];

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text(categories[_selectedIndex]['name'], style: const TextStyle(fontFamily: "Poppins-Bold")),
        backgroundColor: Colors.transparent,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Iconsax.menu_board5), 
          onPressed: () {
            _scaffoldKey.currentState?.openDrawer();
          },
        ),
      ),
      drawer: Drawer(
        width: 200,
        child: Container(
          decoration: BoxDecoration(color: Theme.of(context).colorScheme.surface),
          child: ListView(
            children: [
              SizedBox(
                height: 89,
                child: DrawerHeader(
                  child: Container(
                    decoration: BoxDecoration(color: Theme.of(context).colorScheme.primaryFixedDim, borderRadius: BorderRadius.circular(10)),
                    child: ListTile(
                      onTap: () {
                        Navigator.pushNamed(context, './profile');
                      },
                      leading: SizedBox(
                        height: 35,
                        width: 35,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: Image.network(
                            provider['avatar']['large'],
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      title: Text(
                        provider['name'].length > 12 ? "${provider['name'].substring(0, 10)}..." : provider['name'],
                        style: const TextStyle(fontFamily: "Poppins-Bold", color: Colors.black),
                      ),
                    ),
                  ),
                ),
              ),
              for (int i = 0; i < categories.length; i++)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                  child: Container(
                    height: 50,
                    decoration: BoxDecoration(
                      color: _selectedIndex == i ? Theme.of(context).colorScheme.inverseSurface : Theme.of(context).colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: ListTile(
                      leading: Icon(_selectedIndex == i ? Iconsax.main_component5 : Iconsax.main_component),
                      title: Text(categories[i]['name'], style: const TextStyle(fontSize: 14, fontFamily: "Poppins-Bold")),
                      selectedColor: Theme.of(context).colorScheme.surface,
                      selected: _selectedIndex == i,
                      onTap: () {
                        setState(() {
                          _selectedIndex = i;
                        });
                        Navigator.pop(context);
                      },
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
      body: categories[_selectedIndex]['view'],
    );
  }
    );
}
}