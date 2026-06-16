import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:my_new_app/pages/dashboard_page.dart';

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

  final _formKey = GlobalKey<FormState>();

  Future<void> moveToHome() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        changeButton = true;
      });
      SharedPreferences prefs = await SharedPreferences.getInstance();

      await prefs.setString("name", name);
      await prefs.setString("department", department);
      await prefs.setString("employeeID", employeeId);
      await prefs.setString("email", email);
      await prefs.setString("contactNo", contactNo);

      if (!mounted) return;

      Navigator.push(
        this.context,
        MaterialPageRoute(builder: (context) => const DashboardPage()),
      );

      setState(() {
        changeButton = false;
      });
    }
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
                          keyboardType: TextInputType.text,
                          decoration: InputDecoration(
                            prefixIcon: Icon(Icons.business),
                            hintText: "Enter Department",
                            labelText: "Department",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Department cannot be empty";
                            }
                            return null;
                          },
                          onChanged: (value) {
                            department = value;
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

                        TextFormField(
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                            prefixIcon: Icon(Icons.email),
                            hintText: "Enter Email",
                            labelText: "Email",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Email cannot be empty";
                            } else if (!value.contains("@")) {
                              return "Enter a valid email";
                            }
                            return null;
                          },
                          onChanged: (value) {
                            email = value;
                          },
                        ),

                        SizedBox(height: 15),

                        TextFormField(
                          keyboardType: TextInputType.phone,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          decoration: InputDecoration(
                            prefixIcon: Icon(Icons.phone),
                            hintText: "Enter Contact Number",
                            labelText: "Contact Number",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Contact Number cannot be empty";
                            } else if (value.length != 10) {
                              return "Enter a valid 10 digit number";
                            }
                            return null;
                          },
                          onChanged: (value) {
                            contactNo = value;
                          },
                        ),

                        SizedBox(height: 20),
                        Material(
                          color: Colors.deepPurple,
                          borderRadius: BorderRadius.circular(
                            changeButton ? 50 : 15,
                          ),
                          child: InkWell(
                            onTap: moveToHome,
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
// Day9 update