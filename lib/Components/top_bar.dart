import 'package:flutter/material.dart';
import '../Constants/paths.dart';

class TopBar extends StatelessWidget implements PreferredSizeWidget {
  final bool hasBackButton;
  final Function? onBackPress;
  final String? title;
  final Color? backgroundColor;
  final List<Widget>? actions;

  const TopBar({
    super.key,
    required this.hasBackButton,
    this.title,
    this.backgroundColor,
    this.onBackPress,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      elevation: 0,
      backgroundColor: backgroundColor ?? Theme.of(context).primaryColor,
      centerTitle: true,
      leading: hasBackButton
          ? SizedBox(
        width: 40,
        child: Align(
          alignment: Alignment.bottomCenter,
          child: BackButton(
            color: backgroundColor != null ? Colors.black : Colors.white,
            onPressed: () {
              if (onBackPress != null) {
                onBackPress!();
              } else {
                Navigator.pop(context);
              }
            },
          ),
        ),
      )
          : Container(),
      title: title == null
          ? SizedBox(
          width: 156, child: Image.asset(Paths.PLACEHOLDER))
          : Text(
        title!,
        textAlign: TextAlign.center,
        style: const TextStyle(
            color: Colors.black,
            fontSize: 28,
            fontWeight: FontWeight.bold),
      ),
      actions: actions,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(64);
}
