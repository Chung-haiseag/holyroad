import 'package:flutter/material.dart';
import 'package:holyroad/features/stamp_collection/domain/entities/region_entity.dart';
import 'package:intl/intl.dart';

/// 개별 성지 스탬프 타일.
/// 방문한 성지는 컬러 아이콘, 미방문은 회색 잠금 상태로 표시.
class StampTile extends StatelessWidget {
  final SiteStamp stamp;

  const StampTile({super.key, required this.stamp});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isVisited = stamp.isVisited;

    return Tooltip(
      message: isVisited
          ? '${stamp.site.name}\n방문일: ${_formatDate(stamp.firstVisitDate)}'
          : '${stamp.site.name}\n아직 방문하지 않았습니다',
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: isVisited
              ? theme.colorScheme.primaryContainer
              : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(12),
          border: isVisited
              ? Border.all(color: theme.colorScheme.primary.withValues(alpha: 0.3))
              : null,
          boxShadow: isVisited
              ? [
                  BoxShadow(
                    color: theme.colorScheme.primary.withValues(alpha: 0.15),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 스탬프 아이콘
            Icon(
              isVisited ? Icons.verified : Icons.lock_outline,
              size: 28,
              color: isVisited
                  ? theme.colorScheme.primary
                  : theme.colorScheme.outline.withValues(alpha: 0.4),
            ),
            const SizedBox(height: 4),
            // 성지 이름
            Text(
              _shortenName(stamp.site.name),
              style: theme.textTheme.labelSmall?.copyWith(
                color: isVisited
                    ? theme.colorScheme.onPrimaryContainer
                    : theme.colorScheme.outline.withValues(alpha: 0.6),
                fontWeight: isVisited ? FontWeight.w600 : FontWeight.normal,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  String _shortenName(String name) {
    // 긴 이름 축약: 10자 넘으면 줄임
    if (name.length > 10) {
      return '${name.substring(0, 9)}…';
    }
    return name;
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '기록 없음';
    return DateFormat('yyyy.MM.dd').format(date);
  }
}
