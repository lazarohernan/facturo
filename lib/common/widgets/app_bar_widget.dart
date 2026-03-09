import 'package:flutter/material.dart';

class AppBarWidget extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final bool showBackButton;
  final Widget? leading;
  final PreferredSizeWidget? bottom;
  final Color? backgroundColor;
  final Color? foregroundColor;

  const AppBarWidget({
    super.key,
    required this.title,
    this.actions,
    this.showBackButton = true,
    this.leading,
    this.bottom,
    this.backgroundColor,
    this.foregroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(title),
      actions: actions,
      automaticallyImplyLeading: showBackButton,
      leading: leading,
      bottom: bottom,
      backgroundColor: backgroundColor,
      foregroundColor: foregroundColor,
      elevation: 0,
      centerTitle: false,
    );
  }

  @override
  Size get preferredSize =>
      Size.fromHeight(kToolbarHeight + (bottom?.preferredSize.height ?? 0.0));
}
