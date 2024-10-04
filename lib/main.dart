import 'dart:ui';

import 'package:daizy_tv/Bottom_Menu/_profile.dart';
import 'package:daizy_tv/Bottom_Menu/_setting.dart';
import 'package:daizy_tv/On-Boarding_Screen/login_page.dart';
import 'package:daizy_tv/Provider/theme_provider.dart';
import 'package:daizy_tv/dataBase/appDatabase.dart';
import 'package:daizy_tv/dataBase/user.dart';
import 'package:daizy_tv/pages/Manga/mangaDetails.dart';
import 'package:daizy_tv/pages/Manga/read.dart';
import 'package:daizy_tv/pages/Anime/searchAnime.dart';
import 'package:daizy_tv/pages/Manga/searchManga.dart';
import 'package:daizy_tv/settings/_about.dart';
import 'package:daizy_tv/settings/_languages.dart';
import 'package:daizy_tv/settings/_theme_changer.dart';
import 'package:flutter/material.dart';
import 'package:daizy_tv/pages/Anime/details.dart';
import 'package:daizy_tv/pages/_homepage.dart';
import 'package:daizy_tv/pages/Manga/mangaPage.dart';
import 'package:daizy_tv/pages/Anime/stream.dart';
import 'package:daizy_tv/pages/Anime/animePage.dart';
import 'package:flashy_tab_bar2/flashy_tab_bar2.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';

void main() async{

  // init the Hive
  await Hive.initFlutter();
  await Hive.openBox('mybox');
  await Hive.openBox("app-data");

  
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => Data()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
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
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: Provider.of<ThemeProvider>(context).themeData,
      color: Theme.of(context).colorScheme.surface,
      debugShowCheckedModeBanner: false,
      onGenerateRoute: (settings) {
        final args = settings.arguments as Map<String, dynamic>?;
        switch (settings.name) {

          //On-Boarding_Screen
          case '/login-page' :
          return MaterialPageRoute(builder: (context) => const LoginPage());

          // Anime - Routes
          case '/detailspage':
            final id = args?['id'] ?? '';
            final image = args?['image'] ?? '';
            final tagg = args?['tagg'] ?? '';
            return MaterialPageRoute(
              builder: (context) => Details(id: id, image: image, tagg: tagg),
            );

          case '/stream':
            final id = args?['id'] ?? '';
            return MaterialPageRoute(
              builder: (context) => Stream(id: id),
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
              builder: (context) => Mangadetails(id: id, image: image, tagg: tagg),
            );

          case '/read':
            final mangaId = args?['mangaId'] ?? '';
            final chapterId = args?['chapterId'] ?? '';
            final image = args?['image'] ?? '';
            return MaterialPageRoute(
              builder: (context) =>
                  Read(mangaId: mangaId, chapterId: chapterId, image: image),
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
            return MaterialPageRoute(builder: (context) =>  Setting());

            //Setting-Screens
            case './theme-changer':
            return MaterialPageRoute(builder: (context) => const ThemeChange());
            case './languages':
            return MaterialPageRoute(builder: (context) => const Languages());
            case './about':
            return MaterialPageRoute(builder: (context) => const About());
            

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
      body: _pages[_selectedIndex],
      bottomNavigationBar: Container(
        height: 60,
        margin: const EdgeInsets.only(bottom: 50),
        child: Center(
          child: SizedBox(
            width: 250,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(40),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white
                          .withOpacity(0.3), // Glass-like transparency
                      borderRadius: BorderRadius.circular(30),
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
                          title: const Text('Anime', style: TextStyle(fontFamily: "Poppins-Bold"),),
                          activeColor: Colors.white,
                          inactiveColor: Theme.of(context).colorScheme.primary,
                        ),
                        FlashyTabBarItem(
                          icon: _selectedIndex == 1
                              ? const SizedBox.shrink()
                              : const Icon(Iconsax.home_15),
                          title: const Text('Home', style: TextStyle(fontFamily: "Poppins-Bold"),),
                          activeColor: Colors.white,
                          inactiveColor: Theme.of(context).colorScheme.primary,
                        ),
                        FlashyTabBarItem(
                          icon: _selectedIndex == 2
                              ? const SizedBox.shrink()
                              : const Icon(Icons.book),
                          title: const Text('Manga', style: TextStyle(fontFamily: "Poppins-Bold"),),
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
