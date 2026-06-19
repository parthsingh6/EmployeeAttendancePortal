import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:table_calendar/table_calendar.dart';

class AttendancePage extends StatefulWidget {
  const AttendancePage({super.key});

  @override
  State<AttendancePage> createState() => _AttendancePageState();
}

class _AttendancePageState extends State<AttendancePage> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  Map<DateTime, String> attendanceMap = {};

  Future<void> loadAttendanceData() async {
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection("attendance")
        .get();

    Map<DateTime, String> tempMap = {};

    for (var doc in snapshot.docs) {
      var data = doc.data() as Map<String, dynamic>;

      DateTime date = (data["date"] as Timestamp).toDate();

      tempMap[DateTime(date.year, date.month, date.day)] = data["status"];
    }

    setState(() {
      attendanceMap = tempMap;
    });
  }

  @override
  void initState() {
    super.initState();
    loadAttendanceData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Attendance History")),

      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              elevation: 5,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: Colors.green.shade100,
                      child: const Icon(
                        Icons.calendar_month,
                        color: Colors.green,
                        size: 30,
                      ),
                    ),

                    const SizedBox(width: 15),

                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Attendance Record",
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        Text(
                          "Daily attendance details",
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: ListTile(
                leading: const Icon(
                  Icons.calendar_today,
                  color: Colors.deepPurple,
                ),
                title: const Text("Date"),
                subtitle: Text(
                  DateFormat('dd MMM yyyy').format(DateTime.now()),
                ),
              ),
            ),

            const SizedBox(height: 20),

            TableCalendar(
              firstDay: DateTime.utc(2020, 1, 1),
              lastDay: DateTime.utc(2035, 12, 31),
              focusedDay: _focusedDay,

              selectedDayPredicate: (day) {
                return isSameDay(_selectedDay, day);
              },

              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                });
              },

              calendarStyle: CalendarStyle(
                todayDecoration: BoxDecoration(
                  color: Colors.deepPurple,
                  shape: BoxShape.circle,
                ),

                selectedDecoration: BoxDecoration(
                  color: Colors.green,
                  shape: BoxShape.circle,
                ),
              ),

              calendarBuilders: CalendarBuilders(
                defaultBuilder: (context, day, focusedDay) {
                  DateTime normalizedDay = DateTime(
                    day.year,
                    day.month,
                    day.day,
                  );

                  String? status = attendanceMap[normalizedDay];

                  if (status == null) return null;

                  Color color;

                  if (status == "Present") {
                    color = Colors.green;
                  } else if (status == "Absent") {
                    color = Colors.red;
                  } else if (status == "Late") {
                    color = Colors.orange;
                  } else {
                    color = Colors.yellow;
                  }

                  return Container(
                    margin: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '${day.day}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 20),

            const Text(
              "Attendance History",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 10),

            Expanded(
              child: StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection("attendance")
                    .orderBy("date", descending: true)
                    .snapshots(),

                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(child: Text("No Attendance Records"));
                  }

                  return ListView.builder(
                    itemCount: snapshot.data!.docs.length,

                    itemBuilder: (context, index) {
                      var data = snapshot.data!.docs[index];

                      return Card(
                        margin: const EdgeInsets.only(bottom: 10),

                        child: ListTile(
                          leading: Icon(
                            data["status"] == "Present"
                                ? Icons.check_circle
                                : Icons.cancel,
                            color: data["status"] == "Present"
                                ? Colors.green
                                : Colors.red,
                          ),

                          title: Text(
                            DateFormat(
                              'dd MMM yyyy',
                            ).format((data["date"] as Timestamp).toDate()),
                          ),

                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,

                            children: [
                              Text("Punch In: ${data["punchIn"]}"),

                              Text("Punch Out: ${data["punchOut"]}"),

                              Text("Working Hours: ${data["workingHours"]}"),
                              Text("Status: ${data["status"]}"),
                            ],
                          ),
                        ),
                      );
                    },
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
