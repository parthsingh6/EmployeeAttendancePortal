import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Displays attendance records of all employees for the administrator

class AdminAttendancePage extends StatelessWidget {
  const AdminAttendancePage({super.key});

  // Builds the Admin Attendance screen

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Attendance")),

      // Retrieves attendance records from Firestore in real time
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection("attendance")
            .orderBy("date", descending: true)
            .snapshots(),

        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No Attendance Records"));
          }

          // Builds the attendance record list

          return ListView.builder(
            padding: const EdgeInsets.all(15),
            itemCount: snapshot.data!.docs.length,

            itemBuilder: (context, index) {
              var attendance = snapshot.data!.docs[index];

              DateTime date = (attendance["date"] as Timestamp).toDate();

              // Attendance record card

              return Card(
                elevation: 2,
                margin: const EdgeInsets.only(bottom: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),

                child: Padding(
                  padding: const EdgeInsets.all(15),

                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,

                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 24,
                            backgroundColor: Colors.green.shade100,
                            child: const Icon(
                              Icons.person,
                              color: Colors.green,
                            ),
                          ),

                          const SizedBox(width: 12),

                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,

                              children: [
                                Text(
                                  attendance["employeeName"],
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),

                                Text("ID : ${attendance["employeeId"]}"),
                              ],
                            ),
                          ),

                          // Displays the employee's attendance status
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),

                            decoration: BoxDecoration(
                              color: attendance["status"] == "Present"
                                  ? Colors.green.shade100
                                  : Colors.red.shade100,

                              borderRadius: BorderRadius.circular(20),
                            ),

                            child: Text(
                              attendance["status"],
                              style: TextStyle(
                                color: attendance["status"] == "Present"
                                    ? Colors.green
                                    : Colors.red,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const Divider(height: 30),

                      Row(
                        children: [
                          const Icon(
                            Icons.calendar_today,
                            size: 18,
                            color: Colors.deepPurple,
                          ),
                          const SizedBox(width: 8),
                          Text("${date.day}/${date.month}/${date.year}"),
                        ],
                      ),
                      const SizedBox(height: 8),

                      Row(
                        children: [
                          const Icon(
                            Icons.login,
                            size: 18,
                            color: Colors.green,
                          ),
                          const SizedBox(width: 8),
                          Text("Punch In : ${attendance["punchIn"]}"),
                        ],
                      ),
                      Row(
                        children: [
                          const Icon(Icons.logout, size: 18, color: Colors.red),
                          const SizedBox(width: 8),
                          Text("Punch Out : ${attendance["punchOut"]}"),
                        ],
                      ),
                      const SizedBox(height: 8),

                      Row(
                        children: [
                          const Icon(
                            Icons.schedule,
                            size: 18,
                            color: Colors.orange,
                          ),
                          const SizedBox(width: 8),
                          Text("Working Hours : ${attendance["workingHours"]}"),
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
    );
  }
}
