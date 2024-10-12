import 'package:animated_segmented_tab_control/animated_segmented_tab_control.dart';
import 'package:flutter/material.dart';

class Animelist extends StatefulWidget {
  const Animelist({super.key});

  @override
  _AnimelistState createState() => _AnimelistState();
}

class _AnimelistState extends State<Animelist> {
  @override
  Widget build(BuildContext context) {
    final textStyle = Theme.of(context).textTheme.bodyLarge;
    final selectedTextStyle = textStyle?.copyWith(fontWeight: FontWeight.bold);

    return DefaultTabController(
      length: 5, // Number of tabs
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Anime List"),
        ),
        body: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: SegmentedTabControl(
                  // Customization of widget
                  tabTextColor: Colors.black,
                  selectedTabTextColor: Colors.white,  // Color of the selected indicator
                  indicatorPadding: const EdgeInsets.all(0),
                  squeezeIntensity: 1.5,
                  height: 45,  
                  tabPadding: const EdgeInsets.symmetric(horizontal: 12),
                  textStyle: textStyle,
                  selectedTextStyle: selectedTextStyle,
                  // Tabs for anime categories
                  tabs: const [
                    SegmentTab(label: ""),
                    SegmentTab(label: 'Planning'),
                    SegmentTab(label: 'Continue'),
                    SegmentTab(label: 'Watched'),
                    SegmentTab(label: 'Scheduled'),
                  ],
                ),
              ),
              const Expanded(
                child: TabBarView(
                  physics: BouncingScrollPhysics(),
                  children: [
                    Center(child: Text('Completed Anime List')),
                    Center(child: Text('Planning to Watch List')),
                    Center(child: Text('Continue Watching List')),
                    Center(child: Text('Watched Anime List')),
                    Center(child: Text('Scheduled Anime List')),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
