// ignore_for_file: file_names

import 'package:delivery_app/pages/home_user/home-re.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:delivery_app/models/food_model.dart';

class PaymentPage extends StatelessWidget {
  final Food food;
  final int quantity;
  final String recipientPhone;
  final String recipientAddress;

  const PaymentPage({
    super.key,
    required this.food,
    required this.quantity,
    required this.recipientPhone,
    required this.recipientAddress,
  });

  double get totalPrice => food.price * quantity;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Payment Summary',
            style: GoogleFonts.lato(
                color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('Order Summary'),
            const SizedBox(height: 16),
            _buildSummaryRow(
              food.name,
              '\$${food.price.toStringAsFixed(2)} x $quantity',
            ),
            const Divider(),
            _buildSummaryRow(
              'Total:',
              '\$${totalPrice.toStringAsFixed(2)}',
              isBold: true,
            ),
            const SizedBox(height: 8),
            Text(
              'Estimated delivery time: 15 - 30 mins',
              style: GoogleFonts.lato(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 24),
            _buildDeliveryInfo(),
            const Spacer(),
            _buildBottomBar(context),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) => Text(
        title,
        style: GoogleFonts.lato(fontSize: 24, fontWeight: FontWeight.bold),
      );

  Widget _buildSummaryRow(String title, String value, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title,
            style: GoogleFonts.lato(
                fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
        Text(value,
            style: GoogleFonts.lato(
                fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
      ],
    );
  }

  Widget _buildDeliveryInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Delivery Information',
          style: GoogleFonts.lato(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            const Icon(Icons.location_on, color: Colors.black),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                recipientAddress,
                style: GoogleFonts.lato(color: Colors.grey[600]),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            const Icon(Icons.phone, color: Colors.black),
            const SizedBox(width: 8),
            Text(
              recipientPhone,
              style: GoogleFonts.lato(color: Colors.grey[600]),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBottomBar(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          '\$${totalPrice.toStringAsFixed(2)}',
          style: GoogleFonts.lato(
            fontSize: 24,
            color: Colors.red,
            fontWeight: FontWeight.bold,
          ),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (context) => const FoodHomeScreen()
                    .animate()
                    .slideX(begin: 1, end: 0, curve: Curves.ease),
              ),
              (route) => false,
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.black,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
          child: const Text(
            'Pay Now',
            style: TextStyle(color: Colors.white),
          ),
        ),
      ],
    );
  }
}
