import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

// A section title with an optional link on the right, such as SEE ALL.
class SectionHeader extends StatelessWidget {
  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;

  const SectionHeader({
    super.key,
    required this.title,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Text(title, style: AppText.cardTitle)),
        if (actionLabel != null)
          InkWell(
            onTap: onAction,
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Text(
                actionLabel!,
                style: AppText.caps.copyWith(color: AppColors.primaryDark),
              ),
            ),
          ),
      ],
    );
  }
}
