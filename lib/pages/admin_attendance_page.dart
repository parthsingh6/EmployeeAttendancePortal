import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminAttendancePage extends StatelessWidget {
  const AdminAttendancePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Attendance")),

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

          return ListView.builder(
            padding: const EdgeInsets.all(15),
            itemCount: snapshot.data!.docs.length,

            itemBuilder: (context, index) {
              var attendance = snapshot.data!.docs[index];

              DateTime date = (attendance["date"] as Timestamp).toDate();

              return Card(
                elevation: 3,
                margin: const EdgeInsets.only(bottom: 15),

                child: Padding(
                  padding: const EdgeInsets.all(15),

                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,

                    children: [
                      Row(
                        children: [
                          CircleAvatar(
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

                      const Divider(height: 25),

                      Text("Date : ${date.day}/${date.month}/${date.year}"),

                      const SizedBox(height: 8),

                      Text("Punch In : ${attendance["punchIn"]}"),

                      const SizedBox(height: 8),

                      Text("Punch Out : ${attendance["punchOut"]}"),

                      const SizedBox(height: 8),

                      Text("Working Hours : ${attendance["workingHours"]}"),
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
