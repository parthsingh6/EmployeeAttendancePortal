import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:my_new_app/pages/attendance_page.dart';
import 'package:my_new_app/pages/profile_page.dart';
import 'package:my_new_app/pages/leave_page.dart';
import 'package:my_new_app/pages/reports_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  String name = "";
  String department = "";
  String employeeId = "";
  int presentCount = 0;
  int absentCount = 0;
  int leaveCount = 0;
  double attendancePercentage = 0;

  String punchInTime = "";
  bool isPunchedIn = false;

  String punchOutTime = "";
  bool isPunchedOut = false;

  String workingHours = "";
  DateTime? punchInDateTime;
  DateTime? punchOutDateTime;

  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  Future<void> loadAttendanceSummary() async {
    QuerySnapshot snapshot = await firestore.collection("attendance").get();

    int present = 0;
    int absent = 0;
    int leave = 0;

    for (var doc in snapshot.docs) {
      String status = doc["status"];

      if (status == "Present" || status == "Late") {
        present++;
      } else if (status == "Absent") {
        absent++;
      } else if (status == "Leave") {
        leave++;
      }
    }

    setState(() {
      presentCount = present;
      absentCount = absent;
      leaveCount = leave;

      attendancePercentage = (presentCount + leaveCount) == 0
          ? 0
          : (presentCount / (presentCount + leaveCount + absentCount)) * 100;
    });
  }

  void punchOut() {
    DateTime now = DateTime.now();

    String hour = (now.hour % 12 == 0) ? "12" : (now.hour % 12).toString();

    String minute = now.minute.toString().padLeft(2, '0');

    String period = now.hour >= 12 ? "PM" : "AM";

    Duration difference = now.difference(punchInDateTime!);

    String attendanceStatus;

    if (difference.inHours >= 8) {
      attendanceStatus = "Present";
    } else if (difference.inHours >= 4) {
      attendanceStatus = "Half Day";
    } else {
      attendanceStatus = "Absent";
    }

    bool isLate =
        punchInDateTime!.hour > 9 ||
        (punchInDateTime!.hour == 9 && punchInDateTime!.minute > 0);

    if (isLate && attendanceStatus == "Present") {
      attendanceStatus = "Late";
    }

    setState(() {
      punchOutTime = "$hour:$minute $period";
      punchOutDateTime = now;

      workingHours =
          "${difference.inHours}h "
          "${difference.inMinutes % 60}m "
          "${difference.inSeconds % 60}s";

      isPunchedOut = true;
    });

    firestore.collection("attendance").add({
      "employeeId": employeeId,
      "employeeName": name,
      "department": department,
      "date": Timestamp.now(),
      "punchIn": punchInTime,
      "punchOut": punchOutTime,
      "workingHours": workingHours,
      "status": attendanceStatus,
    });
  }

  String getGreeting() {
    int hour = DateTime.now().hour;

    if (hour < 12) {
      return "Good Morning";
    } else if (hour < 17) {
      return "Good Afternoon";
    } else if (hour < 21) {
      return "Good Evening";
    } else {
      return "Good Night";
    }
  }

  @override
  void initState() {
    super.initState();
    loadData();
    loadAttendanceSummary();
  }

  Future<void> loadData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    setState(() {
      name = prefs.getString("name") ?? "";
      department = prefs.getString("department") ?? "";
      employeeId = prefs.getString("employeeID") ?? "";
    });
  }

  void punchIn() {
    DateTime now = DateTime.now();

    String hour = (now.hour % 12 == 0) ? "12" : (now.hour % 12).toString();

    String minute = now.minute.toString().padLeft(2, '0');

    String period = now.hour >= 12 ? "PM" : "AM";

    setState(() {
      punchInTime = "$hour:$minute $period";
      punchInDateTime = now;
      isPunchedIn = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Dashboard")),

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
                      backgroundColor: Colors.deepPurple.shade100,
                      child: Icon(
                        Icons.person,
                        size: 35,
                        color: Colors.deepPurple,
                      ),
                    ),

                    SizedBox(width: 15),

                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name.isNotEmpty
                              ? name[0].toUpperCase() + name.substring(1)
                              : "",
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        SizedBox(height: 5),

                        Text(
                          "Department: ${department.isNotEmpty ? department[0].toUpperCase() + department.substring(1) : ''}",
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey.shade700,
                          ),
                        ),

                        SizedBox(height: 5),

                        Text(
                          "Employee ID: $employeeId",
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade700,
                          ),
                        ),

                        SizedBox(height: 5),

                        Text(
                          "${getGreeting()} 👋",
                          style: TextStyle(
                            color: Colors.blue,
                            fontWeight: FontWeight.w500,
                          ),
                        ),

                        SizedBox(height: 5),

                        Text(
                          DateFormat('dd MMMM yyyy').format(DateTime.now()),
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 25),

            Text(
              "Attendance Summary",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            SizedBox(height: 10),

            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Column(
                      children: [
                        Text(
                          presentCount.toString(),
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                        SizedBox(height: 5),
                        Text("Present"),
                      ],
                    ),
                  ),
                ),

                const SizedBox(width: 10),

                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade50,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Column(
                      children: [
                        Text(
                          leaveCount.toString(),
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.orange,
                          ),
                        ),
                        SizedBox(height: 5),
                        Text("Leave"),
                      ],
                    ),
                  ),
                ),

                const SizedBox(width: 10),

                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Column(
                      children: [
                        Text(
                          absentCount.toString(),
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.red,
                          ),
                        ),
                        SizedBox(height: 5),
                        Text("Absent"),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: Padding(
                padding: const EdgeInsets.all(15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Attendance Percentage",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 10),

                    Text(
                      "${attendancePercentage.toStringAsFixed(1)}%",
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),

                    const SizedBox(height: 10),

                    LinearProgressIndicator(
                      value: attendancePercentage / 100,
                      minHeight: 8,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ],
                ),
              ),
            ),

            Card(
              elevation: 5,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.access_time,
                              color: Colors.blue,
                              size: 20,
                            ),

                            SizedBox(width: 5),

                            Text(
                              "Today's Status",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 5),
                        Text(
                          !isPunchedIn
                              ? "🔴 Not Punched In"
                              : isPunchedOut
                              ? "🟢 Present\nPunch In: $punchInTime\nPunch Out: $punchOutTime\nWorking Hours: $workingHours"
                              : "🟢 Present\nPunch In: $punchInTime",
                          style: TextStyle(
                            color: isPunchedIn ? Colors.green : Colors.red,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),

                    ElevatedButton(
                      onPressed: isPunchedOut
                          ? null
                          : (isPunchedIn ? punchOut : punchIn),

                      child: Text(
                        isPunchedOut
                            ? "Completed"
                            : (isPunchedIn ? "Punch Out" : "Punch In"),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 25),

            Text(
              "Quick Actions",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            SizedBox(height: 15),

            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 15,
                mainAxisSpacing: 15,
                childAspectRatio: 1.3,
                children: [
                  InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AttendancePage(),
                        ),
                      );
                    },

                    child: Card(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.calendar_month,
                            size: 40,
                            color: Colors.deepPurple,
                          ),
                          SizedBox(height: 5),
                          Text(
                            "Attendance",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),

                          SizedBox(height: 3),

                          Text(
                            "View Records",
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  ),

                  InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const LeavePage(),
                        ),
                      );
                    },

                    child: Card(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.beach_access,
                            size: 40,
                            color: Colors.orange,
                          ),
                          SizedBox(height: 5),
                          Text(
                            "Leave",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),

                          SizedBox(height: 3),

                          Text(
                            "Apply Leave",
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  ),

                  InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ReportsPage(),
                        ),
                      );
                    },

                    child: Card(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.bar_chart, size: 40, color: Colors.green),

                          SizedBox(height: 5),

                          Text(
                            "Reports",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),

                          SizedBox(height: 3),

                          Text(
                            "View Reports",
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  ),

                  InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ProfilePage(),
                        ),
                      );
                    },
                    child: Card(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.person, size: 40, color: Colors.blue),
                          SizedBox(height: 5),
                          Text(
                            "Profile",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),

                          SizedBox(height: 3),

                          Text(
                            "Employee Info",
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
