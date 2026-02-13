import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:holyroad/features/admin/domain/repositories/admin_repository.dart';
import 'package:holyroad/features/admin/presentation/providers/admin_providers.dart';
import 'package:holyroad/features/admin/presentation/widgets/admin_user_detail_dialog.dart';

class AdminUsersScreen extends ConsumerWidget {
  const AdminUsersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usersAsync = ref.watch(adminUsersProvider);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('사용자 관리'),
        automaticallyImplyLeading: false,
      ),
      body: usersAsync.when(
        data: (users) {
          if (users.isEmpty) {
            return const Center(child: Text('사용자가 없습니다.'));
          }
          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: SizedBox(
              width: double.infinity,
              child: DataTable(
                headingRowColor: WidgetStateProperty.all(colorScheme.surfaceContainerHighest.withValues(alpha: 0.5)),
                border: TableBorder.all(color: colorScheme.outlineVariant, borderRadius: BorderRadius.circular(8)),
                columns: const [
                  DataColumn(label: Text('사용자')),
                  DataColumn(label: Text('이메일')),
                  DataColumn(label: Text('레벨'), numeric: true),
                  DataColumn(label: Text('역할')),
                  DataColumn(label: Text('상세')),
                ],
                rows: users.map((user) => DataRow(
                  cells: [
                    DataCell(Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircleAvatar(
                          radius: 14,
                          backgroundColor: colorScheme.primaryContainer,
                          backgroundImage: user.photoUrl.isNotEmpty ? NetworkImage(user.photoUrl) : null,
                          child: user.photoUrl.isEmpty ? Text(user.displayName[0], style: TextStyle(fontSize: 12, color: colorScheme.onPrimaryContainer)) : null,
                        ),
                        const SizedBox(width: 8),
                        Text(user.displayName, style: const TextStyle(fontWeight: FontWeight.w500)),
                      ],
                    )),
                    DataCell(Text(user.email)),
                    DataCell(Text('${user.level}')),
                    DataCell(
                      DropdownButton<String>(
                        value: user.role,
                        underline: const SizedBox.shrink(),
                        isDense: true,
                        items: const [
                          DropdownMenuItem(value: 'user', child: Text('user')),
                          DropdownMenuItem(value: 'admin', child: Text('admin')),
                        ],
                        onChanged: (newRole) async {
                          if (newRole != null && newRole != user.role) {
                            await ref.read(adminRepositoryProvider).updateUserRole(user.uid, newRole);
                            ref.invalidate(adminUsersProvider);
                          }
                        },
                      ),
                    ),
                    DataCell(
                      IconButton(
                        icon: Icon(Icons.info_outline, size: 18, color: colorScheme.primary),
                        tooltip: '상세 보기',
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (ctx) => AdminUserDetailDialog(user: user),
                          );
                        },
                      ),
                    ),
                  ],
                )).toList(),
              ),
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }
}
