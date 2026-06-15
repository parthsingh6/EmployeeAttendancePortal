import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StudentDetails extends StatefulWidget {
  const StudentDetails({super.key});

  @override
  State<StudentDetails> createState() => _StudentDetailsState();
}

class _StudentDetailsState extends State<StudentDetails> {
  String name = "";
  String department = "";
  String employeeID = "";
  String email = "";
  String contactNo = "";

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    setState(() {
      name = prefs.getString("name") ?? "";
      department = prefs.getString("department") ?? "";
      employeeID = prefs.getString("employeeID") ?? "";
      email = prefs.getString("email") ?? "";
      contactNo = prefs.getString("contactNo") ?? "";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Employee Details")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Name: $name"),
            SizedBox(height: 10),

            Text("Department: $department"),
            SizedBox(height: 10),

            Text("Employee ID: $employeeID"),
            SizedBox(height: 10),

            Text("Email: $email"),
            SizedBox(height: 10),

            Text("Contact No: $contactNo"),
          ],
        ),
      ),
    );
  }
}
