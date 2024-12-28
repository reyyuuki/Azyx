// ignore_for_file: library_private_types_in_public_api
import 'package:azyx/Preferences/PrefManager.dart';
import 'package:azyx/Provider/sources_provider.dart';
import 'package:azyx/Screens/Bottom_Menu/_profile.dart';
import 'package:azyx/Screens/Bottom_Menu/_setting.dart';
import 'package:azyx/Provider/theme_provider.dart';
import 'package:azyx/Screens/Favrouite/anime_favorite.dart';
import 'package:azyx/Screens/Favrouite/favrouite_page.dart';
import 'package:azyx/Screens/Favrouite/manga_favourite_page.dart';
import 'package:azyx/Screens/Favrouite/novel_favourite.dart';
import 'package:azyx/Screens/Novel/novel_detailspage.dart';
import 'package:azyx/Screens/Novel/novel_page.dart';
import 'package:azyx/Screens/Novel/novel_search.dart';
import 'package:azyx/Screens/Novel/reading_page.dart';
import 'package:azyx/StorageProvider.dart';
import 'package:azyx/api/EpisodeDetails/GetMediaIDs/GetMediaIDs.dart';
import 'package:azyx/auth/auth_provider.dart';
import 'package:azyx/Hive_Data/appDatabase.dart';
import 'package:azyx/Screens/Anime/watch_screen.dart';
import 'package:azyx/Screens/Manga/mangaDetails.dart';
import 'package:azyx/Screens/Manga/read.dart';
import 'package:azyx/Screens/Anime/searchAnime.dart';
import 'package:azyx/Screens/Manga/searchManga.dart';
import 'package:azyx/components/Common/check_platform.dart';
import 'package:azyx/components/Desktop/Manga/desktop_manga_detail.dart';
import 'package:azyx/components/Desktop/anime/desktop_details_page.dart';
import 'package:flutter/material.dart';
import 'package:azyx/Screens/Anime/details.dart';
import 'package:azyx/Screens/Home/_homepage.dart';
import 'package:azyx/Screens/Manga/mangaPage.dart';
import 'package:azyx/Screens/Anime/animePage.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' show ProviderScope;
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:ionicons/ionicons.dart';
import 'package:isar/isar.dart';
import 'package:media_kit/media_kit.dart';
import 'package:provider/provider.dart';

late Isar isar;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  MediaKit.ensureInitialized();
  await Hive.initFlutter();
  await StorageProvider().requestPermission();
  isar = await StorageProvider().initDB(null);
  await PrefManager.init();
  await Hive.openBox('app-data');
  await Hive.openBox('mybox');
  await dotenv.load(fileName: ".env");
  initializeDateFormatting();
  GetMediaIDs.getData();
  final supportedLocales = DateFormat.allLocalesWithSymbols();
  for (var locale in supportedLocales) {
    initializeDateFormatting(locale);
  }
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(systemNavigationBarColor: Colors.transparent));

  runApp(ProviderScope(
    child: MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => Data()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(
            create: (_) => AniListProvider()..tryAutoLogin()),
        ChangeNotifierProvider(
            create: (_) => SourcesProvider())
      ],
      child: const MainApp(),
    ),
  ));
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
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
            final title = args?['title'] ?? '';
            return MaterialPageRoute(
              builder: (context) => Details(id: id, image: image, tagg: tagg,title: title,),
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
                builder: (context) => PlatformWidget(
                    androidWidget:
                        Mangadetails(id: id, image: image, tagg: tagg),
                    windowsWidget:
                        DesktopMangaDetail(id: id, image: image, tagg: tagg)));

          case '/mangaFavorite':
            final id = args?['id'] ?? '';
            final image = args?['image'] ?? '';
            final tagg = args?['tagg'] ?? '';
            return MaterialPageRoute(
              builder: (context) =>
                  MangaFavouritePage(id: id, image: image, tagg: tagg),
            );

          case '/animeFavorite':
            final id = args?['id'] ?? '';
            final image = args?['image'] ?? '';
            final tagg = args?['tagg'] ?? '';
            return MaterialPageRoute(
              builder: (context) =>
                  AnimeFavouritePage(id: id, image: image, tagg: tagg),
            );

          case '/novelFavorite':
            final id = args?['id'] ?? "";
            final image = args?['image'] ?? '';
            final tagg = args?['tagg'] ?? "";
            return MaterialPageRoute(
                builder: (context) =>
                    NovelFavouritePage(id: id, image: image, tagg: tagg));

          // case '/read':
          //   final mangaId = args?['mangaId'] ?? '';
          //   final chapterLink = args?['chapterLink'] ?? '';
          //   final image = args?['image'] ?? '';
          //   return MaterialPageRoute(
          //     builder: (context) => Read(
          //       mangaId: mangaId,
          //       chapterLink: chapterLink,
          //       image: image,
          //     ),
          //   );

          case '/searchManga':
            final name = args?['name'] ?? '';
            return MaterialPageRoute(
              builder: (context) => SearchManga(name: name),
            );

          // Novel - Screens
          case '/novelDetail':
            final id = args?['id'] ?? '';
            final image = args?['image'] ?? '';
            final tagg = args?['tagg'] ?? '';
            return MaterialPageRoute(
                builder: (context) =>
                    Noveldetails(id: id, image: image, tagg: tagg));

          case '/novelRead':
            final novelId = args?['novelId'] ?? '';
            final chapterLink = args?['chapterLink'] ?? '';
            final image = args?['image'] ?? '';
            final title = args?['title'] ?? '';
            return MaterialPageRoute(
              builder: (context) => NovelRead(
                  novelId: novelId,
                  chapterLink: chapterLink,
                  image: image,
                  title: title),
            );

          case '/searchNovel':
            final name = args?['name'];
            return MaterialPageRoute(
                builder: (context) => NovelSearch(name: name));
          //Bottom-Menu-Screens
          case './profile':
            return MaterialPageRoute(builder: (context) => const Profile());
          case './settings':
            return MaterialPageRoute(builder: (context) => const Setting());

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
  bool isOpen = false;

  final List<Widget> _pages = [
    const HomePage(),
    // const FavrouitePage(),
    const Animepage(),
    const Mangapage(),
    const NovelPage()
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      // body: Row(
      //   children: [
      //     NavigationBar(
      //       onDestinationSelected: (int index) {
      //         setState(() {
      //           _selectedIndex = index;
      //         });
      //       },
      //       indicatorColor: Theme.of(context).colorScheme.secondaryContainer,
      //       selectedIndex: _selectedIndex,
      //       destinations: const <Widget>[
      //         NavigationDestination(
      //           selectedIcon: Icon(Icons.home),
      //           icon: Icon(Icons.home_outlined),
      //           label: 'Home',
      //         ),
      //                         NavigationDestination(
      //                           selectedIcon: Icon(Icons.favorite),
      //                           icon: Icon(Icons.favorite_border),
      //                           label: 'Favorites',
      //                         ),
      //                         NavigationDestination(
      //                           selectedIcon: Icon(Icons.movie_filter),
      //                           icon: Icon(Icons.movie_filter_outlined),
      //                           label: 'Anime',
      //                         ),
      //                         NavigationDestination(
      //                           selectedIcon: Icon(Ionicons.book),
      //                           icon: Icon(Ionicons.book_outline),
      //                           label: 'Manga',
      //                         ),
      //                         NavigationDestination(
      //                           selectedIcon: Icon(Icons.book),
      //                           icon: Icon(Icons.book_outlined),
      //                           label: 'Novel',
      //                         ),
      //       ],
      //     ),
      //     Expanded(child: _pages[_selectedIndex]),
      //   ],
      // ),
      body: Container(
        decoration: BoxDecoration(
              gradient: LinearGradient(colors: [
            Theme.of(context).colorScheme.surface,
            Theme.of(context).colorScheme.primary
          ], begin: Alignment.topLeft, end: Alignment.bottomRight)),
          child: _pages[_selectedIndex],
      ),
      bottomNavigationBar: NavigationBar(
        onDestinationSelected: (int index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        indicatorColor: Theme.of(context).colorScheme.secondaryContainer,
        selectedIndex: _selectedIndex,
        destinations: const <Widget>[
          NavigationDestination(
            selectedIcon: Icon(Icons.home),
            icon: Icon(Icons.home_outlined),
            label: 'Home',
          ),
          // NavigationDestination(
          //   selectedIcon: Icon(Icons.favorite),
          //   icon: Icon(Icons.favorite_border),
          //   label: 'Favorites',
          // ),
          NavigationDestination(
            selectedIcon: Icon(Icons.movie_filter),
            icon: Icon(Icons.movie_filter_outlined),
            label: 'Anime',
          ),
          NavigationDestination(
            selectedIcon: Icon(Ionicons.book),
            icon: Icon(Ionicons.book_outline),
            label: 'Manga',
          ),
          NavigationDestination(
            selectedIcon: Icon(Icons.book),
            icon: Icon(Icons.book_outlined),
            label: 'Novel',
          ),
        ],
      ),
    );
  }
}
