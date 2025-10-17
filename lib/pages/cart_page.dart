import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flowershop/pages/order_page.dart';
import 'package:flowershop/pages/gallery_page.dart';
import 'package:flowershop/pages/token_storage.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:io';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class CartItems {
  final int cartItemId;
  final String imagePath;
  final String name;
  int quantity;
  final double price;

  CartItems({
    required this.cartItemId,
    required this.imagePath,
    required this.name,
    required this.quantity,
    required this.price,
  });

  factory CartItems.fromJson(Map<String, dynamic> json) {
    return CartItems(
      cartItemId: json['id'],
      imagePath: json['image_name']?.toString() ?? '',
      name: json['name']?.toString() ?? 'Unknown',
      quantity: int.tryParse(json['quantity']?.toString() ?? '') ?? 1,
      price: double.tryParse(json['price']?.toString() ?? '0') ?? 0.0,
    );
  }
}

class _CartPageState extends State<CartPage> {
  bool _isLoading = true;
  List<CartItems> cartItems = [];

  @override
  void initState() {
    super.initState();
    _initializeCart();
  }

  Future<void> _initializeCart() async {
    await _fetchCartItems();
    await _fetchTotalPrice();
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _fetchCartItems() async {
    final token = await Token.getToken();
    final response = await http.get(
      Uri.parse('http://127.0.0.1:8000/api/cart/items'),
      headers: {
        HttpHeaders.authorizationHeader: 'Bearer $token',
        HttpHeaders.acceptHeader: 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> jsonData = json.decode(response.body);
      setState(() {
        cartItems = jsonData.map((item) => CartItems.fromJson(item)).toList();
      });
    } else {
      throw Exception('HTTP ${response.statusCode}'); // ✅ Specific
    }
  }

  Future<double> _fetchTotalPrice() async {
    final token = await Token.getToken();
    final response = await http.get(
      Uri.parse('http://127.0.0.1:8000/api/cart/total'),
      headers: {
        HttpHeaders.authorizationHeader: 'Bearer $token',
        HttpHeaders.acceptHeader: 'application/json',
      },
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return double.tryParse(data['total'].toString()) ?? 0;
    } else {
      throw Exception('HTTP ${response.statusCode}'); // ✅ Specific
    }
  }

  Future<void> _deleteCartItem(CartItems item) async {
    final token = await Token.getToken();
    final response = await http.delete(
      Uri.parse('http://127.0.0.1:8000/api/cart/items/${item.cartItemId}'),
      headers: {HttpHeaders.authorizationHeader: 'Bearer $token'},
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
    } else {
      throw Exception('HTTP ${response.statusCode}'); // ✅ Specific
    }
  }

  Future<void> _updateItemQuantity(CartItems item) async {
    final token = await Token.getToken();
    final response = await http.patch(
      Uri.parse('http://127.0.0.1:8000/api/cart/items/${item.cartItemId}'),
      headers: {
        HttpHeaders.authorizationHeader: 'Bearer $token',
        HttpHeaders.contentTypeHeader: 'application/json',
      },
      body: jsonEncode({"quantity": item.quantity}),
    );
  }

  Future<void> _isUserDetailsUpdated() async {
    final token = await Token.getToken();
    final response = await http.get(
      Uri.parse('http://127.0.0.1:8000/api/profile?details=complete'),
      headers: {
        HttpHeaders.authorizationHeader: 'Bearer $token',
        HttpHeaders.acceptHeader: 'application/json',
      },
    );
    final data = jsonDecode(response.body);

    if (response.statusCode == 200 && data['success'] == true) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => OrderPage()),
      );
      return;
    }

    if (response.statusCode == 422 && data['success'] == false) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(data['message'], style: TextStyle(color: Colors.white)),
          duration: Duration(milliseconds: 500),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (response.statusCode != 200) {
      throw Exception('HTTP ${response.statusCode}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "My Cart",
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
          onPressed: () => {Navigator.pop(context)},
        ),
      ),
      body:
          _isLoading
              ? Center(child: CircularProgressIndicator())
              : cartItems.isEmpty
              ? Center(
                child: Padding(
                  padding: const EdgeInsets.only(
                    top: 60.0,
                  ), // move down slightly from top
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      IconButton(
                        icon: Icon(
                          Icons.shopping_cart,
                          color: Colors.black,
                          size: 150,
                        ),
                        onPressed: () {},
                      ),
                      Text(
                        "Your cart is empty",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: 3),
                      SizedBox(
                        width: 300,
                        child: Text(
                          "Looks like you have not added anything to your cart. Go ahead & explore the gallery!",
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      SizedBox(height: 10),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.pink,
                          padding: EdgeInsets.symmetric(
                            vertical: 10,
                            horizontal: 15,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5),
                          ),
                        ),
                        onPressed:
                            () => {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => GalleryPage(),
                                ),
                              ),
                            },
                        child: Text(
                          "Shop Now",
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
              )
              : Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      itemCount: cartItems.length,
                      itemBuilder: (context, index) {
                        var item = cartItems[index];
                        return Column(
                          children: [
                            ListTile(
                              minTileHeight: 120,
                              leading: ClipRRect(
                                borderRadius: BorderRadius.vertical(
                                  top: Radius.circular(2),
                                ),
                                child: SizedBox(
                                  width: 100,
                                  height: 100,
                                  child: Image.network(
                                    item.imagePath,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              title: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.name,
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  Text(
                                    '₱${item.price.toStringAsFixed(2)}',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: Icon(Icons.remove),
                                    onPressed: () {
                                      setState(() {
                                        if (item.quantity > 1) {
                                          item.quantity--;
                                          _updateItemQuantity(item);
                                        }
                                      });
                                    },
                                  ),
                                  Text(
                                    '${item.quantity}',
                                    style: TextStyle(fontSize: 14),
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.add),
                                    onPressed: () {
                                      setState(() {
                                        item.quantity++;
                                        _updateItemQuantity(item);
                                      });
                                    },
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.delete),
                                    color: Colors.red,
                                    onPressed: () {
                                      setState(() {
                                        cartItems.remove(item);
                                        _deleteCartItem(item);
                                      });
                                    },
                                  ),
                                ],
                              ),
                            ),
                            Divider(),
                          ],
                        );
                      },
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(20.0),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            FutureBuilder(
                              future: _fetchTotalPrice(),
                              builder: (context, snapshot) {
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Total",
                                      style: GoogleFonts.inter(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    Text(
                                      '${snapshot.data}',
                                      style: GoogleFonts.inter(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                            ElevatedButton(
                              onPressed: () async {
                                await _isUserDetailsUpdated();
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.pink,
                                padding: EdgeInsets.symmetric(
                                  vertical: 15,
                                  horizontal: 40,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(5),
                                ),
                              ),
                              child: Text(
                                "Check out",
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
    );
  }
}
