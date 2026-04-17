import 'package:flutter/material.dart';

/// شريط علوي مخصص مع زر عودة اختياري
class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final VoidCallback? onBack;
  final bool showBackButton;
  final List<Widget>? actions;
  final Widget? bottom;
  final bool centerTitle;
  
  const CustomAppBar({
    super.key,
    required this.title,
    this.onBack,
    this.showBackButton = true,
    this.actions,
    this.bottom,
    this.centerTitle = true,
  });

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight + (bottom?.preferredSize.height ?? 0));

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(title),
      centerTitle: centerTitle,
      leading: showBackButton
          ? IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: onBack ?? () => Navigator.of(context).pop(),
            )
          : null,
      actions: actions,
      elevation: 0,
      scrolledUnderElevation: 2,
      bottom: bottom,
    );
  }
}
