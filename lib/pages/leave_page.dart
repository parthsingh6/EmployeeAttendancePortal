import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LeavePage extends StatefulWidget {
  const LeavePage({super.key});

  @override
  State<LeavePage> createState() => _LeavePageState();
}

class _LeavePageState extends State<LeavePage> {
  DateTime? selectedDate;

  TextEditingController reasonController = TextEditingController();

  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  String employeeId = "";
  String name = "";
  String department = "";

  Future<void> loadEmployeeData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    setState(() {
      employeeId = prefs.getString("employeeID") ?? "";
      name = prefs.getString("name") ?? "";
      department = prefs.getString("department") ?? "";
    });
  }

  @override
  void initState() {
    super.initState();
    loadEmployeeData();
  }

  Future<void> pickDate() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2024),
      lastDate: DateTime(2030),
    );

    if (pickedDate != null) {
      setState(() {
        selectedDate = pickedDate;
      });
    }
  }

  Future<void> applyLeave() async {
    if (selectedDate == null || reasonController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select date and enter reason")),
      );
      return;
    }

    await firestore.collection("leave_requests").add({
      "employeeId": employeeId,
      "employeeName": name,
      "department": department,
      "leaveDate": Timestamp.fromDate(selectedDate!),
      "reason": reasonController.text,
      "status": "Pending",
      "appliedOn": Timestamp.now(),
    });

    if (!mounted) return;

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("Leave Applied Successfully")));

    setState(() {
      selectedDate = null;
    });

    reasonController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Leave Request")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
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
                      radius: 28,
                      backgroundColor: Colors.orange.shade100,
                      child: const Icon(
                        Icons.beach_access,
                        color: Colors.orange,
                      ),
                    ),

                    const SizedBox(width: 15),

                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          "Leave Request",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        SizedBox(height: 5),

                        Text(
                          "Apply and track your leave",
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),
            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: ListTile(
                leading: const Icon(
                  Icons.calendar_month,
                  color: Colors.deepPurple,
                ),

                title: const Text("Leave Date"),

                subtitle: Text(
                  selectedDate == null
                      ? "Tap to select date"
                      : selectedDate.toString().split(" ")[0],
                ),

                trailing: const Icon(Icons.arrow_forward_ios),

                onTap: pickDate,
              ),
            ),

            const SizedBox(height: 20),

            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: TextField(
                  controller: reasonController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: "Enter reason for leave...",
                    prefixIcon: Icon(Icons.edit_note),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: applyLeave,
              child: const Text("Apply Leave"),
            ),
            const SizedBox(height: 30),

            const Text(
              "Leave History",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 10),

            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: firestore
                    .collection("leave_requests")
                    .where("employeeId", isEqualTo: employeeId)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(
                      child: Text(
                        "No Leave Requests",
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    );
                  }

                  return ListView.builder(
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (context, index) {
                      var data = snapshot.data!.docs[index];
                      DateTime leaveDate = (data["leaveDate"] as Timestamp)
                          .toDate();

                      return Card(
                        elevation: 3,
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          leading: const Icon(
                            Icons.event_note,
                            color: Colors.orange,
                          ),

                          title: Text(
                            data["reason"],
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),

                          subtitle: Text(
                            "${leaveDate.day}/${leaveDate.month}/${leaveDate.year}",
                          ),

                          trailing: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.orange.shade100,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              data["status"],
                              style: const TextStyle(
                                color: Colors.orange,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
