import 'package:flutter/material.dart';
import 'logo.dart';

class CravnAppBar extends StatelessWidget implements PreferredSizeWidget {
  final Widget? title;
  final List<Widget>? actions;

  const CravnAppBar({super.key, this.title, this.actions});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: title ?? const CravnLogo(),
      actions: actions,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      elevation: 0,
      centerTitle: true,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
