import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:holyroad/core/services/image_upload_service.dart';
import 'package:holyroad/features/map/domain/entities/holy_site_entity.dart';
import 'package:holyroad/features/pilgrimage/domain/entities/visit_entity.dart';
import 'package:holyroad/features/pilgrimage/domain/repositories/firestore_repository.dart';
import 'package:holyroad/features/profile/domain/badge_entity.dart';
import 'package:holyroad/features/profile/domain/badge_service.dart';
import 'package:holyroad/features/profile/presentation/widgets/badge_earned_dialog.dart';

/// 기도문 + 사진 제출 바텀시트.
/// [site]가 전달되면 해당 성지 정보와 함께 기도문을 저장합니다.
/// [initialImage]가 전달되면 카메라에서 바로 찍은 사진이 미리 첨부됩니다.
class PrayerSubmitDialog extends ConsumerStatefulWidget {
  final HolySite? site;
  final XFile? initialImage;

  const PrayerSubmitDialog({
    super.key,
    this.site,
    this.initialImage,
  });

  @override
  ConsumerState<PrayerSubmitDialog> createState() => _PrayerSubmitDialogState();
}

class _PrayerSubmitDialogState extends ConsumerState<PrayerSubmitDialog> {
  final _messageController = TextEditingController();
  XFile? _selectedImage;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _selectedImage = widget.initialImage;
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 20,
        right: 20,
        top: 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 드래그 핸들
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[400],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 12),
          // 헤더 + 제출 버튼을 한 줄에
          Row(
            children: [
              Icon(Icons.edit_note, color: colorScheme.primary, size: 22),
              const SizedBox(width: 6),
              Text(
                '기도 남기기',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              if (widget.site != null) ...[
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    widget.site!.name,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ] else
                const Spacer(),
              FilledButton(
                onPressed: _isSubmitting ? null : _submitPrayer,
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                ),
                child: _isSubmitting
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text('제출', style: TextStyle(fontSize: 15)),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // 기도문 입력
          TextField(
            controller: _messageController,
            maxLines: 3,
            maxLength: 500,
            decoration: InputDecoration(
              hintText: '이곳에서의 기도와 묵상을 나눠주세요...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
            ),
          ),
          const SizedBox(height: 8),

          // 이미지 미리보기 또는 추가 버튼
          if (_selectedImage != null)
            _buildImagePreview()
          else
            _buildImageButtons(),

          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildImageButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => _pickImage(ImageSource.camera),
            icon: const Icon(Icons.camera_alt, size: 18),
            label: const Text('카메라'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => _pickImage(ImageSource.gallery),
            icon: const Icon(Icons.photo_library, size: 18),
            label: const Text('갤러리'),
          ),
        ),
      ],
    );
  }

  Widget _buildImagePreview() {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 250),
            child: Image.file(
              File(_selectedImage!.path),
              width: double.infinity,
              fit: BoxFit.contain,
            ),
          ),
        ),
        Positioned(
          top: 8,
          right: 8,
          child: GestureDetector(
            onTap: () => setState(() => _selectedImage = null),
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: Colors.black54,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.close, color: Colors.white, size: 18),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    final uploadService = ref.read(imageUploadServiceProvider);
    final image = await uploadService.pickImage(source);
    if (image != null && mounted) {
      setState(() => _selectedImage = image);
    }
  }

  Future<void> _submitPrayer() async {
    final message = _messageController.text.trim();
    if (message.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('기도문을 입력해주세요.')),
      );
      return;
    }

    // 로그인 확인
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('로그인이 필요합니다. 먼저 로그인해주세요.')),
        );
      }
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      String photoUrl = '';

      // 이미지가 있으면 업로드 시도 (실패해도 기도문은 저장)
      if (_selectedImage != null) {
        try {
          final uploadService = ref.read(imageUploadServiceProvider);
          final timestamp = DateTime.now().millisecondsSinceEpoch;
          final storagePath = 'visits/prayer_${currentUser.uid}_$timestamp.jpg';
          photoUrl = await uploadService.uploadImage(_selectedImage!, storagePath);
        } catch (e) {
          debugPrint('이미지 업로드 실패 (기도문은 계속 저장): $e');
          // 이미지 업로드 실패해도 기도문 저장은 계속 진행
        }
      }

      // VisitEntity 생성 및 Firestore 저장
      final firestoreRepo = ref.read(firestoreRepositoryProvider);
      final visit = VisitEntity(
        id: '',
        userId: currentUser.uid,
        userDisplayName: currentUser.displayName ?? '순례자',
        userPhotoUrl: currentUser.photoURL ?? '',
        siteId: widget.site?.id ?? 'unknown',
        siteName: widget.site?.name ?? '성지',
        timestamp: DateTime.now(),
        prayerMessage: message,
        photoUrl: photoUrl,
      );

      await firestoreRepo.addVisit(visit);

      // ── 배지 체크 ──
      List<BadgeDefinition> newBadges = [];
      try {
        final badgeService = BadgeService();
        // 사용자의 전체 방문 기록을 가져와서 통계 계산
        final visitsStream = firestoreRepo.getUserVisits(currentUser.uid);
        final visits = await visitsStream.first;

        final totalVisits = visits.length;
        final totalPhotos = visits.where((v) => v.photoUrl.isNotEmpty).length;
        final uniqueSites = visits.map((v) => v.siteId).toSet().length;
        final totalPrayers = visits.where((v) => v.prayerMessage.isNotEmpty).length;
        final streakDays = _calculateStreak(visits);

        final badgeContext = BadgeCheckContext(
          totalVisits: totalVisits,
          totalPhotos: totalPhotos,
          uniqueSites: uniqueSites,
          streakDays: streakDays,
          totalPrayers: totalPrayers,
        );

        // 이미 획득한 배지 목록 조회
        final earnedIds = await badgeService.getEarnedBadgeIds(currentUser.uid);

        // 새 배지 체크
        newBadges = badgeService.checkNewBadges(badgeContext, earnedIds);

        // 새 배지가 있으면 Firestore에 저장
        if (newBadges.isNotEmpty) {
          final earnedBadges = newBadges
              .map((b) => EarnedBadge(badgeId: b.id, earnedAt: DateTime.now()))
              .toList();
          await badgeService.saveBadges(currentUser.uid, earnedBadges);
        }
      } catch (e) {
        debugPrint('배지 체크 중 오류 (기도문은 이미 저장됨): $e');
      }

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(photoUrl.isEmpty && _selectedImage != null
                ? '기도문이 제출되었습니다. (사진은 업로드 실패)'
                : '기도문이 제출되었습니다.'),
            behavior: SnackBarBehavior.floating,
          ),
        );

        // 새 배지가 있으면 축하 다이얼로그 표시
        if (newBadges.isNotEmpty && mounted) {
          await BadgeEarnedDialog.showIfNeeded(context, newBadges);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('제출 중 오류가 발생했습니다: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  /// 연속 순례일 계산 (프로필 화면과 동일 로직).
  int _calculateStreak(List<VisitEntity> visits) {
    if (visits.isEmpty) return 0;

    final visitDates = visits
        .map((v) => DateTime(v.timestamp.year, v.timestamp.month, v.timestamp.day))
        .toSet()
        .toList()
      ..sort((a, b) => b.compareTo(a));

    if (visitDates.isEmpty) return 0;

    final today = DateTime(
      DateTime.now().year,
      DateTime.now().month,
      DateTime.now().day,
    );

    final lastVisitDate = visitDates.first;
    final daysDiff = today.difference(lastVisitDate).inDays;
    if (daysDiff > 1) return 0;

    int streak = 1;
    for (int i = 0; i < visitDates.length - 1; i++) {
      final diff = visitDates[i].difference(visitDates[i + 1]).inDays;
      if (diff == 1) {
        streak++;
      } else {
        break;
      }
    }
    return streak;
  }
}
