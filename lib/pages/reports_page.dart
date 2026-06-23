import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';

class ReportsPage extends StatefulWidget {
  const ReportsPage({super.key});

  @override
  State<ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends State<ReportsPage> {
  int presentCount = 0;
  int absentCount = 0;
  int lateCount = 0;
  int halfDayCount = 0;
  int totalDays = 0;

  double attendancePercentage = 0;

  Future<void> loadReportData() async {
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection("attendance")
        .get();

    int present = 0;
    int absent = 0;
    int late = 0;
    int halfDay = 0;

    for (var doc in snapshot.docs) {
      String status = doc["status"];

      if (status == "Present") {
        present++;
      } else if (status == "Absent") {
        absent++;
      } else if (status == "Late") {
        late++;
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

  Widget buildPieChart() {
    return SizedBox(
      height: 220,
      child: Stack(
        alignment: Alignment.center,
        children: [
          PieChart(
            PieChartData(
              centerSpaceRadius: 55,
              centerSpaceColor: Colors.white,
              sectionsSpace: 2,
              pieTouchData: PieTouchData(enabled: true),

              sections: [
                PieChartSectionData(
                  value: presentCount.toDouble(),
                  color: Colors.green,
                  title: "",
                  radius: 70,
                ),

                PieChartSectionData(
                  value: absentCount.toDouble(),
                  color: Colors.red,
                  title: "",
                  radius: 70,
                ),

                PieChartSectionData(
                  value: lateCount.toDouble(),
                  color: Colors.orange,
                  title: "",
                  radius: 70,
                ),

                PieChartSectionData(
                  value: halfDayCount.toDouble(),
                  color: Colors.amber,
                  title: "",
                  radius: 70,
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

  @override
  void initState() {
    super.initState();
    loadReportData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Reports")),
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
                          "Attendance Report",
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          "Monthly attendance summary",
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 25),

            buildPieChart(),

            const SizedBox(height: 20),

            const SizedBox(height: 15),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Row(
                  children: [
                    const Icon(Icons.circle, color: Colors.green, size: 12),
                    const SizedBox(width: 5),
                    Text("Present: $presentCount"),
                  ],
                ),

                Row(
                  children: [
                    const Icon(Icons.circle, color: Colors.orange, size: 12),
                    const SizedBox(width: 5),
                    Text("Late: $lateCount"),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 10),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Row(
                  children: [
                    const Icon(Icons.circle, color: Colors.red, size: 12),
                    const SizedBox(width: 5),
                    Text("Absent: $absentCount"),
                  ],
                ),

                Row(
                  children: [
                    const Icon(Icons.circle, color: Colors.amber, size: 12),
                    const SizedBox(width: 5),
                    Text("Half Day: $halfDayCount"),
                  ],
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
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Total Working Days",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          totalDays.toString(),
                          style: const TextStyle(
                            fontSize: 18,
                            color: Colors.deepPurple,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 20),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Attendance Percentage",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          "${attendancePercentage.toStringAsFixed(1)}%",
                          style: const TextStyle(
                            fontSize: 18,
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
