import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Displays attendance analytics and performance reports for the employee

class ReportsPage extends StatefulWidget {
  const ReportsPage({super.key});

  @override
  State<ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends State<ReportsPage> {
  // Stores attendance statistics for the logged-in employee
  int presentCount = 0;
  int absentCount = 0;
  int lateCount = 0;
  int halfDayCount = 0;
  int totalDays = 0;

  double attendancePercentage = 0;

  String employeeId = "";
  bool isLoading = true;

  // Loads the employee ID from SharedPreferences

  Future<void> loadEmployee() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    setState(() {
      employeeId = prefs.getString("employeeID") ?? "";
      isLoading = false;
    });
  }

  // Retrieves attendance records from Firestore and calculates report statistics

  Future<void> loadReportData() async {
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection("attendance")
        .where("employeeId", isEqualTo: employeeId)
        .get();

    int present = 0;
    int absent = 0;
    int late = 0;
    int halfDay = 0;

    for (var doc in snapshot.docs) {
      String status = doc["status"];

      if (status == "Present") {
        present++;
      } else if (status == "Late") {
        late++;
        present++; // Late attendance contributes towards overall attendance percentage
      } else if (status == "Absent") {
        absent++;
      } else if (status == "Half Day") {
        halfDay++;
      }
    }

    int total = present + absent + late + halfDay;

    setState(() {
      presentCount = present;
      absentCount = absent;
      lateCount = late;
      halfDayCount = halfDay;
      totalDays = total;

      attendancePercentage = total == 0
          ? 0
          : ((present + late + (halfDay * 0.5)) / total) * 100;
    });
  }

  // Builds a pie chart to visualize attendance distribution

  Widget buildPieChart() {
    return SizedBox(
      height: 140,
      child: Stack(
        alignment: Alignment.center,
        children: [
          PieChart(
            PieChartData(
              centerSpaceRadius: 32,
              centerSpaceColor: Colors.white,
              sectionsSpace: 2,
              pieTouchData: PieTouchData(enabled: true),

              sections: [
                PieChartSectionData(
                  value: presentCount.toDouble(),
                  color: Colors.green,
                  title: "",
                  radius: 42,
                ),

                PieChartSectionData(
                  value: absentCount.toDouble(),
                  color: Colors.red,
                  title: "",
                  radius: 42,
                ),

                PieChartSectionData(
                  value: lateCount.toDouble(),
                  color: Colors.orange,
                  title: "",
                  radius: 42,
                ),

                PieChartSectionData(
                  value: halfDayCount.toDouble(),
                  color: Colors.amber,
                  title: "",
                  radius: 42,
                ),
              ],
            ),
          ),

          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "${attendancePercentage.toStringAsFixed(1)}%",
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),

              const Text("Attendance", style: TextStyle(color: Colors.grey)),
            ],
          ),
        ],
      ),
    );
  }

  // Initializes the reports page

  @override
  void initState() {
    super.initState();
    initializePage();
  }

  // Loads employee information and attendance report data

  Future<void> initializePage() async {
    await loadEmployee();
    await loadReportData();
  }

  // Builds the Reports page user interface

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Reports")),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Reports page header
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
                        child: Icon(
                          Icons.bar_chart,
                          color: Colors.green,
                          size: 30,
                        ),
                      ),
                      const SizedBox(width: 15),
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Attendance Analytics",
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            "Monthly Performance Report",
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 25),

              const SizedBox(height: 20),

              // Displays overall attendance percentage and performance rating
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: const [
                          Icon(
                            Icons.analytics,
                            color: Colors.deepPurple,
                            size: 22,
                          ),
                          SizedBox(width: 8),
                          Text(
                            "Attendance Percentage",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 25),

                      Center(
                        child: Text(
                          "${attendancePercentage.toStringAsFixed(1)}%",
                          style: const TextStyle(
                            fontSize: 34,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                      ),

                      const SizedBox(height: 6),

                      Center(
                        child: Text(
                          attendancePercentage >= 90
                              ? "Excellent"
                              : attendancePercentage >= 75
                              ? "Good"
                              : attendancePercentage >= 50
                              ? "Average"
                              : "Needs Improvement",
                          style: TextStyle(
                            color: attendancePercentage >= 75
                                ? Colors.green
                                : attendancePercentage >= 50
                                ? Colors.orange
                                : Colors.red,
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      ClipRRect(
                        borderRadius: BorderRadius.circular(30),
                        child: LinearProgressIndicator(
                          minHeight: 14,
                          value: attendancePercentage / 100,
                          backgroundColor: Colors.grey.shade300,
                          valueColor: const AlwaysStoppedAnimation(
                            Colors.deepPurple,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Displays detailed attendance statistics
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.calendar_month,
                            color: Colors.deepPurple,
                            size: 22,
                          ),

                          const SizedBox(width: 8),

                          const Text(
                            "Attendance Summary",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const Spacer(),

                          Text(
                            "$totalDays Days",
                            style: const TextStyle(
                              fontSize: 17,
                              color: Colors.deepPurple,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 15),
                      const Divider(),

                      ListTile(
                        visualDensity: VisualDensity.compact,
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(
                          Icons.check_circle,
                          color: Colors.green,
                        ),
                        title: const Text("Present"),
                        trailing: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.green.shade50,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            presentCount.toString(),
                            style: const TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),

                      const Divider(thickness: 0.8, height: 28),
                      ListTile(
                        visualDensity: VisualDensity.compact,
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(Icons.cancel, color: Colors.red),
                        title: const Text("Absent"),
                        trailing: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.red.shade50,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            absentCount.toString(),
                            style: const TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),

                      const Divider(thickness: 0.8, height: 28),
                      ListTile(
                        visualDensity: VisualDensity.compact,
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(
                          Icons.access_time,
                          color: Colors.orange,
                        ),
                        title: const Text("Late"),
                        trailing: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.orange.shade50,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            lateCount.toString(),
                            style: const TextStyle(
                              color: Colors.orange,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),

                      const Divider(thickness: 0.8, height: 28),
                      ListTile(
                        visualDensity: VisualDensity.compact,
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(
                          Icons.timelapse,
                          color: Colors.amber,
                        ),
                        title: const Text("Half Day"),
                        trailing: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.amber.shade50,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            halfDayCount.toString(),
                            style: const TextStyle(
                              color: Colors.amber,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
