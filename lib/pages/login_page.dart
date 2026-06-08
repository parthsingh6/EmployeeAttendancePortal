import 'package:flutter/material.dart';

class LoginPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      child: Column(
        children: [
          Image.asset("assets/images/login_image.png", fit: BoxFit.cover),
          SizedBox(height: 20),

          Text(
            "Login Page",
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          SizedBox(
            height: 20,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
            child: Column(
              children: [
              TextFormField(
              decoration: InputDecoration(
                hintText: "Enter username",
                labelText: "UserName",
              ),
            ),
            TextFormField(
              obscureText: true,
              decoration: InputDecoration(
                hintText: "Enter password",
                labelText: "Password",
              ),
            ),
             SizedBox(
            height: 20,
          ),
          ElevatedButton(
            child: Text("Login"),
            onPressed: () {
              print("Hi User");
            },
          )
              ],
            ),
          )
      
        ],
      ),
      /*Center(
        child: Text(
          "Login Page",
          style: TextStyle(
            fontSize: 30,
            color: Colors.red,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),*/
    );
  }
}
