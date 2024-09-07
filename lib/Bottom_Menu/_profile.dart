import 'dart:io';
import 'dart:ui';

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:iconsax/iconsax.dart';
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
  final TextEditingController _nameController = TextEditingController(); // Controller for TextField

  @override
  void initState() {
    super.initState();
    imagePath = box.get("imagePath") ?? "";
    userName = box.get("userName") ?? "";
    _nameController.text = userName; // Initialize the TextField with current username
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

  Future<void> _showEditDialog() async {
    AwesomeDialog(
      context: context,
      headerAnimationLoop: false,
      animType: AnimType.bottomSlide,
      dialogBackgroundColor: Theme.of(context).colorScheme.surfaceContainer,
      dialogBorderRadius: BorderRadius.circular(20),
      customHeader:  Icon(
    Iconsax.user_edit, // Change to any icon you want
    size: 50,
    color: Theme.of(context).colorScheme.primary,
  ),
      title: 'Edit Username',
      btnOkIcon: Iconsax.user_edit,
      btnCancelIcon: Iconsax.close_circle,
      body: Column(
        children: [
          const Text('Enter your Username', style: TextStyle(fontSize: 16,fontWeight: FontWeight.w500),),
          const SizedBox(height: 20),
           Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: TextField(
              controller: _nameController,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                labelText: 'Username',
                prefixIcon: const Icon(Icons.person),
              ),
            ),
          ),
        ],
      ),
      btnOkOnPress: () {
        setState(() {
          userName = _nameController.text;
          box.put("userName", userName); // Update the username in Hive
        });
      },
      btnCancelOnPress: () {},
    ).show();
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
                  child: imagePath.isNotEmpty
                      ? Image.file(
                          File(imagePath),
                          fit: BoxFit.cover,
                        )
                      : Container(
                          color: Colors.grey, // Fallback color for when no image is available
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
                          child: imagePath.isNotEmpty
                              ? Image.file(
                                  File(imagePath),
                                  fit: BoxFit.cover,
                                )
                              : Container(
                                  color: Colors.grey, // Placeholder for the profile image
                                ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      userName.isNotEmpty ? userName : "No Name", // Fallback name
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
              )
            ],
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            child: Center(
              child: AnimatedButton(
                key: const ValueKey("editButton"), // Added key
                height: 50,
                width: 300,
                color: Theme.of(context).colorScheme.onSecondaryFixed,
                pressEvent: () {
                  _showEditDialog(); 
                },
                text:
                  "Edit name",
                ),
              ),
            ),
        ],
      ),
    );
  }
}
