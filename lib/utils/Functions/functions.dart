import 'package:dartotsu_extension_bridge/ExtensionManager.dart';

String getExtensionIcon(ExtensionType extensionType) {
  switch (extensionType) {
    case ExtensionType.mangayomi:
      return 'https://raw.githubusercontent.com/kodjodevf/mangayomi/main/assets/app_icons/icon-red.png';
    case ExtensionType.aniyomi:
      return 'https://raw.githubusercontent.com/aniyomiorg/aniyomi/main/.github/assets/logo.png';
  }
}
