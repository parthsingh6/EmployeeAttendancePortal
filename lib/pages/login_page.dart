import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:my_new_app/pages/dashboard_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:my_new_app/pages/admin_dashboard.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  String name = "";
  String department = "";
  String employeeId = "";
  String email = "";
  String contactNo = "";

  bool changeButton = false;

  final Map<String, Map<String, String>> employees = {
    "111111": {
      "name": "Parth",
      "department": "Technology",
      "email": "parth@work.com",
      "contact": "9876543210",
    },
    "222222": {
      "name": "Avni",
      "department": "Human Resources",
      "email": "avni@work.com",
      "contact": "9876543211",
    },
    "333333": {
      "name": "Nayan",
      "department": "Finance",
      "email": "nayan@work.com",
      "contact": "9876543212",
    },
    "999999": {
      "name": "admin",
      "department": "Administration",
      "email": "admin@company.com",
      "contact": "9999999999",
    },
  };

  final _formKey = GlobalKey<FormState>();

  Future<void> moveToHome() async {
    if (_formKey.currentState!.validate()) {
      if (!employees.containsKey(employeeId) ||
          employees[employeeId]!["name"]!.toLowerCase() != name.toLowerCase()) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text("Login Failed"),
            content: const Text("Invalid Employee Credentials"),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("OK"),
              ),
            ],
          ),
        );

        return;
      }
    }

    setState(() {
      changeButton = true;
    });

    department = employees[employeeId]!["department"]!;
    email = employees[employeeId]!["email"]!;
    contactNo = employees[employeeId]!["contact"]!;

    SharedPreferences prefs = await SharedPreferences.getInstance();

    await prefs.setString("name", name);
    await prefs.setString("department", department);
    await prefs.setString("employeeID", employeeId);
    await prefs.setString("email", email);
    await prefs.setString("contactNo", contactNo);

    await prefs.setBool("isLoggedIn", true);
    await FirebaseFirestore.instance
        .collection("employees")
        .doc(employeeId)
        .set({
          "name": name,
          "department": department,
          "employeeID": employeeId,
          "email": email,
          "contactNo": contactNo,
          "createdAt": Timestamp.now(),
        });

    if (!mounted) return;

    if (employeeId == "999999") {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const AdminDashboard()),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const DashboardPage()),
      );
    }

    setState(() {
      changeButton = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              SizedBox(
                height: 120,
                child: Image.asset(
                  "assets/images/login_image.png",
                  fit: BoxFit.contain,
                ),
              ),
              SizedBox(height: 20),

              Text(
                "Employee Attendance Portal",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple,
                ),
              ),

              SizedBox(height: 15),

              Text(
                "Employee Attendance Management System",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Card(
                  elevation: 10,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 16,
                      horizontal: 32,
                    ),
                    child: Column(
                      children: [
                        TextFormField(
                          textCapitalization: TextCapitalization.words,
                          decoration: InputDecoration(
                            prefixIcon: Icon(Icons.person),
                            hintText: "Enter Name",
                            labelText: "Employee Name",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Name cannot be empty";
                            }
                            return null;
                          },
                          onChanged: (value) {
                            name = value;
                            setState(() {});
                          },
                        ),

                        SizedBox(height: 15),

                        TextFormField(
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          decoration: InputDecoration(
                            prefixIcon: Icon(Icons.badge),
                            hintText: "Enter Employee ID",
                            labelText: "Employee ID",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Employee ID cannot be empty";
                            }
                            return null;
                          },
                          onChanged: (value) {
                            employeeId = value;
                          },
                        ),

                        SizedBox(height: 15),

                        SizedBox(height: 20),
                        Material(
                          color: Colors.deepPurple,
                          child: InkWell(
                            onTap: () {
                              moveToHome();
                            },
                            child: AnimatedContainer(
                              duration: Duration(seconds: 1),
                              width: changeButton ? 50 : 180,
                              height: 50,
                              alignment: Alignment.center,
                              child: changeButton
                                  ? Icon(Icons.done, color: Colors.white)
                                  : Text(
                                      "Login",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                      ),
                                    ),

                              // shape: changeButton
                              // ?BoxShape.circle :
                              // BoxShape.rectangle,
                            ),
                          ),
                        ),

                        // ElevatedButton(
                        //   child: Text("Login"),
                        //   style: TextButton.styleFrom(minimumSize: Size(150, 40)),
                        //   onPressed: () {
                        //   Navigator.pushNamed(context, MyRoutes.homeRoute);
                        //   },
                        // ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

