// import 'package:delivery_app/pages/home-rider/RealTimeMapPage.dart';
// ignore_for_file: file_names, use_build_context_synchronously

import 'package:delivery_app/pages/home-rider/RealTimeMapPage.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:delivery_app/config/config.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DeliveryDetailsPage extends StatefulWidget {
  final Map<String, dynamic> order;
  const DeliveryDetailsPage({super.key, required this.order});

  @override
  State<DeliveryDetailsPage> createState() => _DeliveryDetailsPageState();
}

class _DeliveryDetailsPageState extends State<DeliveryDetailsPage> {
  String? riderId;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _getRiderId();
  }

  Future<void> _getRiderId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      riderId = prefs.getString('userId');
    });
  }

  Future<void> _acceptOrder(BuildContext context) async {
    if (riderId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('ไม่พบข้อมูล riderId')),
      );
      return;
    }
    setState(() => isLoading = true);
    try {
      final response = await http.post(
        Uri.parse('$acceptOrder/${widget.order['_id']}/accept'),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: jsonEncode({'riderId': riderId!}),
      );
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('คุณได้รับงานนี้แล้ว')),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => RealTimeMapPage(orderId: widget.order['_id']),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('เกิดข้อผิดพลาด: ${response.statusCode}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('เกิดข้อผิดพลาด: $e')),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final order = widget.order;
    if (order.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('รายละเอียดคำสั่งส่ง'),
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 0,
        ),
        body: const Center(child: Text('ไม่พบข้อมูลคำสั่งส่ง')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('รายละเอียดคำสั่งส่ง'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildOrderInfo(order),
                const SizedBox(height: 20),
                _buildRecipientInfo(order),
                const SizedBox(height: 20),
                _buildItemsList(order),
                const SizedBox(height: 20),
                _buildTotalAmount(order),
                const SizedBox(height: 30),
                _buildAcceptButton(context),
              ],
            ),
          ),
          if (isLoading)
            Container(
              color: Colors.black.withOpacity(0.2),
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }

  Widget _buildOrderInfo(Map<String, dynamic> order) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'คำสั่งที่ ${order['_id']}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'สถานะ: ${_getStatusInThai(order['status'])}',
              style: TextStyle(
                color: _getStatusColor(order['status']),
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'วันที่สั่ง: ${DateFormat('dd/MM/yyyy HH:mm').format(DateTime.parse(order['createdAt']))}',
              style: const TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecipientInfo(Map<String, dynamic> order) {
    final recipient = order['recipient'] ?? {};
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'ข้อมูลผู้รับ',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text('ชื่อ: ${recipient['name'] ?? '-'}'),
            const SizedBox(height: 4),
            Text('ที่อยู่: ${recipient['address'] ?? '-'}'),
            const SizedBox(height: 4),
            Text('เบอร์โทร: ${recipient['phone'] ?? '-'}'),
          ],
        ),
      ),
    );
  }

  Widget _buildItemsList(Map<String, dynamic> order) {
    final items = order['items'] as List? ?? [];
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'รายการสินค้า',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ...items.map((item) {
              final name = item['name'] ?? 'ไม่ระบุชื่อสินค้า';
              final quantity = item['quantity'] ?? 0;
              final price = item['price'] ?? 0;
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(name),
                    Text('$quantity x ฿${price.toStringAsFixed(2)}'),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildTotalAmount(Map<String, dynamic> order) {
    final total = order['totalAmount'] ?? 0;
    return Card(
      elevation: 2,
      color: Colors.orange[50],
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'ยอดรวมทั้งสิ้น',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              '฿${total.toStringAsFixed(2)}',
              style: const TextStyle(
                  fontSize: 18, fontWeight: FontWeight.bold, color: Colors.orange),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAcceptButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isLoading
            ? null
            : () => _acceptOrder(context),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.orange,
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
        child: const Text(
          'รับงาน',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }

  String _getStatusInThai(String? status) {
    switch (status) {
      case 'pending':
        return 'รอดำเนินการ';
      case 'processing':
        return 'กำลังดำเนินการ';
      case 'shipped':
        return 'จัดส่งแล้ว';
      case 'delivered':
        return 'ส่งถึงผู้รับแล้ว';
      case 'cancelled':
        return 'ยกเลิกแล้ว';
      default:
        return status ?? '-';
    }
  }

  Color _getStatusColor(String? status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'processing':
        return Colors.blue;
      case 'shipped':
        return Colors.green;
      case 'delivered':
        return Colors.purple;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
