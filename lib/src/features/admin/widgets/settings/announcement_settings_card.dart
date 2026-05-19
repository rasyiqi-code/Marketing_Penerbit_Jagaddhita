import 'package:flutter/material.dart';
import 'package:marketing_penerbit_jagaddhita/src/core/widgets/app_text_field.dart';

class AnnouncementSettingsCard extends StatelessWidget {
  final TextEditingController latestInfoController;
  final TextEditingController webBaseUrlController;

  const AnnouncementSettingsCard({
    super.key,
    required this.latestInfoController,
    required this.webBaseUrlController,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppTextField(
            controller: latestInfoController,
            label: 'Info Terkini',
            icon: Icons.info_outline,
            maxLines: 2,
          ),
          const SizedBox(height: 16),
          AppTextField(
            controller: webBaseUrlController,
            label: 'URL Dasar Web App',
            icon: Icons.link,
            helperText: 'URL dasar untuk link Bio',
          ),
        ],
      ),
    );
  }
}
