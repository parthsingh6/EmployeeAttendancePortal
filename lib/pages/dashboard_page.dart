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
    QuerySnapshot snapshot = await firestore
        .collection("attendance")
        .where("employeeId", isEqualTo: employeeId)
        .orderBy("date", descending: true)
        .get();
    int present = 0;
    int absent = 0;
    int leave = 0;

    for (var doc in snapshot.docs) {
      String status = doc["status"];

      if (status == "Present") {
        present++;
      } else if (status == "Late") {
        present++;
      } else if (status == "Half Day") {
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

  Future<void> punchOut() async {
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

    String attendanceStatus;

    // Half Day
    if (difference.inHours < 4) {
      attendanceStatus = "Half Day";
    }
    // Late
    else if (punchInDateTime!.hour > 9 ||
        (punchInDateTime!.hour == 9 && punchInDateTime!.minute > 0)) {
      attendanceStatus = "Late";
    }
    // Present
    else {
      attendanceStatus = "Present";
    }
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

    DateTime today = DateTime(now.year, now.month, now.day);

    QuerySnapshot snapshot = await firestore
        .collection("attendance")
        .where("employeeId", isEqualTo: employeeId)
        .get();

    DocumentSnapshot? existingDoc;

    for (var doc in snapshot.docs) {
      DateTime docDate = (doc["date"] as Timestamp).toDate();

      if (docDate.year == today.year &&
          docDate.month == today.month &&
          docDate.day == today.day) {
        existingDoc = doc;
        break;
      }
    }

    if (existingDoc != null) {
      await firestore.collection("attendance").doc(existingDoc.id).update({
        "punchOut": punchOutTime,
        "workingHours": workingHours,
        "status": attendanceStatus,
      });
    } else {
      await firestore.collection("attendance").add({
        "employeeId": employeeId,
        "employeeName": name,
        "department": department,
        "date": Timestamp.fromDate(now),
        "punchIn": punchInTime,
        "punchOut": punchOutTime,
        "workingHours": workingHours,
        "status": attendanceStatus,
      });
    }
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

    initializeDashboard();
  }

  Future<void> initializeDashboard() async {
    await loadData();

    await loadAttendanceSummary();

    await loadAttendanceState();
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

    await prefs.remove("name");
    await prefs.remove("department");
    await prefs.remove("employeeID");
    await prefs.remove("email");
    await prefs.remove("contactNo");

    if (!mounted) return;

    Navigator.pushNamedAndRemoveUntil(context, "/login", (route) => false);
  }

  Future<void> punchIn() async {
    DateTime now = DateTime.now();

    DateTime today = DateTime(now.year, now.month, now.day);

    QuerySnapshot snapshot = await firestore
        .collection("attendance")
        .where("employeeId", isEqualTo: employeeId)
        .get();

    bool alreadyPunchedToday = false;

    for (var doc in snapshot.docs) {
      DateTime docDate = (doc["date"] as Timestamp).toDate();

      if (docDate.year == today.year &&
          docDate.month == today.month &&
          docDate.day == today.day) {
        alreadyPunchedToday = true;
        break;
      }
    }

    if (alreadyPunchedToday) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("You have already punched in today.")),
      );
      return;
    }

    String hour = (now.hour % 12 == 0) ? "12" : (now.hour % 12).toString();

    String minute = now.minute.toString().padLeft(2, '0');

    String period = now.hour >= 12 ? "PM" : "AM";

    setState(() {
      punchInTime = "$hour:$minute $period";
      punchInDateTime = now;
      isPunchedIn = true;
    });

    await saveAttendanceState();
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
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
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

                          const SizedBox(height: 3),

                          Text(
                            "Department: ${department.isNotEmpty ? department[0].toUpperCase() + department.substring(1) : ''}",
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey.shade700,
                            ),
                          ),

                          const SizedBox(height: 3),

                          Text(
                            "Employee ID: $employeeId",
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade700,
                            ),
                          ),

                          const SizedBox(height: 3),

                          Text(
                            "${getGreeting()} 👋",
                            style: TextStyle(
                              color: Colors.blue,
                              fontWeight: FontWeight.w500,
                            ),
                          ),

                          const SizedBox(height: 3),

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

              const SizedBox(height: 25),

              const Text(
                "Attendance Overview",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 12),

              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 18,
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.check_circle,
                                color: Colors.green,
                              ),
                              const SizedBox(width: 10),
                              const Text(
                                "Present",
                                style: TextStyle(fontSize: 16),
                              ),
                            ],
                          ),
                          Text(
                            presentCount.toString(),
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                        ],
                      ),

                      const Divider(height: 25),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.event_busy,
                                color: Colors.orange,
                              ),
                              const SizedBox(width: 10),
                              const Text(
                                "Leave",
                                style: TextStyle(fontSize: 16),
                              ),
                            ],
                          ),
                          Text(
                            leaveCount.toString(),
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.orange,
                            ),
                          ),
                        ],
                      ),

                      const Divider(height: 25),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.cancel, color: Colors.red),
                              const SizedBox(width: 10),
                              const Text(
                                "Absent",
                                style: TextStyle(fontSize: 16),
                              ),
                            ],
                          ),
                          Text(
                            absentCount.toString(),
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.red,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 12),

              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  isPunchedOut
                                      ? Icons.check_circle
                                      : Icons.access_time_filled,
                                  color: isPunchedOut
                                      ? Colors.green
                                      : Colors.blue,
                                ),

                                const SizedBox(width: 8),

                                Text(
                                  isPunchedOut
                                      ? "Attendance Completed"
                                      : "Today's Status",
                                  style: const TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 15),

                            if (!isPunchedIn)
                              const Text(
                                "Not Punched In",
                                style: TextStyle(
                                  color: Colors.red,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),

                            if (isPunchedIn) ...[
                              Row(
                                children: [
                                  const Icon(
                                    Icons.login,
                                    size: 18,
                                    color: Colors.green,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    "Punch In : $punchInTime",
                                    style: const TextStyle(fontSize: 15),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 8),

                              if (isPunchedOut)
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.logout,
                                      size: 18,
                                      color: Colors.red,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      "Punch Out : $punchOutTime",
                                      style: const TextStyle(fontSize: 15),
                                    ),
                                  ],
                                ),

                              if (isPunchedOut) const SizedBox(height: 8),

                              if (isPunchedOut)
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.timer,
                                      size: 18,
                                      color: Colors.deepPurple,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      workingHours,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                            ],
                          ],
                        ),
                      ),

                      ElevatedButton(
                        onPressed: isPunchedOut
                            ? null
                            : (isPunchedIn ? punchOut : punchIn),

                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(120, 46),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),

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

              const SizedBox(height: 15),

              Text(
                "Quick Actions",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 15),

              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 15,
                mainAxisSpacing: 15,
                childAspectRatio: 1.8,

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
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.calendar_month,
                            size: 30,
                            color: Colors.deepPurple,
                          ),
                          const SizedBox(height: 3),
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
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.beach_access,
                            size: 30,
                            color: Colors.orange,
                          ),
                          const SizedBox(height: 3),
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
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.bar_chart, size: 30, color: Colors.green),

                          const SizedBox(height: 3),

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
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.person, size: 30, color: Colors.blue),
                          const SizedBox(height: 3),
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
            ],
          ),
        ),
      ),
    );
  }
}
