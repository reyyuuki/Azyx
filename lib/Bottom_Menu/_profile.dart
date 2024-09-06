import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:image_picker/image_picker.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {

  var box = Hive.box('mybox');
    String imagePath = "";
  String userName = "";

  @override
  void initState() {
    super.initState();
    imagePath = box.get("imagePath") ?? "";
    userName = box.get("userName") ?? "";
  }

  Future<void> _pickImage() async {
    try {
      final pickedImage = await ImagePicker().pickImage(source: ImageSource.gallery);

      if (pickedImage != null) {
        setState(() {
          imagePath = pickedImage.path;
        });
        box.put("imagePath", imagePath);
      }
    } catch (e) {
      print('Error picking image: $e');
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: ListView(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                height: 300,
                width: MediaQuery.of(context).size.width,
                child: ImageFiltered(
                  imageFilter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Image.file(
                    File(imagePath),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Positioned(
                bottom: -20,
                left: 0,
                right: 0,
                child: Container(
                  height: 200,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.transparent,
                        Theme.of(context).colorScheme.surface,
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),
              ),
              Center(
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: _pickImage,
                      child: SizedBox(
                        width: 200,
                        height: 200,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(100),
                          child: Image.file(
                            File(imagePath),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10,),
                    Text(userName, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),)
                  ],
                ),
              )
            ],
          ),
        ],
      ),
    );
  }
}
