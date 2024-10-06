import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:iconsax/iconsax.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io'; // For File

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String? imagePath; // Nullable imagePath to handle when no image is selected

  // Method to pick an image
  Future _pickImage() async {
    try {
      final pickedImage = await ImagePicker().pickImage(source: ImageSource.gallery);

      if (pickedImage != null) {
        setState(() {
          imagePath = pickedImage.path;
        });
      } else {
        log('No image selected.');
      }
    } catch (e) {
      log('Error picking image: $e');
    }
  }

  // Method to store data using Hive
  void _storeUserData() {
    final box = Hive.box('mybox');
    box.put('userName', _usernameController.text);
    box.put('passWord', _passwordController.text);
    box.put('imagePath', imagePath);
    box.put('login', true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SizedBox(
          width: 300,
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: _pickImage,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(50),
                    child: imagePath != null
                        ? Image.file(
                            File(imagePath!),
                            height: 100,
                            width: 100,
                            fit: BoxFit.cover,
                          )
                        : Container(
                            height: 100,
                            width: 100,
                            decoration: BoxDecoration(
                                color: Theme.of(context)
                                    .colorScheme
                                    .surfaceContainerHighest,
                                borderRadius: BorderRadius.circular(20)),
                            child: Icon(Iconsax.image5, size: 50),
                          ),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  "Welcome bro!",
                  style: TextStyle(fontSize: 30),
                ),
                const SizedBox(height: 60),
                TextFormField(
                  controller: _usernameController,
                  inputFormatters: [
                    // Capitalize the first letter of the username
                    TextInputFormatter.withFunction((oldValue, newValue) {
                      if (newValue.text.isNotEmpty) {
                        return newValue.copyWith(
                          text: newValue.text[0].toUpperCase() + newValue.text.substring(1),
                        );
                      }
                      return newValue;
                    }),
                  ],
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.person),
                    hintText: 'Username',
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide.none,
                    ),
                    fillColor: Theme.of(context).colorScheme.surfaceContainer,
                    filled: true,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Username is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 40),
                SizedBox(
                  width: 300,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.inversePrimary,
                    ),
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        _storeUserData();
                        Navigator.pushNamed(context, '/homeScreen');
                      }
                    },
                    child: Text(
                      "LogIn",
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.inverseSurface,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
