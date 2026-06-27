import 'package:flutter/material.dart';

class AdminEmployeeDetails extends StatelessWidget {
  final Map<String, dynamic> employee;

  const AdminEmployeeDetails({
    super.key,
    required this.employee,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Employee Details"),
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),

        child: Card(
          elevation: 3,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),

          child: Padding(
            padding: const EdgeInsets.all(20),

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [

                const Center(
                  child: CircleAvatar(
                    radius: 40,
                    child: Icon(Icons.person,size:40),
                  ),
                ),

                const SizedBox(height:25),

                Text(
                  "Name : ${employee["name"]}",
                  style: const TextStyle(fontSize:18),
                ),

                const SizedBox(height:15),

                Text(
                  "Employee ID : ${employee["employeeID"]}",
                  style: const TextStyle(fontSize:18),
                ),

                const SizedBox(height:15),

                Text(
                  "Department : ${employee["department"]}",
                  style: const TextStyle(fontSize:18),
                ),

                const SizedBox(height:15),

                Text(
                  "Email : ${employee["email"]}",
                  style: const TextStyle(fontSize:18),
                ),

                const SizedBox(height:15),

                Text(
                  "Contact : ${employee["contactNo"]}",
                  style: const TextStyle(fontSize:18),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}