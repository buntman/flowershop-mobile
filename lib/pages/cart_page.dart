import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flowershop/pages/order_page.dart';
import 'package:flowershop/pages/gallery_page.dart';
import 'package:flowershop/pages/token_storage.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'package:confirm_dialog/confirm_dialog.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class CartItems {
  final int cartItemId;
  final String image;
  final String name;
  int quantity;
  final double price;

  CartItems({
    required this.cartItemId,
    required this.image,
    required this.name,
    required this.quantity,
    required this.price,
  });

  factory CartItems.fromJson(Map<String, dynamic> json) {
    return CartItems(
      cartItemId: json['id'],
      image: json['image_name']?.toString() ?? '',
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
      throw Exception('HTTP ${response.statusCode}');
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
      throw Exception('HTTP ${response.statusCode}');
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
      throw Exception('HTTP ${response.statusCode}');
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
      Navigator.pushReplacement(
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
      backgroundColor: Colors.white,
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
                        return Card(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 6,
                          ),
                          elevation: 3,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: LayoutBuilder(
                            builder: (context, constraints) {
                              final imageSize =
                                  constraints.maxWidth *
                                  0.25; // 25% of card width
                              return Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: SizedBox(
                                        width: imageSize,
                                        height: imageSize,
                                        child: Image.network(
                                          item.image,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),

                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          // Product name and price
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                item.name,
                                                style: const TextStyle(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w400,
                                                ),
                                              ),
                                              const SizedBox(height: 8),
                                              Text(
                                                '₱${item.price.toStringAsFixed(2)}',
                                                style: const TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ],
                                          ),

                                          const SizedBox(height: 8),

                                          // Quantity and buttons
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Row(
                                                children: [
                                                  IconButton(
                                                    icon: const Icon(
                                                      Icons.remove,
                                                    ),
                                                    iconSize: 16,
                                                    onPressed: () async {
                                                      if (item.quantity > 1) {
                                                        setState(() {
                                                          item.quantity--;
                                                          _updateItemQuantity(
                                                            item,
                                                          );
                                                        });
                                                        return;
                                                      }
                                                      final confirmed =
                                                          await confirm(
                                                            context,
                                                            content: const Text(
                                                              'Do you want to remove this item?',
                                                            ),
                                                            textOK: const Text(
                                                              'Yes',
                                                            ),
                                                            textCancel:
                                                                const Text(
                                                                  'No',
                                                                ),
                                                          );
                                                      if (!confirmed) return;
                                                      setState(() {
                                                        cartItems.remove(item);
                                                        _deleteCartItem(item);
                                                      });
                                                    },
                                                  ),
                                                  Container(
                                                    padding:
                                                        const EdgeInsets.symmetric(
                                                          horizontal: 8,
                                                          vertical: 4,
                                                        ),
                                                    decoration: BoxDecoration(
                                                      color: Colors.white,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            6,
                                                          ),
                                                    ),
                                                    child: Text(
                                                      '${item.quantity}',
                                                      style: const TextStyle(
                                                        fontSize: 12,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        color: Colors.black,
                                                      ),
                                                    ),
                                                  ),
                                                  IconButton(
                                                    icon: const Icon(Icons.add),
                                                    iconSize: 16,
                                                    onPressed: () {
                                                      setState(() {
                                                        item.quantity++;
                                                        _updateItemQuantity(
                                                          item,
                                                        );
                                                      });
                                                    },
                                                  ),
                                                ],
                                              ),
                                              ElevatedButton(
                                                onPressed: () async {
                                                  await _deleteCartItem(item);
                                                  setState(() {
                                                    cartItems.remove(item);
                                                  });
                                                },
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: Colors.pink,
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        vertical: 4,
                                                        horizontal: 8,
                                                      ),
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          5,
                                                        ),
                                                  ),
                                                ),
                                                child: Text(
                                                  "Delete",
                                                  style: GoogleFonts.poppins(
                                                    fontSize: 12,
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
                            },
                          ),
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
