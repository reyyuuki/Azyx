

import 'package:daizy_tv/Theme/themes.dart';
import 'package:daizy_tv/pages/details.dart';
import 'package:daizy_tv/pages/stream.dart';
import 'package:daizy_tv/pages/homepage.dart';
import 'package:flutter/material.dart';


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
              case '/detailspage':
                final id = args?['id'] ?? '';
                final image = args?['poster'] ?? '';
                return MaterialPageRoute(
                  builder: (context) => Details(id: id, url: image),
                );
              case '/stream':
                final id = args?['id'] ?? '';
                return MaterialPageRoute(
                  builder: (context) => Stream(id: id),
                );
              default:
                // Optionally, you can return a default page or an error page here
                return MaterialPageRoute(
                  builder: (context) => const Scaffold(
                    body: Center(child: Text('Page not found')),
                  ),
                );
            }
          },
          home: Homepage(),
  );
}

 
}
