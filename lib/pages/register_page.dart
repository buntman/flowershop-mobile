import 'package:flowershop/pages/login_page.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController email = TextEditingController();
  final TextEditingController password = TextEditingController();
  final TextEditingController confirmPassword = TextEditingController();

  Future<void> register() async {
    final url = Uri.parse("http://10.0.2.2:8000/api/register");

    final response = await http.post(
      url,
      headers: {
        HttpHeaders.contentTypeHeader: 'application/json',
        HttpHeaders.acceptHeader: 'application/json',
      },
      body: jsonEncode({
        "email": email.text,
        "password": password.text,
        "password_confirmation": confirmPassword.text,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "${data["message"]}",
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w300,
              color: Colors.white,
            ),
          ),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()),
      );
    } else if (response.statusCode == 422) {
      final data = jsonDecode(response.body);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${data["message"] ?? ""}',
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w300,
              color: Colors.white,
            ),
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(255, 255, 255, 1),
      body: Column(
        children: [
          Padding(padding: EdgeInsets.only(top: 50.0)),
          Text(
            "Flowershop",
            style: GoogleFonts.poppins(
              fontSize: 32,
              fontWeight: FontWeight.w600,
              color: const Color.fromARGB(255, 190, 54, 165),
            ),
          ),
          Padding(padding: EdgeInsets.only(top: 10, bottom: 10)),
          Text(
            "Register",
            style: GoogleFonts.poppins(
              fontSize: 35,
              fontWeight: FontWeight.w600,
            ),
          ),
          Padding(padding: EdgeInsets.only(top: 30)),
          Row(
            children: <Widget>[
              Padding(padding: EdgeInsets.only(left: 50)),
              Text(
                "Email",
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w500,
                  fontSize: 16,
                  color: Color.fromRGBO(255, 105, 181, 1),
                ),
              ),
            ],
          ),
          Padding(
            padding: EdgeInsets.only(top: 5, left: 50, right: 50),
            child: TextField(
              controller: email,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderSide: BorderSide.none,
                  borderRadius: BorderRadius.circular(10),
                ),
                filled: true,
                hintText: "Enter your email",
                fillColor: Color.fromRGBO(255, 227, 235, 1),
              ),
            ),
          ),
          Padding(padding: EdgeInsets.only(top: 15)),
          Row(
            children: <Widget>[
              Padding(padding: EdgeInsets.only(left: 50)),
              Text(
                "Password",
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w500,
                  fontSize: 16,
                  color: Color.fromRGBO(255, 105, 181, 1),
                ),
              ),
            ],
          ),
          Padding(
            padding: EdgeInsets.only(top: 5, left: 50, right: 50),
            child: TextField(
              obscureText: true,
              controller: password,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderSide: BorderSide.none,
                  borderRadius: BorderRadius.circular(10),
                ),
                filled: true,
                hintText: "Enter your password",
                fillColor: Color.fromRGBO(255, 227, 235, 1),
              ),
            ),
          ),
          Padding(padding: EdgeInsets.only(top: 20)),
          Row(
            children: <Widget>[
              Padding(padding: EdgeInsets.only(left: 50)),
              Text(
                "Confirm Password",
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w500,
                  fontSize: 16,
                  color: Color.fromRGBO(255, 105, 181, 1),
                ),
              ),
            ],
          ),
          Padding(
            padding: EdgeInsets.only(top: 5, left: 50, right: 50),
            child: TextField(
              obscureText: true,
              controller: confirmPassword,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderSide: BorderSide.none,
                  borderRadius: BorderRadius.circular(10),
                ),
                filled: true,
                hintText: "Enter your password",
                fillColor: Color.fromRGBO(255, 227, 235, 1),
              ),
            ),
          ),
          Padding(padding: EdgeInsets.only(top: 20)),
          ElevatedButton(
            onPressed: () async {
              await register();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Color.fromRGBO(224, 6, 98, .47),
              foregroundColor: Color.fromRGBO(33, 33, 33, 1),
              minimumSize: Size(310, 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text("Register", style: GoogleFonts.poppins()),
          ),
          Padding(padding: EdgeInsets.only(top: 10)),
          Row(
            children: <Widget>[
              Padding(padding: EdgeInsets.only(left: 70)),
              Text(
                "Already have an account?",
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w400,
                  fontSize: 14,
                  color: Color.fromRGBO(255, 168, 212, 1),
                ),
              ),
              TextButton(
                onPressed:
                    () => {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => LoginPage()),
                      ),
                    },
                child: Text(
                  "Login",
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w400,
                    color: Color.fromRGBO(126, 79, 99, 1),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
