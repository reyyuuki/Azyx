// ignore_for_file: depend_on_referenced_packages

import 'dart:convert';
import 'package:azyx/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:get/get_navigation/get_navigation.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:get/utils.dart';
import "package:http/http.dart" as http;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';

class UpdateNotifier extends GetxController {
  @override
  void onInit() {
    super.onInit();
    checkUpdate();
  }

  String fileName = '';
  String downloadLink = '';

  static Future<void> downloadFile() async {
    if (await Permission.storage.request().isGranted) {
      final directory = await getExternalStorageDirectory();
      Utils.log('permission success: ${directory.toString()}');
    } else {
      Utils.log('no permission');
    }
  }

  static Future<void> checkUpdate() async {
    const url = "https://api.github.com/repos/reyyuuki/AzyX/releases/latest";
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        String latestVersion = data['tag_name'].toString().replaceFirst(
          "v",
          "",
        );
        String changelog = data['body'];
        String releaseTitle = data['name'];

        PackageInfo packageInfo = await PackageInfo.fromPlatform();
        String currentVersion = packageInfo.version;
        Utils.log("$latestVersion == $currentVersion");
        if (latestVersion != currentVersion) {
          _showUpdateBottomSheet(Get.context!, changelog, releaseTitle);
        } else {
          Utils.log("You are on latest update");
        }
      }
    } catch (e) {
      Utils.log("error when checking update: $e");
    }
  }

  static Future<void> autoCheckUpdate(context) async {
    const url = "https://api.github.com/repos/reyyuuki/AzyX/releases/latest";
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        String latestVersion = data['tag_name'].toString().replaceFirst(
          "v",
          "",
        );
        String changelog = data['body'];
        String releaseTitle = data['name'];

        PackageInfo packageInfo = await PackageInfo.fromPlatform();
        String currentVersion = packageInfo.version;
        Utils.log("$latestVersion == $currentVersion");
        if (latestVersion != currentVersion) {
          _showUpdateBottomSheet(context, changelog, releaseTitle);
        }
      }
    } catch (e) {
      Utils.log("error when checking update: $e");
    }
  }

  static Map<String, List<String>> _parseChangelog(String changelog) {
    Map<String, List<String>> parsedChanges = {};
    List<String> sections = changelog.split(
      RegExp(r'(?<=\r\n)\*\*[^*]+(?=\*\*)'),
    );

    for (var section in sections) {
      if (section.trim().isEmpty) continue;

      List<String> lines = section
          .split('\r\n')
          .where((line) => line.isNotEmpty)
          .toList();
      String header = lines.first.trim();

      List<String> body = lines
          .sublist(1)
          .map(
            (line) => line
                .replaceAll(RegExp(r'https?:\/\/\S+'), '')
                .replaceAll(RegExp(r'[#*`\[\]]'), '')
                .trim(),
          )
          .where((line) => line.isNotEmpty)
          .toList();

      parsedChanges[header] = body;
    }

    return parsedChanges;
  }

  static void _showUpdateBottomSheet(
    BuildContext context,
    String changelog,
    String name,
  ) {
    Map<String, List<String>> parsedChanges = _parseChangelog(changelog);
    List<String> headers = parsedChanges.keys.toList();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.5,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 10,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Column(
            children: [
              const Text(
                'Update Available',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  fontFamily: "Poppins-Bold",
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Text(
                name,
                style: const TextStyle(fontFamily: 'Poppins-SemiBold'),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: headers.map((header) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 10),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.circle,
                                  size: 10,
                                  color: Theme.of(context).primaryColor,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  header
                                      .replaceAll('**', '')
                                      .replaceAll('#', ''),
                                  style: const TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 10),
                              ],
                            ),
                          ),
                          SizedBox(
                            height: 200,
                            child: ListView.builder(
                              physics: const BouncingScrollPhysics(),
                              itemCount: parsedChanges[header]?.length ?? 0,
                              itemBuilder: (context, index) {
                                final change = parsedChanges[header]![index];
                                return Padding(
                                  padding: const EdgeInsets.only(
                                    left: 20,
                                    top: 5,
                                  ),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Padding(
                                        padding: EdgeInsets.only(
                                          top: 5,
                                          right: 8,
                                        ),
                                        child: Icon(
                                          Icons.circle,
                                          size: 6,
                                          color: Colors.grey,
                                        ),
                                      ),
                                      Expanded(
                                        child: Text(
                                          change.split(':').last,
                                          style: const TextStyle(fontSize: 14),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              const Divider(thickness: 1),
              const SizedBox(height: 15),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        backgroundColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                          side: BorderSide(
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        launchUrl(
                          Uri.parse(
                            'https://github.com/reyyuuki/AzyX/releases/latest',
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor: Colors.black,
                      ),
                      child: const Text('Update'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
