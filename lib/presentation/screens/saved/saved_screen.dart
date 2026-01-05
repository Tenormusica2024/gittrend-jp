import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../widgets/repository_card.dart';

class SavedScreen extends StatelessWidget {
  const SavedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Saved Repositories'),
        actions: [
          TextButton(
            onPressed: () {},
            child: const Text('Edit'),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 16),
        children: const [
          RepositoryCard(
            fullName: 'line/armeria',
            description: 'Your go-to microservice framework for any situation',
            stars: 4201,
            language: 'Java',
            tags: ['Microservices'],
            isSaved: true,
          ),
          RepositoryCard(
            fullName: 'nicklockwood/SwiftFormat',
            description: 'A command-line tool and Xcode Extension for formatting Swift code',
            stars: 7892,
            language: 'Swift',
            tags: ['Formatter', 'CLI'],
            isSaved: true,
          ),
        ],
      ),
    );
  }
}
