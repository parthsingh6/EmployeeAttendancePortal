import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminLeavePage extends StatelessWidget {
  const AdminLeavePage({super.key});

  Future<void> updateStatus(String docId, String status) async {
    await FirebaseFirestore.instance
        .collection("leave_requests")
        .doc(docId)
        .update({"status": status});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Leave Requests")),

      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection("leave_requests")
            .orderBy("appliedOn", descending: true)
            .snapshots(),

        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No Leave Requests"));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(15),
            itemCount: snapshot.data!.docs.length,

            itemBuilder: (context, index) {
              var leave = snapshot.data!.docs[index];

              DateTime leaveDate = (leave["leaveDate"] as Timestamp).toDate();

              String status = leave["status"];

              return Card(
                elevation: 3,
                margin: const EdgeInsets.only(bottom: 15),

                child: Padding(
                  padding: const EdgeInsets.all(15),

                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,

                    children: [
                      Text(
                        leave["employeeName"],
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 8),

                      Text("Employee ID : ${leave["employeeId"]}"),

                      const SizedBox(height: 8),

                      Text(
                        "Leave Date : ${leaveDate.day}/${leaveDate.month}/${leaveDate.year}",
                      ),

                      const SizedBox(height: 8),

                      Text("Reason : ${leave["reason"]}"),

                      const SizedBox(height: 15),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,

                        children: [
                          Chip(
                            label: Text(status),
                            backgroundColor: status == "Approved"
                                ? Colors.green.shade100
                                : status == "Rejected"
                                ? Colors.red.shade100
                                : Colors.orange.shade100,
                          ),

                          Row(
                            children: [
                              ElevatedButton(
                                onPressed: status == "Pending"
                                    ? () {
                                        updateStatus(leave.id, "Approved");
                                      }
                                    : null,

                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                ),

                                child: const Text("Approve"),
                              ),

                              const SizedBox(width: 10),

                              ElevatedButton(
                                onPressed: status == "Pending"
                                    ? () {
                                        updateStatus(leave.id, "Rejected");
                                      }
                                    : null,

                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                ),

                                child: const Text("Reject"),
                              ),
                            ],
                          ),
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
