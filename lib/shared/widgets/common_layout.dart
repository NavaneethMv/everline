import 'package:everline/shared/widgets/custom_navbar_widget.dart';
import 'package:flutter/material.dart';

class CommonLayout extends StatelessWidget {
  final Widget widget;
  final String currentPath;

  const CommonLayout({
    super.key,
    required this.widget,
    required this.currentPath,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      bottomNavigationBar: CustomNavbarWidget(),
      body: widget,
    );
  }
}
