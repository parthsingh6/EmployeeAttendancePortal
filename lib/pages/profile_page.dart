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
      appBar: AppBar(title: const Text("Profile")),

      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Card(
          elevation: 5,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 40,
                        backgroundColor: Colors.deepPurple.shade100,
                        child: const Icon(
                          Icons.person,
                          size: 40,
                          color: Colors.deepPurple,
                        ),
                      ),

                      const SizedBox(height: 10),

                      Text(
                        name,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 5),

                      Text(
                        "${department.isNotEmpty ? department[0].toUpperCase() + department.substring(1) : ''} Department",
                        style: TextStyle(color: Colors.grey, fontSize: 16),
                      ),
                      const SizedBox(height: 20),

                      Divider(),
                    ],
                  ),
                ),

                ListTile(
                  leading: const Icon(Icons.business),
                  title: const Text("Department"),
                  subtitle: Text(
                    department.isNotEmpty
                        ? "${department[0].toUpperCase()}${department.substring(1)}"
                        : "",
                  ),
                ),

                ListTile(
                  leading: const Icon(Icons.badge),
                  title: const Text("Employee ID"),
                  subtitle: Text(employeeId),
                ),

                ListTile(
                  leading: const Icon(Icons.email),
                  title: const Text("Email"),
                  subtitle: Text(email),
                ),

                ListTile(
                  leading: const Icon(Icons.phone),
                  title: const Text("Contact"),
                  subtitle: Text(contactNo),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
