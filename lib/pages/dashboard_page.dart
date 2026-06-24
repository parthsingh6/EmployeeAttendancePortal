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
  Future<void> saveAttendanceState() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    await prefs.setBool("isPunchedIn", isPunchedIn);
    await prefs.setBool("isPunchedOut", isPunchedOut);

    await prefs.setString("punchInTime", punchInTime);
    await prefs.setString("punchOutTime", punchOutTime);
    await prefs.setString("workingHours", workingHours);
    if (punchInDateTime != null) {
      await prefs.setString(
        "punchInDateTime",
        punchInDateTime!.toIso8601String(),
      );
    }
  }

  Future<void> loadAttendanceState() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    String? savedPunchInDateTime = prefs.getString("punchInDateTime");

    if (savedPunchInDateTime != null) {
      punchInDateTime = DateTime.parse(savedPunchInDateTime);
    }

    print("Loaded punchInDateTime: $punchInDateTime");

    setState(() {
      isPunchedIn = prefs.getBool("isPunchedIn") ?? false;
      isPunchedOut = prefs.getBool("isPunchedOut") ?? false;

      punchInTime = prefs.getString("punchInTime") ?? "";
      punchOutTime = prefs.getString("punchOutTime") ?? "";
      workingHours = prefs.getString("workingHours") ?? "";

      if (punchInDateTime == null) {
        isPunchedIn = false;
        isPunchedOut = false;
        punchInTime = "";
      }
    });
  }

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
    print("Punch Out Clicked");
    print("punchInDateTime = $punchInDateTime");

    DateTime now = DateTime.now();

    String hour = (now.hour % 12 == 0) ? "12" : (now.hour % 12).toString();

    String minute = now.minute.toString().padLeft(2, '0');

    String period = now.hour >= 12 ? "PM" : "AM";

    if (punchInDateTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Punch In time not found. Please Punch In again."),
        ),
      );
      return;
    }
    Duration difference = now.difference(punchInDateTime!);

    String attendanceStatus = "Present";

    // bool isLate =
    //     punchInDateTime!.hour > 9 ||
    //     (punchInDateTime!.hour == 9 && punchInDateTime!.minute > 0);

    // if (isLate && attendanceStatus == "Present") {
    //   attendanceStatus = "Late";
    // }

    setState(() {
      punchOutTime = "$hour:$minute $period";
      punchOutDateTime = now;

      workingHours =
          "${difference.inHours}h "
          "${difference.inMinutes % 60}m "
          "${difference.inSeconds % 60}s";

      isPunchedOut = true;
    });

    saveAttendanceState();

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
    loadAttendanceState();
  }

  Future<void> loadData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    setState(() {
      name = prefs.getString("name") ?? "";
      department = prefs.getString("department") ?? "";
      employeeId = prefs.getString("employeeID") ?? "";
    });
  }

  Future<void> logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    await prefs.clear();

    if (!mounted) return;

    Navigator.pushNamedAndRemoveUntil(context, "/login", (route) => false);
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
    saveAttendanceState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Dashboard"),

        actions: [
          IconButton(icon: const Icon(Icons.logout), onPressed: logout),
        ],
      ),

      body: Padding(
        padding: const EdgeInsets.all(15),
        child: SingleChildScrollView(
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
                        radius: 25,
                        backgroundColor: Colors.deepPurple.shade100,
                        child: Icon(
                          Icons.person,
                          size: 30,
                          color: Colors.deepPurple,
                        ),
                      ),

                      SizedBox(width: 10),

                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name.isNotEmpty
                                ? name[0].toUpperCase() + name.substring(1)
                                : "",
                            style: TextStyle(
                              fontSize: 20,
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
                                ? "Not Punched In"
                                : isPunchedOut
                                ? "Present\nIn: $punchInTime\nOut: $punchOutTime"
                                : "Punched In\n$punchInTime",
                            style: TextStyle(
                              color: isPunchedIn ? Colors.green : Colors.red,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
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

              SizedBox(height: 15),

              Text(
                "Quick Actions",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),

              SizedBox(height: 15),

              Container(
                height: 350,
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
                              size: 32,
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
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
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
                              size: 32,
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
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
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
                            Icon(
                              Icons.bar_chart,
                              size: 32,
                              color: Colors.green,
                            ),

                            SizedBox(height: 5),

                            Text(
                              "Reports",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),

                            SizedBox(height: 3),

                            Text(
                              "View Reports",
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
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
                            Icon(Icons.person, size: 32, color: Colors.blue),
                            SizedBox(height: 5),
                            Text(
                              "Profile",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),

                            SizedBox(height: 3),

                            Text(
                              "Employee Info",
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
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
      ),
    );
  }
}
