import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:medicines_for_children_flutter/core/domain/models/medicine.dart';
import 'package:medicines_for_children_flutter/core/domain/active_child_provider.dart';
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
                DropdownButtonFormField<MedicineType>(
                  value: _type,
                  decoration: const InputDecoration(
                    labelText: 'Type',
                    prefixIcon: Icon(Icons.category_outlined),
                  ),
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
                    }
                  },
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<MedicineStatus>(
                  value: _status,
                  decoration: const InputDecoration(
                    labelText: 'Status',
                    prefixIcon: Icon(Icons.verified_outlined),
                  ),
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
                    }
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
