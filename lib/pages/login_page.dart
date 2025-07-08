import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flowershop/pages/home_page.dart';
import 'package:flowershop/pages/token_storage.dart';
import 'package:flowershop/pages/register_page.dart';
import 'package:http/http.dart' as http;


class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool rememberme = false;
  final TextEditingController email = TextEditingController();
  final TextEditingController password = TextEditingController();
  String message = '';

  Future<void> login() async {
    final url = Uri.parse("http://10.0.2.2:8000/api/login");

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "email": email.text, 
        "password": password.text,
      }),
    );

    final data = jsonDecode(response.body);
    
    if (data["success"] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("successful login ", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.green,
        ),
      );
      await Token.storeToken(data["token"]);
      Navigator.push(context, MaterialPageRoute(builder: (context) => HomePage()));
    } else if(data["success"] == false){ //temporary validations
      ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${data["errors"]["email"] ?? ""}\n${data["errors"]["password"] ?? ""}', style: TextStyle(color: Colors.white)),
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
          Padding(padding: EdgeInsets.only(top: 80.0)),
          Text(
            "Rizza's Flowershop",
            style: GoogleFonts.poppins(
                fontSize: 32,
                fontWeight: FontWeight.w600,
                color: const Color.fromARGB(255, 190, 54, 165),
            )
          ),
          Padding(padding: EdgeInsets.only(top: 20,bottom: 20)),
              Text(
                "Login",
                style: GoogleFonts.poppins(
                  fontSize: 35,
                  fontWeight: FontWeight.w600,
                ),
              ),
          Padding(padding: EdgeInsets.only(top: 40)),
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
          Padding(padding:
           EdgeInsets.only(
            top: 5,
           left: 50,
           right: 50
           ),
          child: TextField(
            controller: email,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderSide: BorderSide.none,
                borderRadius: BorderRadius.circular(10)
              ),
              filled: true,
              hintText: "Enter your email",
              fillColor: Color.fromRGBO(255, 227, 235, 1)
            ),
          ),
          ),
          Padding(padding: EdgeInsets.only(top: 15)),
          Row(
            children: <Widget>[
              Padding(padding: EdgeInsets.only(left: 50,)),
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
          Padding(padding:
           EdgeInsets.only(
            top: 5,
           left: 50,
           right: 50
           ),
          child: TextField(
            obscureText: true,
            controller: password,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderSide: BorderSide.none,
                borderRadius: BorderRadius.circular(10)
              ),
              filled: true,
              hintText: "Enter your password",
              fillColor: Color.fromRGBO(255, 227, 235, 1)
            ),
          ),
          ),

          Row(
            children: [
              Padding(padding: EdgeInsets.only(top: 20,left: 40)),
              Checkbox(value: rememberme, onChanged:(value) => setState(() {
                rememberme = value!;
              }),),
              Text("Remember me",
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w400,
                color: Color.fromRGBO(126, 79, 99, 1)
              ),),
              Padding(padding: EdgeInsets.only(left: 30)),
              TextButton(
                onPressed: () => {},
                child: Text("Forgot Password?",
                 style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w400,
                  color: Color.fromRGBO(126, 79, 99, 1),
                  decoration: TextDecoration.underline),
                )
              ),
            ],
          ),
          Padding(padding: EdgeInsets.only(top: 20)),
          ElevatedButton(onPressed: (){
            login();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Color.fromRGBO(224, 6, 98, .47),
            foregroundColor: Color.fromRGBO(33, 33, 33, 1),
            minimumSize: Size(310, 50),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10)
            )
          ), 
           child: Text(
          "Login",
           style: GoogleFonts.poppins(),
           )),
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
              TextButton(onPressed: () => {
      Navigator.push(context, MaterialPageRoute(builder: (context) => RegisterPage())),
                  }, 
              child: Text(
                "Sign Up",
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w400,
                  color: Color.fromRGBO(126, 79, 99, 1)
                ),
              ))
            ]
           ),
        ]
      ),
    );
  }
}
