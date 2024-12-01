import 'dart:developer';

import 'package:azyx/components/Common/slider.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:iconsax/iconsax.dart';

class DownloadSettings extends StatefulWidget {
  const DownloadSettings({super.key});

  @override
  State<DownloadSettings> createState() => _DownloadSettingsState();
}

class _DownloadSettingsState extends State<DownloadSettings> {
  var box = Hive.box('app-data');
  late int parallelDownloads;
  late int retries;

  @override
  void initState() {
    super.initState();
    parallelDownloads = box.get("parallelDownloads", defaultValue: 50);
    retries = box.get("downloadRetries", defaultValue: 20);
  }

  @override
  Widget build(BuildContext context) {
    log(parallelDownloads.toString());
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: ListView(
        padding: const EdgeInsets.all(8),
        children: [
          IconButton(
              alignment: Alignment.topLeft,
              hoverColor: Colors.transparent,
              highlightColor: Colors.transparent,
              iconSize: 30,
              onPressed: () {
                Navigator.pop(context);
              },
              icon: const Icon(Icons.arrow_back_ios)),
          const SizedBox(
            height: 40,
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 10),
            child: Text(
              "Download settings",
              style: TextStyle(fontFamily: "Poppins-Bold", fontSize: 30),
            ),
          ),
          const SizedBox(
            height: 30,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Download - Speed",
                  style: TextStyle(
                      fontFamily: "Poppins-Bold",
                      fontSize: 18,
                      color: Theme.of(context).colorScheme.primary),
                ),
                Icon(
                  Icons.speed,
                  size: 30,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ],
            ),
          ),
          const SizedBox(
            height: 8,
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
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
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Retries",
                  style: TextStyle(
                      fontFamily: "Poppins-Bold",
                      fontSize: 18,
                      color: Theme.of(context).colorScheme.primary),
                ),
                Icon(
                  Iconsax.document_download,
                  size: 30,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Icon(Icons.downloading),
                
                Expanded(
                  child: CustomSlider(
                      onChanged: (double value) {
                        setState(() {
                          retries = value.toInt();
                          box.put("downloadRetries", retries);
                        });
                      },
                      divisions: 10,
                      max: 100,
                      min: 10,
                      value: retries.toDouble()),
                ),
                
                Text(
                  retries.toString(),
                  style: const TextStyle(
                      fontFamily: "Poppins-Bold", fontSize: 16),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
