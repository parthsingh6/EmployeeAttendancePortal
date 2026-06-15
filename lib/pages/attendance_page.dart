import 'package:flutter/material.dart';

class AttendancePage extends StatelessWidget {
  const AttendancePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Attendance History"),
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            Text(
              "Attendance Record",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            SizedBox(height: 20),

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