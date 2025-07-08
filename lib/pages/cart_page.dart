import 'package:flowershop/pages/home_page.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flowershop/pages/payment_page.dart';
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
  final int cartId;
  final String imagePath;
  final String name;
  final double price;
  int quantity;

  CartItems({
    required this.cartId,
    required this.imagePath,
    required this.name,
    required this.price,
    required this.quantity,
  });

  factory CartItems.fromJson(Map<String, dynamic> json) {
    return CartItems(
      cartId: json['cart_id'],
      imagePath: json['image_path']?.toString() ?? '',
      name: json['product_name']?.toString() ?? 'Unknown',
      price: double.tryParse(json['price']?.toString() ?? '0') ?? 0.0,
      quantity: int.tryParse(json['quantity']?.toString() ?? '') ?? 1,
    );
  }
}

class _CartPageState extends State<CartPage> {
  List<CartItems> cartItems = [];

  @override
  void initState() {
    super.initState();
    fetchCartItems();
    fetchTotalPrice();
  }

  Future<void> fetchCartItems() async {
    final token = await Token.getToken();
    final response = await http.get(
      Uri.parse('http://10.0.2.2:8080/api/cart'),
      headers: {HttpHeaders.authorizationHeader: 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final List<dynamic> jsonData = json.decode(response.body);
      setState(() {
        cartItems = jsonData.map((item) => CartItems.fromJson(item)).toList();
      });
    } else {
      throw Exception('Failed to load items');
    }
  }

  Future<void> deleteCartItem(CartItems item) async {
    final token = await Token.getToken();
    final response = await http.post(
      Uri.parse('http://10.0.2.2:8080/api/cart/delete'),
      headers: {
        HttpHeaders.authorizationHeader: 'Bearer $token',
        HttpHeaders.contentTypeHeader: 'application/json',
      },
      body: jsonEncode({"cart_id": item.cartId}),
    );
  }

  Future<void> updateItemQuantity(CartItems item) async {
    final token = await Token.getToken();
    final response = await http.post(
      Uri.parse('http://10.0.2.2:8080/api/cart/update-quantity'),
      headers: {
        HttpHeaders.authorizationHeader: 'Bearer $token',
        HttpHeaders.contentTypeHeader: 'application/json',
      },
      body: jsonEncode({"cart_id": item.cartId, "quantity": item.quantity}),
    );
  }

  Future<double> fetchTotalPrice() async {
    final token = await Token.getToken();
    final response = await http.get(
      Uri.parse('http://10.0.2.2:8080/api/cart/total-price'),
      headers: {HttpHeaders.authorizationHeader: 'Bearer $token'},
    );
    final data = jsonDecode(response.body);
    if (response.statusCode == 200) {
      return double.tryParse(data['total_price'].toString()) ?? 0;
    } else {
      throw Exception('Failed to fetch price');
    }
  }

  Future<void> isUserDetailsUpdated() async {
    final token = await Token.getToken();
    final response = await http.get(
      Uri.parse('http://10.0.2.2:8080/api/profile/details'),
      headers: {HttpHeaders.authorizationHeader: 'Bearer $token'},
    );
    final data = jsonDecode(response.body);
    if (response.statusCode == 200) {
      if (data['success'] == false) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              data['message'],
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.red,
          ),
        );
      } else {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => PaymentPage()),
        );
      }
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
          onPressed:
              () => {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => HomePage()),
                ),
              },
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.shopping_cart, color: Colors.black),
            onPressed: () {},
          ),
        ],
      ),
      body:
          cartItems.isEmpty
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
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
                            Navigator.push(
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
                                    fit: BoxFit.fitHeight,
                                  ),
                                ),
                              ),
                              title: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.name,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    '₱${item.price.toStringAsFixed(2)}',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
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
                                          updateItemQuantity(item);
                                        }
                                      });
                                    },
                                  ),
                                  Text(
                                    '${item.quantity}',
                                    style: TextStyle(fontSize: 18),
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.add),
                                    onPressed: () {
                                      setState(() {
                                        item.quantity++;
                                        updateItemQuantity(item);
                                      });
                                    },
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.delete),
                                    color: Colors.red,
                                    onPressed: () {
                                      setState(() {
                                        cartItems.remove(item);
                                        deleteCartItem(item);
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
                              future: fetchTotalPrice(),
                              builder: (context, snapshot) {
                                return Column(
                                  children: [
                                    Text(
                                      "Total price",
                                      style: GoogleFonts.inter(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                    Text(
                                      '${snapshot.data}',
                                      style: GoogleFonts.inter(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                            ElevatedButton(
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
                              onPressed: () async {
                                await isUserDetailsUpdated();
                              },
                              child: Text(
                                "Place an order",
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
