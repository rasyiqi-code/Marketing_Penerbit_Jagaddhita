import 'package:flutter/material.dart';
import 'package:marketing_penerbit_jagaddhita/src/core/models/user_model.dart';
import 'package:marketing_penerbit_jagaddhita/src/core/theme/app_theme.dart';
import 'package:marketing_penerbit_jagaddhita/src/core/utils/network_image_web_helper.dart';

class ProfileAvatar extends StatelessWidget {
  final UserModel? user;

  const ProfileAvatar({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppTheme.primaryColor.withValues(alpha: 0.1),
        border: Border.all(
          color: AppTheme.primaryColor.withValues(alpha: 0.2),
          width: 2,
        ),
      ),
      child: ClipOval(
        child: user?.photoUrl != null
            ? NetworkImageWeb(imageUrl: user!.photoUrl!, fit: BoxFit.cover)
            : Center(
                child: Text(
                  (user?.email ?? 'U').substring(0, 1).toUpperCase(),
                  style: const TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryColor,
                  ),
                ),
              ),
      ),
    );
  }
}
