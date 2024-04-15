import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:basic_utils/basic_utils.dart';
import 'package:table_calendar/table_calendar.dart';
import 'dart:collection';

class Event {
  final String title;
  Event(this.title);
}

class CalendarPage extends StatefulWidget {
  const CalendarPage({Key? key}) : super(key: key);

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  late DateTime _selectedDay;
  late Map<DateTime, List<Event>> _events;

  @override
  void initState() {
    super.initState();
    _selectedDay = DateTime.now();
    _events = {};
  }

  void _addEvent(DateTime day) {
    showDialog(
      context: context,
      builder: (context) {
        String eventTitle = '';
        return AlertDialog(
          title: Text('Add Event'),
          content: TextField(
            onChanged: (value) {
              eventTitle = value;
            },
            decoration: InputDecoration(hintText: 'Enter event title'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  final event = Event(eventTitle);
                  if (_events[day] == null) {
                    _events[day] = [event];
                  } else {
                    _events[day]!.add(event);
                  }
                  Navigator.pop(context);
                });
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _onDaySelected(DateTime day, DateTime focusedDay) {
    setState(() {
      _selectedDay = day;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("User Calendar")),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Text("Selected Day = " + _selectedDay.toString().split(" ")[0]),
            Container(
              child: TableCalendar(
                locale: "en_US",
                rowHeight: 50,
                headerStyle: HeaderStyle(
                  formatButtonVisible: false,
                  titleCentered: true,
                ),
                availableGestures: AvailableGestures.all,
                selectedDayPredicate: (day) => isSameDay(day, _selectedDay),
                focusedDay: _selectedDay,
                firstDay: DateTime.utc(2014, 01, 01),
                lastDay: DateTime.utc(2034, 01, 01),
                onDaySelected: _onDaySelected,
                eventLoader: (day) => _events[day] ?? [],
                onDayLongPressed: (selectedDay, focusedDay) {
                  _addEvent(selectedDay);
                },
              ),
            ),
            SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: _events[_selectedDay]?.length ?? 0,
                itemBuilder: (context, index) {
                  final event = _events[_selectedDay]![index];
                  return ListTile(
                    title: Text(event.title),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}