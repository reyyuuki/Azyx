import 'dart:convert';
import 'package:azyx/Widgets/AzyXWidgets/azyx_gradient_container.dart';
import 'package:azyx/Widgets/AzyXWidgets/azyx_snack_bar.dart';
import 'package:azyx/Widgets/AzyXWidgets/azyx_text.dart';
import 'package:azyx/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
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
    // checkUpdate();
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

  static Future<void> checkUpdate({bool showFeedback = false}) async {
    const url = "https://api.github.com/repos/reyyuuki/AzyX/releases/latest";
    try {
      if (showFeedback) {
        azyxSnackBar("Checking for updates...");
      }
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        String latestVersion = data['tag_name'].toString().replaceFirst(
          "v",
          "",
        );
        String changelog = data['body'] ?? '';
        String releaseTitle = data['name'] ?? '';
        PackageInfo packageInfo = await PackageInfo.fromPlatform();
        String currentVersion = packageInfo.version;
        Utils.log("$latestVersion == $currentVersion");
        if (latestVersion != currentVersion) {
          if (Get.context != null) {
            _showUpdateBottomSheet(Get.context!, changelog, releaseTitle);
          }
        } else {
          Utils.log("You are on latest update");
          if (showFeedback) {
            azyxSnackBar("You are on the latest version ($currentVersion)");
          }
        }
      } else {
        if (showFeedback) {
          azyxSnackBar("Failed to check for updates");
        }
      }
    } catch (e) {
      Utils.log("error when checking update: $e");
      if (showFeedback) {
        azyxSnackBar("Error checking for updates");
      }
    }
  }

  static Future<void> autoCheckUpdate(BuildContext? context) async {
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
          if (Get.context != null) {
            _showUpdateBottomSheet(Get.context!, changelog, releaseTitle);
          }
        }
      }
    } catch (e) {
      Utils.log("error when checking update: $e");
    }
  }

  static void _showUpdateBottomSheet(
    BuildContext context,
    String changelog,
    String name,
  ) {
    final colors = Theme.of(context).colorScheme;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.68,
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            border: Border.all(color: colors.outline.withOpacity(0.08)),
          ),
          child: ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            child: AzyXGradientContainer(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(
                      child: Container(
                        width: 36,
                        height: 4,
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: colors.outline.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: colors.primary.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.system_update_rounded,
                            color: colors.primary,
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const AzyXText(
                                text: 'App Update Available',
                                fontVariant: FontVariant.bold,
                                fontSize: 18,
                              ),
                              const SizedBox(height: 2),
                              AzyXText(
                                text: name.isNotEmpty
                                    ? name
                                    : 'New Version Released',
                                fontSize: 13,
                                fontVariant: FontVariant.bold,
                                color: colors.primary,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const AzyXText(
                      text: "WHAT'S NEW",
                      fontSize: 11,
                      fontVariant: FontVariant.bold,
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: colors.surfaceContainerHighest.withOpacity(
                            0.35,
                          ),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: colors.outline.withOpacity(0.08),
                          ),
                        ),
                        child: SingleChildScrollView(
                          physics: const BouncingScrollPhysics(),
                          child: MarkdownBody(
                            data: changelog.isNotEmpty
                                ? changelog
                                : 'A new update for AzyX is available with performance improvements and bug fixes.',
                            styleSheet: MarkdownStyleSheet(
                              p: TextStyle(
                                fontSize: 13,
                                color: colors.onSurfaceVariant,
                              ),
                              h1: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: colors.onSurface,
                              ),
                              h2: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: colors.onSurface,
                              ),
                              listBullet: TextStyle(color: colors.primary),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextButton(
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 13),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            onPressed: () => Navigator.pop(context),
                            child: AzyXText(
                              text: 'Later',
                              color: colors.onSurfaceVariant,
                              fontVariant: FontVariant.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 2,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: colors.primary,
                              foregroundColor: colors.onPrimary,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(vertical: 13),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            onPressed: () {
                              launchUrl(
                                Uri.parse(
                                  'https://github.com/reyyuuki/AzyX/releases/latest',
                                ),
                              );
                            },
                            child: const AzyXText(
                              text: 'Update Now',
                              fontVariant: FontVariant.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
