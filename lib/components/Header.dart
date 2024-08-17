import 'package:flutter/material.dart';

class Header extends StatelessWidget {
    const Header({
      super.key,
    });
  
    @override
    Widget build(BuildContext context) {
      return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
       Column(
        crossAxisAlignment: CrossAxisAlignment.start,
         children: [
           const Text("DaizyTv" ,style: TextStyle(fontSize: 30,fontFamily: 'Poppins')),
           Text("Enjoy Unlimited Anime!", style: TextStyle(fontSize: 15, color: Colors.grey[500]),)
         ],
       ),
        SizedBox(width: 50, height: 50, child: ClipRRect(borderRadius: BorderRadius.circular(50) , child:Image.network("https://s4.anilist.co/file/anilistcdn/media/anime/cover/large/bx16498-73IhOXpJZiMF.jpg", fit: BoxFit.cover,),))
      ],
                  );
                  
    }
  }