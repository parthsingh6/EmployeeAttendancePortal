import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Displays overall attendance and leave statistics for administrators

class AdminReportsPage extends StatefulWidget {
  const AdminReportsPage({super.key});

  @override
  State<AdminReportsPage> createState() => _AdminReportsPageState();
}

class _AdminReportsPageState extends State<AdminReportsPage> {
  // Stores attendance and leave report statistics
  int totalEmployees = 0;
  int totalPresent = 0;
  int totalAbsent = 0;
  int pendingLeaves = 0;
  int approvedLeaves = 0;
  int rejectedLeaves = 0;

  // Initializes the reports page

  @override
  void initState() {
    super.initState();
    loadReportData();
  }

  // Retrieves report data from Firestore

  Future<void> loadReportData() async {
    final firestore = FirebaseFirestore.instance;

    final employees = await firestore.collection("employees").get();
    final attendance = await firestore.collection("attendance").get();
    final leaves = await firestore.collection("leave_requests").get();

    setState(() {
      totalEmployees = employees.docs.length;

      totalPresent = attendance.docs
          .where((doc) => doc["status"] == "Present")
          .length;

      totalAbsent = attendance.docs
          .where((doc) => doc["status"] == "Absent")
          .length;

      pendingLeaves = leaves.docs
          .where((doc) => doc["status"] == "Pending")
          .length;

      approvedLeaves = leaves.docs
          .where((doc) => doc["status"] == "Approved")
          .length;

      rejectedLeaves = leaves.docs
          .where((doc) => doc["status"] == "Rejected")
          .length;
    });
  }

  // Builds a reusable report summary card

  Widget reportTile(IconData icon, Color color, String title, int value) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      margin: const EdgeInsets.only(bottom: 15),
      child: ListTile(
        leading: CircleAvatar(
          radius: 24,
          backgroundColor: color.withValues(alpha: 0.15),
          child: Icon(icon, color: color),
        ),
        title: Text(title),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            value.toString(),
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ),
      ),
    );
  }

  // Builds the Admin Reports screen

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Reports"),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: loadReportData,
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(15),
        children: [
          reportTile(
            Icons.people,
            Colors.blue,
            "Total Employees",
            totalEmployees,
          ),
          reportTile(Icons.check_circle, Colors.green, "Present", totalPresent),
          reportTile(Icons.cancel, Colors.red, "Absent", totalAbsent),
          reportTile(
            Icons.pending_actions,
            Colors.orange,
            "Pending Leaves",
            pendingLeaves,
          ),
          reportTile(
            Icons.verified,
            Colors.green,
            "Approved Leaves",
            approvedLeaves,
          ),
          reportTile(
            Icons.close,
            Colors.red,
            "Rejected Leaves",
            rejectedLeaves,
          ),
        ],
      ),
    );
  }
}
