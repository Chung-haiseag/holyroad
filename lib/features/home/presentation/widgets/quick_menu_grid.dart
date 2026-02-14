import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class QuickMenuGrid extends StatelessWidget {
  const QuickMenuGrid({super.key});

  @override
  Widget build(BuildContext context) {
    final menuItems = [
      {'icon': Icons.map, 'label': '성지 지도', 'route': '/map'},
      {'icon': Icons.church, 'label': '순례 체험', 'route': '/pilgrimage'},
      {'icon': Icons.book, 'label': '순례 나눔', 'route': '/guestbook'},
      {'icon': Icons.chat_bubble, 'label': 'AI 상담', 'route': '/ai-chat'},
      {
        'icon': Icons.collections_bookmark,
        'label': '스탬프',
        'route': '/stamp-collection'
      },
      {'icon': Icons.style, 'label': '말씀 뽑기', 'route': '/verse-gacha'},
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 0.85,
      ),
      itemCount: menuItems.length,
      itemBuilder: (context, index) {
        final item = menuItems[index];
        final route = item['route'] as String;

        return GestureDetector(
          onTap: route.isNotEmpty ? () => context.push(route) : null,
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.secondaryContainer,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  item['icon'] as IconData,
                  color: Theme.of(context).colorScheme.onSecondaryContainer,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                item['label'] as String,
                style: Theme.of(context).textTheme.labelMedium,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      },
    );
  }
}
