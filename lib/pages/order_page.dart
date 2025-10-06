import 'package:confirm_dialog/confirm_dialog.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flowershop/pages/home_page.dart';
import 'package:flowershop/pages/temporary_storage.dart';
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

class ItemsToCheckOut {
  final int productId;
  final String name;
  final int quantity;
  final double subTotal;

  ItemsToCheckOut({
    required this.productId,
    required this.name,
    required this.quantity,
    required this.subTotal,
  });

  factory ItemsToCheckOut.fromJson(Map<String, dynamic> json) {
    return ItemsToCheckOut(
      productId: json['id'],
      name: json['name']?.toString() ?? '',
      quantity: int.tryParse(json['quantity']?.toString() ?? '') ?? 0,
      subTotal: double.tryParse(json['sub_total']?.toString() ?? '0') ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() => {'product_name': name, 'quantity': quantity};
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
                  SnackBar(content: Text('Error: ${error.description}')),
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
  List<ItemsToCheckOut> items = [];
  String? _paymentOption;
  String? _pickupDate;
  String? _pickupTime;
  double? totalPrice = 0;
  int? cartId;

  @override
  void initState() {
    super.initState();
    _initializeOrder();
  }

  Future<void> _initializeOrder() async {
    await _fetchPaymentAndSchedule();
    await _fetchItems();
    await _fetchTotalPrice();
  }

  Future<void> _fetchItems() async {
    final token = await Token.getToken();
    final response = await http.get(
      Uri.parse('http://10.0.2.2:8000/api/cart/items/checkout'),
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
      throw Exception('Failed to load order');
    }
  }

  Future<void> _fetchTotalPrice() async {
    final token = await Token.getToken();
    final response = await http.get(
      Uri.parse('http://10.0.2.2:8000/api/cart/total'),
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
      throw Exception('Failed to fetch total price');
    }
  }

  Future<void> _fetchPaymentAndSchedule() async {
    String? payment = await TemporaryStorage.getPaymentOption();
    String? date = await TemporaryStorage.getPickupDate();
    String? time = await TemporaryStorage.getPickupTime();
    setState(() {
      _paymentOption = payment;
      _pickupDate = date;
      _pickupTime = time;
    });
  }

  Future<void> _updateCartStatus() async {
    final token = await Token.getToken();
    final response = await http.patch(
      Uri.parse('http://10.0.2.2:8000/api/cart/$cartId'),
      headers: {
        HttpHeaders.authorizationHeader: 'Bearer $token',
        HttpHeaders.contentTypeHeader: 'application/json',
      },
      body: jsonEncode({"status": "checked_out"}),
    );
  }

  Future<String?> _sendOrderDetails() async {
    final token = await Token.getToken();
    final response = await http.post(
      Uri.parse('http://10.0.2.2:8000/api/order'),
      headers: {
        HttpHeaders.authorizationHeader: 'Bearer $token',
        HttpHeaders.contentTypeHeader: 'application/json',
      },
      body: jsonEncode({
        "payment_method": _paymentOption,
        "pickup_date": _pickupDate,
        "pickup_time": _pickupTime,
        "total": totalPrice,
        "order_items": items.map((e) => e.toJson()).toList(),
      }),
    );
    if (response.statusCode != 200) {
      final data = jsonDecode(response.body);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(data['message'], style: TextStyle(color: Colors.white)),
          backgroundColor: Colors.red,
        ),
      );
    }
    final data = jsonDecode(response.body);
    if (data.containsKey('checkout_url')) {
      return data['checkout_url'];
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(data['message'], style: TextStyle(color: Colors.white)),
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
              await TemporaryStorage.removeData();
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => HomePage()),
              );
            }
          },
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Column(
                  children: [
                    Radio(
                      activeColor: Color.fromRGBO(250, 34, 144, 1),
                      value: 'payment options',
                      groupValue: '',
                      onChanged: (value) {},
                      toggleable: false,
                      fillColor: WidgetStateColor.resolveWith(
                        (states) => Color.fromRGBO(250, 34, 144, 1),
                      ),
                    ),
                    Text(
                      "Payment\nOptions",
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: Color.fromRGBO(250, 34, 144, 1),
                      ),
                    ),
                  ],
                ),
                Text(
                  "     ..........................................................     ",
                ),
                Column(
                  children: [
                    Radio(
                      value: 'Confirm',
                      groupValue: 'Confirm',
                      onChanged: (value) {},
                      toggleable: false,
                      autofocus: false,
                      fillColor: WidgetStateColor.resolveWith(
                        (states) => Color.fromRGBO(250, 34, 144, 1),
                      ),
                    ),
                    Text(
                      "Confirm\n",
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: Color.fromRGBO(250, 34, 144, 1),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 20),
            Text(
              "Order Detail",
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              _paymentOption ?? '....',
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w400,
              ),
            ),
            Text(
              'Pickup Date:${_pickupDate ?? '....'}',
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w400,
              ),
            ),
            Text(
              'Pickup Time:${_pickupTime ?? '....'}',
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w400,
              ),
            ),
            SizedBox(height: 20),
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Order Summary",
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Divider(),
                  SizedBox(
                    height: 200,
                    child: ListView.builder(
                      itemCount: items.length,
                      itemBuilder: (context, index) {
                        var item = items[index];
                        return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text('${item.quantity}x'),
                              SizedBox(width: 10),
                              Text(
                                item.name,
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Spacer(),
                              Text(
                                '₱${item.subTotal.toStringAsFixed(2)}',
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
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
            Spacer(),
            Text(
              "Total Price",
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              '₱$totalPrice',
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            Padding(padding: EdgeInsets.only(top: 15)),
            ElevatedButton(
              onPressed: () async {
                String? url = await _sendOrderDetails();
                await _updateCartStatus();
                await TemporaryStorage.removeData();

                if (url != null) {
                  // Payment method is Online, open the WebView for checkout
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PaymentWebView(url: url),
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color.fromRGBO(250, 34, 144, 1),
                minimumSize: Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              child: Text(
                'Confirm Order',
                style: GoogleFonts.poppins(fontSize: 16, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
