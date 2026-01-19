// Medicine create/edit form UI.
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:medicines_for_children_flutter/core/domain/models/medicine.dart';
import 'package:medicines_for_children_flutter/core/domain/active_child_provider.dart';
import 'package:medicines_for_children_flutter/core/platform/image_provider.dart';
import 'package:medicines_for_children_flutter/features/medicines/application/medicine_editor_controller.dart';
import 'package:medicines_for_children_flutter/features/medicines/domain/medicine_draft.dart';

class MedicineFormPage extends ConsumerStatefulWidget {
  const MedicineFormPage({super.key, this.medicineId, this.draft});

  final String? medicineId;
  final MedicineDraft? draft;

  bool get isEditing => medicineId != null;

  @override
  ConsumerState<MedicineFormPage> createState() => _MedicineFormPageState();
}

class _MedicineFormPageState extends ConsumerState<MedicineFormPage> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;
  late final TextEditingController _aliasController;
  late final TextEditingController _doseController;
  late final TextEditingController _doseUnitController;
  late final TextEditingController _routeController;
  late final TextEditingController _frequencyController;
  late final TextEditingController _notesController;

  MedicineType _type = MedicineType.everyday;
  MedicineStatus _status = MedicineStatus.inUse;
  late List<String> _photoUrls;

  @override
  void initState() {
    super.initState();
    final medicine = _loadMedicine();
    final draft = medicine == null ? widget.draft : null;
    _nameController = TextEditingController(text: medicine?.name ?? draft?.name ?? '');
    _aliasController = TextEditingController(text: medicine?.alias ?? draft?.alias ?? '');
    _doseController = TextEditingController(text: medicine?.dose ?? draft?.dose ?? '');
    _doseUnitController = TextEditingController(text: medicine?.doseUnit ?? draft?.doseUnit ?? '');
    _routeController = TextEditingController(text: medicine?.route ?? draft?.route ?? '');
    _frequencyController = TextEditingController(text: medicine?.frequency ?? draft?.frequency ?? '');
    _notesController = TextEditingController(text: medicine?.notes ?? draft?.notes ?? '');
    _type = medicine?.type ?? draft?.type ?? MedicineType.everyday;
    _status = medicine?.status ?? draft?.status ?? MedicineStatus.inUse;
    _photoUrls = _resolvePhotos(medicine, draft);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _aliasController.dispose();
    _doseController.dispose();
    _doseUnitController.dispose();
    _routeController.dispose();
    _frequencyController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    final controller = ref.read(medicineEditorControllerProvider.notifier);
    final state = ref.read(medicineEditorControllerProvider);

    if (state.isSaving) {
      return;
    }

    bool success = false;
    final editingMedicine = _loadMedicine();
    if (widget.isEditing && editingMedicine != null) {
      final updated = editingMedicine.copyWith(
        name: _nameController.text.trim(),
        alias: _aliasController.text.trim(),
        dose: _doseController.text.trim(),
        doseUnit: _doseUnitController.text.trim(),
        route: _routeController.text.trim(),
        frequency: _frequencyController.text.trim(),
        notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
        type: _type,
        status: _status,
        photoUrls: _photoUrls,
        photoUrl: _photoUrls.isEmpty ? null : _photoUrls.first,
      );
      success = await controller.updateMedicine(updated);
    } else {
      final draft = MedicineDraft(
        name: _nameController.text.trim(),
        alias: _aliasController.text.trim(),
        dose: _doseController.text.trim(),
        doseUnit: _doseUnitController.text.trim(),
        route: _routeController.text.trim(),
        frequency: _frequencyController.text.trim(),
        notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
        type: _type,
        status: _status,
        photoUrls: _photoUrls,
        photoUrl: _photoUrls.isEmpty ? null : _photoUrls.first,
      );
      success = await controller.createMedicine(draft) != null;
    }

    if (!mounted) {
      return;
    }

    final nextState = ref.read(medicineEditorControllerProvider);
    if (nextState.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(nextState.errorMessage!)),
      );
      return;
    }

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(widget.isEditing ? 'Medicine updated.' : 'Medicine added.'),
        ),
      );
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final editorState = ref.watch(medicineEditorControllerProvider);
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEditing ? 'Edit medicine' : 'Add medicine'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildTextField(
                  controller: _nameController,
                  label: 'Medicine name',
                  icon: Icons.medication_outlined,
                  validator: (value) => value == null || value.trim().isEmpty
                      ? 'Enter a medicine name'
                      : null,
                ),
                const SizedBox(height: 12),
                _buildTextField(
                  controller: _aliasController,
                  label: 'Known as',
                  icon: Icons.label_outline,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildTextField(
                        controller: _doseController,
                        label: 'Dose',
                        icon: Icons.medication_liquid_outlined,
                        validator: (value) => value == null || value.trim().isEmpty
                            ? 'Enter the dose amount'
                            : null,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildTextField(
                        controller: _doseUnitController,
                        label: 'Unit',
                        icon: Icons.straighten_outlined,
                        validator: (value) => value == null || value.trim().isEmpty
                            ? 'Enter the unit'
                            : null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _buildTextField(
                  controller: _routeController,
                  label: 'Route',
                  icon: Icons.air_outlined,
                  validator: (value) => value == null || value.trim().isEmpty
                      ? 'Enter the route'
                      : null,
                ),
                const SizedBox(height: 12),
                _buildTextField(
                  controller: _frequencyController,
                  label: 'Frequency',
                  icon: Icons.schedule_outlined,
                  validator: (value) => value == null || value.trim().isEmpty
                      ? 'Enter the frequency'
                      : null,
                ),
                const SizedBox(height: 12),
                FormField<MedicineType>(
                  initialValue: _type,
                  builder: (state) {
                    return InputDecorator(
                      decoration: InputDecoration(
                        labelText: 'Type',
                        prefixIcon: const Icon(Icons.category_outlined),
                        errorText: state.errorText,
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<MedicineType>(
                          isExpanded: true,
                          value: state.value,
                          items: MedicineType.values
                              .map((type) => DropdownMenuItem(
                                    value: type,
                                    child: Text(_typeLabel(type)),
                                  ))
                              .toList(),
                          onChanged: (value) {
                            if (value != null) {
                              setState(() {
                                _type = value;
                              });
                              state.didChange(value);
                            }
                          },
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 12),
                FormField<MedicineStatus>(
                  initialValue: _status,
                  builder: (state) {
                    return InputDecorator(
                      decoration: InputDecoration(
                        labelText: 'Status',
                        prefixIcon: const Icon(Icons.verified_outlined),
                        errorText: state.errorText,
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<MedicineStatus>(
                          isExpanded: true,
                          value: state.value,
                          items: MedicineStatus.values
                              .map((status) => DropdownMenuItem(
                                    value: status,
                                    child: Text(_statusLabel(status)),
                                  ))
                              .toList(),
                          onChanged: (value) {
                            if (value != null) {
                              setState(() {
                                _status = value;
                              });
                              state.didChange(value);
                            }
                          },
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _notesController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Notes',
                    prefixIcon: Icon(Icons.notes_outlined),
                  ),
                ),
                const SizedBox(height: 12),
                _buildPhotoSection(context),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: editorState.isSaving ? null : _submit,
                  child: editorState.isSaving
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(widget.isEditing ? 'Save changes' : 'Add medicine'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Medicine? _loadMedicine() {
    if (!widget.isEditing || widget.medicineId == null) {
      return null;
    }
    final child = ref.read(activeChildProvider);
    if (child == null) {
      return null;
    }
    return child.medicines.firstWhere(
      (medicine) => medicine.id == widget.medicineId,
      orElse: () => child.medicines.first,
    );
  }

  List<String> _resolvePhotos(Medicine? medicine, MedicineDraft? draft) {
    final urls = <String>[];
    if (medicine != null) {
      urls.addAll(medicine.photoUrls);
      if (medicine.photoUrl != null && medicine.photoUrl!.trim().isNotEmpty) {
        urls.add(medicine.photoUrl!);
      }
    }
    if (draft != null) {
      urls.addAll(draft.photoUrls);
      if (draft.photoUrl != null && draft.photoUrl!.trim().isNotEmpty) {
        urls.add(draft.photoUrl!);
      }
    }
    return urls.toSet().toList();
  }

  Widget _buildPhotoSection(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Packaging photos', style: theme.textTheme.titleSmall),
        const SizedBox(height: 8),
        if (_photoUrls.isNotEmpty)
          SizedBox(
            height: 96,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemBuilder: (context, index) {
                final path = _photoUrls[index];
                final image = createImageProvider(path);
                return Stack(
                  children: [
                    Container(
                      width: 96,
                      height: 96,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(12),
                        image: image == null
                            ? null
                            : DecorationImage(
                                image: image,
                                fit: BoxFit.cover,
                              ),
                      ),
                      child: image == null ? const Icon(Icons.photo_outlined) : null,
                    ),
                    Positioned(
                      top: 4,
                      right: 4,
                      child: IconButton(
                        icon: const Icon(Icons.close, size: 18),
                        onPressed: () {
                          setState(() {
                            _photoUrls.removeAt(index);
                          });
                        },
                        style: IconButton.styleFrom(
                          backgroundColor: theme.colorScheme.surface,
                          padding: EdgeInsets.zero,
                        ),
                      ),
                    ),
                  ],
                );
              },
              separatorBuilder: (context, index) => const SizedBox(width: 8),
              itemCount: _photoUrls.length,
            ),
          )
        else
          const Text('No photos added yet.'),
        const SizedBox(height: 8),
        Wrap(
          spacing: 12,
          children: [
            OutlinedButton.icon(
              onPressed: () => _pickPhoto(context, ImageSource.camera),
              icon: const Icon(Icons.photo_camera_outlined),
              label: const Text('Take photo'),
            ),
            OutlinedButton.icon(
              onPressed: () => _pickPhoto(context, ImageSource.gallery),
              icon: const Icon(Icons.photo_library_outlined),
              label: const Text('Choose photo'),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _pickPhoto(BuildContext context, ImageSource source) async {
    final picker = ImagePicker();
    try {
      final image = await picker.pickImage(source: source, imageQuality: 85);
      if (image == null) {
        return;
      }
      setState(() {
        _photoUrls.add(image.path);
      });
    } catch (_) {
      if (!context.mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            source == ImageSource.camera
                ? 'Camera not available on this device. Use a device with a camera.'
                : 'Unable to access photos on this device.',
          ),
        ),
      );
    }
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    FormFieldValidator<String>? validator,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
      ),
      validator: validator,
    );
  }

  String _typeLabel(MedicineType type) {
    switch (type) {
      case MedicineType.everyday:
        return 'Everyday';
      case MedicineType.asNeeded:
        return 'As-needed';
      case MedicineType.both:
        return 'Everyday + as-needed';
    }
  }

  String _statusLabel(MedicineStatus status) {
    switch (status) {
      case MedicineStatus.inUse:
        return 'In use';
      case MedicineStatus.noLongerUsed:
        return 'No longer used';
    }
  }
}
