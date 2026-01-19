// As-needed dose record screen UI.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:medicines_for_children_flutter/core/domain/active_child_provider.dart';
import 'package:medicines_for_children_flutter/core/domain/models/medicine.dart';
import 'package:medicines_for_children_flutter/features/schedules/application/as_needed_record_controller.dart';

class AsNeededRecordPage extends ConsumerStatefulWidget {
  const AsNeededRecordPage({super.key});

  @override
  ConsumerState<AsNeededRecordPage> createState() => _AsNeededRecordPageState();
}

class _AsNeededRecordPageState extends ConsumerState<AsNeededRecordPage> {
  final _notesController = TextEditingController();
  String? _selectedMedicineId;
  DateTime _dateTime = DateTime.now();

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final child = ref.watch(activeChildProvider);
    final recordState = ref.watch(asNeededRecordControllerProvider);

    if (child == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Record as-needed')),
        body: const Padding(
          padding: EdgeInsets.all(16),
          child: Text('No child profile available.'),
        ),
      );
    }

    final candidates = child.medicines.where((medicine) {
      return medicine.status == MedicineStatus.inUse &&
          (medicine.type == MedicineType.asNeeded ||
              medicine.type == MedicineType.both);
    }).toList();

    if (candidates.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Record as-needed')),
        body: const Padding(
          padding: EdgeInsets.all(16),
          child: Text('No as-needed medicines available.'),
        ),
      );
    }

    _selectedMedicineId ??= candidates.first.id;

    return Scaffold(
      appBar: AppBar(title: const Text('Record as-needed')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              FormField<String>(
                initialValue: _selectedMedicineId,
                builder: (state) {
                  return InputDecorator(
                    decoration: InputDecoration(
                      labelText: 'Medicine',
                      prefixIcon: const Icon(Icons.medication_outlined),
                      errorText: state.errorText,
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        isExpanded: true,
                        value: state.value,
                        items: candidates
                            .map(
                              (medicine) => DropdownMenuItem(
                                value: medicine.id,
                                child: Text(medicine.name),
                              ),
                            )
                            .toList(),
                        onChanged: (value) {
                          setState(() => _selectedMedicineId = value);
                          state.didChange(value);
                        },
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
              _DateTimeField(
                label: 'Date & time',
                value: _dateTime,
                onPick: (value) => setState(() => _dateTime = value),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _notesController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Notes (optional)',
                  prefixIcon: Icon(Icons.notes_outlined),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: recordState.isSaving ? null : _submit,
                child: recordState.isSaving
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Record dose'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (_selectedMedicineId == null) {
      return;
    }
    final success = await ref
        .read(asNeededRecordControllerProvider.notifier)
        .recordAdministration(
          medicineId: _selectedMedicineId!,
          dateTime: _dateTime,
          notes: _notesController.text.trim().isEmpty
              ? null
              : _notesController.text.trim(),
        );
    if (!mounted) {
      return;
    }
    final state = ref.read(asNeededRecordControllerProvider);
    if (state.errorMessage != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(state.errorMessage!)));
      return;
    }
    if (success) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('As-needed dose recorded.')));
      Navigator.of(context).pop();
    }
  }
}

class _DateTimeField extends StatelessWidget {
  const _DateTimeField({
    required this.label,
    required this.value,
    required this.onPick,
  });

  final String label;
  final DateTime value;
  final ValueChanged<DateTime> onPick;

  @override
  Widget build(BuildContext context) {
    final formatted = DateFormat('d MMM y · h:mm a').format(value);
    return Semantics(
      button: true,
      label: '$label. Selected $formatted.',
      child: InkWell(
        onTap: () async {
          final date = await showDatePicker(
            context: context,
            initialDate: value,
            firstDate: DateTime(value.year - 2),
            lastDate: DateTime(value.year + 2),
          );
          if (!context.mounted) {
            return;
          }
          if (date == null) {
            return;
          }
          final time = await showTimePicker(
            context: context,
            initialTime: TimeOfDay.fromDateTime(value),
          );
          if (!context.mounted) {
            return;
          }
          if (time == null) {
            return;
          }
          onPick(
            DateTime(date.year, date.month, date.day, time.hour, time.minute),
          );
        },
        child: InputDecorator(
          decoration: InputDecoration(
            labelText: label,
            prefixIcon: const Icon(Icons.access_time_outlined),
          ),
          child: Text(formatted),
        ),
      ),
    );
  }
}
