import 'dart:ui';

import 'package:daizy_tv/Provider/manga_sources.dart';
import 'package:daizy_tv/Screens/Bottom_Menu/_profile.dart';
import 'package:daizy_tv/Screens/Bottom_Menu/_setting.dart';
import 'package:daizy_tv/Provider/theme_provider.dart';
import 'package:daizy_tv/auth/auth_provider.dart';
import 'package:daizy_tv/Hive_Data/appDatabase.dart';
import 'package:daizy_tv/Hive_Data/user.dart';
import 'package:daizy_tv/Screens/Anime/watch_screen.dart';
import 'package:daizy_tv/Screens/Lists/animelist.dart';
import 'package:daizy_tv/Screens/Lists/mangalist.dart';
import 'package:daizy_tv/Screens/Manga/mangaDetails.dart';
import 'package:daizy_tv/Screens/Manga/read.dart';
import 'package:daizy_tv/Screens/Anime/searchAnime.dart';
import 'package:daizy_tv/Screens/Manga/searchManga.dart';
import 'package:daizy_tv/Screens/settings/_about.dart';
import 'package:daizy_tv/Screens/settings/_languages.dart';
import 'package:daizy_tv/Screens/settings/_theme_changer.dart';
import 'package:flutter/material.dart';
import 'package:daizy_tv/Screens/Anime/details.dart';
import 'package:daizy_tv/Screens/Home/_homepage.dart';
import 'package:daizy_tv/Screens/Manga/mangaPage.dart';
import 'package:daizy_tv/Screens/Anime/animePage.dart';
import 'package:flashy_tab_bar2/flashy_tab_bar2.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';

void main() async {
  // init the Hive
  await Hive.initFlutter();
  await Hive.openBox('mybox');
  await Hive.openBox("app-data");
  await dotenv.load(fileName: ".env");

  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => Data()),
      ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ChangeNotifierProvider(create: (_) => AniListProvider()..tryAutoLogin()),
      ChangeNotifierProvider(create: (_) => MangaSourcesProvider()..allMangaSources())
    ],
    child: const MainApp(),
  ));
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  UserDataBase? userDataBase;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: Provider.of<ThemeProvider>(context).themeData,
      color: Theme.of(context).colorScheme.surface,
      debugShowCheckedModeBanner: false,
      onGenerateRoute: (settings) {
        final args = settings.arguments as Map<String, dynamic>?;
        switch (settings.name) {
       
          // Anime - Routes
          case '/detailspage':
            final id = args?['id'] ?? '';
            final image = args?['image'] ?? '';
            final tagg = args?['tagg'] ?? '';
            return MaterialPageRoute(
              builder: (context) => Details(id: id, image: image, tagg: tagg),
            );

          case '/stream':
  return MaterialPageRoute(
    builder: (context) => WatchPage(
      episodeSrc: args!['episodeSrc'], 
      episodeData: args['episodeData'], 
      currentEpisode: args['currentEpisode'], 
      episodeTitle: args['episodeTitle'], 
      subtitleTracks: args['subtitleTracks'], 
      animeTitle: args['animeTitle'], 
      activeServer: args['activeServer'], 
      isDub: args['isDub'],
      animeId: int.parse(args['animeId']) ,
    ),
  );

          case '/searchAnime':
            final name = args?['name'] ?? '';
            return MaterialPageRoute(
              builder: (context) => SearchAnime(name: name),
            );

          // Manga - Routes
          case '/mangaDetail':
            final id = args?['id'] ?? '';
            final image = args?['image'] ?? '';
            final tagg = args?['tagg'] ?? '';
            return MaterialPageRoute(
              builder: (context) =>
                  Mangadetails(id: id, image: image, tagg: tagg),
            );

          case '/read':
            final mangaId = args?['mangaId'] ?? '';
            final chapterLink = args?['chapterLink'] ?? '';
            final image = args?['image'] ?? '';
            return MaterialPageRoute(
              builder: (context) =>
                  Read(mangaId: mangaId, chapterLink: chapterLink, image: image,),
            );

          case '/searchManga':
            final name = args?['name'] ?? '';
            return MaterialPageRoute(
              builder: (context) => SearchManga(name: name),
            );

          // Main-Screen
          case '/homeScreen':
            return MaterialPageRoute(builder: (context) => const HomeScreen());

          //Bottom-Menu-Screens
          case './profile':
            return MaterialPageRoute(builder: (context) => const Profile());
          case './settings':
            return MaterialPageRoute(builder: (context) => const Setting());

          //Setting-Screens
          case './theme-changer':
            return MaterialPageRoute(builder: (context) => const ThemeChange());
          case './languages':
            return MaterialPageRoute(builder: (context) => const Languages());
          case './about':
            return MaterialPageRoute(builder: (context) => const About());


          //Lists 
          case './animelist': 
            return MaterialPageRoute(builder: (context) => const Animelist());
          case './mangalist':
            return MaterialPageRoute(builder: (context) => const Mangalist());
            
          default:
            return MaterialPageRoute(
              builder: (context) => const Scaffold(
                body: Center(child: Text('Page not found')),
              ),
            );
        }
      },
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 1;

  final List<Widget> _pages = [
    const Animepage(),
    const HomePage(),
    const Mangapage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      extendBodyBehindAppBar: true,
      body: _pages[_selectedIndex],
      bottomNavigationBar: Container(
        height: 60,
        margin: const EdgeInsets.only(bottom: 40),
        child: Center(
          child: SizedBox(
            width: 230,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(30),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                    decoration: BoxDecoration(
                       // Glass-like transparency
                      borderRadius: BorderRadius.circular(230),
                      border: Border.all(width: 1, color: Theme.of(context).colorScheme.inverseSurface
                          .withOpacity(0.4),)
                    ),
                    child: FlashyTabBar(
                      selectedIndex: _selectedIndex,
                      showElevation: true,
                      onItemSelected: (index) => setState(() {
                        _selectedIndex = index;
                      }),
                      backgroundColor: Colors.transparent,
                      items: [
                        FlashyTabBarItem(
                          icon: _selectedIndex == 0
                              ? const SizedBox.shrink()
                              : const Icon(Icons.movie),
                          title: const Text(
                            'Anime',
                            style: TextStyle(fontFamily: "Poppins-Bold"),
                          ),
                          activeColor: Colors.white,
                          inactiveColor: Theme.of(context).colorScheme.primary,
                        ),
                        FlashyTabBarItem(
                          icon: _selectedIndex == 1
                              ? const SizedBox.shrink()
                              : const Icon(Iconsax.home_15),
                          title: const Text(
                            'Home',
                            style: TextStyle(fontFamily: "Poppins-Bold"),
                          ),
                          activeColor: Colors.white,
                          inactiveColor: Theme.of(context).colorScheme.primary,
                        ),
                        FlashyTabBarItem(
                          icon: _selectedIndex == 2
                              ? const SizedBox.shrink()
                              : const Icon(Icons.book),
                          title: const Text(
                            'Manga',
                            style: TextStyle(fontFamily: "Poppins-Bold"),
                          ),
                          activeColor: Colors.white,
                          inactiveColor: Theme.of(context).colorScheme.primary,
                        ),
                      ],
                    )),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
