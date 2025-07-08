import 'package:flowershop/pages/home_page.dart';
import 'package:flowershop/pages/login_page.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flowershop/pages/token_storage.dart';
import 'package:flowershop/pages/edit_profile_page.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:io';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class UserInfo {
  final String email;
  String name;
  String contactNumber;

  UserInfo({
    required this.email,
    required this.name,
    required this.contactNumber,
  });

  factory UserInfo.fromJson(Map<String, dynamic> json) {
    return UserInfo(
      email: json['email']?.toString() ?? '',
      name:
          json['name']?.toString().trim().isNotEmpty == true
              ? json['name'].toString()
              : 'Not Set',
      contactNumber:
          json['contact_number']?.toString().trim().isNotEmpty == true
              ? json['contact_number'].toString()
              : 'Not Set',
    );
  }
}

class _ProfilePageState extends State<ProfilePage> {
  UserInfo? user;

  @override
  void initState() {
    super.initState();
    fetchUserDetails();
  }

  Future<void> fetchUserDetails() async {
    final token = await Token.getToken();
    final response = await http.get(
      Uri.parse('http://10.0.2.2:8080/api/profile'),
      headers: {HttpHeaders.authorizationHeader: 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonData = json.decode(response.body);
      setState(() {
        user = UserInfo.fromJson(jsonData);
      });
    } else {
      throw Exception('Failed to user');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Profile",
          style: GoogleFonts.inter(
            color: Colors.black,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed:
              () => {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => HomePage()),
                ),
              },
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            IconButton(
              icon: Icon(Icons.person, color: Colors.black, size: 180),
              onPressed: () {
              },
            ),
            Container(
              margin: EdgeInsets.only(right: 30),
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.pink,
                  padding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => EditProfilePage()),
                  );
                },
                child: Text(
                  "Edit Profile",
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
            Row(
              children: <Widget>[
                Padding(padding: EdgeInsets.only(left: 32)),
                Text(
                  "Email",
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w500,
                    fontSize: 16,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
            Padding(padding: EdgeInsets.only(bottom: 5)),
            Container(
              margin: EdgeInsets.symmetric(
                horizontal: 30,
              ), // margin on left & right
              width: double.infinity,
              alignment: Alignment.centerLeft,
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 10),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade400),
                borderRadius: BorderRadius.circular(8),
                color: Colors.grey.shade100,
              ),
              child: Text(
                user?.email ?? '',
                style: TextStyle(fontSize: 16, color: Colors.grey.shade800),
              ),
            ),
            Padding(padding: EdgeInsets.only(bottom: 10)),
            Row(
              children: <Widget>[
                Padding(padding: EdgeInsets.only(left: 32)),
                Text(
                  "Name",
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w500,
                    fontSize: 16,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
            Padding(padding: EdgeInsets.only(bottom: 5)),
            Container(
              margin: EdgeInsets.symmetric(
                horizontal: 30,
              ), // margin on left & right
              width: double.infinity,
              alignment: Alignment.centerLeft,
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 10),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade400),
                borderRadius: BorderRadius.circular(8),
                color: Colors.grey.shade100,
              ),
              child: Text(
                user?.name ?? '',
                style: TextStyle(fontSize: 16, color: Colors.grey.shade800),
              ),
            ),
            Padding(padding: EdgeInsets.only(bottom: 10)),
            Row(
              children: <Widget>[
                Padding(padding: EdgeInsets.only(left: 32)),
                Text(
                  "Contact Number",
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w500,
                    fontSize: 16,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
            Padding(padding: EdgeInsets.only(bottom: 5)),
            Container(
              margin: EdgeInsets.symmetric(
                horizontal: 30,
              ), // margin on left & right
              width: double.infinity,
              alignment: Alignment.centerLeft,
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 10),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade400),
                borderRadius: BorderRadius.circular(8),
                color: Colors.grey.shade100,
              ),
              child: Text(
                user?.contactNumber ?? '',
                style: TextStyle(fontSize: 16, color: Colors.grey.shade800),
              ),
            ),
            Padding(padding: EdgeInsets.only(bottom: 20)),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.pink,
                padding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
              onPressed: () async {
                await Token.removeToken();
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => LoginPage()),
                );
              },
              child: Text(
                "Sign Out",
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
