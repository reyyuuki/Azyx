import 'package:daizy_tv/Provider/theme_provider.dart';
import 'package:daizy_tv/Theme/themes.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Modes extends StatelessWidget {
  const Modes({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                  onPressed: () {
                    final themeProvider =
                        Provider.of<ThemeProvider>(context, listen: false);
                    themeProvider.setTheme(lightmode);
                    Navigator.pushNamed(context, '/login-page');
                  },
                  child: Text("Light Mode")),
              const SizedBox(
                height: 20,
              ),
              ElevatedButton(
                  onPressed: () {
                    final themeProvider =
                        Provider.of<ThemeProvider>(context, listen: false);
                    themeProvider.setTheme(lightmode);
                    Navigator.pushNamed(context, '/login-page');
                  },
                  child: Text("Dark Mode")),
            ],
          ),
        ),
      ),
    );
  }
}
