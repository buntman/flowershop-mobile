import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flowershop/pages/token_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'dart:convert';

class OrdersListPage extends StatefulWidget {
  const OrdersListPage({super.key});

  @override
  State<OrdersListPage> createState() => _OrdersListPageState();
}

enum OrderStatus {
  pending('pending'),
  readyForPickup('ready_for_pickup'),
  completed('completed');

  final String value;
  const OrderStatus(this.value);
}

class Order {
  final int orderId;
  final String orderNumber;
  final double totalPrice;
  String status;
  final List<OrderItem> items;

  Order({
    required this.orderId,
    required this.orderNumber,
    required this.totalPrice,
    required this.status,
    required this.items,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      orderId: json['id'],
      orderNumber: json['order_number'],
      totalPrice: double.tryParse(json['total']?.toString() ?? '0') ?? 0.0,
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
      name: json['name']?.toString() ?? '',
      quantity: int.tryParse(json['quantity']?.toString() ?? '') ?? 0,
      price: double.tryParse(json['price']?.toString() ?? '0') ?? 0.0,
    );
  }
}

class _OrdersListPageState extends State<OrdersListPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<String> tabs = ['Pending', 'Ready for Pickup', 'Completed'];
  List<Order> pendingOrders = [];
  List<Order> readyOrders = [];
  List<Order> completedOrders = [];
  bool _isPendingLoading = true;
  bool _isReadyLoading = true;
  bool _isCompletedLoading = true;

  @override
  void initState() {
    super.initState();

    _tabController = TabController(length: tabs.length, vsync: this);

    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        onTabChanged(_tabController.index);
      }
    });
    onTabChanged(0);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _fetchOrderDetails(OrderStatus status) async {
    setState(() {
      switch (status) {
        case OrderStatus.pending:
          _isPendingLoading = true;
          break;
        case OrderStatus.readyForPickup:
          _isReadyLoading = true;
          break;
        case OrderStatus.completed:
          _isCompletedLoading = true;
          break;
      }
    });
    final token = await Token.getToken();
    final response = await http.get(
      Uri.parse('http://127.0.0.1:8000/api/order/${status.value}'),
      headers: {HttpHeaders.authorizationHeader: 'Bearer $token'},
    );

    if (response.statusCode != 200) {
      throw Exception('HTTP ${response.statusCode}');
    }

    final decoded = jsonDecode(response.body);
    if (decoded is! Map<String, dynamic> || decoded['orders'] is! List) {
      setState(() {
        _isPendingLoading = _isReadyLoading = _isCompletedLoading = false;
      });
      throw Exception('Unexpected JSON format: $decoded');
    }

    final List<Order> orders =
        (decoded['orders'] as List)
            .map((orderJson) => Order.fromJson(orderJson))
            .toList();

    if (!mounted) return;

    setState(() {
      switch (status) {
        case OrderStatus.pending:
          pendingOrders = orders;
          _isPendingLoading = false;
          break;
        case OrderStatus.readyForPickup:
          readyOrders = orders;
          _isReadyLoading = false;
          break;
        case OrderStatus.completed:
          completedOrders = orders;
          _isCompletedLoading = false;
          break;
      }
    });
  }

  Future<void> onTabChanged(int index) async {
    final status = OrderStatus.values[index];
    if (status == OrderStatus.pending && pendingOrders.isNotEmpty)
      return; //prevent unnecessary api calls
    if (status == OrderStatus.readyForPickup && readyOrders.isNotEmpty) return;
    if (status == OrderStatus.completed && completedOrders.isNotEmpty) return;

    await _fetchOrderDetails(status);
  }

  Future<void> markOrderAsComplete(Order order) async {
    final token = await Token.getToken();
    final response = await http.patch(
      Uri.parse('http://127.0.0.1:8000/api/order/${order.orderId}'),
      headers: {HttpHeaders.authorizationHeader: 'Bearer $token'},
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
          controller: _tabController,
          tabs: tabs.map((t) => Tab(text: t)).toList(),
          isScrollable: false,
          labelPadding: const EdgeInsets.symmetric(horizontal: 4.0),
          labelColor: Colors.pink,
          unselectedLabelColor: Colors.grey[700],
          indicatorColor: Colors.pink,
          indicatorWeight: 3.0,
          labelStyle: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
          unselectedLabelStyle: GoogleFonts.poppins(
            fontWeight: FontWeight.w500,
            fontSize: 12,
          ),
        ),
      ),
      backgroundColor: const Color.fromARGB(255, 254, 207, 223),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildOrderList(pendingOrders, _isPendingLoading, Colors.white),
          _buildOrderList(readyOrders, _isReadyLoading, Colors.white),
          _buildOrderList(completedOrders, _isCompletedLoading, Colors.white),
        ],
      ),
    );
  }

  Widget _buildOrderList(List<Order> orders, bool isLoading, Color cardColor) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
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
                Text(
                  'Order # ${order.orderNumber}',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                    color: Colors.grey[700],
                  ),
                ),
                const Divider(height: 24, thickness: 1),
                Text(
                  'Order summary',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 12),
                ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height * 0.25,
                  ),
                  child: ListView.builder(
                    shrinkWrap: true,
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
                                Flexible(
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
                                Text(
                                  '${item.price.toStringAsFixed(2)} PHP',
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
                      '${order.totalPrice.toStringAsFixed(2)} PHP',
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
                    if (order.status == OrderStatus.readyForPickup.value)
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
                          await markOrderAsComplete(order);
                          setState(() {
                            orders.remove(order);
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
