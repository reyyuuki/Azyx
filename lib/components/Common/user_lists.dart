import 'package:daizy_tv/auth/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
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
  

 if(provider.userData['name'] == null){
    return const SizedBox.shrink();
 }
    return Padding(
      padding: const EdgeInsets.only(left: 15),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "${provider.userData['name']}'s Lists",
                style: TextStyle(
                  fontSize: 18,
                  fontFamily: "Poppins-Bold",
                  foreground: Paint()
                    ..shader = LinearGradient(
                      colors: [
                        Theme.of(context).colorScheme.inverseSurface,
                        Theme.of(context).colorScheme.primary,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ).createShader(const Rect.fromLTWH(0, 0, 200, 70)),
                ),
              ),
              Icon(
                Iconsax.arrow_right_4,
                color: Theme.of(context).colorScheme.primary,
              ),
            ],
          ),
          const SizedBox(
            height: 10,
          ),
          ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, './animelist');
                
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
              ),
              child: SizedBox(
                width: 120,
                height: 45,
                child: Row(
                  children: [
                    Icon(
                      Icons.movie_filter,
                      color: Theme.of(context).colorScheme.inversePrimary,
                    ),
                    const SizedBox(
                      width: 5,
                    ),
                    Text(
                      "AnimeList",
                      style: TextStyle(
                          fontSize: 16,
                          fontFamily: "Poppins-Bold",
                          color: Theme.of(context).colorScheme.inversePrimary),
                    ),
                  ],
                ),
              )),
          const SizedBox(
            height: 10,
          ),
          ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, './mangalist');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
              ),
              child: SizedBox(
                width: 120,
                height: 45,
                child: Row(
                  children: [
                    Icon(
                      Icons.movie_filter,
                      color: Theme.of(context).colorScheme.inversePrimary,
                    ),
                    const SizedBox(
                      width: 5,
                    ),
                    Text(
                      "MangaList",
                      style: TextStyle(
                          fontSize: 16,
                          fontFamily: "Poppins-Bold",
                          color: Theme.of(context).colorScheme.inversePrimary),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}
