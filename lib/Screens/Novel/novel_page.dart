import 'dart:developer';

import 'package:daizy_tv/components/Common/Header.dart';
import 'package:daizy_tv/components/Novel/novel_carousale.dart';
import 'package:daizy_tv/components/Novel/reusable_list.dart';
import 'package:daizy_tv/utils/scraper/Novel/wuxia_novel.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

class NovelPage extends StatefulWidget {
  const NovelPage({super.key});

  @override
  State<NovelPage> createState() => _NovelPageState();
}


class _NovelPageState extends State<NovelPage> {

  @override
  void initState() {
    super.initState();
    loadData();
  }

List<Map<String, dynamic>>? data;
  Future<void> loadData() async{
    try{
      final response = await scrapeHomePageData();
  if(response != null){
    setState(() {
      data = response;
    });
  }
    }catch(e){
      log(e.toString());
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        children: [
         const Header(),
         const SizedBox(height: 10,),
         Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: SizedBox(
                    height: 50,
                    child: TextField(
                      onSubmitted: (String value) {
                        Navigator.pushNamed(
                          context,
                          '/searchAnime',
                          arguments: {"name": value},
                        );
                      },
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Iconsax.search_normal),
                        hintText: 'Search Anime...',
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: BorderSide(
                              color: Theme.of(context).colorScheme.primary),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: BorderSide.none,
                        ),
                        fillColor:
                            Theme.of(context).colorScheme.surfaceContainer,
                        filled: true,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 30.0),
               NovelCarousale(route: '/detailsPage', animeData: data,),
               const SizedBox(height: 20,),
               NovelList(name: "Popular Novel", taggName: "Popular", route: '', data: data?.sublist(0,10),),
                const SizedBox(height: 20,),
               NovelList(name: "Trending Novel", taggName: "Popular", route: '', data: data?.sublist(10,20),),
                const SizedBox(height: 20,),
               NovelList(name: "Latest Novel", taggName: "Popular", route: '', data: data?.sublist(20,30),)
        ],
      ),
    );
  }
}