import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flowershop/pages/cart_page.dart';
import 'package:flowershop/pages/gallery_page.dart';
import 'package:flowershop/pages/profile_page.dart';
import 'package:flowershop/pages/history_page.dart';
import 'package:flowershop/pages/token_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:io';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class Bouquet {
  final String name;
  final String description;
  final double price;
  final String imagePath;

  const Bouquet({
    required this.name,
    required this.description,
    required this.price,
    required this.imagePath,
  });

  factory Bouquet.fromJson(Map<String, dynamic> json) {
    return Bouquet(
      name: json['name']?.toString() ?? 'Unknown',
      description: json['description']?.toString() ?? '',
      price: double.tryParse(json['price']?.toString() ?? '0') ?? 0.0,
      imagePath: json['image_path']?.toString() ?? '',
    );
  }
}

class _HomePageState extends State<HomePage> {
  List<Bouquet> bouquets = [];

  @override
  void initState() {
    super.initState();
    fetchBouquets();
  }

  Future<void> fetchBouquets() async {
    final token = await Token.getToken();
    final response = await http.get(
      Uri.parse('http://10.0.2.2:8080/api/home'),
      headers: {HttpHeaders.authorizationHeader: 'Bearer $token'},
    );
    if (response.statusCode == 200) {
      final List<dynamic> jsonData = json.decode(response.body);
      setState(() {
        bouquets = jsonData.map((item) => Bouquet.fromJson(item)).toList();
      });
    } else {
      throw Exception('Failed to load bouquets');
    }
  }

  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      switch (_selectedIndex) {
        case 0:
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => HomePage()),
          );
        case 1:
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => GalleryPage()),
          );
        case 2:
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => CartPage()),
          );
        case 3:
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => HistoryPage()),
          );
      }
    });
  }

  final TextEditingController searchbar = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(255, 255, 255, 1),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.purple, // Highlighted item color
        unselectedItemColor: Colors.grey, // Unselected item color
        onTap: _onItemTapped, // Handle tap
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.grid_view),
            label: "Gallery",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: "Checkout",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list_alt),
            label: "Orders",
          ),
        ],
      ),
      body: ListView(
        padding: EdgeInsets.all(20),
        children: [
          Row(
            children: [
              Text(
                "Rizza FlowerShop",
                style: GoogleFonts.dancingScript(
                  fontWeight: FontWeight.bold,
                  fontSize: 28,
                  color: Color.fromRGBO(190, 54, 165, 1),
                ),
              ),
              Padding(padding: EdgeInsets.only(left: 120)),
              IconButton(
                onPressed:
                    () => {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => ProfilePage()),
                      ),
                    },
                icon: Icon(Icons.person, color: Colors.pink, size: 40),
              ),
            ],
          ),
          Padding(padding: EdgeInsets.only(top: 30)),
          Text(
            "Shop Our Best",
            style: GoogleFonts.merriweather(
              fontWeight: FontWeight.bold,
              fontSize: 40,
            ),
          ),
          Text(
            "Sellers",
            style: GoogleFonts.merriweather(
              fontWeight: FontWeight.bold,
              fontSize: 40,
            ),
          ),
          Padding(
            padding: EdgeInsets.only(top: 10),
            child: TextField(
              controller: searchbar,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderSide: BorderSide(width: 1, color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                prefixIcon: Icon(Icons.search),
                filled: true,
                hintText: "what do you want to find?",
                hintStyle: GoogleFonts.inter(
                  fontWeight: FontWeight.normal,
                  fontSize: 16,
                ),
                fillColor: Color.fromRGBO(255, 255, 255, 1),
              ),
            ),
          ),
          Padding(padding: EdgeInsets.only(top: 40)),
          Text(
            "Event Categories",
            style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          Padding(padding: EdgeInsets.only(top: 10)),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color.fromRGBO(255, 255, 255, 1),
                    side: BorderSide(width: 1, color: Colors.grey),
                    fixedSize: Size(95, 40),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  child: Text("Text"),
                ),
                Padding(padding: EdgeInsets.only(left: 10)),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color.fromRGBO(255, 255, 255, 1),
                    side: BorderSide(width: 1, color: Colors.grey),
                    fixedSize: Size(95, 40),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  child: Text("Text"),
                ),
                Padding(padding: EdgeInsets.only(left: 10)),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color.fromRGBO(255, 255, 255, 1),
                    side: BorderSide(width: 1, color: Colors.grey),
                    fixedSize: Size(95, 40),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  child: Text("Text"),
                ),
                Padding(padding: EdgeInsets.only(left: 10)),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color.fromRGBO(255, 255, 255, 1),
                    side: BorderSide(width: 1, color: Colors.grey),
                    fixedSize: Size(95, 40),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  child: Text("Text"),
                ),
                Padding(padding: EdgeInsets.only(left: 10)),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color.fromRGBO(255, 255, 255, 1),
                    side: BorderSide(width: 1, color: Colors.grey),
                    fixedSize: Size(95, 40),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  child: Text("Text"),
                ),
                Padding(padding: EdgeInsets.only(left: 10)),
              ],
            ),
          ),
          Padding(padding: EdgeInsets.only(top: 10)),
          Row(children: [Image.asset("lib/assets/images/Frame1.png")]),
          Padding(padding: EdgeInsets.only(top: 10)),
          ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: bouquets.length,
            itemBuilder: (context, index) {
              final bouquet = bouquets[index];
              return Card(
                elevation: 0,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 100, // Set the size you want
                        height: 100,
                        child: Image.network(
                          bouquet.imagePath,
                          fit: BoxFit.cover,
                        ),
                      ),
                      SizedBox(width: 10), // Spacing between image and content
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              bouquet.name,
                              style: GoogleFonts.inter(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Padding(padding: EdgeInsets.only(top: 8)),
                            Text(
                              bouquet.description,
                              style: GoogleFonts.inter(
                                fontSize: 10,
                                fontWeight: FontWeight.w300,
                              ),
                            ),
                            Padding(padding: EdgeInsets.only(top: 3)),
                            Text(
                              '₱${bouquet.price.toStringAsFixed(2)}',
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          Padding(padding: EdgeInsets.only(top: 10)),
          Row(
            children: [
              Text(
                "Gallery",
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
              Padding(padding: EdgeInsets.only(left: 210)),
              TextButton(
                onPressed:
                    () => {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => GalleryPage()),
                      ),
                    },
                child: Text(
                  "view all",
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
          ),
          Row(
            children: [
              SizedBox(
                width: 150,
                child: Image.network(
                  'http://10.0.2.2:8080/images/inventory-items/sweetbouquet.jpg',
                ),
              ),
              SizedBox(width: 40),
              SizedBox(
                width: 150,
                child: Image.network(
                  'http://10.0.2.2:8080/images/inventory-items/lavenderbouquet.jpg',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
