import 'package:flutter/material.dart';
import 'package:race_tracking_app/theme/theme.dart';

enum RaceButtonType { primary, secondary }

class RaceButton extends StatelessWidget {
  final String text;
  final IconData? icon;
  final VoidCallback onPressed;
  final RaceButtonType type;
  final Color? color;

  const RaceButton({
    super.key,
    required this.text,
    this.icon,
    required this.onPressed,
    this.type = RaceButtonType.primary,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    // Define button color
    Color backGroundColor =
        color ??
        (type == RaceButtonType.primary
            ? RaceColors.primary
            : RaceColors.green);
    Color textColor = RaceColors.white;
    Color iconColor = RaceColors.white;

    // build button widget
    return OutlinedButton(
      style: OutlinedButton.styleFrom(
        backgroundColor: backGroundColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(RaceSpacings.radius),
        ),
        side: BorderSide.none,
        padding: EdgeInsets.symmetric(
          horizontal: RaceSpacings.xl,
          vertical: RaceSpacings.l,
        ),
      ),
      onPressed: onPressed,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (icon != null) ...[
            Icon(icon, color: iconColor, size: 20),
            SizedBox(width: RaceSpacings.s),
          ],
          Text(text, style: RaceTextStyles.button.copyWith(color: textColor)),
        ],
      ),
    );
  }
}
