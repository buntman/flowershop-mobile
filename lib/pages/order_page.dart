import 'package:confirm_dialog/confirm_dialog.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flowershop/pages/home_page.dart';
import 'package:flowershop/pages/token_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'dart:convert';
import 'package:webview_flutter/webview_flutter.dart';

class OrderPage extends StatefulWidget {
  const OrderPage({super.key, DateTime? date, TimeOfDay? time});

  @override
  State<OrderPage> createState() => _OrderPageState();
}

class UserInfo {
  final String email;
  final String name;
  final String contactNumber;

  UserInfo({
    required this.email,
    required this.name,
    required this.contactNumber,
  });

  factory UserInfo.fromJson(Map<String, dynamic> json) {
    return UserInfo(
      email: json['email']?.toString() ?? '',
      name: json['name']?.toString().trim() ?? '',
      contactNumber: json['contact_number']?.toString().trim() ?? '',
    );
  }
}

class ItemsToCheckOut {
  final int productId;
  final String name;
  final int quantity;
  final double subTotal;
  final String image;

  ItemsToCheckOut({
    required this.productId,
    required this.name,
    required this.quantity,
    required this.subTotal,
    required this.image,
  });

  factory ItemsToCheckOut.fromJson(Map<String, dynamic> json) {
    return ItemsToCheckOut(
      productId: json['id'],
      name: json['name']?.toString() ?? '',
      quantity: int.tryParse(json['quantity']?.toString() ?? '') ?? 0,
      subTotal: double.tryParse(json['sub_total']?.toString() ?? '0') ?? 0.0,
      image: json['image_name']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'product_id': productId,
    'product_name': name,
    'quantity': quantity,
    'sub_total': subTotal,
    'image_name': image,
  };
}

class PaymentWebView extends StatefulWidget {
  final String url;

  const PaymentWebView({Key? key, required this.url}) : super(key: key);

  @override
  State<PaymentWebView> createState() => _PaymentWebViewState();
}

class _PaymentWebViewState extends State<PaymentWebView> {
  late final WebViewController _controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _controller =
        WebViewController()
          ..setJavaScriptMode(JavaScriptMode.unrestricted)
          ..setNavigationDelegate(
            NavigationDelegate(
              onPageStarted: (url) {
                setState(() => _isLoading = true);
              },
              onPageFinished: (url) {
                setState(() => _isLoading = false);
              },
              onWebResourceError: (error) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Error: ${error.description}'),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
            ),
          )
          ..loadRequest(Uri.parse(widget.url));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Complete Payment"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading) const Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }
}

class _OrderPageState extends State<OrderPage> {
  UserInfo? user;
  List<ItemsToCheckOut> items = [];
  String _paymentMethod = 'online';
  double? totalPrice = 0;
  int? cartId;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeOrder();
  }

  Future<void> _initializeOrder() async {
    await _fetchItems();
    await _fetchTotalPrice();
    await _fetchUserDetails();
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _fetchUserDetails() async {
    final token = await Token.getToken();
    final response = await http.get(
      Uri.parse('http://127.0.0.1:8000/api/profile'),
      headers: {
        HttpHeaders.authorizationHeader: 'Bearer $token',
        HttpHeaders.acceptHeader: 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonData = json.decode(response.body);
      setState(() {
        user = UserInfo.fromJson(jsonData);
      });
    } else {
      throw Exception('HTTP ${response.statusCode}');
    }
  }

  Future<void> _fetchItems() async {
    final token = await Token.getToken();
    final response = await http.get(
      Uri.parse('http://127.0.0.1:8000/api/cart/items/checkout'),
      headers: {
        HttpHeaders.authorizationHeader: 'Bearer $token',
        HttpHeaders.acceptHeader: 'application/json',
      },
    );
    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonData = json.decode(response.body);
      setState(() {
        cartId = jsonData['cart_id'];
        items =
            (jsonData['items'] as List)
                .map((item) => ItemsToCheckOut.fromJson(item))
                .toList();
      });
    } else {
      throw Exception('HTTP ${response.statusCode}');
    }
  }

  Future<void> _fetchTotalPrice() async {
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
      setState(() {
        totalPrice = double.tryParse(data['total'].toString()) ?? 0;
      });
    } else {
      throw Exception('Failed to load order');
    }
  }

  Future<void> _updateCartStatus() async {
    final token = await Token.getToken();
    final response = await http.patch(
      Uri.parse('http://127.0.0.1:8000/api/cart/$cartId'),
      headers: {HttpHeaders.authorizationHeader: 'Bearer $token'},
    );
  }

  Future<String?> _sendOrderDetails() async {
    final token = await Token.getToken();
    final response = await http.post(
      Uri.parse('http://127.0.0.1:8000/api/order'),
      headers: {
        HttpHeaders.authorizationHeader: 'Bearer $token',
        HttpHeaders.contentTypeHeader: 'application/json',
      },
      body: jsonEncode({
        "payment_method": _paymentMethod,
        "total": totalPrice,
        "order_items": items.map((e) => e.toJson()).toList(),
      }),
    );
    if (response.statusCode != 200) {
      final data = jsonDecode(response.body);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(data['message'], style: TextStyle(color: Colors.white)),
          duration: Duration(seconds: 2),
          backgroundColor: Colors.red,
        ),
      );
      return null;
    }
    final data = jsonDecode(response.body);
    if (data.containsKey('checkout_url')) {
      return data['checkout_url'];
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(data['message'], style: TextStyle(color: Colors.white)),
          duration: Duration(seconds: 2),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => HomePage()),
      );
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Confirm Order",
          style: GoogleFonts.inter(
            color: Colors.black,
            fontSize: 14,
            fontWeight: FontWeight.w400,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () async {
            if (await confirm(
              context,
              content: const Text(
                'The edited content will be discarded, do you still want to exit?',
              ),
              textOK: const Text('Yes'),
              textCancel: const Text('No'),
            )) {
              Navigator.pop(context);
            }
          },
        ),
      ),
      body:
          _isLoading
              ? Center(child: CircularProgressIndicator())
              : Padding(
                padding: EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      constraints: BoxConstraints(minWidth: 600, minHeight: 50),
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.person_outline,
                            size: 20,
                            color: Colors.grey[600],
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  user?.name ?? '',
                                  style: GoogleFonts.inter(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  user?.contactNumber ?? '',
                                  style: GoogleFonts.inter(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(padding: EdgeInsets.only(top: 10)),
                    Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.storefront,
                                color: Colors.pink,
                                size: 22,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Rizza Flower Shop', //
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                            child: ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: items.length,
                              itemBuilder: (context, index) {
                                var item = items[index];
                                const double imageSize = 60; //
                                return Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 8.0,
                                    horizontal: 12.0,
                                  ),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: SizedBox(
                                          width: imageSize,
                                          height: imageSize,
                                          child: Image.network(
                                            item.image,
                                            fit: BoxFit.cover,
                                            errorBuilder:
                                                (
                                                  context,
                                                  error,
                                                  stackTrace,
                                                ) => Container(
                                                  color: Colors.grey.shade200,
                                                  child: const Icon(
                                                    Icons.image_not_supported,
                                                    color: Colors.grey,
                                                  ),
                                                ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),

                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              item.name,
                                              style: GoogleFonts.inter(
                                                fontSize: 13,
                                                fontWeight: FontWeight.w400,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              '₱${item.subTotal.toStringAsFixed(2)}',
                                              style: GoogleFonts.inter(
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),

                                      Text(
                                        '${item.quantity}x',
                                        style: GoogleFonts.inter(
                                          fontSize: 13,
                                          color: Colors.grey[600],
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
                    Padding(padding: EdgeInsets.only(top: 20)),
                    Text(
                      'Payment Method',
                      style: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      title: Row(
                        children: [
                          Icon(
                            Icons.payment,
                            color: const Color.fromRGBO(250, 34, 144, 1),
                            size: 22,
                          ),
                          const SizedBox(width: 10),
                          Text(
                            'Online',
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      trailing: Radio(
                        activeColor: const Color.fromRGBO(250, 34, 144, 1),
                        fillColor: WidgetStateColor.resolveWith(
                          (states) => const Color.fromRGBO(250, 34, 144, 1),
                        ),
                        value: 'online',
                        groupValue: _paymentMethod,
                        onChanged: (value) {
                          setState(() {
                            _paymentMethod = value.toString();
                          });
                        },
                      ),
                      onTap: () {
                        setState(() {
                          _paymentMethod = 'online';
                        });
                      },
                    ),
                    Spacer(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
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
                              '₱$totalPrice',
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        ElevatedButton(
                          onPressed: () async {
                            String? url = await _sendOrderDetails();
                            await _updateCartStatus();
                            if (url != null) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (context) => PaymentWebView(url: url),
                                ),
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.symmetric(
                              vertical: 15,
                              horizontal: 40,
                            ),
                            backgroundColor: Color.fromRGBO(250, 34, 144, 1),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5),
                            ),
                          ),
                          child: Text(
                            'Place Order',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
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
