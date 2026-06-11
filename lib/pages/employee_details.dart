import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StudentDetails extends StatefulWidget {
  const StudentDetails({super.key});

  @override
  State<StudentDetails> createState() => _StudentDetailsState();
}

class _StudentDetailsState extends State<StudentDetails> {
  String name = "";
  String studentClass = "";
  String rollNo = "";
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
      studentClass = prefs.getString("class") ?? "";
      rollNo = prefs.getString("rollNo") ?? "";
      email = prefs.getString("email") ?? "";
      contactNo = prefs.getString("contactNo") ?? "";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Student Details")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Name: $name"),
            SizedBox(height: 10),

            Text("Class: $studentClass"),
            SizedBox(height: 10),

            Text("Roll No: $rollNo"),
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
