import 'dart:math';

import 'package:hive_flutter/hive_flutter.dart';

class UserDataBase {
  String userName = '';
  String passWord = '';
  String imagePath = '';
  bool login = true;

  // reference to the Hive box
  final _mybox = Hive.box('mybox');

  // Method to store data
  void storeData() {
    _mybox.put('userName', userName);
    _mybox.put('passWord', passWord);
    _mybox.put('imagePath', imagePath);
    _mybox.put('login', login);
  }

  // Method to retrieve data
  void loadData() {
    userName = _mybox.get('userName', defaultValue: '');
    passWord = _mybox.get('passWord', defaultValue: '');
    imagePath = _mybox.get('imagePath', defaultValue: '');
    login = _mybox.get('login', defaultValue: true);

    // Assign a default name if the userName is empty
    if (userName.isEmpty) {
      userName = 'User${Random().nextInt(1000)}'; 
      storeData(); 
    }
  }

  // Method to delete data
  void deleteData() {
    _mybox.delete('userName');
    _mybox.delete('passWord');
    _mybox.delete('imagePath');
  }
}
