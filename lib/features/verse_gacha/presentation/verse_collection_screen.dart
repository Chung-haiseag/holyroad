import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:holyroad/features/verse_gacha/data/bible_verse_data.dart';
import 'package:holyroad/features/verse_gacha/domain/entities/collected_verse.dart';
import 'package:holyroad/features/verse_gacha/domain/providers/verse_gacha_providers.dart';

/// 66권 말씀 컬렉션 화면 (구약/신약 구분, 수집률).
class VerseCollectionScreen extends ConsumerWidget {
  const VerseCollectionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final collectionAsync = ref.watch(verseCollectionProvider);
    final collectedBooks = ref.watch(collectedBooksCountProvider);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text('말씀 컬렉션 ($collectedBooks/66)'),
          centerTitle: true,
          bottom: const TabBar(
            tabs: [
              Tab(text: '구약 (39권)'),
              Tab(text: '신약 (27권)'),
            ],
          ),
        ),
        body: collectionAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, _) => Center(child: Text('오류: $err')),
          data: (collection) {
            final collectedBookIndices =
                collection.map((c) => c.bookIndex).toSet();

            return TabBarView(
              children: [
                // 구약
                _buildBookGrid(
                  context: context,
                  theme: theme,
                  books: _oldTestamentBooks,
                  collectedIndices: collectedBookIndices,
                  collection: collection,
                ),
                // 신약
                _buildBookGrid(
                  context: context,
                  theme: theme,
                  books: _newTestamentBooks,
                  collectedIndices: collectedBookIndices,
                  collection: collection,
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildBookGrid({
    required BuildContext context,
    required ThemeData theme,
    required List<_BookInfo> books,
    required Set<int> collectedIndices,
    required List<CollectedVerse> collection,
  }) {
    final collected = books.where((b) => collectedIndices.contains(b.index)).length;

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Text(
                  '수집률: $collected/${books.length}',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                Text(
                  '${(collected / books.length * 100).toStringAsFixed(0)}%',
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              childAspectRatio: 0.9,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final book = books[index];
                final isCollected = collectedIndices.contains(book.index);
                // 수집된 경우 가장 높은 등급 표시
                final bestRarity = _getBestRarity(collection, book.index);

                return _BookTile(
                  name: book.shortName,
                  isCollected: isCollected,
                  rarityColor: bestRarity,
                );
              },
              childCount: books.length,
            ),
          ),
        ),
        const SliverPadding(padding: EdgeInsets.only(bottom: 32)),
      ],
    );
  }

  Color? _getBestRarity(List<CollectedVerse> collection, int bookIndex) {
    final versesForBook = collection.where((c) => c.bookIndex == bookIndex);
    if (versesForBook.isEmpty) return null;

    // 가장 높은 등급 컬러 반환
    final rarities = versesForBook.map((c) => c.verseRarity).toList();
    if (rarities.any((r) => r.name == 'legendary')) return const Color(0xFFFFD54F);
    if (rarities.any((r) => r.name == 'epic')) return const Color(0xFFAB47BC);
    if (rarities.any((r) => r.name == 'rare')) return const Color(0xFF42A5F5);
    return const Color(0xFF78909C);
  }
}

class _BookTile extends StatelessWidget {
  final String name;
  final bool isCollected;
  final Color? rarityColor;

  const _BookTile({
    required this.name,
    required this.isCollected,
    this.rarityColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: isCollected
            ? (rarityColor ?? theme.colorScheme.primaryContainer)
                .withValues(alpha: 0.2)
            : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
        border: isCollected
            ? Border.all(
                color: (rarityColor ?? theme.colorScheme.primary)
                    .withValues(alpha: 0.4),
              )
            : null,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isCollected ? Icons.menu_book : Icons.lock_outline,
            size: 24,
            color: isCollected
                ? (rarityColor ?? theme.colorScheme.primary)
                : theme.colorScheme.outline.withValues(alpha: 0.4),
          ),
          const SizedBox(height: 4),
          Text(
            name,
            style: theme.textTheme.labelSmall?.copyWith(
              color: isCollected
                  ? theme.colorScheme.onSurface
                  : theme.colorScheme.outline.withValues(alpha: 0.5),
              fontWeight: isCollected ? FontWeight.w600 : FontWeight.normal,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _BookInfo {
  final int index;
  final String shortName;
  const _BookInfo(this.index, this.shortName);
}

const _oldTestamentBooks = [
  _BookInfo(1, '창세기'), _BookInfo(2, '출애굽기'), _BookInfo(3, '레위기'),
  _BookInfo(4, '민수기'), _BookInfo(5, '신명기'), _BookInfo(6, '여호수아'),
  _BookInfo(7, '사사기'), _BookInfo(8, '룻기'), _BookInfo(9, '삼상'),
  _BookInfo(10, '삼하'), _BookInfo(11, '왕상'), _BookInfo(12, '왕하'),
  _BookInfo(13, '대상'), _BookInfo(14, '대하'), _BookInfo(15, '에스라'),
  _BookInfo(16, '느헤미야'), _BookInfo(17, '에스더'), _BookInfo(18, '욥기'),
  _BookInfo(19, '시편'), _BookInfo(20, '잠언'), _BookInfo(21, '전도서'),
  _BookInfo(22, '아가'), _BookInfo(23, '이사야'), _BookInfo(24, '예레미야'),
  _BookInfo(25, '예레미야\n애가'), _BookInfo(26, '에스겔'), _BookInfo(27, '다니엘'),
  _BookInfo(28, '호세아'), _BookInfo(29, '요엘'), _BookInfo(30, '아모스'),
  _BookInfo(31, '오바댜'), _BookInfo(32, '요나'), _BookInfo(33, '미가'),
  _BookInfo(34, '나훔'), _BookInfo(35, '하박국'), _BookInfo(36, '스바냐'),
  _BookInfo(37, '학개'), _BookInfo(38, '스가랴'), _BookInfo(39, '말라기'),
];

const _newTestamentBooks = [
  _BookInfo(40, '마태'), _BookInfo(41, '마가'), _BookInfo(42, '누가'),
  _BookInfo(43, '요한'), _BookInfo(44, '사도행전'), _BookInfo(45, '로마서'),
  _BookInfo(46, '고전'), _BookInfo(47, '고후'), _BookInfo(48, '갈라디아'),
  _BookInfo(49, '에베소'), _BookInfo(50, '빌립보'), _BookInfo(51, '골로새'),
  _BookInfo(52, '살전'), _BookInfo(53, '살후'), _BookInfo(54, '딤전'),
  _BookInfo(55, '딤후'), _BookInfo(56, '디도서'), _BookInfo(57, '빌레몬'),
  _BookInfo(58, '히브리'), _BookInfo(59, '야고보'), _BookInfo(60, '벧전'),
  _BookInfo(61, '벧후'), _BookInfo(62, '요일'), _BookInfo(63, '요이'),
  _BookInfo(64, '요삼'), _BookInfo(65, '유다'), _BookInfo(66, '요한계시록'),
];
