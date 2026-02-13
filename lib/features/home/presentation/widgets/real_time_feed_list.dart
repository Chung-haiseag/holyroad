import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:holyroad/features/pilgrimage/domain/repositories/firestore_repository.dart';
import 'package:timeago/timeago.dart' as timeago;

class RealTimeFeedList extends ConsumerWidget {
  const RealTimeFeedList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final visitsAsync = ref.watch(recentVisitsProvider);

    return visitsAsync.when(
      data: (visits) {
        return ListView.builder(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: visits.length,
          itemBuilder: (context, index) {
            final visit = visits[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              elevation: 0,
              shape: RoundedRectangleBorder(
                side: BorderSide(color: Colors.grey.shade200),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 16,
                          backgroundImage: NetworkImage(visit.userPhotoUrl),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          visit.userDisplayName,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const Spacer(),
                        Text(
                          timeago.format(visit.timestamp, locale: 'en_short'), // Use actual localization later
                          style: const TextStyle(color: Colors.grey, fontSize: 12),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(visit.prayerMessage),
                    if (visit.photoUrl.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                                visit.photoUrl,
                                width: double.infinity,
                                fit: BoxFit.contain,
                            ),
                        ),
                    ]
                  ],
                ),
              ),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Text('Error: $err'),
    );
  }
}
