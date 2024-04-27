import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:basic_utils/basic_utils.dart';
import 'package:table_calendar/table_calendar.dart';
import 'dart:collection';

class Event {
  final String id;
  final String title;

  Event({required this.id, required this.title});
}

class CalendarPage extends StatefulWidget {
  const CalendarPage({Key? key}) : super(key: key);

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  late DateTime _selectedDay;
  late Map<DateTime, List<Event>> _events;
  bool isDarkMode = false;

  Future<void> getDarkModeValue() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      isDarkMode = prefs.getBool('isDarkMode') ?? false;
    });
  }

  @override
  void initState() {
    super.initState();
    getDarkModeValue();
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
                  final eventId = UniqueKey().toString();
                  final event = Event(id: eventId, title: eventTitle);

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

  void _deleteEvent(DateTime day, String eventId) {
    setState(() {
      _events[day]?.removeWhere((event) => event.id == eventId);
    });
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    setState(() {
      _selectedDay = selectedDay;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("User Calendar"),
        backgroundColor: isDarkMode ? Color.fromRGBO(167, 43, 42, 1) : Color.fromRGBO(77, 95, 128, 100),
      ),
      backgroundColor: isDarkMode ? Color.fromRGBO(203, 102, 102, 40) : Color.fromRGBO(198, 218, 231, 1),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Text("Selected Day: " + _selectedDay.toString().split(" ")[0]),
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
                    trailing: IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () {
                        _deleteEvent(_selectedDay, event.id);
                      },
                    ),
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