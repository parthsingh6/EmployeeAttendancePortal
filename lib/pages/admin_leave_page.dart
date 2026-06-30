import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Displays and manages employee leave requests

class AdminLeavePage extends StatelessWidget {
  const AdminLeavePage({super.key});

  // Updates the leave request status in Firestore

  Future<void> updateStatus(String docId, String status) async {
    await FirebaseFirestore.instance
        .collection("leave_requests")
        .doc(docId)
        .update({"status": status});
  }

  // Builds the Admin Leave Management screen

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Leave Requests")),

      // Retrieves leave requests from Firestore in real time
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

          // Builds the list of leave requests
          return ListView.builder(
            padding: const EdgeInsets.all(15),
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              var leave = snapshot.data!.docs[index];

              DateTime leaveDate = (leave["leaveDate"] as Timestamp).toDate();
              String status = leave["status"];

              // Leave request card
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
                            radius: 20,
                            backgroundColor: Colors.orange.shade100,
                            child: const Icon(
                              Icons.person,
                              color: Colors.orange,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              leave["employeeName"],
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
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
                          // Displays the current leave request status
                          Chip(
                            label: Text(
                              status,
                              style: TextStyle(
                                color: status == "Approved"
                                    ? Colors.green
                                    : status == "Rejected"
                                    ? Colors.red
                                    : Colors.orange,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            backgroundColor: status == "Approved"
                                ? Colors.green.shade100
                                : status == "Rejected"
                                ? Colors.red.shade100
                                : Colors.orange.shade100,
                          ),

                          Row(
                            children: [
                              // Approves the selected leave request
                              ElevatedButton(
                                onPressed: status == "Pending"
                                    ? () => updateStatus(leave.id, "Approved")
                                    : null,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                ),
                                child: const Text("Approve"),
                              ),

                              const SizedBox(width: 10),

                              // Rejects the selected leave request
                              ElevatedButton(
                                onPressed: status == "Pending"
                                    ? () => updateStatus(leave.id, "Rejected")
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
