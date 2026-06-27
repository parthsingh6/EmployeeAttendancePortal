import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AttendancePage extends StatefulWidget {
  const AttendancePage({super.key});

  @override
  State<AttendancePage> createState() => _AttendancePageState();
}

class _AttendancePageState extends State<AttendancePage> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  Map<DateTime, String> attendanceMap = {};

  List<Map<String, dynamic>> attendanceHistory = [];

  String employeeId = "";
  bool isLoading = true;

  Future<void> loadEmployee() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    setState(() {
      employeeId = prefs.getString("employeeID") ?? "";
      isLoading = false;
    });
  }

  Future<void> loadAttendanceData() async {
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection("attendance")
        .where("employeeId", isEqualTo: employeeId)
        .get();

    Map<DateTime, String> tempMap = {};

    List<Map<String, dynamic>> tempHistory = [];

    for (var doc in snapshot.docs) {
      var data = doc.data() as Map<String, dynamic>;

      DateTime date = (data["date"] as Timestamp).toDate();

      tempMap[DateTime(date.year, date.month, date.day)] = data["status"];

      tempHistory.add({"date": date, "status": data["status"]});
    }

    setState(() {
      attendanceMap = tempMap;
      attendanceHistory = tempHistory;
    });
  }

  @override
  void initState() {
    super.initState();
    initializePage();
  }

  Future<void> initializePage() async {
    await loadEmployee();
    await loadAttendanceData();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Attendance History")),

      body: SingleChildScrollView(
        child: Padding(
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
                    } else if (status == "Late") {
                      color = Colors.orange;
                    } else if (status == "Half Day") {
                      color = Colors.amber;
                    } else {
                      color = Colors.red;
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

              const SizedBox(height: 20),

              const Text(
                "Attendance History",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 10),
              StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection("attendance")
                    .where("employeeId", isEqualTo: employeeId)
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
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: snapshot.data!.docs.length,

                    itemBuilder: (context, index) {
                      var data = snapshot.data!.docs[index];

                      return Card(
                        margin: const EdgeInsets.only(bottom: 10),

                        child: Padding(
                          padding: const EdgeInsets.all(18),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    DateFormat('dd MMM yyyy').format(
                                      (data["date"] as Timestamp).toDate(),
                                    ),
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),

                                  const Spacer(),

                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: data["status"] == "Present"
                                          ? Colors.green.shade100
                                          : data["status"] == "Late"
                                          ? Colors.orange.shade100
                                          : data["status"] == "Half Day"
                                          ? Colors.amber.shade100
                                          : Colors.red.shade100,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      data["status"],
                                      style: TextStyle(
                                        color: data["status"] == "Present"
                                            ? Colors.green
                                            : data["status"] == "Late"
                                            ? Colors.orange
                                            : data["status"] == "Half Day"
                                            ? Colors.amber.shade800
                                            : Colors.red,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 15),

                              const Divider(),

                              const SizedBox(height: 12),

                              Row(
                                children: [
                                  const Icon(
                                    Icons.login,
                                    color: Colors.green,
                                    size: 20,
                                  ),

                                  const SizedBox(width: 10),

                                  const Text(
                                    "Punch In",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),

                                  const Spacer(),

                                  Text(
                                    data["punchIn"],
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 12),

                              Row(
                                children: [
                                  const Icon(
                                    Icons.logout,
                                    color: Colors.red,
                                    size: 20,
                                  ),

                                  const SizedBox(width: 10),

                                  const Text(
                                    "Punch Out",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),

                                  const Spacer(),

                                  Text(
                                    data["punchOut"],
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 12),

                              Row(
                                children: [
                                  const Icon(
                                    Icons.schedule,
                                    color: Colors.deepPurple,
                                    size: 20,
                                  ),

                                  const SizedBox(width: 10),

                                  const Text(
                                    "Working Hours",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),

                                  const Spacer(),

                                  Text(
                                    data["workingHours"],
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.deepPurple,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
