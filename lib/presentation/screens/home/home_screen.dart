import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../widgets/repository_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: ShaderMask(
          shaderCallback: (bounds) => AppColors.primaryGradient.createShader(bounds),
          child: const Text(
            'GitTrend JP',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.person_outline),
            onPressed: () {},
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          indicatorColor: AppColors.primary,
          indicatorWeight: 2,
          labelStyle: AppTypography.body.copyWith(fontWeight: FontWeight.w600),
          tabs: const [
            Tab(text: 'Today'),
            Tab(text: 'Weekly'),
            Tab(text: 'Japanese'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _TrendingList(title: "Today's Trending"),
          _TrendingList(title: 'This Week'),
          _TrendingList(title: 'Japanese Repos'),
        ],
      ),
    );
  }
}

class _TrendingList extends StatelessWidget {
  final String title;

  const _TrendingList({required this.title});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 16),
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              Container(
                width: 4,
                height: 24,
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: AppTypography.subtitle,
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'NEW',
                  style: AppTypography.caption.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
        const RepositoryCard(
          fullName: 'openai/whisper-jp',
          description: 'Japanese-optimized speech recognition model with improved accuracy for business conversations',
          stars: 2847,
          starsToday: 123,
          language: 'Python',
          tags: ['AI', 'Speech'],
        ),
        const RepositoryCard(
          fullName: 'vercel/next-intl',
          description: 'Internationalization for Next.js with full Japanese support and RTL layouts',
          stars: 1523,
          starsToday: 45,
          language: 'TypeScript',
          tags: ['i18n', 'Next.js'],
        ),
        const RepositoryCard(
          fullName: 'line/armeria',
          description: 'Your go-to microservice framework for any situation',
          stars: 4201,
          starsToday: 32,
          language: 'Java',
          tags: ['Microservices'],
        ),
        const RepositoryCard(
          fullName: 'nicklockwood/SwiftFormat',
          description: 'A command-line tool and Xcode Extension for formatting Swift code',
          stars: 7892,
          starsToday: 28,
          language: 'Swift',
          tags: ['Formatter', 'CLI'],
        ),
        const RepositoryCard(
          fullName: 'rust-lang/rustlings',
          description: 'Small exercises to get you used to reading and writing Rust code!',
          stars: 52400,
          starsToday: 156,
          language: 'Rust',
          tags: ['Learning', 'Tutorial'],
        ),
      ],
    );
  }
}
