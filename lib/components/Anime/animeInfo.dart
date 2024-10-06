import 'package:flutter/material.dart';

class AnimeInfo extends StatelessWidget {
final dynamic animeData;

   const AnimeInfo({super.key,this.animeData});

  @override
  Widget build(BuildContext context) {
    if (animeData == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          const SizedBox(
            width: 100,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Aired: ",style: TextStyle( fontFamily: "Poppins-Bold")),
                SizedBox(
                  height: 5,
                ),
                Text("Premiered: ",style: TextStyle( fontFamily: "Poppins-Bold")),
                SizedBox(
                  height: 5,
                ),
                Text("Duration: ",style: TextStyle( fontFamily: "Poppins-Bold")),
                SizedBox(
                  height: 5,
                ),
                Text("Status: ",style: TextStyle( fontFamily: "Poppins-Bold")),
                SizedBox(
                  height: 5,
                ),
                Text("Rating: ",style: TextStyle( fontFamily: "Poppins-Bold")),
                SizedBox(
                  height: 5,
                ),
                Text("Quality: ",style: TextStyle( fontFamily: "Poppins-Bold")),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(animeData['aired'] ?? "??",style: TextStyle( fontFamily: "Poppins-Bold")),
              const SizedBox(
                height: 5,
              ),
              Text(animeData['premiered'] ?? "??",style: TextStyle( fontFamily: "Poppins-Bold")),
              const SizedBox(
                height: 5,
              ),
              Text(animeData['duration'] ?? "??",style: TextStyle( fontFamily: "Poppins-Bold")),
              const SizedBox(
                height: 5,
              ),
              Text(animeData['status'] ?? "??",style: TextStyle( fontFamily: "Poppins-Bold")),
              const SizedBox(
                height: 5,
              ),
              Text(animeData['rating'] ?? "??",style: TextStyle( fontFamily: "Poppins-Bold")),
              const SizedBox(
                height: 5,
              ),
              Text(animeData['quality'] ?? "??",style: TextStyle( fontFamily: "Poppins-Bold")),
            ],
          ),
        ],
      ),
    );
  }
}
