import 'package:flutter/material.dart';
import 'package:holyroad/core/widgets/cached_holy_image.dart';
import 'package:holyroad/features/map/domain/entities/holy_site_entity.dart';

/// 검색 결과 타일 위젯
class SearchResultTile extends StatelessWidget {
  final HolySite site;
  final VoidCallback onTap;

  const SearchResultTile({
    super.key,
    required this.site,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              CachedHolyImage(
                imageUrl: site.imageUrl,
                width: 60,
                height: 60,
                borderRadius: BorderRadius.circular(10),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            site.name,
                            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 6),
                        _buildTypeBadge(context, site.siteType),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      site.description,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: colorScheme.onSurfaceVariant),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTypeBadge(BuildContext context, HolySiteType type) {
    final (label, color) = switch (type) {
      HolySiteType.church => ('교회', const Color(0xFFD32F2F)),
      HolySiteType.school => ('학교', const Color(0xFF1565C0)),
      HolySiteType.museum => ('박물관', const Color(0xFF2E7D32)),
      HolySiteType.memorial => ('기념관', const Color(0xFFE65100)),
      HolySiteType.martyrdom => ('순교지', const Color(0xFF880E4F)),
      HolySiteType.holySite => ('성지', const Color(0xFF6A1B9A)),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}
