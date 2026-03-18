import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final bool showBack;
  final bool showClose;
  final VoidCallback? onBack;
  final VoidCallback? onClose;
  final List<Widget>? actions;

  const CustomAppBar({
    super.key,
    this.title,
    this.showBack = true,
    this.showClose = false,
    this.onBack,
    this.onClose,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      scrolledUnderElevation: 0,
      leading: showBack
          ? IconButton(
              icon: const Icon(Icons.chevron_left, size: 28, color: AppColors.textDark),
              onPressed: onBack ?? () => Navigator.of(context).pop(),
            )
          : null,
      title: title != null
          ? Text(
              title!,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textDark,
              ),
            )
          : null,
      centerTitle: true,
      actions: [
        if (showClose)
          IconButton(
            icon: const Icon(Icons.close, color: AppColors.textDark),
            onPressed: onClose ?? () => Navigator.of(context).pop(),
          ),
        if (actions != null) ...actions!,
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
