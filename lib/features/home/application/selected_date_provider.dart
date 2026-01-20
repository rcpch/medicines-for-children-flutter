// Provider for selected date on home schedule.
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SelectedDateController extends Notifier<DateTime> {
  @override
  DateTime build() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  void setDate(DateTime date) {
    state = date;
  }
}

final selectedDateProvider = NotifierProvider<SelectedDateController, DateTime>(
  SelectedDateController.new,
);
