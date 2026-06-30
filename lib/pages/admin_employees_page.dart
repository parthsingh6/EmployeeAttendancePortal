import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'admin_employee_details.dart';

// Displays all registered employees for the administrator

class AdminEmployeesPage extends StatefulWidget {
  const AdminEmployeesPage({super.key});

  @override
  State<AdminEmployeesPage> createState() => _AdminEmployeesPageState();
}

class _AdminEmployeesPageState extends State<AdminEmployeesPage> {
  // Controller used for employee search

  final TextEditingController searchController = TextEditingController();

  // Stores the search query entered by the administrator

  String searchText = "";

  // Builds the Employee Management screen

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Employees")),

      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(15),

            // Search employees by name or employee ID
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: "Search by Name or Employee ID",
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.grey.shade100,

                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide.none,
                ),

                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide.none,
                ),

                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: const BorderSide(
                    color: Colors.deepPurple,
                    width: 2,
                  ),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  searchText = value.toLowerCase();
                });
              },
            ),
          ),

          Expanded(
            // Retrieves employee records from Firestore in real time
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection("employees")
                  .snapshots(),

              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text("No Employees Found"));
                }

                // Builds the employee list

                return ListView.builder(
                  padding: const EdgeInsets.all(15),
                  itemCount: snapshot.data!.docs.length,

                  itemBuilder: (context, index) {
                    var employee = snapshot.data!.docs[index];

                    String employeeName = employee["name"]
                        .toString()
                        .toLowerCase();

                    String employeeId = employee["employeeID"].toString();

                    // Filters employees based on the search query
                    if (searchText.isNotEmpty &&
                        !employeeName.contains(searchText) &&
                        !employeeId.contains(searchText)) {
                      return const SizedBox.shrink();
                    }

                    // Employee information card

                    return Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                      margin: const EdgeInsets.only(bottom: 15),

                      child: ListTile(
                        leading: CircleAvatar(
                          radius: 24,
                          backgroundColor: Colors.deepPurple.shade100,
                          child: const Icon(
                            Icons.person,
                            color: Colors.deepPurple,
                          ),
                        ),

                        title: Text(
                          employee["name"],
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text("Employee ID : ${employee["employeeID"]}"),
                              Text("Department : ${employee["department"]}"),
                            ],
                          ),
                        ),

                        trailing: const Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 18,
                          color: Colors.grey,
                        ),

                        // Opens the selected employee's detailed profile
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => AdminEmployeeDetails(
                                employee:
                                    employee.data() as Map<String, dynamic>,
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
