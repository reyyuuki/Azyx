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
              builder: (context) => Read(mangaId: mangaId, chapterId: chapterId ),
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
    Animepage(),
    Loginpage(),
    Mangapage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex], 
      bottomNavigationBar: CurvedNavigationBar(
        index: _selectedIndex, 
        items: [
          Icon(Icons.home),
          Icon(Icons.login),
          Icon(Icons.movie),
        ],
        animationDuration: Duration(milliseconds: 300),
        backgroundColor: Colors.transparent,
        color: Theme.of(context).colorScheme.primary,
        height: 50,
        animationCurve: Curves.easeInOut,
        onTap: (index) {
          setState(() {
            _selectedIndex = index; 
          });
        },
      ),
    );
  }
}
