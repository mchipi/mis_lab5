import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:mis_lab3/models/exam.dart';

class CreateExamWidget extends StatefulWidget {
  final Function(Exam) addExam;

  const CreateExamWidget({required this.addExam, Key? key}) : super(key: key);

  @override
  CreateExamWidgetState createState() => CreateExamWidgetState();
}

class CreateExamWidgetState extends State<CreateExamWidget> {
  final TextEditingController subjectController = TextEditingController();
  DateTime date = DateTime.now();
  TimeOfDay time = TimeOfDay.now();

  Future<void> selectDate(BuildContext context) async {
    final DateTime? datePicked = await showDatePicker(
      context: context,
      initialDate: date,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (datePicked != null && datePicked != date) {
      setState(() {
        date = datePicked;
      });
    }
  }

  void selectTime(BuildContext context) async {
    final TimeOfDay? timePicked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(date),
    );

    if (timePicked != null && timePicked != time) {
      setState(() {
        date = DateTime(
          date.year,
          date.month,
          date.day,
          timePicked.hour,
          timePicked.minute,
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCourseNameTextField(),
            const SizedBox(height: 30),
            _buildDateRow(context),
            const SizedBox(height: 20),
            _buildTimeRow(context),
            const SizedBox(height: 50),
            _buildAddExamButton(context),
          ],
        ),
      ),
    );
  }

  TextField _buildCourseNameTextField() {
    return TextField(
      controller: subjectController,
      decoration: const InputDecoration(labelText: 'Course Name'),
    );
  }

  Row _buildDateRow(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text('Date: ${date.toLocal().toString().split(' ')[0]}'),
        ElevatedButton(
          child: const Text('Select Date'),
          onPressed: () => selectDate(context),
        ),
      ],
    );
  }

  Row _buildTimeRow(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text('Time: ${date.toLocal().toString().split(' ')[1].substring(0, 5)}'),
        ElevatedButton(
          onPressed: () => selectTime(context),
          child: const Text('Select Time'),
        ),
      ],
    );
  }

  ElevatedButton _buildAddExamButton(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        Exam exam = Exam(
          courseName: subjectController.text,
          dateTime: date,
        );
        widget.addExam(exam);
        Navigator.pop(context);
      },
      child: const Text('Add Exam'),
    );
  }
}
