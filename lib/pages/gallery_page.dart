import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flowershop/pages/cart_page.dart';
import 'package:flowershop/pages/home_page.dart';
import 'package:flowershop/pages/history_page.dart';
import 'package:flowershop/pages/token_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:io';

class GalleryPage extends StatefulWidget {
  const GalleryPage({super.key});

  @override
  State<GalleryPage> createState() => _GalleryPagestate();
}


class Bouquet {
    final String name;
    final double price;
    final String imagePath;
    
    const Bouquet({required this.name, required this.price, required this.imagePath});

    factory Bouquet.fromJson(Map<String,dynamic> json) {
        return Bouquet(
        name: json['name']?.toString() ?? 'Unknown',
        price: double.tryParse(json['price']?.toString() ?? '0') ?? 0.0,
        imagePath: json['image_path']?.toString() ?? '',
      );
    }
}

class _GalleryPagestate extends State<GalleryPage> {
      List<Bouquet> bouquets = [];

      @override
      void initState() {
          super.initState();
          fetchBouquets();
      }

      Future <void> fetchBouquets() async {
            final token = await Token.getToken();
            final response = await http.get(
            Uri.parse('http://10.0.2.2:8080/api/gallery'),
            headers: {HttpHeaders.authorizationHeader: 'Bearer $token'},
            );
            if(response.statusCode == 200) {
                final List<dynamic> jsonData = json.decode(response.body);
                 setState(() {
                    bouquets = jsonData.map((item) => Bouquet.fromJson(item)).toList();
                });
            } else {
                throw Exception('Failed to load bouquets');
            }
      }

      Future <void> addBouquetToCart(Bouquet bouquet) async {
            final token = await Token.getToken();
            final response = await http.post(
            Uri.parse('http://10.0.2.2:8080/api/cart/add'),
            headers: {
                HttpHeaders.authorizationHeader: 'Bearer $token',
                HttpHeaders.contentTypeHeader: 'application/json',
            },
            body: jsonEncode({
                "name": bouquet.name,
                })
            );
            final data = jsonDecode(response.body);
            if(data['success'] == true) {
                ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                content: Text(data['message'], style: TextStyle(color: Colors.white)),
                backgroundColor: Colors.green,
                ),
            );
            } else if(data['success'] == false){
                ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                content: Text(data['message'], style: TextStyle(color: Colors.white)),
                backgroundColor: Colors.red,
                ),
            );
            }
      }


  int _selectedIndex = 1; // Set the default selected index

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      switch (_selectedIndex){
        case 0:
          Navigator.push(context, MaterialPageRoute(builder: (context) => HomePage()));
        case 1:
          Navigator.push(context, MaterialPageRoute(builder: (context) => GalleryPage()));
        case 2:
          Navigator.push(context, MaterialPageRoute(builder: (context) => CartPage()));
        case 3:
          Navigator.push(context, MaterialPageRoute(builder: (context) => HistoryPage()));
      }
    });
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
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => HomePage()));
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
            icon: Icon(Icons.shopping_bag_outlined, color: Colors.black),
            onPressed: () {},
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Gallery',
                  style: GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                Row(
                  children: [
                    SizedBox(
                      width: 60,
                      height: 30,
                      child: ElevatedButton(onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color.fromRGBO(255, 255, 255, 1),
                        side: BorderSide(width: 1,color: Colors.grey),
                        padding: EdgeInsets.symmetric(vertical: 1, horizontal: 4),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4)
                        )
                      ),
                      child: Text("sort by",
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.w400,
                        fontSize: 14,
                        color: Colors.grey,
                      ),)),),
                    Padding(padding: EdgeInsets.only(left: 5)),
                    SizedBox(
                      width: 60,
                      height: 30,
                      child: ElevatedButton(onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color.fromRGBO(255, 255, 255, 1),
                        side: BorderSide(width: 1,color: Colors.grey),
                        padding: EdgeInsets.symmetric(vertical: 1, horizontal: 4),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4)
                        )
                      ),
                      child: Text("filter",
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.w400,
                        fontSize: 14,
                        color: Colors.grey,
                      ),)),),
                      Padding(padding: EdgeInsets.only(right: 10))
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
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
                            child: Image.network(
                              bouquet.imagePath,
                              fit: BoxFit.fitWidth,
                              width: double.infinity,
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.all(8),
                          child: Column(
                            children: [
                              Text(bouquet.name, style: GoogleFonts.inter(fontWeight: FontWeight.w500)),
                              SizedBox(height: 5),
                              Text('₱${bouquet.price.toStringAsFixed(2)}', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold)),
                              SizedBox(height: 5),
                              OutlinedButton(
                                style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: Color.fromRGBO(190, 54, 165, 1), width: 2),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                padding: EdgeInsets.symmetric(vertical: 10, horizontal: 30),
                                minimumSize: Size(30, 5),
                              ),
                              onPressed: () {
                                  addBouquetToCart(bouquet);
                              },
                              child: Text(
                                'Add to Cart',
                                style: GoogleFonts.averiaSerifLibre(
                                color: Color.fromRGBO(190, 54, 165, 1),
                                fontSize: 10,
                                fontWeight: FontWeight.w300
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
