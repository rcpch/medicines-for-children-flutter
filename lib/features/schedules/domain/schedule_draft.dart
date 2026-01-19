// Draft model for schedule form edits.
class ScheduleDraft {
  const ScheduleDraft({
    required this.medicineId,
    required this.startDate,
    required this.endDate,
    required this.times,
    required this.weekdaysActive,
  });

  final String medicineId;
  final DateTime startDate;
  final DateTime endDate;
  final List<String> times;
  final List<bool> weekdaysActive;
}
