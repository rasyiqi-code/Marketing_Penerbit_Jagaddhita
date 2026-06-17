import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:marketing_penerbit_jagaddhita/src/core/models/user_model.dart';
import 'package:marketing_penerbit_jagaddhita/src/core/models/link_bio_model.dart';
import 'package:marketing_penerbit_jagaddhita/src/core/services/firestore/link_bio_service.dart';
import 'package:marketing_penerbit_jagaddhita/src/core/services/firestore/user_service.dart';
import 'package:marketing_penerbit_jagaddhita/src/features/link_bio/screens/link_bio_preview_screen.dart';

class LinkBioLoadingScreen extends StatelessWidget {
  final String userId;

  const LinkBioLoadingScreen({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    final linkBioService = Provider.of<LinkBioService>(context, listen: false);
    final userService = Provider.of<UserService>(context, listen: false);

    return Scaffold(
      body: FutureBuilder<UserModel?>(
        future: userService.resolveUser(userId),
        builder: (context, userSnapshot) {
          if (userSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (userSnapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text('Error: ${userSnapshot.error}'),
              ),
            );
          }
          if (!userSnapshot.hasData || userSnapshot.data == null) {
            return const Center(child: Text('User Not Found (Empty Data)'));
          }

          final user = userSnapshot.data!;

          return StreamBuilder<List<LinkBioModel>>(
            stream: linkBioService.getLinks(user.id),
            builder: (context, linkSnapshot) {
              if (linkSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              final links = linkSnapshot.data ?? [];

              return LinkBioPreviewScreen(
                user: user,
                links: links,
                isPublicView: true, // New flag to hide close button
              );
            },
          );
        },
      ),
    );
  }
}
