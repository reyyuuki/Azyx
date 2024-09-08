import 'dart:io';
import 'dart:ui';

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:daizy_tv/components/Recently-added/animeCarousale.dart';
import 'package:daizy_tv/components/Recently-added/mangaCarousale.dart';
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
  var appData = Hive.box("app-data");
  String imagePath = "";
  String userName = "";
   List<dynamic>? animeWatches;
   List<dynamic>? mangaReads;
  
  final TextEditingController _nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    imagePath = box.get("imagePath") ?? "";
    userName = box.get("userName") ?? "";
    animeWatches = appData.get("currently-Watching");
    mangaReads = appData.get("currently-Reading");
    _nameController.text = userName; 
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
    Iconsax.user_edit,
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
          box.put("userName", userName);
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
                          color: Colors.transparent,
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
                                color: Theme.of(context).colorScheme.onSecondaryFixed,
                                child: Icon(Iconsax.user, size: 80,))
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      userName.isNotEmpty ? userName : "Guest", // Fallback name
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
            const SizedBox(height:10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: Center(
                child: Container(
                  width: 200,
                  height: 60,
                  decoration: BoxDecoration(color: Theme.of(context).colorScheme.onSecondaryFixed, borderRadius: BorderRadius.circular(20)),
                  child:  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          children: [
                            const Text("Anime", style: TextStyle(fontWeight: FontWeight.bold),),
                            Text(animeWatches != null ? animeWatches!.length.toString() : "0", style: const TextStyle(fontWeight: FontWeight.bold)),
                          ],
                        ),
                        Column(
                          children: [
                            const Text("Manga", style: TextStyle(fontWeight: FontWeight.bold)),
                            Text(mangaReads != null ?  mangaReads!.length.toString() : "0", style: const TextStyle(fontWeight: FontWeight.bold)),
                          ],
                        )
                    ],),
                  ),
                ),
              ),
            ),
            const SizedBox(height:10),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 15),
              child: Text("Stats", style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),),
            ),
            const SizedBox(height:10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: Container(
                height: 230,
                decoration: BoxDecoration(color: Theme.of(context).colorScheme.onSecondaryFixed,
                borderRadius: BorderRadius.circular(20)
                ),
                child: const Padding(
                  padding: EdgeInsets.all(20.0),
                  child: Row(
                    mainAxisAlignment:MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Episodes Watched",style: TextStyle(fontSize: 16),),
                          SizedBox(height: 10,),
                          Text("Days Watched",style: TextStyle(fontSize: 16),),
                          SizedBox(height: 10,),
                          Text("Anime Mean Score",style: TextStyle(fontSize: 16),),
                          SizedBox(height: 10,),
                          Text("Chapters Read",style: TextStyle(fontSize: 16),),
                          SizedBox(height: 10,),
                          Text("Volume Read",style: TextStyle(fontSize: 16),),
                          SizedBox(height: 10,),
                          Text("Mnaga Mean Score",style: TextStyle(fontSize: 16),),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("0",style: TextStyle(fontSize: 16),),
                          SizedBox(height: 10,),
                          Text("0",style: TextStyle(fontSize: 16),),
                          SizedBox(height: 10,),
                          Text("0",style: TextStyle(fontSize: 16),),
                          SizedBox(height: 10,),
                          Text("0",style: TextStyle(fontSize: 16),),
                          SizedBox(height: 10,),
                          Text("0",style: TextStyle(fontSize: 16),),
                          SizedBox(height: 10,),
                          Text("0",style: TextStyle(fontSize: 16),),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
             const SizedBox(height: 20,),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Animecarousale(carosaleData: animeWatches),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Mangacarousale(carosaleData: mangaReads),
            )
        ],
      ),
    );
  }
}
