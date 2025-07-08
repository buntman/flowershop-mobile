import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flowershop/pages/token_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'dart:convert';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class Order {
  final String orderId;
  final double totalPrice;
  final String pickupDate;
  final String pickupTime;
  final String paymentMethod;
  String status;
  final List<OrderItem> items;

  Order({
    required this.orderId,
    required this.totalPrice,
    required this.pickupDate,
    required this.pickupTime,
    required this.paymentMethod,
    required this.status,
    required this.items,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      orderId: json['id'],
      totalPrice:
          double.tryParse(json['total_price']?.toString() ?? '0') ?? 0.0,
      pickupDate: json['pickup_date']?.toString() ?? '',
      pickupTime: json['pickup_time']?.toString() ?? '',
      paymentMethod: json['payment_method']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      items:
          (json['items'] as List<dynamic>?)
              ?.map((item) => OrderItem.fromJson(item as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

class OrderItem {
  final String name;
  final int quantity;
  final double price;

  OrderItem({required this.name, required this.quantity, required this.price});

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      name: json['product_name']?.toString() ?? '',
      quantity: int.tryParse(json['quantity']?.toString() ?? '') ?? 0,
      price: double.tryParse(json['price']?.toString() ?? '0') ?? 0.0,
    );
  }
}

class _HistoryPageState extends State<HistoryPage> {
  final List<String> tabs = ['Pending', 'Ready for Pick Up', 'Picked Up'];
  List<Order> pendingOrders = [];
  List<Order> readyOrders = [];
  List<Order> pickedUpOrders = [];

  @override
  void initState() {
    super.initState();
    fetchOrderDetails();
  }

  Future<void> fetchOrderDetails() async {
    final token = await Token.getToken();
    final response = await http.get(
      Uri.parse('http://10.0.2.2:8080/api/order/details'),
      headers: {HttpHeaders.authorizationHeader: 'Bearer $token'},
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      List<Order> pending = [];
      List<Order> ready = [];
      List<Order> pickedUp = [];

      if (data is Map<String, dynamic>) {
        final order = Order.fromJson(data);
        final status = data['status'];
        if (status == 'Pending') {
          pending.add(order);
        } else if (status == 'Ready for Pickup') {
          ready.add(order);
        } else if (status == 'Picked Up') {
          pickedUp.add(order);
        }
      } else if (data is List) {
        for (var orderJson in data) {
          final order = Order.fromJson(orderJson);
          final status = orderJson['status'];
          if (status == 'Pending') {
            pending.add(order);
          } else if (status == 'Ready for Pickup') {
            ready.add(order);
          } else if (status == 'Picked Up') {
            pickedUp.add(order);
          }
        }
      }

      setState(() {
        pendingOrders = pending;
        readyOrders = ready;
        pickedUpOrders = pickedUp;
      });
    }
  }

  Future<void> updatePickedUpOrderStatus(Order order) async {
    final token = await Token.getToken();
    final response = await http.post(
      Uri.parse('http://10.0.2.2:8080/api/order/status'),
      headers: {
        HttpHeaders.authorizationHeader: 'Bearer $token',
        HttpHeaders.contentTypeHeader: 'application/json',
      },
      body: jsonEncode({"order_id": order.orderId}),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: tabs.length,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 1,
          shadowColor: Colors.grey.shade300,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: Text(
            'Purchase History',
            style: GoogleFonts.poppins(
              color: Colors.black,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          bottom: TabBar(
            isScrollable: false,
            labelColor: Colors.pink,
            unselectedLabelColor: Colors.grey[700],
            indicatorColor: Colors.pink,
            indicatorWeight: 3.0, // Slightly thicker indicator
            labelStyle: GoogleFonts.poppins(
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
            unselectedLabelStyle: GoogleFonts.poppins(
              fontWeight: FontWeight.w500,
              fontSize: 12,
            ),
            tabs: tabs.map((t) => Tab(text: t)).toList(),
          ),
        ),
        backgroundColor: const Color.fromARGB(255, 254, 207, 223),
        body: TabBarView(
          children: [
            // Pending tab
            _buildOrderList(pendingOrders, Colors.white),
            // Ready to Pick Up tab
            _buildOrderList(readyOrders, Colors.white),
            // Picked Up tab
            _buildOrderList(pickedUpOrders, Colors.white),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderList(List<Order> orders, Color cardColor) {
    if (orders.isEmpty) {
      return Center(
        child: Text(
          'No orders Available.',
          style: GoogleFonts.poppins(color: Colors.grey[600]),
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: orders.length,
      itemBuilder: (context, index) {
        final order = orders[index];
        return Card(
          color: cardColor,
          elevation: 2,
          shadowColor: Colors.grey.shade200,
          margin: const EdgeInsets.only(bottom: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Section: Payment, Shop, Address, Pickup Time
                Text(
                  'Order ID: ${order.orderId}',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                    color: Colors.grey[700],
                  ),
                ),
                Text(
                  order.paymentMethod,
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                    color: Colors.grey[700],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "Rizza Flower Shop",
                  style: GoogleFonts.poppins(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "MWCW+588, Rizal St, Bacolod, 6100 Negros Occidental",
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  // Use row for label and value
                  children: [
                    Text(
                      'Pick up time: ',
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: Colors.grey[800],
                      ),
                    ),
                    Text(
                      '${order.pickupDate}  ${order.pickupTime}',
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),

                const Divider(height: 24, thickness: 1), // Thicker divider
                // --- Order Summary Section ---
                Text(
                  'Order summary',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 12),

                // --- Scrollable Item List ---
                ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height * 0.25,
                  ),
                  child: ListView.builder(
                    shrinkWrap:
                        true, // Important for ListView inside Column/ConstrainedBox
                    itemCount: order.items.length,
                    itemBuilder: (ctx, itemIndex) {
                      final item = order.items[itemIndex];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Left side: Quantity and Name
                                Flexible(
                                  // Allow text wrapping
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '${item.quantity}x ',
                                        style: GoogleFonts.poppins(
                                          fontWeight: FontWeight.w500,
                                          color: Colors.pink,
                                          fontSize: 14,
                                        ),
                                      ),
                                      Expanded(
                                        // Allow name to take space and wrap
                                        child: Text(
                                          item.name,
                                          style: GoogleFonts.poppins(
                                            fontSize: 14,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 16),
                                // Right side: Price
                                Text(
                                  '${item.price.toStringAsFixed(2)} PHP', // Ensure price is double
                                  style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                const Divider(height: 24, thickness: 1),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total Price',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      '${order.totalPrice.toStringAsFixed(2)} PHP', // Ensure total price is double
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 5),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (order.status == 'Ready for Pickup')
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
                        onPressed: () async {
                          await updatePickedUpOrderStatus(order);
                          setState(() {
                            orders.remove(order);
                            order.status = 'Picked Up';
                            pickedUpOrders.add(order);
                          });
                        },
                        child: Text(
                          "Complete",
                          style: GoogleFonts.poppins(
                            fontSize: 14,
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
        );
      },
    );
  }
}
