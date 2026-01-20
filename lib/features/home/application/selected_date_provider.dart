// Provider for selected date on home schedule.
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Manages the selected date for the home schedule view.
class SelectedDateController extends Notifier<DateTime> {
  // Initializes the selected date to today.
  @override
  DateTime build() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  // Updates the selected date.
  void setDate(DateTime date) {
    state = date;
  }
}

// Provides the selected date state.
final selectedDateProvider = NotifierProvider<SelectedDateController, DateTime>(
  SelectedDateController.new,
);
