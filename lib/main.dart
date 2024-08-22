import 'dart:ui';

import 'package:daizy_tv/pages/Manga/mangaDetails.dart';
import 'package:daizy_tv/pages/Manga/read.dart';
import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:daizy_tv/Theme/themes.dart';
import 'package:daizy_tv/pages/Anime/details.dart';
import 'package:daizy_tv/pages/loginPage.dart';
import 'package:daizy_tv/pages/mangaPage.dart';
import 'package:daizy_tv/pages/Anime/stream.dart';
import 'package:daizy_tv/pages/animePage.dart';
import 'package:flashy_tab_bar2/flashy_tab_bar2.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: lightmode,
      darkTheme: darkmode,
      color: Theme.of(context).colorScheme.surface,
      debugShowCheckedModeBanner: false,
      onGenerateRoute: (settings) {
        final args = settings.arguments as Map<String, dynamic>?;
        switch (settings.name) {
          // Anime - Routes
          case '/detailspage':
            final id = args?['id'] ?? '';
            final image = args?['image'] ?? '';
            return MaterialPageRoute(
              builder: (context) => Details(id: id, image: image),
            );
          case '/stream':
            final id = args?['id'] ?? '';
            return MaterialPageRoute(
              builder: (context) => Stream(id: id),
            );

          // Manga - Routes
          case '/mangaDetail':
            final id = args?['id'] ?? '';
            final image = args?['image'] ?? '';
            return MaterialPageRoute(
              builder: (context) => Mangadetails(id: id, image: image),
            );
          case '/read':
            final mangaId = args?['mangaId'] ?? '';
            final chapterId = args?['chapterId'] ?? '';
            return MaterialPageRoute(
              builder: (context) =>
                  Read(mangaId: mangaId, chapterId: chapterId),
            );
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
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const Animepage(),
    const Loginpage(),
    const Mangapage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: _pages[_selectedIndex],
      bottomNavigationBar: Container(
        height: 60,
        margin: EdgeInsets.only(bottom: 20),
        child: Center(
          child: SizedBox(
            width: 250,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(40),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.5), // Glass-like transparency
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.3), // Border color
                        width: 1,
                      ),
                    ),
                  child: FlashyTabBar(
                    animationCurve: Curves.linear,
                    backgroundColor: Colors.transparent,
                    selectedIndex: _selectedIndex,
                    showElevation: false,
                    onItemSelected: (index) => setState(() {
                      _selectedIndex = index;
                    }),
                    items: [
                      FlashyTabBarItem(
                          icon: const Icon(Icons.movie), title: const Text('Anime')),
                      FlashyTabBarItem(
                          icon: const Icon(Icons.login), title: const Text('Login')),
                      FlashyTabBarItem(
                          icon: const Icon(Icons.book), title: const Text('Manga')),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
