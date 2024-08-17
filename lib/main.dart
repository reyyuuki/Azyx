

import 'package:daizy_tv/Theme/themes.dart';
import 'package:daizy_tv/pages/details.dart';
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
    home: Homepage(),
    initialRoute: '/homepage',
    
    routes: {
      '/homepage' : (context) => const Homepage(),
      '/detailspage': (context) {
           final id = ModalRoute.of(context)?.settings.arguments as String?;
          return Details(id: id ?? 'defaultId');
        },
    },
  );
}

 
}
