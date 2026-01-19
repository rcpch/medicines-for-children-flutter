// Add child profile screen UI.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:medicines_for_children_flutter/core/domain/models/child.dart';
import 'package:medicines_for_children_flutter/features/home/application/primary_carer_controller.dart';

class AddChildPage extends ConsumerStatefulWidget {
  const AddChildPage({super.key});

  @override
  ConsumerState<AddChildPage> createState() => _AddChildPageState();
}

class _AddChildPageState extends ConsumerState<AddChildPage> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _conditionController = TextEditingController();
  final _allergiesController = TextEditingController();
  final _notesController = TextEditingController();
  final _dobController = TextEditingController();
  DateTime? _dateOfBirth;
  bool _isSaving = false;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _conditionController.dispose();
    _allergiesController.dispose();
    _notesController.dispose();
    _dobController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add child')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _firstNameController,
                    decoration: const InputDecoration(
                      labelText: 'First name',
                      prefixIcon: Icon(Icons.badge_outlined),
                    ),
                    textInputAction: TextInputAction.next,
                    validator: (value) => value == null || value.trim().isEmpty
                        ? 'Enter a first name'
                        : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _lastNameController,
                    decoration: const InputDecoration(
                      labelText: 'Last name',
                      prefixIcon: Icon(Icons.badge_outlined),
                    ),
                    textInputAction: TextInputAction.next,
                    validator: (value) => value == null || value.trim().isEmpty
                        ? 'Enter a last name'
                        : null,
                  ),
                  const SizedBox(height: 16),
                  Semantics(
                    button: true,
                    label:
                        'Date of birth. ${_dateOfBirth == null ? 'No date selected.' : _dobController.text}.',
                    child: TextFormField(
                      controller: _dobController,
                      readOnly: true,
                      decoration: const InputDecoration(
                        labelText: 'Date of birth',
                        prefixIcon: Icon(Icons.cake_outlined),
                      ),
                      onTap: _pickDateOfBirth,
                      validator: (_) => _dateOfBirth == null
                          ? 'Choose a date of birth'
                          : null,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _conditionController,
                    decoration: const InputDecoration(
                      labelText: 'Condition',
                      prefixIcon: Icon(Icons.healing_outlined),
                    ),
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _allergiesController,
                    decoration: const InputDecoration(
                      labelText: 'Allergies',
                      helperText: 'Separate multiple allergies with commas.',
                      prefixIcon: Icon(Icons.warning_amber_outlined),
                    ),
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _notesController,
                    decoration: const InputDecoration(
                      labelText: 'Notes for carers',
                      prefixIcon: Icon(Icons.notes_outlined),
                    ),
                    maxLines: 4,
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: _isSaving ? null : _submit,
                      child: _isSaving
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Add child'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickDateOfBirth() async {
    final now = DateTime.now();
    final firstDate = DateTime(now.year - 18, now.month, now.day);
    final lastDate = DateTime(now.year, now.month, now.day);
    var initial = _dateOfBirth ?? DateTime(now.year - 8, now.month, now.day);
    if (initial.isBefore(firstDate)) {
      initial = firstDate;
    } else if (initial.isAfter(lastDate)) {
      initial = lastDate;
    }
    final selected = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: firstDate,
      lastDate: lastDate,
      initialDatePickerMode: DatePickerMode.year,
    );
    if (selected == null) {
      return;
    }
    setState(() {
      _dateOfBirth = selected;
      _dobController.text = DateFormat('d MMM y').format(selected);
    });
  }

  List<String> _parseAllergies(String raw) {
    return raw
        .split(',')
        .map((item) => item.trim())
        .where((item) => item.isNotEmpty)
        .toList();
  }

  Future<void> _submit() async {
    final form = _formKey.currentState;
    if (form == null || !(form.validate())) {
      return;
    }
    setState(() => _isSaving = true);
    final child = Child(
      id: 'child-${DateTime.now().millisecondsSinceEpoch}',
      firstName: _firstNameController.text.trim(),
      lastName: _lastNameController.text.trim(),
      dateOfBirth: _dateOfBirth ?? DateTime(1970, 1, 1),
      condition: _conditionController.text.trim(),
      allergies: _parseAllergies(_allergiesController.text),
      notes: _notesController.text.trim().isEmpty
          ? null
          : _notesController.text.trim(),
      medicines: const [],
      schedules: const [],
      asNeededSchedules: const [],
    );

    final controller = ref.read(primaryCarerControllerProvider.notifier);
    final success = await controller.addChild(child);
    if (!mounted) {
      return;
    }
    setState(() => _isSaving = false);
    if (success) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Child added.')));
      Navigator.of(context).pop();
    } else {
      final error =
          ref.read(primaryCarerControllerProvider).errorMessage ??
          'Unable to add child right now.';
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error)));
    }
  }
}
