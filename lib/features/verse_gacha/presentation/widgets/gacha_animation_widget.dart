import 'dart:math';
import 'package:flutter/material.dart';
import 'package:holyroad/features/verse_gacha/domain/entities/bible_verse.dart';
import 'package:holyroad/features/verse_gacha/presentation/widgets/verse_card_widget.dart';

/// 카드 뒤집기 + 등급별 빛 효과 애니메이션.
class GachaAnimationWidget extends StatefulWidget {
  final BibleVerse verse;
  final VoidCallback? onAnimationComplete;

  const GachaAnimationWidget({
    super.key,
    required this.verse,
    this.onAnimationComplete,
  });

  @override
  State<GachaAnimationWidget> createState() => _GachaAnimationWidgetState();
}

class _GachaAnimationWidgetState extends State<GachaAnimationWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _flipAnimation;
  late Animation<double> _glowAnimation;
  bool _showFront = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _flipAnimation = Tween<double>(begin: 0, end: pi).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.easeInOut),
      ),
    );

    _glowAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.5, 1.0, curve: Curves.easeOut),
      ),
    );

    _controller.addListener(() {
      if (_flipAnimation.value >= pi / 2 && !_showFront) {
        setState(() => _showFront = true);
      }
    });

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.onAnimationComplete?.call();
      }
    });

    // 잠깐 대기 후 애니메이션 시작
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Stack(
          alignment: Alignment.center,
          children: [
            // 등급별 빛 효과
            if (_glowAnimation.value > 0)
              Container(
                width: 300 + (_glowAnimation.value * 60),
                height: 400 + (_glowAnimation.value * 60),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: _getGlowColor(widget.verse.rarity)
                          .withValues(alpha: _glowAnimation.value * 0.4),
                      blurRadius: 40 * _glowAnimation.value,
                      spreadRadius: 10 * _glowAnimation.value,
                    ),
                  ],
                ),
              ),
            // 카드 (뒤집기 애니메이션)
            Transform(
              alignment: Alignment.center,
              transform: Matrix4.identity()
                ..setEntry(3, 2, 0.001)
                ..rotateY(_flipAnimation.value),
              child: _showFront ? _buildFront() : _buildBack(),
            ),
          ],
        );
      },
    );
  }

  Widget _buildBack() {
    return Container(
      width: 280,
      height: 380,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF37474F), Color(0xFF263238)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.auto_stories, size: 64, color: Colors.white.withValues(alpha: 0.5)),
            const SizedBox(height: 12),
            Text(
              '오늘의 말씀',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.7),
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFront() {
    // 앞면은 180도 뒤집어서 보여줘야 정상으로 보임
    return Transform(
      alignment: Alignment.center,
      transform: Matrix4.identity()..rotateY(pi),
      child: SizedBox(
        width: 280,
        child: VerseCardWidget(verse: widget.verse, showFull: true),
      ),
    );
  }

  Color _getGlowColor(VerseRarity rarity) {
    switch (rarity) {
      case VerseRarity.normal:
        return const Color(0xFF78909C);
      case VerseRarity.rare:
        return const Color(0xFF42A5F5);
      case VerseRarity.epic:
        return const Color(0xFFAB47BC);
      case VerseRarity.legendary:
        return const Color(0xFFFFD54F);
    }
  }
}
