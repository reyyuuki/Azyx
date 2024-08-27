import 'dart:io';

import 'package:daizy_tv/dataBase/user.dart';
import 'package:flutter/material.dart';

class Header extends StatefulWidget {
  final String? name;
  const Header({super.key, this.name});

  @override
  _HeaderState createState() => _HeaderState();
}

class _HeaderState extends State<Header> {
  UserDataBase? _userDataBase;
  String _userName = "";
   // Default username

  @override
  void initState() {
    super.initState();
    _userDataBase = UserDataBase();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    _userDataBase?.loadData(); // Load data from Hive
    setState(() {
      _userName = _userDataBase!.userName.isNotEmpty ? _userDataBase!.userName : "User";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
               Text(
                _userName,
                style: const TextStyle(fontSize: 20, fontFamily: 'Poppins'),
              ),
              Text(
                "Enjoy unlimited ${widget.name}!", // Display the username
                style: TextStyle(fontSize: 12, color: Colors.grey[500]),
              ),
            ],
          ),
          SizedBox(
            width: 50,
            height: 50,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(50),
              child: Image.file(
                File(_userDataBase!.imagePath),
                fit: BoxFit.cover,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
