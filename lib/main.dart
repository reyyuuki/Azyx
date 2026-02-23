// ignore_for_file: must_be_immutable, depend_on_referenced_packages
import 'dart:async';
import 'dart:io';

import 'package:app_links/app_links.dart';
import 'package:azyx/Controllers/anilist_add_to_list_controller.dart';
import 'package:azyx/Controllers/anilist_auth.dart';
import 'package:azyx/Controllers/anilist_data_controller.dart';
import 'package:azyx/Controllers/offline_controller.dart';
import 'package:azyx/Controllers/services/mal_service.dart';
import 'package:azyx/Controllers/services/service_handler.dart';
import 'package:azyx/Controllers/services/simkl_service.dart';
import 'package:azyx/Controllers/settings_controller.dart';
import 'package:azyx/Controllers/source/source_controller.dart';
import 'package:azyx/Controllers/ui_setting_controller.dart';
import 'package:azyx/HiveClass/theme_data.dart';
import 'package:azyx/HiveClass/ui_setting_class.dart';
import 'package:azyx/Providers/theme_provider.dart';
import 'package:azyx/Screens/Anime/anime_screen.dart';
import 'package:azyx/Screens/Home/home_screen.dart';
import 'package:azyx/Screens/Library/library_screen.dart';
import 'package:azyx/Screens/Manga/manga_screen.dart';
import 'package:azyx/Widgets/AzyXWidgets/azyx_snack_bar.dart';
import 'package:azyx/Widgets/common/custom_nav_bar.dart';
import 'package:azyx/utils/deeplink.dart';
import 'package:azyx/utils/update_notifier.dart';
import 'package:azyx/utils/utils.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:media_kit/media_kit.dart';
import 'package:provider/provider.dart';

class MyCustomScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
    PointerDeviceKind.touch,
    PointerDeviceKind.mouse,
    PointerDeviceKind.trackpad,
    PointerDeviceKind.stylus,
  };
}

void main(List<String> args) async {
  runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
      SystemChrome.setSystemUIOverlayStyle(
        const SystemUiOverlayStyle(
          systemNavigationBarColor: Colors.transparent,
          statusBarColor: Colors.transparent,
        ),
      );
      deepLink();
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
      initializeDateFormatting();
      Get.put(UpdateNotifier());
      Get.put(AnilistService());
      Get.put(MalService());
      Get.put(SimklService());
      Get.put(ServiceHandler());
      Get.put(AnilistDataController());
      Get.put(OfflineController());
      Get.put(UiSettingController());
      Get.put(AnilistAddToListController());
      Get.put(SettingsController());
      Get.put(SourceController());
      runApp(
        MultiProvider(
          providers: [ChangeNotifierProvider(create: (_) => ThemeProvider())],
          child: const MainApp(),
        ),
      );

      if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
        doWhenWindowReady(() {
          final win = appWindow;
          const initialSize = Size(1280, 720);
          const minSize = Size(320, 568);
          win.minSize = minSize;
          win.size = initialSize;
          win.alignment = Alignment.center;
          win.title = "AzyX";
          win.show();
        });
      }
    },
    (error, stack) {
      Utils.log("Unhandled error: $error");
    },
  );
}

void deepLink() async {
  final appLink = AppLinks();
  try {
    final initLink = await appLink.getInitialLink();
    if (initLink != null) Deeplink.useDeepLink(initLink);
  } catch (e) {
    azyxSnackBar('Error while getting link: $e');
  }
  appLink.uriLinkStream.listen(
    (uri) => Deeplink.useDeepLink(uri),
    onError: (err) => azyxSnackBar('Error Opening link: $err'),
  );
}

Rx<int> index = 2.obs;

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  bool get isDesktop =>
      Platform.isWindows || Platform.isLinux || Platform.isMacOS;

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ThemeProvider>(context);
    return GetMaterialApp(
      scrollBehavior: MyCustomScrollBehavior(),
      debugShowCheckedModeBanner: false,
      theme: provider.themeData,
      home: HomePage(),
      builder: (context, child) {
        if (isDesktop) {
          return Scaffold(
            body: WindowBorder(
              color: Theme.of(context).colorScheme.surface,
              child: Column(
                children: [
                  const CustomTitleBar(),
                  Expanded(child: child!),
                ],
              ),
            ),
          );
        }
        return child!;
      },
    );
  }
}

class CustomTitleBar extends StatefulWidget {
  const CustomTitleBar({super.key});

  @override
  State<CustomTitleBar> createState() => _CustomTitleBarState();
}

class _CustomTitleBarState extends State<CustomTitleBar> {
  void _maximizeOrRestore() {
    setState(() {
      appWindow.maximizeOrRestore();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final bgColor = theme.scaffoldBackgroundColor;
    final iconColor = theme.iconTheme.color ?? Colors.white;

    return Container(
      height: 32,
      color: bgColor,
      child: Row(
        children: [
          Expanded(
            child: MoveWindow(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: Image.asset(
                        'assets/images/icon.jpg',
                        width: 16,
                        height: 16,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'AzyX',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: iconColor.withOpacity(0.85),
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          _TitleBarButton(
            icon: Icons.remove,
            iconColor: iconColor,
            hoverColor: isDark
                ? Colors.white.withOpacity(0.1)
                : Colors.black.withOpacity(0.07),
            onPressed: () => appWindow.minimize(),
          ),
          _TitleBarButton(
            icon: appWindow.isMaximized
                ? Icons.filter_none_rounded
                : Icons.crop_square_rounded,
            iconColor: iconColor,
            iconSize: appWindow.isMaximized ? 13 : 15,
            hoverColor: isDark
                ? Colors.white.withOpacity(0.1)
                : Colors.black.withOpacity(0.07),
            onPressed: _maximizeOrRestore,
          ),
          _TitleBarButton(
            icon: Icons.close,
            iconColor: iconColor,

            hoverColor: const Color(0xFFE81123),
            hoverIconColor: Colors.white,
            onPressed: () => appWindow.close(),
          ),
        ],
      ),
    );
  }
}

class _TitleBarButton extends StatefulWidget {
  final IconData icon;
  final Color iconColor;
  final Color hoverColor;
  final Color? hoverIconColor;
  final VoidCallback onPressed;
  final double iconSize;

  const _TitleBarButton({
    required this.icon,
    required this.iconColor,
    required this.hoverColor,
    required this.onPressed,
    this.hoverIconColor,
    this.iconSize = 15,
  });

  @override
  State<_TitleBarButton> createState() => _TitleBarButtonState();
}

class _TitleBarButtonState extends State<_TitleBarButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onPressed,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 100),
          width: 46,
          height: 32,
          color: _hovered ? widget.hoverColor : Colors.transparent,
          child: Icon(
            widget.icon,
            size: widget.iconSize,
            color: _hovered
                ? (widget.hoverIconColor ?? widget.iconColor)
                : widget.iconColor,
          ),
        ),
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
  }

  final List<Widget> _screens = [
    const HomeScreen(),
    const LibraryScreen(),
    const AnimeScreen(),
    const MangaScreen(),
  ];

  bool get isDesktop =>
      Platform.isWindows || Platform.isLinux || Platform.isMacOS;

  @override
  Widget build(BuildContext context) {
    if (!isDesktop) {
      return Scaffold(
        extendBody: true,
        body: Obx(() => _screens[index.value]),
        bottomNavigationBar: Obx(
          () => CustomNavBar(
            screens: _screens,
            index: index.value,
            onChanged: (newIndex) {
              index.value = newIndex;
            },
          ),
        ),
      );
    }

    return Scaffold(
      extendBody: true,
      body: Obx(() => _screens[index.value]),
      bottomNavigationBar: Obx(
        () => CustomNavBar(
          screens: _screens,
          index: index.value,
          onChanged: (newIndex) {
            index.value = newIndex;
          },
        ),
      ),
    );
  }
}

class WindowButtons extends StatefulWidget {
  const WindowButtons({super.key});

  @override
  State<WindowButtons> createState() => _WindowButtonsState();
}

class _WindowButtonsState extends State<WindowButtons> {
  void maximizeOrRestore() {
    setState(() {
      appWindow.maximizeOrRestore();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final buttonColors = WindowButtonColors(
      iconNormal: Theme.of(context).iconTheme.color,
      mouseOver: isDark
          ? Colors.white.withOpacity(0.1)
          : Colors.black.withOpacity(0.05),
      mouseDown: isDark
          ? Colors.white.withOpacity(0.2)
          : Colors.black.withOpacity(0.1),
      iconMouseOver: Theme.of(context).iconTheme.color,
      iconMouseDown: Theme.of(context).iconTheme.color,
    );

    final closeButtonColors = WindowButtonColors(
      mouseOver: const Color(0xFFD32F2F),
      mouseDown: const Color(0xFFB71C1C),
      iconNormal: Theme.of(context).iconTheme.color,
      iconMouseOver: Colors.white,
      iconMouseDown: Colors.white,
    );

    return Row(
      children: [
        MinimizeWindowButton(colors: buttonColors),
        appWindow.isMaximized
            ? RestoreWindowButton(
                colors: buttonColors,
                onPressed: maximizeOrRestore,
              )
            : MaximizeWindowButton(
                colors: buttonColors,
                onPressed: maximizeOrRestore,
              ),
        CloseWindowButton(colors: closeButtonColors),
      ],
    );
  }
}
