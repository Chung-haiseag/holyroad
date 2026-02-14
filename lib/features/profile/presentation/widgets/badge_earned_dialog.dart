import 'package:flutter/material.dart';
import 'package:holyroad/features/profile/domain/badge_entity.dart';

/// 배지 획득 축하 다이얼로그.
/// 새로 획득한 배지 목록을 받아서 애니메이션과 함께 표시합니다.
class BadgeEarnedDialog extends StatefulWidget {
  final List<BadgeDefinition> newBadges;

  const BadgeEarnedDialog({super.key, required this.newBadges});

  /// 새로 획득한 배지가 있을 때 다이얼로그를 표시합니다.
  static Future<void> showIfNeeded(
    BuildContext context,
    List<BadgeDefinition> newBadges,
  ) async {
    if (newBadges.isEmpty) return;
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => BadgeEarnedDialog(newBadges: newBadges),
    );
  }

  @override
  State<BadgeEarnedDialog> createState() => _BadgeEarnedDialogState();
}

class _BadgeEarnedDialogState extends State<BadgeEarnedDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isSingle = widget.newBadges.length == 1;

    return FadeTransition(
      opacity: _fadeAnimation,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 축하 아이콘
              const Text(
                '🎉',
                style: TextStyle(fontSize: 40),
              ),
              const SizedBox(height: 8),
              Text(
                isSingle ? '배지 획득!' : '${widget.newBadges.length}개 배지 획득!',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.primary,
                    ),
              ),
              const SizedBox(height: 16),

              // 배지 목록
              ...widget.newBadges.map((badge) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      children: [
                        // 배지 아이콘
                        Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            color: badge.color.withValues(alpha: 0.15),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: badge.color.withValues(alpha: 0.5),
                              width: 2,
                            ),
                          ),
                          child: Icon(
                            badge.icon,
                            color: badge.color,
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 12),
                        // 배지 정보
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                badge.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              Text(
                                badge.description,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  )),
            ],
          ),
          actions: [
            Center(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: FilledButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('감사합니다 🙏'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
