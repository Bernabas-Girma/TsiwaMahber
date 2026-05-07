import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tsiwa_mahber/core/constants/app_constants.dart';
import 'package:tsiwa_mahber/core/theme/app_theme.dart';
import 'package:tsiwa_mahber/features/tsiwa/data/tsiwa_repository.dart';
import 'package:tsiwa_mahber/features/tsiwa/domain/tsiwa_mahber.dart';
import 'package:tsiwa_mahber/core/l10n/app_strings.dart';

class TsiwaFormScreen extends StatefulWidget {
  final String areaId;
  final TsiwaMahber? existingTsiwa;

  const TsiwaFormScreen({super.key, required this.areaId, this.existingTsiwa});

  @override
  State<TsiwaFormScreen> createState() => _TsiwaFormScreenState();
}

class _TsiwaFormScreenState extends State<TsiwaFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _tsiwaRepository = TsiwaRepository();

  late final TextEditingController _nameController;
  late final TextEditingController _churchNameController;
  late final TextEditingController _saintNameController;
  late final TextEditingController _locationController;
  late final TextEditingController _descriptionController;

  late final TextEditingController _monthlyTsiwaDayController;
  late final TextEditingController _monthlyTsiwaDayNoteController;

  late bool _isActive;
  late bool _isArchived;
  bool _isSaving = false;
  bool _isUploadingImage = false;
  String _profileImageUrl = '';

  late List<YearlyZikirEntry> _yearlyZikir;

  bool get _isEditing => widget.existingTsiwa != null;

  @override
  void initState() {
    super.initState();
    final t = widget.existingTsiwa;

    _nameController = TextEditingController(text: t?.name ?? '');
    _churchNameController = TextEditingController(text: t?.churchName ?? '');
    _saintNameController = TextEditingController(text: t?.saintName ?? '');
    _locationController = TextEditingController(text: t?.location ?? '');
    _descriptionController = TextEditingController(text: t?.description ?? '');

    _monthlyTsiwaDayController = TextEditingController(
      text: t?.monthlyTsiwaDay.toString() ?? '1',
    );
    _monthlyTsiwaDayNoteController = TextEditingController(
      text: t?.monthlyTsiwaDayNote ?? '',
    );

    _yearlyZikir = List.from(t?.yearlyZikir ?? []);

    _isActive = t?.isActive ?? true;
    _isArchived = t?.isArchived ?? false;
    _profileImageUrl = t?.profileImageUrl ?? '';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _churchNameController.dispose();
    _saintNameController.dispose();
    _locationController.dispose();
    _descriptionController.dispose();
    _monthlyTsiwaDayController.dispose();
    _monthlyTsiwaDayNoteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? S.editTsiwa : S.newTsiwa),
        actions: [
          if (_isSaving)
            const Padding(
              padding: EdgeInsets.all(16),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppTheme.primary,
                ),
              ),
            )
          else
            IconButton(icon: const Icon(Icons.check), onPressed: _save),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildSectionHeader(S.basicInfo),
            const SizedBox(height: 12),
            _buildProfileImagePicker(),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _nameController,
              label: S.tsiwaName,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return S.enterTsiwaName;
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            _buildTextField(
              controller: _churchNameController,
              label: S.churchName,
            ),
            const SizedBox(height: 12),
            _buildTextField(
              controller: _saintNameController,
              label: S.saintName,
            ),
            const SizedBox(height: 12),
            _buildTextField(controller: _locationController, label: S.location),
            const SizedBox(height: 12),
            _buildTextField(
              controller: _descriptionController,
              label: S.description,
              maxLines: 3,
            ),
            const SizedBox(height: 24),
            _buildSectionHeader(S.monthlyTsiwaDay),
            const SizedBox(height: 8),
            _buildNumberField(
              controller: _monthlyTsiwaDayController,
              label: S.dayRange,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return S.enterDay;
                }
                final day = int.tryParse(value);
                if (day == null || day < 1 || day > 30) {
                  return S.dayMustBe1to30;
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            _buildTextField(
              controller: _monthlyTsiwaDayNoteController,
              label: S.note,
            ),
            const SizedBox(height: 24),
            _buildYearlyZikirSection(),
            const SizedBox(height: 24),
            _buildSectionHeader(S.status),
            const SizedBox(height: 8),
            Card(
              child: Column(
                children: [
                  SwitchListTile(
                    title: Text(S.active),
                    subtitle: Text(S.tsiwaIsActive),
                    value: _isActive,
                    onChanged: (value) => setState(() => _isActive = value),
                  ),
                  if (_isEditing) ...[
                    const Divider(height: 1),
                    SwitchListTile(
                      title: Text(S.archive),
                      subtitle: Text(S.archiveTsiwa),
                      value: _isArchived,
                      onChanged: (value) => setState(() => _isArchived = value),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 32),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: BorderSide(color: Colors.grey.shade700),
                    ),
                    child: Text(S.cancel),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isSaving ? null : _save,
                    child: Text(_isEditing ? S.save : S.create),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildYearlyZikirSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(child: _buildSectionHeader(S.yearlyZikirTitle)),
            IconButton(
              icon: const Icon(Icons.add_circle, color: AppTheme.primary),
              onPressed: _addZikirEntry,
              tooltip: S.addYearlyZikir,
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (_yearlyZikir.isEmpty)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                S.noYearlyZikirYet,
                style: const TextStyle(color: AppTheme.textMuted, fontSize: 13),
              ),
            ),
          )
        else
          ..._yearlyZikir.asMap().entries.map((entry) {
            final index = entry.key;
            final zikir = entry.value;
            final monthName = AppConstants.ethiopianMonthName(zikir.month);
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: AppTheme.secondary.withValues(alpha: 0.15),
                  child: const Icon(
                    Icons.auto_awesome,
                    color: AppTheme.secondary,
                    size: 18,
                  ),
                ),
                title: Text('$monthName ${zikir.day}'),
                subtitle: zikir.note.isNotEmpty
                    ? Text(
                        zikir.note,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppTheme.textMuted,
                        ),
                      )
                    : null,
                trailing: IconButton(
                  icon: const Icon(
                    Icons.delete_outline,
                    color: Colors.red,
                    size: 20,
                  ),
                  onPressed: () => _removeZikirEntry(index),
                ),
              ),
            );
          }),
      ],
    );
  }

  void _addZikirEntry() {
    int selectedMonth = 1;
    int selectedDay = 1;
    final noteController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(S.addYearlyZikir),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      S.month,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppTheme.textMuted,
                      ),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<int>(
                      initialValue: selectedMonth,
                      items: List.generate(AppConstants.tsiwaMonthCount, (i) {
                        return DropdownMenuItem(
                          value: i + 1,
                          child: Text(AppConstants.ethiopianMonths[i]),
                        );
                      }),
                      onChanged: (val) {
                        if (val != null) {
                          setDialogState(() => selectedMonth = val);
                        }
                      },
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      S.day,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppTheme.textMuted,
                      ),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<int>(
                      initialValue: selectedDay,
                      items: List.generate(30, (i) {
                        return DropdownMenuItem(
                          value: i + 1,
                          child: Text('${i + 1}'),
                        );
                      }),
                      onChanged: (val) {
                        if (val != null) {
                          setDialogState(() => selectedDay = val);
                        }
                      },
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: noteController,
                      decoration: InputDecoration(
                        labelText: S.note,
                        border: const OutlineInputBorder(),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: Text(S.cancel),
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _yearlyZikir.add(
                        YearlyZikirEntry(
                          month: selectedMonth,
                          day: selectedDay,
                          note: noteController.text.trim(),
                        ),
                      );
                    });
                    Navigator.pop(ctx);
                  },
                  child: Text(S.add),
                ),
              ],
            );
          },
        );
      },
    ).then((_) => noteController.dispose());
  }

  void _removeZikirEntry(int index) {
    setState(() {
      _yearlyZikir.removeAt(index);
    });
  }

  Widget _buildProfileImagePicker() {
    return Center(
      child: GestureDetector(
        onTap: _isUploadingImage ? null : _pickAndUploadImage,
        child: Column(
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: AppTheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppTheme.primary.withValues(alpha: 0.3),
                ),
                image: _profileImageUrl.isNotEmpty
                    ? DecorationImage(
                        image: NetworkImage(_profileImageUrl),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: _isUploadingImage
                  ? const Center(
                      child: SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    )
                  : _profileImageUrl.isEmpty
                      ? const Icon(Icons.add_a_photo,
                          color: AppTheme.primary, size: 32)
                      : null,
            ),
            const SizedBox(height: 8),
            Text(
              _profileImageUrl.isEmpty
                  ? S.noProfileImage
                  : S.tapToViewDetails,
              style: const TextStyle(
                fontSize: 12,
                color: AppTheme.textMuted,
              ),
            ),
            if (_profileImageUrl.isNotEmpty)
              TextButton(
                onPressed: () =>
                    setState(() => _profileImageUrl = ''),
                child: Text(
                  S.delete,
                  style: const TextStyle(
                      color: Colors.red, fontSize: 12),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickAndUploadImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 512,
      maxHeight: 512,
      imageQuality: 70,
    );
    if (picked == null) return;

    setState(() => _isUploadingImage = true);

    try {
      final file = File(picked.path);
      final tsiwaId = widget.existingTsiwa?.id ?? 'new_${DateTime.now().millisecondsSinceEpoch}';
      final ref = FirebaseStorage.instance
          .ref()
          .child('tsiwa_images')
          .child('$tsiwaId.jpg');

      await ref.putFile(
        file,
        SettableMetadata(contentType: 'image/jpeg'),
      );

      final url = await ref.getDownloadURL();
      setState(() => _profileImageUrl = url);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${S.dataSaveFailed}: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isUploadingImage = false);
      }
    }
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: AppTheme.primary,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(labelText: label),
      maxLines: maxLines,
      validator: validator,
    );
  }

  Widget _buildNumberField({
    required TextEditingController controller,
    required String label,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(labelText: label),
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      validator: validator,
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final tsiwa = TsiwaMahber(
        id: widget.existingTsiwa?.id ?? '',
        areaId: widget.areaId,
        name: _nameController.text.trim(),
        churchName: _churchNameController.text.trim(),
        saintName: _saintNameController.text.trim(),
        location: _locationController.text.trim(),
        description: _descriptionController.text.trim(),
        monthlyTsiwaDay: int.parse(_monthlyTsiwaDayController.text.trim()),
        monthlyTsiwaDayNote: _monthlyTsiwaDayNoteController.text.trim(),
        yearlyZikir: _yearlyZikir,
        isActive: _isActive,
        isArchived: _isArchived,
        profileImageUrl: _profileImageUrl,
        currentRotationIndex: widget.existingTsiwa?.currentRotationIndex ?? 0,
        memberCount: widget.existingTsiwa?.memberCount ?? 0,
        museCount: widget.existingTsiwa?.museCount ?? 0,
      );

      if (_isEditing) {
        await _tsiwaRepository.updateTsiwa(widget.areaId, tsiwa);
      } else {
        await _tsiwaRepository.createTsiwa(widget.areaId, tsiwa);
      }

      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(S.dataSaveFailed)));
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }
}
