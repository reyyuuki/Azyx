import 'package:cached_network_image/cached_network_image.dart';
import 'package:daizy_tv/components/Header.dart';
import 'package:daizy_tv/components/Recently-added/animeCarousale.dart';
import 'package:daizy_tv/components/Recently-added/mangaCarousale.dart';
import 'package:daizy_tv/dataBase/appDatabase.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<Data>(context);
    var box = Hive.box("app-data");
    final List<dynamic>? animeWatches = box.get("currently-Watching");
    final List<dynamic>? readsmanga = box.get("currently-Reading");
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListView(
          children: [
            Header(),
            SizedBox(height: 20,),
            Animecarousale(carosaleData: animeWatches),
            SizedBox(height: 20,),
            Mangacarousale(carosaleData: readsmanga)
          ],
        ),
      ),
    );
  }
}