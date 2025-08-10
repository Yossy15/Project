// ignore_for_file: file_names, library_private_types_in_public_api, use_build_context_synchronously

import 'dart:convert';
import 'dart:developer';
import 'package:delivery_app/pages/home-user-sender/list-add-menu/all-page.dart';
import 'package:delivery_app/pages/home-user-sender/list-add-menu/checkout.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:delivery_app/models/order.dart';

class CartPage extends StatefulWidget {
  final List<Order> cartOrders;

  const CartPage({super.key, required this.cartOrders});

  @override
  _CartPageState createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  bool isLoading = false;
  final String baseUrl = 'https://back-deliverys.onrender.com/api/orders/';

  Future<void> removeFromCart(Order order) async {
    setState(() {
      widget.cartOrders.remove(order);
      for (var item in order.items) {
        item.orders = 1;
      }
    });
    await _updateOrderOnServer(order);
  }

  Future<void> _updateOrderOnServer(Order order) async {
    final String updateUrl = '$baseUrl${order.id}';
    try {
      final response = await http.put(
        Uri.parse(updateUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'items': order.items
              .map((item) => {
                    'name': item.name,
                    'orders': item.orders,
                    "quantity": item.quantity,
                    "price": item.price,
                  })
              .toList(),
        }),
      );
      if (response.statusCode == 200) {
        log('Order updated successfully');
      } else {
        throw Exception('Failed to update order');
      }
    } catch (e) {
      log('Error updating order: $e');
    }
  }

  Future<void> checkout() async {
    setState(() => isLoading = true);
    for (var order in widget.cartOrders) {
      await _updateOrderOnServer(order);
    }
    widget.cartOrders.clear();
    setState(() => isLoading = false);
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const AllPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredOrders = widget.cartOrders
        .where((order) => order.items.any((item) => item.orders == 0))
        .toList();

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: const EdgeInsets.all(16.0),
      width: double.infinity,
      height: MediaQuery.of(context).size.height * 0.5,
      child: Column(
        children: [
          Expanded(
            child: filteredOrders.isEmpty
                ? Center(
                    child: Text('ไม่มีสินค้าในตะกร้า', style: GoogleFonts.itim()),
                  )
                : ListView.builder(
                    itemCount: filteredOrders.length,
                    itemBuilder: (context, index) =>
                        _buildCartItem(filteredOrders[index]),
                  ),
          ),
          const SizedBox(height: 12),
          _buildCheckoutButton(context, filteredOrders),
          if (isLoading)
            const Padding(
              padding: EdgeInsets.only(top: 12),
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }

  Widget _buildCartItem(Order order) {
    final item = order.items.firstWhere((item) => item.orders == 0, orElse: () => order.items[0]);
    return ListTile(
      title: Text(item.name, style: GoogleFonts.itim()),
      subtitle: Text('\$${item.price.toStringAsFixed(2)}', style: GoogleFonts.itim()),
      trailing: IconButton(
        icon: const Icon(Icons.delete, color: Colors.red),
        onPressed: () => removeFromCart(order),
      ),
    );
  }

  Widget _buildCheckoutButton(BuildContext context, List<Order> filteredOrders) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        FloatingActionButton.extended(
          onPressed: filteredOrders.isEmpty || isLoading
              ? null
              : () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CheckoutPage(cartOrders: filteredOrders),
                    ),
                  );
                },
          backgroundColor: Colors.green,
          icon: const Icon(Icons.payment),
          label: const Text('ชำระเงิน'),
        ),
      ],
    );
  }
}
