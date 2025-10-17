import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flowershop/pages/home_page.dart';
import 'package:flowershop/pages/token_storage.dart';
import 'package:flowershop/pages/register_page.dart';
import 'package:http/http.dart' as http;
import 'dart:io';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool rememberme = false;
  final TextEditingController email = TextEditingController();
  final TextEditingController password = TextEditingController();

  Future<void> login() async {
    final url = Uri.parse("http://127.0.0.1:8000/api/login");

    final response = await http.post(
      url,
      headers: {
        HttpHeaders.contentTypeHeader: 'application/json',
        HttpHeaders.acceptHeader: 'application/json',
      },
      body: jsonEncode({"email": email.text, "password": password.text}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      await Token.storeToken(data["token"]);
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => HomePage()),
        (Route<dynamic> route) => false,
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
          duration: Duration(seconds: 2),
          backgroundColor: Colors.red,
        ),
      );
    } else {
      throw Exception('HTTP ${response.statusCode}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(255, 255, 255, 1),
      body: SafeArea(
        child: Column(
          children: [
            Padding(padding: EdgeInsets.only(top: 50.0)),
            Text(
              "Flowershop",
              style: GoogleFonts.poppins(
                fontSize: 36,
                fontWeight: FontWeight.w600,
                color: const Color.fromARGB(255, 190, 54, 165),
              ),
            ),
            Padding(padding: EdgeInsets.only(top: 30)),
            Row(
              children: <Widget>[
                Padding(padding: EdgeInsets.only(left: 30)),
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
              padding: EdgeInsets.only(top: 5, left: 30, right: 30),
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
                Padding(padding: EdgeInsets.only(left: 30)),
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
              padding: EdgeInsets.only(top: 5, left: 30, right: 30),
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
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  children: [
                    Checkbox(
                      value: rememberme,
                      onChanged: (value) {
                        setState(() {
                          rememberme = value!;
                        });
                      },
                    ),
                    Text(
                      "Remember me",
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w400,
                        color: Color.fromRGBO(126, 79, 99, 1),
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  width: 28,
                ), // adjust this value to move them closer/farther
                TextButton(
                  onPressed: () {},
                  child: Text(
                    "Forgot Password?",
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w400,
                      color: Color.fromRGBO(126, 79, 99, 1),
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ],
            ),
            Padding(padding: EdgeInsets.only(top: 20)),
            ElevatedButton(
              onPressed: () {
                login();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color.fromRGBO(224, 6, 98, .47),
                foregroundColor: Color.fromRGBO(33, 33, 33, 1),
                minimumSize: Size(300, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text("Login", style: GoogleFonts.poppins()),
            ),
            Padding(padding: EdgeInsets.only(top: 10)),
            Row(
              children: <Widget>[
                Padding(padding: EdgeInsets.only(left: 70)),
                Text(
                  "Don't have an account?",
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
                          MaterialPageRoute(
                            builder: (context) => RegisterPage(),
                          ),
                        ),
                      },
                  child: Text(
                    "Sign Up",
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
      ),
    );
  }
}
