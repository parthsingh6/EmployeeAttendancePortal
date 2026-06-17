import 'package:flutter/material.dart';

class AttendancePage extends StatelessWidget {
  const AttendancePage({super.key});

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
              child: const ListTile(
                leading: Icon(Icons.calendar_today, color: Colors.deepPurple),
                title: Text("Date"),
                subtitle: Text("17 Jun 2026"),
              ),
            ),

            const SizedBox(height: 10),

            const SizedBox(height: 20),

            Card(
              child: ListTile(
                leading: Icon(Icons.login, color: Colors.green),
                title: Text("Punch In"),
                subtitle: Text("12:49 PM"),
              ),
            ),

            SizedBox(height: 10),

            Card(
              child: ListTile(
                leading: Icon(Icons.logout, color: Colors.red),
                title: Text("Punch Out"),
                subtitle: Text("5:32 PM"),
              ),
            ),

            SizedBox(height: 10),

            Card(
              child: ListTile(
                leading: Icon(Icons.timer, color: Colors.blue),
                title: Text("Working Hours"),
                subtitle: Text("4h 43m"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
