import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class QuickMenuGrid extends StatelessWidget {
  const QuickMenuGrid({super.key});

  @override
  Widget build(BuildContext context) {
    final menuItems = [
      {'icon': Icons.map, 'label': '지도', 'route': '/map'},
      {'icon': Icons.flag, 'label': '성지 순례', 'route': '/pilgrimage'},
      {'icon': Icons.book, 'label': '순례자의기록', 'route': '/guestbook'},
      {'icon': Icons.chat_bubble, 'label': 'AI 상담', 'route': '/ai-chat'},
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        childAspectRatio: 0.8,
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
