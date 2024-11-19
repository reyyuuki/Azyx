import 'dart:developer';

import 'package:daizy_tv/components/Common/slider.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class DownloadSettings extends StatefulWidget {
  const DownloadSettings({super.key});

  @override
  State<DownloadSettings> createState() => _DownloadSettingsState();
}

class _DownloadSettingsState extends State<DownloadSettings> {
  var box = Hive.box('app-data');
  late int parallelDownloads;

  @override
  void initState() {
    super.initState();
    parallelDownloads = box.get("parallelDownloads", defaultValue: 50);
  }

  @override
  Widget build(BuildContext context) {
    log(parallelDownloads.toString());
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Text(
          "Download Settings",
          style: TextStyle(fontFamily: "Poppins-Bold"),
        ),
        leading:  IconButton(
          onPressed: (){
            Navigator.pop(context);
          },
         icon: Icon(Icons.arrow_back_ios)),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListView(
          children: [
            const SizedBox(
              height: 40,
            ),
            Row(
              children: [
                Icon(
                  Icons.speed,
                  size: 30,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(
                  width: 10,
                ),
                Text(
                  "Download - Speed",
                  style: TextStyle(
                      fontFamily: "Poppins-Bold",
                      fontSize: 18,
                      color: Theme.of(context).colorScheme.primary),
                )
              ],
            ),
            const SizedBox(
              height: 20,
            ),
            Column(
              children: [
                CustomSlider(
                    onChanged: (double value) {
                      setState(() {
                        parallelDownloads = value.toInt();
                        box.put("parallelDownloads", parallelDownloads);
                      });
                    },
                    max: 100,
                    min: 50,
                    divisions: 2,
                    value: parallelDownloads.toDouble()),
                const SizedBox(
                  height: 10,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Normal",
                      style: TextStyle(
                          color: parallelDownloads <= 50
                              ? Theme.of(context).colorScheme.primary
                              : Theme.of(context).colorScheme.inverseSurface,
                          fontFamily: "Poppins-Bold",
                          fontSize: 16),
                    ),
                    Text(
                      "Ultra",
                      style: TextStyle(
                          color: parallelDownloads > 60 &&
                                  parallelDownloads <= 75
                              ? Theme.of(context).colorScheme.primary
                              : Theme.of(context).colorScheme.inverseSurface,
                          fontFamily: "Poppins-Bold",
                          fontSize: 16),
                    ),
                    Text(
                      "Extreme",
                      style: TextStyle(
                          color: parallelDownloads > 75
                              ? Theme.of(context).colorScheme.primary
                              : Theme.of(context).colorScheme.inverseSurface,
                          fontFamily: "Poppins-Bold",
                          fontSize: 16),
                    ),
                  ],
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
