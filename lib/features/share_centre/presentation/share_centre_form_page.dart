// Share Centre submit form UI.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:medicines_for_children_flutter/app/router/app_router.dart';
import 'package:medicines_for_children_flutter/core/domain/active_child_provider.dart';
import 'package:medicines_for_children_flutter/features/share_centre/application/share_centre_providers.dart';

class ShareCentreCreatePage extends ConsumerStatefulWidget {
  const ShareCentreCreatePage({super.key});

  @override
  ConsumerState<ShareCentreCreatePage> createState() =>
      _ShareCentreCreatePageState();
}

class _ShareCentreCreatePageState extends ConsumerState<ShareCentreCreatePage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _notesController = TextEditingController();
  late DateTime _dateFrom;
  late DateTime _dateTo;
  bool _digital = true;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _dateFrom = DateTime(now.year, now.month, now.day);
    _dateTo = _dateFrom.add(const Duration(days: 7));
  }

  @override
  void dispose() {
    _emailController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final child = ref.watch(activeChildProvider);
    if (child == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('New share')),
        body: const Padding(
          padding: EdgeInsets.all(16),
          child: Text('No child profile available yet.'),
        ),
      );
    }

    final actionState = ref.watch(shareCentreControllerProvider);
    final controller = ref.read(shareCentreControllerProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: const Text('New share')),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(
                'Invite a carer to view this schedule for a limited time.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Carer email',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Enter an email address.';
                  }
                  if (!value.contains('@')) {
                    return 'Enter a valid email address.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _DateCard(
                      label: 'Start date',
                      date: _dateFrom,
                      onTap: actionState.isSaving
                          ? null
                          : () async {
                              final selected = await _pickDate(
                                context,
                                initialDate: _dateFrom,
                                firstDate: DateTime.now(),
                              );
                              if (selected == null) {
                                return;
                              }
                              setState(() {
                                _dateFrom = selected;
                                if (_dateTo.isBefore(_dateFrom)) {
                                  _dateTo = _dateFrom.add(
                                    const Duration(days: 1),
                                  );
                                }
                              });
                            },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _DateCard(
                      label: 'End date',
                      date: _dateTo,
                      onTap: actionState.isSaving
                          ? null
                          : () async {
                              final selected = await _pickDate(
                                context,
                                initialDate: _dateTo,
                                firstDate: _dateFrom,
                              );
                              if (selected == null) {
                                return;
                              }
                              setState(() {
                                _dateTo = selected;
                              });
                            },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SwitchListTile.adaptive(
                value: _digital,
                title: const Text('Digital link access'),
                subtitle: const Text('Provide a secure link instead of a PDF.'),
                onChanged: actionState.isSaving
                    ? null
                    : (value) {
                        setState(() {
                          _digital = value;
                        });
                      },
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _notesController,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: 'Notes (optional)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: actionState.isSaving
                    ? null
                    : () async {
                        if (!(_formKey.currentState?.validate() ?? false)) {
                          return;
                        }
                        final schedule = await controller.createSchedule(
                          childId: child.id,
                          email: _emailController.text.trim(),
                          dateFrom: _dateFrom,
                          dateTo: _dateTo,
                          digital: _digital,
                          notes: _notesController.text.trim().isEmpty
                              ? null
                              : _notesController.text.trim(),
                        );
                        if (schedule != null && context.mounted) {
                          context.goNamed(
                            AppRoute.shareCentreDetail.name,
                            pathParameters: {'shareId': schedule.apiId},
                          );
                        }
                      },
                child: actionState.isSaving
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Create share'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<DateTime?> _pickDate(
    BuildContext context, {
    required DateTime initialDate,
    required DateTime firstDate,
  }) {
    return showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: initialDate.add(const Duration(days: 365)),
    );
  }
}

class _DateCard extends StatelessWidget {
  const _DateCard({
    required this.label,
    required this.date,
    required this.onTap,
  });

  final String label;
  final DateTime date;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final formatted = DateFormat.yMMMd().format(date);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Ink(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Theme.of(context).colorScheme.outlineVariant,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: 4),
            Text(formatted, style: Theme.of(context).textTheme.titleSmall),
          ],
        ),
      ),
    );
  }
}
