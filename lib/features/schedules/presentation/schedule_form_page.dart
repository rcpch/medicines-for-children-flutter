import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:medicines_for_children_flutter/core/domain/active_child_provider.dart';
import 'package:medicines_for_children_flutter/core/domain/models/medicine.dart';
import 'package:medicines_for_children_flutter/core/domain/models/schedule.dart';
import 'package:medicines_for_children_flutter/features/schedules/application/schedule_editor_controller.dart';
import 'package:medicines_for_children_flutter/features/schedules/domain/schedule_draft.dart';

class ScheduleFormPage extends ConsumerStatefulWidget {
  const ScheduleFormPage({super.key, this.scheduleId});

  final String? scheduleId;

  bool get isEditing => scheduleId != null;

  @override
  ConsumerState<ScheduleFormPage> createState() => _ScheduleFormPageState();
}

class _ScheduleFormPageState extends ConsumerState<ScheduleFormPage> {
  final _formKey = GlobalKey<FormState>();
  DateTime? _startDate;
  DateTime? _endDate;
  List<bool> _weekdays = List<bool>.filled(7, true);
  List<TimeOfDay> _times = [];
  String? _selectedMedicineId;

  @override
  void initState() {
    super.initState();
    final schedule = _loadSchedule();
    _startDate = schedule?.startDate ?? DateTime.now();
    _endDate = schedule?.endDate ?? DateTime.now().add(const Duration(days: 7));
    _weekdays = schedule?.weekdaysActive.toList() ?? List<bool>.filled(7, true);
    _times = schedule?.times
            .map((time) => _parseTime(time))
            .whereType<TimeOfDay>()
            .toList() ??
        [const TimeOfDay(hour: 8, minute: 0)];
    _selectedMedicineId = schedule?.medicineId;
  }

  @override
  Widget build(BuildContext context) {
    final child = ref.watch(activeChildProvider);
    final editorState = ref.watch(scheduleEditorControllerProvider);

    if (child == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Schedule')),
        body: const Padding(
          padding: EdgeInsets.all(16),
          child: Text('No child profile available.'),
        ),
      );
    }

    if (child.medicines.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Schedule')),
        body: const Padding(
          padding: EdgeInsets.all(16),
          child: Text('Add a medicine before creating a schedule.'),
        ),
      );
    }

    _selectedMedicineId ??= child.medicines.first.id;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEditing ? 'Edit schedule' : 'Add schedule'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                DropdownButtonFormField<String>(
                  value: _selectedMedicineId,
                  decoration: const InputDecoration(
                    labelText: 'Medicine',
                    prefixIcon: Icon(Icons.medication_outlined),
                  ),
                  items: child.medicines
                      .where((medicine) => medicine.status == MedicineStatus.inUse)
                      .map((medicine) => DropdownMenuItem(
                            value: medicine.id,
                            child: Text(medicine.name),
                          ))
                      .toList(),
                  onChanged: (value) => setState(() => _selectedMedicineId = value),
                  validator: (value) => value == null ? 'Choose a medicine' : null,
                ),
                const SizedBox(height: 16),
                _DateField(
                  label: 'Start date',
                  value: _startDate,
                  onPick: (date) => setState(() => _startDate = date),
                ),
                const SizedBox(height: 12),
                _DateField(
                  label: 'End date',
                  value: _endDate,
                  onPick: (date) => setState(() => _endDate = date),
                ),
                const SizedBox(height: 16),
                Text('Weekdays', style: Theme.of(context).textTheme.titleSmall),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: List.generate(7, (index) {
                    final label = DateFormat.E().format(DateTime(2024, 1, index + 1));
                    return FilterChip(
                      label: Text(label),
                      selected: _weekdays[index],
                      onSelected: (selected) {
                        setState(() {
                          _weekdays[index] = selected;
                        });
                      },
                    );
                  }),
                ),
                const SizedBox(height: 16),
                Text('Times per day', style: Theme.of(context).textTheme.titleSmall),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final time in _times)
                      InputChip(
                        label: Text(time.format(context)),
                        onDeleted: _times.length > 1
                            ? () {
                                setState(() {
                                  _times.remove(time);
                                });
                              }
                            : null,
                      ),
                    ActionChip(
                      label: const Text('Add time'),
                      avatar: const Icon(Icons.add_alarm_outlined),
                      onPressed: _pickTime,
                    ),
                  ],
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
                      : Text(widget.isEditing ? 'Save schedule' : 'Add schedule'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }
    final startDate = _startDate;
    final endDate = _endDate;
    if (startDate == null || endDate == null) {
      return;
    }
    if (endDate.isBefore(startDate)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('End date must be after the start date.')),
      );
      return;
    }
    if (_times.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Add at least one time.')),
      );
      return;
    }

    final controller = ref.read(scheduleEditorControllerProvider.notifier);
    bool success = false;
    if (widget.isEditing && widget.scheduleId != null) {
      final schedule = _loadSchedule();
      if (schedule == null) {
        return;
      }
      success = await controller.updateSchedule(
        schedule.copyWith(
          medicineId: _selectedMedicineId!,
          startDate: startDate,
          endDate: endDate,
          weekdaysActive: _weekdays,
          times: _times.map(_formatTime).toList(),
        ),
      );
    } else {
      final draft = ScheduleDraft(
        medicineId: _selectedMedicineId!,
        startDate: startDate,
        endDate: endDate,
        weekdaysActive: _weekdays,
        times: _times.map(_formatTime).toList(),
      );
      success = await controller.createSchedule(draft) != null;
    }

    if (!mounted) {
      return;
    }
    final state = ref.read(scheduleEditorControllerProvider);
    if (state.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(state.errorMessage!)),
      );
      return;
    }
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(widget.isEditing ? 'Schedule updated.' : 'Schedule added.'),
        ),
      );
      Navigator.of(context).pop();
    }
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _times.isEmpty ? const TimeOfDay(hour: 8, minute: 0) : _times.last,
    );
    if (picked != null) {
      setState(() {
        _times.add(picked);
        _times.sort((a, b) => a.hour == b.hour ? a.minute.compareTo(b.minute) : a.hour.compareTo(b.hour));
      });
    }
  }

  MedicineSchedule? _loadSchedule() {
    if (!widget.isEditing || widget.scheduleId == null) {
      return null;
    }
    final child = ref.read(activeChildProvider);
    if (child == null || child.schedules.isEmpty) {
      return null;
    }
    return child.schedules.firstWhere(
      (schedule) => schedule.id == widget.scheduleId,
      orElse: () => child.schedules.first,
    );
  }

  String _formatTime(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  TimeOfDay? _parseTime(String raw) {
    final parts = raw.split(':');
    if (parts.length != 2) {
      return null;
    }
    final hour = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1]);
    if (hour == null || minute == null) {
      return null;
    }
    return TimeOfDay(hour: hour, minute: minute);
  }
}

class _DateField extends StatelessWidget {
  const _DateField({
    required this.label,
    required this.value,
    required this.onPick,
  });

  final String label;
  final DateTime? value;
  final ValueChanged<DateTime> onPick;

  @override
  Widget build(BuildContext context) {
    final text = value == null ? 'Select date' : DateFormat.yMMMd().format(value!);
    return InkWell(
      onTap: () async {
        final now = DateTime.now();
        final picked = await showDatePicker(
          context: context,
          initialDate: value ?? now,
          firstDate: DateTime(now.year - 2),
          lastDate: DateTime(now.year + 5),
        );
        if (picked != null) {
          onPick(picked);
        }
      },
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: const Icon(Icons.event_outlined),
        ),
        child: Text(text),
      ),
    );
  }
}
