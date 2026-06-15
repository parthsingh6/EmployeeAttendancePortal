import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String name = "";
  String department = "";
  String employeeId = "";
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
      employeeId = prefs.getString("employeeID") ?? "";
      email = prefs.getString("email") ?? "";
      contactNo = prefs.getString("contactNo") ?? "";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile"),
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Card(
          elevation: 5,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Name: $name"),
                SizedBox(height: 10),

                Text("Department: $department"),
                SizedBox(height: 10),

                Text("Employee ID: $employeeId"),
                SizedBox(height: 10),

                Text("Email: $email"),
                SizedBox(height: 10),

                Text("Contact: $contactNo"),
              ],
            ),
          ),
        ),
      ),
    );
  }
}