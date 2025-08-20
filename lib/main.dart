// ignore_for_file: must_be_immutable, depend_on_referenced_packages
import 'package:azyx/Controllers/anilist_add_to_list_controller.dart';
import 'package:azyx/Controllers/anilist_auth.dart';
import 'package:azyx/Controllers/anilist_data_controller.dart';
import 'package:azyx/Controllers/services/mal_service.dart';
import 'package:azyx/Controllers/offline_controller.dart';
import 'package:azyx/Controllers/services/service_handler.dart';
import 'package:azyx/Controllers/settings_controller.dart';
import 'package:azyx/Controllers/source/source_controller.dart';
import 'package:azyx/Controllers/ui_setting_controller.dart';
import 'package:azyx/HiveClass/theme_data.dart';
import 'package:azyx/HiveClass/ui_setting_class.dart';
import 'package:azyx/Preferences/PrefManager.dart';
import 'package:azyx/Providers/theme_provider.dart';
import 'package:azyx/Screens/Anime/anime_screen.dart';
import 'package:azyx/Screens/Library/library_screen.dart';
import 'package:azyx/Screens/Home/home_screen.dart';
import 'package:azyx/Screens/Manga/manga_screen.dart';
import 'package:azyx/Screens/Novel/novel_screen.dart';
import 'package:azyx/storage_provider.dart';
import 'package:azyx/Widgets/common/custom_nav_bar.dart';
import 'package:azyx/Controllers/local_history_controller.dart';
import 'package:dartotsu_extension_bridge/dartotsu_extension_bridge.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' show ProviderScope;
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:isar/isar.dart';
import 'package:media_kit/media_kit.dart';
import 'package:provider/provider.dart';

class MyCustomScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
        PointerDeviceKind.trackpad,
        PointerDeviceKind.stylus
      };
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      systemNavigationBarColor: Colors.transparent,
      statusBarColor: Colors.transparent));
  MediaKit.ensureInitialized();
  await Hive.initFlutter();
  Hive.registerAdapter(ThemeClassAdapter());
  Hive.registerAdapter(UiSettingClassAdapter());
  await Hive.openBox('theme-data');
  await Hive.openBox('app-data');
  await Hive.openBox('ui-settings');
  await Hive.openBox("offline-data");

  await Hive.openBox("auth");
  await dotenv.load(fileName: ".env");
  await StorageProvider().requestPermission();
  await PrefManager.init();
  initializeDateFormatting();
  Get.put(AnilistService());
  Get.put(AnilistDataController());
  Get.put(OfflineController());
  Get.put(UiSettingController());
  Get.put(AnilistAddToListController());
  // Get.put(LocalHistoryController());
  Get.put(SettingsController());
  Get.put(MalService());
  Get.put(ServiceHandler());
  Get.put(SourceController());
  runApp(MultiProvider(
    providers: [ChangeNotifierProvider(create: (_) => ThemeProvider())],
    child: const ProviderScope(
      child: MainApp(),
    ),
  ));
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ThemeProvider>(context);
    return GetMaterialApp(
      scrollBehavior: MyCustomScrollBehavior(),
      debugShowCheckedModeBanner: false,
      theme: provider.themeData,
      home: HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  HomePage({super.key});

  final List<Widget> _screens = [
    const HomeScreen(),
    const LibraryScreen(),
    const AnimeScreen(),
    const MangaScreen(),
    const NovelScreen(),
  ];

  Rx<int> index = 2.obs;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        extendBody: true,
        body: Obx(() => _screens[index.value]),
        bottomNavigationBar: Obx(() => CustomNavBar(
              screens: _screens,
              index: index.value,
              onChanged: (newIndex) {
                index.value = newIndex;
              },
            )));
  }
}
