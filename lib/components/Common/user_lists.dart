import 'package:daizy_tv/Screens/Lists/animelist.dart';
import 'package:daizy_tv/Screens/Lists/mangalist.dart';
import 'package:daizy_tv/auth/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:provider/provider.dart';

class UserLists extends StatefulWidget {
  const UserLists({super.key});

  @override
  State<UserLists> createState() => _UserListsState();
}

class _UserListsState extends State<UserLists> {
  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AniListProvider>(context, listen: false);

    if (provider.userData['name'] == null) {
      return const SizedBox.shrink();
    }
    return Padding(
      padding: const EdgeInsets.only(left: 15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const Animelist(),
                    ));
                provider.fetchUserAnimeList();
              },
              style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context)
                      .colorScheme
                      .secondaryContainer
                      .withOpacity(0.6),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10))),
              child: SizedBox(
                width: 90,
                height: 65,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.movie_filter,
                      size: 26,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    Text(
                      "AnimeList",
                      style: TextStyle(
                          fontSize: 16,
                          fontFamily: "Poppins-Bold",
                          color: Theme.of(context).colorScheme.primary),
                    ),
                  ],
                ),
              )),
          const SizedBox(
            width: 15,
          ),
          ElevatedButton(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const Mangalist(),
                    ));
                provider.fetchUserMangaList();
              },
              style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context)
                      .colorScheme
                      .secondaryContainer
                      .withOpacity(0.6),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10))),
              child: SizedBox(
                width: 90,
                height: 65,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Ionicons.book,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    Text(
                      "MangaList",
                      style: TextStyle(
                          fontSize: 16,
                          fontFamily: "Poppins-Bold",
                          color: Theme.of(context).colorScheme.primary),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}
