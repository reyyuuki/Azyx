
import 'package:azyx/Widgets/AzyXWidgets/azyx_text.dart';
import 'package:flutter/material.dart';
import 'package:loading_indicator_m3e/loading_indicator_m3e.dart';

void showloader(context) {
    showModalBottomSheet(
        context: context,
        showDragHandle: true,
        builder: (context) {
          return const SizedBox(
            height: 100,
            child: Column(
              children: [
                AzyXText(
                 text:  "Getting data",
                  fontSize: 20,
                  fontVariant: FontVariant.bold,
                ),
                SizedBox(
                  height: 10,
                ),
                Center(
                  child: LoadingIndicatorM3E(),
                ),
              ],
            ),
          );
        });
  }