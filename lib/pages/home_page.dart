import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flowershop/pages/cart_page.dart';
import 'package:flowershop/pages/gallery_page.dart';
import 'package:flowershop/pages/profile_page.dart';
import 'package:flowershop/pages/orders_list_page.dart';
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
  final double price;
  final String image;

  const Bouquet({required this.name, required this.price, required this.image});

  factory Bouquet.fromJson(Map<String, dynamic> json) {
    return Bouquet(
      name: json['name']?.toString() ?? 'Unknown',
      price: double.tryParse(json['price']?.toString() ?? '0') ?? 0.0,
      image: json['image_name']?.toString() ?? '',
    );
  }
}

class _HomePageState extends State<HomePage> {
  List<Bouquet> bouquets = [];

  @override
  void initState() {
    super.initState();
    _initializeHome();
  }

  Future<void> _initializeHome() async {
    await _fetchBouquets();
  }

  Future<void> _fetchBouquets() async {
    final token = await Token.getToken();
    final response = await http.get(
      Uri.parse('http://127.0.0.1:8000/api/home'),
      headers: {
        HttpHeaders.authorizationHeader: 'Bearer $token',
        HttpHeaders.acceptHeader: 'application/json',
      },
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
    });
    switch (_selectedIndex) {
      case 0:
        break;
      case 1:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => GalleryPage()),
        );
        break;
      case 2:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => OrdersListPage()),
        );
        break;
      case 3:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ProfilePage()),
        );
        break;
    }
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
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(
            icon: Icon(Icons.grid_view),
            label: "Gallery",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long),
            label: "Orders",
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Me"),
        ],
      ),
      body: SafeArea(
        child: ListView(
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
                Padding(padding: EdgeInsets.only(left: 85)),
                IconButton(
                  onPressed:
                      () => {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => CartPage()),
                        ),
                      },
                  icon: Icon(Icons.shopping_cart, size: 32),
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
                            bouquet.image,
                            fit: BoxFit.cover,
                          ),
                        ),
                        SizedBox(
                          width: 10,
                        ), // Spacing between image and content
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
                                'It is a long established fact that a reader will be distracted by the readable content of a page when looking at its layout. The point of using Lorem Ipsum is that it has a more-or-less normal distribution of letters,',
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
          ],
        ),
      ),
    );
  }
}
