import 'package:flutter/material.dart';
import 'package:mis_lab3/models/exam.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

class Calendar extends StatelessWidget {
  final List<Exam> exams;

  const Calendar({super.key, required this.exams});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Exams'),
      ),
      body: SfCalendar(
        view: CalendarView.month,
        dataSource: _getCalendarData(),
        onTap: (CalendarTapDetails details) {
          if (details.targetElement == CalendarElement.calendarCell) {
            _handleDateTap(context, details.date!);
          }
        },
      ),
    );
  }

  _DataSource _getCalendarData() {
    List<Appointment> appointments = [];

    for (var exam in exams) {
      appointments.add(Appointment(
        startTime: exam.dateTime,
        endTime: exam.dateTime.add(const Duration(hours: 2)),
        subject: exam.courseName,
      ));
    }

    return _DataSource(appointments);
  }

  void _handleDateTap(BuildContext context, DateTime selectedDate) {
    List<Exam> selectedExams = exams
        .where((exam) =>
            exam.dateTime.year == selectedDate.year &&
            exam.dateTime.month == selectedDate.month &&
            exam.dateTime.day == selectedDate.day)
        .toList();

    if (selectedExams.isNotEmpty) {
      _showExamsDialog(context, selectedDate, selectedExams);
    }
  }

  void _showExamsDialog(
      BuildContext context, DateTime selectedDate, List<Exam> exams) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Exams on ${selectedDate.toLocal()}'),
          content: Column(
            children: exams
                .map((exam) => Text(
                    '${exam.courseName} - ${exam.dateTime.hour}:${exam.dateTime.minute}'))
                .toList(),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }
}

class _DataSource extends CalendarDataSource {
  _DataSource(List<Appointment> source) {
    appointments = source;
  }
}