import 'package:flutter/material.dart';

class LeavePage extends StatefulWidget {
  const LeavePage({super.key});

  @override
  State<LeavePage> createState() => _LeavePageState();
}

class _LeavePageState extends State<LeavePage> {
  DateTime? selectedDate;

  TextEditingController reasonController = TextEditingController();

  List<String> leaveHistory = [];

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

  void applyLeave() {
    if (selectedDate == null || reasonController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select date and enter reason")),
      );

      return;
    }

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("Leave Applied Successfully")));

    setState(() {
      leaveHistory.add(
        "${selectedDate.toString().split(' ')[0]} - ${reasonController.text}",
      );

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
              child: leaveHistory.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(
                            Icons.note_alt_outlined,
                            size: 60,
                            color: Colors.grey,
                          ),

                          SizedBox(height: 10),

                          Text(
                            "No leave requests found",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey,
                            ),
                          ),

                          SizedBox(height: 5),

                          Text(
                            "Apply your first leave request",
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: leaveHistory.length,
                      itemBuilder: (context, index) {
                        return Card(
                          elevation: 3,
                          child: ListTile(
                            leading: const Icon(
                              Icons.event_note,
                              color: Colors.orange,
                            ),
                            title: Text(
                              leaveHistory[index],
                              style: const TextStyle(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            subtitle: const Text("Leave Request"),
                          ),
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
