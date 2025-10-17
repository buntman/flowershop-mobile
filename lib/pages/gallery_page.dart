import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flowershop/pages/orders_list_page.dart';
import 'package:flowershop/pages/profile_page.dart';
import 'package:flowershop/pages/cart_page.dart';
import 'package:flowershop/pages/token_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:io';

class GalleryPage extends StatefulWidget {
  const GalleryPage({super.key});

  @override
  State<GalleryPage> createState() => _GalleryPagestate();
}

class Bouquet {
  final int id;
  final String name;
  final double price;
  final String image;

  const Bouquet({
    required this.id,
    required this.name,
    required this.price,
    required this.image,
  });

  factory Bouquet.fromJson(Map<String, dynamic> json) {
    return Bouquet(
      id: json['id'],
      name: json['name']?.toString() ?? 'Unknown',
      price: double.tryParse(json['price']?.toString() ?? '0') ?? 0.0,
      image: json['image_name']?.toString() ?? '',
    );
  }
}

class _GalleryPagestate extends State<GalleryPage> {
  bool _isLoading = true;
  List<Bouquet> bouquets = [];

  @override
  void initState() {
    super.initState();
    _initializeGallery();
  }

  Future<void> _initializeGallery() async {
    await _fetchBouquets();
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _fetchBouquets() async {
    final token = await Token.getToken();
    final response = await http.get(
      Uri.parse('http://127.0.0.1:8000/api/gallery'),
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

  Future<void> _addBouquetToCart(Bouquet bouquet) async {
    final token = await Token.getToken();
    final response = await http.post(
      Uri.parse('http://127.0.0.1:8000/api/cart/items'),
      headers: {
        HttpHeaders.authorizationHeader: 'Bearer $token',
        HttpHeaders.contentTypeHeader: 'application/json',
        HttpHeaders.acceptHeader: 'application/json',
      },
      body: jsonEncode({"product_id": bouquet.id}),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(data['message'], style: TextStyle(color: Colors.white)),
          duration: Duration(milliseconds: 500),
          backgroundColor: Colors.green,
        ),
      );
    } else if (response.statusCode == 422) {
      final data = jsonDecode(response.body);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(data['message'], style: TextStyle(color: Colors.white)),
          duration: Duration(milliseconds: 500),
          backgroundColor: Colors.red,
        ),
      );
    } else {
      throw Exception('HTTP ${response.statusCode}');
    }
  }

  int _selectedIndex = 1; // Set the default selected index

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    switch (_selectedIndex) {
      case 0:
        Navigator.pop(context);
      case 1:
        break;
      case 2:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => OrdersListPage()),
        );
      case 3:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => ProfilePage()),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: TextField(
          decoration: InputDecoration(
            hintText: 'What do you want to find?',
            prefixIcon: Icon(Icons.search),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
            fillColor: Colors.grey[200],
            filled: true,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.shopping_cart, size: 36),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => CartPage()),
              );
            },
          ),
        ],
      ),
      body:
          _isLoading
              ? Center(child: CircularProgressIndicator())
              : Padding(
                padding: EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Gallery',
                          style: GoogleFonts.inter(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Row(
                          children: [
                            SizedBox(
                              width: 60,
                              height: 30,
                              child: ElevatedButton(
                                onPressed: () {},
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Color.fromRGBO(
                                    255,
                                    255,
                                    255,
                                    1,
                                  ),
                                  side: BorderSide(
                                    width: 1,
                                    color: Colors.grey,
                                  ),
                                  padding: EdgeInsets.symmetric(
                                    vertical: 1,
                                    horizontal: 4,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                                child: Text(
                                  "sort by",
                                  style: GoogleFonts.inter(
                                    fontWeight: FontWeight.w400,
                                    fontSize: 14,
                                    color: Colors.grey,
                                  ),
                                ),
                              ),
                            ),
                            Padding(padding: EdgeInsets.only(left: 5)),
                            SizedBox(
                              width: 60,
                              height: 30,
                              child: ElevatedButton(
                                onPressed: () {},
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Color.fromRGBO(
                                    255,
                                    255,
                                    255,
                                    1,
                                  ),
                                  side: BorderSide(
                                    width: 1,
                                    color: Colors.grey,
                                  ),
                                  padding: EdgeInsets.symmetric(
                                    vertical: 1,
                                    horizontal: 4,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                                child: Text(
                                  "filter",
                                  style: GoogleFonts.inter(
                                    fontWeight: FontWeight.w400,
                                    fontSize: 14,
                                    color: Colors.grey,
                                  ),
                                ),
                              ),
                            ),
                            Padding(padding: EdgeInsets.only(right: 10)),
                          ],
                        ),
                      ],
                    ),
                    Padding(padding: EdgeInsets.only(bottom: 10)),
                    Expanded(
                      child: GridView.builder(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                          childAspectRatio: 0.7,
                        ),
                        itemCount: bouquets.length,
                        itemBuilder: (context, index) {
                          final bouquet = bouquets[index];
                          return Card(
                            margin: EdgeInsets.zero,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.stretch, // see #2
                              children: [
                                Expanded(
                                  child: AspectRatio(
                                    aspectRatio:
                                        1, // 1 = square, or use 3/2, 16/9, etc. for rectangle
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.vertical(
                                        top: Radius.circular(10),
                                      ),
                                      child: Image.network(
                                        bouquet.image,
                                        fit:
                                            BoxFit
                                                .cover, // Fill the box while maintaining aspect
                                      ),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.all(8),
                                  child: Column(
                                    children: [
                                      Text(
                                        bouquet.name,
                                        style: GoogleFonts.inter(
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      SizedBox(height: 5),
                                      Text(
                                        '₱${bouquet.price.toStringAsFixed(2)}',
                                        style: GoogleFonts.inter(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      SizedBox(height: 5),
                                      OutlinedButton(
                                        style: OutlinedButton.styleFrom(
                                          side: const BorderSide(
                                            color: Color.fromRGBO(
                                              190,
                                              54,
                                              165,
                                              1,
                                            ),
                                            width: 2,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              20,
                                            ),
                                          ),
                                          padding: EdgeInsets.symmetric(
                                            vertical: 10,
                                            horizontal: 30,
                                          ),
                                          minimumSize: Size(30, 5),
                                        ),
                                        onPressed: () {
                                          _addBouquetToCart(bouquet);
                                        },
                                        child: Text(
                                          'Add to Cart',
                                          style: GoogleFonts.averiaSerifLibre(
                                            color: Color.fromRGBO(
                                              190,
                                              54,
                                              165,
                                              1,
                                            ),
                                            fontSize: 10,
                                            fontWeight: FontWeight.w300,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
    );
  }
}
