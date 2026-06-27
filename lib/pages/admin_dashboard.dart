import 'package:flutter/material.dart';
import 'admin_employees_page.dart';
import 'admin_attendance_page.dart';
import 'admin_leave_page.dart';
import 'admin_reports_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int totalEmployees = 0;
  int totalPresent = 0;
  int totalAbsent = 0;
  int totalLeaves = 0;

  @override
  void initState() {
    super.initState();
    loadDashboardData();
  }

  Future<void> loadDashboardData() async {
    // Employees
    var employeeSnapshot = await FirebaseFirestore.instance
        .collection("employees")
        .get();

    DateTime today = DateTime.now();

    // Attendance
    var attendanceSnapshot = await FirebaseFirestore.instance
        .collection("attendance")
        .get();

    // Leave Requests
    var leaveSnapshot = await FirebaseFirestore.instance
        .collection("leave_requests")
        .get();

    int present = 0;
    int absent = 0;

    for (var doc in attendanceSnapshot.docs) {
      Timestamp timestamp = doc["date"];
      DateTime date = timestamp.toDate();

      if (date.day == today.day &&
          date.month == today.month &&
          date.year == today.year) {
        if (doc["status"] == "Present") {
          present++;
        } else if (doc["status"] == "Absent") {
          absent++;
        }
      }
    }

    int pendingLeaves = 0;

    for (var doc in leaveSnapshot.docs) {
      if (doc["status"] == "Pending") {
        pendingLeaves++;
      }
    }

    setState(() {
      totalEmployees = employeeSnapshot.docs.length;
      totalPresent = present;
      totalAbsent = absent;
      totalLeaves = pendingLeaves;
    });
  }

  Widget buildCard({
    required IconData icon,
    required Color color,
    required String title,
    required String value,
  }) {
    return Expanded(
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 15),
          child: Column(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: color.withValues(alpha: 0.15),
                child: Icon(icon, color: color, size: 28),
              ),

              const SizedBox(height: 12),

              Text(
                value,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 6),

              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget quickAction(
    BuildContext context,
    IconData icon,
    String title,
    Color color,
    Widget page,
  ) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => page));
        },
        child: Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 22),
            child: Column(
              children: [
                Icon(icon, size: 35, color: color),

                const SizedBox(height: 10),

                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Admin Dashboard"),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: loadDashboardData,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),

              child: Padding(
                padding: const EdgeInsets.all(18),

                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 32,
                      backgroundColor: Colors.deepPurple.shade100,
                      child: const Icon(
                        Icons.admin_panel_settings,
                        color: Colors.deepPurple,
                        size: 34,
                      ),
                    ),

                    const SizedBox(width: 16),

                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,

                      children: [
                        Text(
                          "Welcome Admin",
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        SizedBox(height: 4),

                        Text(
                          "Employee Attendance Portal",
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 25),

            const Text(
              "Overview",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 12),

            Row(
              children: [
                buildCard(
                  icon: Icons.people,
                  color: Colors.blue,
                  title: "Employees",
                  value: totalEmployees.toString(),
                ),

                const SizedBox(width: 12),

                buildCard(
                  icon: Icons.check_circle,
                  color: Colors.green,
                  title: "Present",
                  value: totalPresent.toString(),
                ),
              ],
            ),

            const SizedBox(height: 12),

            Row(
              children: [
                buildCard(
                  icon: Icons.cancel,
                  color: Colors.red,
                  title: "Absent",
                  value: totalAbsent.toString(),
                ),

                const SizedBox(width: 12),

                buildCard(
                  icon: Icons.event_note,
                  color: Colors.orange,
                  title: "Pending Leaves",
                  value: totalLeaves.toString(),
                ),
              ],
            ),

            const SizedBox(height: 30),

            const Text(
              "Quick Actions",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 15),

            Row(
              children: [
                quickAction(
                  context,
                  Icons.people_alt,
                  "Employees",
                  Colors.blue,
                  const AdminEmployeesPage(),
                ),
                const SizedBox(width: 12),

                quickAction(
                  context,
                  Icons.calendar_month,
                  "Attendance",
                  Colors.green,
                  const AdminAttendancePage(),
                ),
              ],
            ),

            const SizedBox(height: 12),

            Row(
              children: [
                quickAction(
                  context,
                  Icons.assignment,
                  "Leaves",
                  Colors.orange,
                  const AdminLeavePage(),
                ),
                const SizedBox(width: 12),

                quickAction(
                  context,
                  Icons.bar_chart,
                  "Reports",
                  Colors.deepPurple,
                  const AdminReportsPage(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
