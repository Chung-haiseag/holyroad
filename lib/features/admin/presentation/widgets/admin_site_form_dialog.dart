import 'package:flutter/material.dart';
import 'package:holyroad/features/map/domain/entities/holy_site_entity.dart';

class AdminSiteFormDialog extends StatefulWidget {
  final HolySite? site; // null = create mode
  const AdminSiteFormDialog({super.key, this.site});

  @override
  State<AdminSiteFormDialog> createState() => _AdminSiteFormDialogState();
}

class _AdminSiteFormDialogState extends State<AdminSiteFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _latController;
  late final TextEditingController _lngController;
  late final TextEditingController _imageUrlController;

  bool get isEditMode => widget.site != null;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.site?.name ?? '');
    _descriptionController = TextEditingController(text: widget.site?.description ?? '');
    _latController = TextEditingController(text: widget.site?.latitude.toString() ?? '');
    _lngController = TextEditingController(text: widget.site?.longitude.toString() ?? '');
    _imageUrlController = TextEditingController(text: widget.site?.imageUrl ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _latController.dispose();
    _lngController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(isEditMode ? '성지 수정' : '새 성지 추가'),
      content: SizedBox(
        width: 480,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: '성지 이름', border: OutlineInputBorder()),
                  validator: (v) => (v == null || v.isEmpty) ? '이름을 입력하세요' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(labelText: '설명', border: OutlineInputBorder()),
                  maxLines: 3,
                  validator: (v) => (v == null || v.isEmpty) ? '설명을 입력하세요' : null,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _latController,
                        decoration: const InputDecoration(labelText: '위도', border: OutlineInputBorder()),
                        keyboardType: TextInputType.number,
                        validator: (v) {
                          if (v == null || v.isEmpty) return '위도 입력';
                          if (double.tryParse(v) == null) return '숫자 입력';
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _lngController,
                        decoration: const InputDecoration(labelText: '경도', border: OutlineInputBorder()),
                        keyboardType: TextInputType.number,
                        validator: (v) {
                          if (v == null || v.isEmpty) return '경도 입력';
                          if (double.tryParse(v) == null) return '숫자 입력';
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _imageUrlController,
                  decoration: const InputDecoration(labelText: '이미지 URL', border: OutlineInputBorder()),
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('취소')),
        FilledButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              final result = HolySite(
                id: widget.site?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
                name: _nameController.text,
                description: _descriptionController.text,
                latitude: double.parse(_latController.text),
                longitude: double.parse(_lngController.text),
                imageUrl: _imageUrlController.text,
              );
              Navigator.of(context).pop(result);
            }
          },
          child: Text(isEditMode ? '수정' : '추가'),
        ),
      ],
    );
  }
}
