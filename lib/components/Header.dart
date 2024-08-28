import 'dart:io';

import 'package:daizy_tv/dataBase/user.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

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
    _userDataBase?.loadData(); 
    setState(() {
      _userName =
          _userDataBase!.userName.isNotEmpty ? _userDataBase!.userName : "User";
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
                style: const TextStyle(fontSize: 20),
              ),
              Text(
                "Enjoy unlimited ${widget.name}!", // Display the username
                style: TextStyle(fontSize: 12, color: Colors.grey[500]),
              ),
            ],
          ),
          GestureDetector(
            onTap: () {
              _displayBottomSheet(context);
            },
            child: SizedBox(
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
          ),
        ],
      ),
    );
  }

  Future _displayBottomSheet(BuildContext context) {
    return showModalBottomSheet(
        context: context,
        barrierColor: Colors.black87.withOpacity(0.5),
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(40))),
        builder: (context) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: SizedBox(
                height: 200,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _userName,
                          style: const TextStyle(fontSize: 20),
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
                    GestureDetector(
                      onTap: () {
                        Navigator.of(context).pop();
                        Future.delayed(Duration(milliseconds: 200), () {
                          Navigator.pushNamed(context, './profile');
                        });
                      },
                      child: Container(
                        color: Colors.transparent,
                        width: MediaQuery.of(context).size.width,
                        height: 40,
                        child: const Row(
                          children: [
                            Icon(
                              Iconsax.user,
                              size: 20,
                            ),
                            const SizedBox(
                              width: 20,
                            ),
                            Text(
                              "Profile",
                              style: TextStyle(fontSize: 18),
                            ),
                          ],
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.of(context).pop();
                        Future.delayed(Duration(milliseconds: 200), () {
                          Navigator.pushNamed(context, './settings');
                        });
                      },
                      child: Container(
                        color: Colors.transparent,
                        height: 40,
                        width: MediaQuery.of(context).size.width,
                        child: const Row(
                          children: [
                            Icon(
                              Iconsax.setting,
                              size: 20,
                            ),
                            const SizedBox(
                              width: 20,
                            ),
                            Text(
                              "Setting",
                              style: TextStyle(fontSize: 18),
                            ),
                          ],
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.of(context).pop();
                        Future.delayed(Duration(milliseconds: 200), () {
                          _userDataBase?.deleteData();
                           Navigator.pushNamed(context, '/login-page');
                        });
                      },
                      child: Container(
                        color: Colors.transparent,
                        width: MediaQuery.of(context).size.width,
                        height: 40,
                        child: const Row(
                          children: [
                            Icon(
                              Iconsax.logout,
                              size: 20,
                            ),
                            const SizedBox(
                              width: 20,
                            ),
                            Text(
                              "LogOut",
                              style: TextStyle(fontSize: 18),
                            ),
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ));
  }
}
