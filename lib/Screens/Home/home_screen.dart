import 'package:azyx/Controllers/services/service_handler.dart';
import 'package:azyx/Widgets/Animation/drop_animation.dart';
import 'package:azyx/Widgets/AzyXWidgets/azyx_gradient_container.dart';
import 'package:flutter/material.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AzyXGradientContainer(
      child: BouncePageAnimation(
        child: Obx(() => serviceHandler.homeWidgets(context).value),
      ),
    );
  }
}
