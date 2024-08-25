import 'package:daizy_tv/Theme/themes.dart';
import 'package:flutter/material.dart';

class ThemeProvider with ChangeNotifier {
  ThemeData _themeData = darkmode;

  ThemeData get themeData => _themeData;
  set themeData(ThemeData themeData){
    _themeData = themeData;
    notifyListeners();
  }

  void toggleTheme(){
    if(_themeData == lightmode){
      themeData = darkmode;
    }
    else{
      themeData = lightmode;
    }
  }
}