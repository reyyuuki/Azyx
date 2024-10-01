import 'dart:io';

import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:iconsax/iconsax.dart';

class Header extends StatelessWidget {
  final String? name;
  const Header({super.key, this.name});

  @override
  Widget build(BuildContext context) {
    var box = Hive.box("mybox");

    return ValueListenableBuilder(
      valueListenable: box.listenable(),
      builder: (context, Box box, child) {
        String image = box.get("imagePath") ?? "";
        String _userName = box.get("userName") ?? "Guest";
        bool isImage = image.isNotEmpty;

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
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                  ),
                  Text(
                    "Enjoy unlimited ${name ?? 'content'}!",
                    style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                  ),
                ],
              ),
              GestureDetector(
                onTap: () {
                  _displayBottomSheet(context, box);
                },
                child: Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(50),
                    color: Theme.of(context).colorScheme.onPrimaryFixedVariant,
                  ),
                  child: isImage
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(25),
                          child: Image.file(
                            File(image),
                            fit: BoxFit.cover,
                          ),
                        )
                      : Icon(
                          Iconsax.user,
                          color: Colors.white,
                          size: 30,
                        ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _displayBottomSheet(BuildContext context, Box box) {
    return showModalBottomSheet(
      context: context,
      barrierColor: Colors.black87.withOpacity(0.5),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(40)),
      ),
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
                    box.get("userName") ?? "Guest",
                    style: const TextStyle(fontSize: 20),
                  ),
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(50),
                      color: Theme.of(context).colorScheme.onPrimaryFixedVariant,
                    ),
                    child: box.get("imagePath") != null && File(box.get("imagePath")!).existsSync()
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(25),
                            child: Image.file(
                              File(box.get("imagePath")!),
                              fit: BoxFit.cover,
                            ),
                          )
                        : Icon(
                            Iconsax.user,
                            color: Colors.white,
                            size: 30,
                          ),
                  ),
                ],
              ),
              GestureDetector(
                onTap: () {
                  Navigator.of(context).pop();
                  Future.delayed(const Duration(milliseconds: 200), () {
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
                      SizedBox(width: 20),
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
                  Future.delayed(const Duration(milliseconds: 200), () {
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
                      SizedBox(width: 20),
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
                  Future.delayed(const Duration(milliseconds: 200), () {
                    box.delete("userName");
                    box.delete("imagePath");
                    Navigator.pushNamed(context, '/login-page');
                  });
                },
                child: Container(
                  color: Colors.transparent,
                  width: MediaQuery.of(context).size.width,
                  height: 40,
                  child:  Row(
                    children: [
                      box.get("userName") != null ?
                      const Icon(
                        Iconsax.login,
                        size: 20,
                      ) : 
                      const Icon(
                        Iconsax.logout,
                        size: 20,
                      ),
                      const SizedBox(width: 20),
                      Text(
                        box.get("userName") != null ? "LogOut" : "LogIn",
                        style: const TextStyle(fontSize: 18),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
