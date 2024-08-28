import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

class Setting extends StatelessWidget {
  const Setting({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Settings"),
        leading:  IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back_ios)),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
              Container(
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), color: Theme.of(context).colorScheme.surfaceContainerHighest,),
                height: 50,
                width: MediaQuery.of(context).size.width,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.palette),
                          SizedBox(width: 10,),
                          Text("Themes")
                        ],
                      ),
                      Transform.rotate(
                        angle: 3.14,
                        child: Icon(Icons.arrow_back_ios))
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10,),
              Container(
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), color: Theme.of(context).colorScheme.surfaceContainerHighest,),
                height: 50,
                width: MediaQuery.of(context).size.width,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.language),
                          SizedBox(width: 10,),
                          Text("Languages")
                        ],
                      ),
                      Transform.rotate(
                        angle: 3.14,
                        child: const Icon(Icons.arrow_back_ios))
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10,),
              Container(
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), color: Theme.of(context).colorScheme.surfaceContainerHighest,),
                height: 50,
                width: MediaQuery.of(context).size.width,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Row(
                        children: [
                          Icon(Iconsax.user_tag),
                          SizedBox(width: 10,),
                          Text("Profile")
                        ],
                      ),
                      Transform.rotate(
                        angle: 3.14,
                        child: Icon(Icons.arrow_back_ios))
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10,),
              Container(
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), color: Theme.of(context).colorScheme.surfaceContainerHighest,),
                height: 50,
                width: MediaQuery.of(context).size.width,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Row(
                        children: [
                          Icon(Iconsax.info_circle5),
                          SizedBox(width: 10,),
                          Text("About")
                        ],
                      ),
                      Transform.rotate(
                        angle: 3.14,
                        child: Icon(Icons.arrow_back_ios))
                    ],
                  ),
                ),
              )
          ],
        ),
      )
    );
  }
}