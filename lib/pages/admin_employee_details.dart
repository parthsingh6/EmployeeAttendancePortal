import 'package:flutter/material.dart';

// Displays complete information of the selected employee

class AdminEmployeeDetails extends StatelessWidget {
  // Stores the selected employee's information

  final Map<String, dynamic> employee;

  const AdminEmployeeDetails({super.key, required this.employee});

  // Builds the Employee Details screen

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Employee Details")),

      body: Padding(
        padding: const EdgeInsets.all(20),

        // Employee information card
        child: Card(
  elevation: 3,
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(24),
  ),

          child: Padding(
            padding: const EdgeInsets.all(20),

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                // Employee profile icon
                
                Center(
  child:CircleAvatar(
                  radius: 45,
                  backgroundColor: Colors.deepPurple.shade100,
                  child: const Icon(
                    Icons.person,
                    size: 45,
                    color: Colors.deepPurple,
                  ),
                ),
                ),

                const SizedBox(height: 25),
                ListTile(
                  leading: const Icon(Icons.person),
                  title: const Text("Name"),
                  subtitle: Text(employee["name"]),
                ),

                const Divider(),

                ListTile(
                  leading: const Icon(Icons.badge),
                  title: const Text("Employee ID"),
                  subtitle: Text(employee["employeeID"]),
                ),

                const Divider(),

                ListTile(
                  leading: const Icon(Icons.business),
                  title: const Text("Department"),
                  subtitle: Text(employee["department"]),
                ),

                const Divider(),

                ListTile(
                  leading: const Icon(Icons.email),
                  title: const Text("Email"),
                  subtitle: Text(employee["email"]),
                ),

                const Divider(),

                ListTile(
                  leading: const Icon(Icons.phone),
                  title: const Text("Contact"),
                  subtitle: Text(employee["contactNo"]),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
