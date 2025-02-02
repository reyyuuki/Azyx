
import 'package:azyx/Widgets/AzyXWidgets/azyx_text.dart';
import 'package:flutter/material.dart';

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
                  "Getting data",
                  style: TextStyle(fontFamily: "Poppins-Bold", fontSize: 20),
                ),
                SizedBox(
                  height: 10,
                ),
                Center(
                  child: CircularProgressIndicator(),
                ),
              ],
            ),
          );
        });
  }