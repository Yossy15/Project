// ignore_for_file: library_private_types_in_public_api, use_build_context_synchronously

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_animate/flutter_animate.dart';
import 'package:delivery_app/pages/home_user/home-re.dart';
import 'package:delivery_app/pages/home_user/profile.dart';
import 'package:delivery_app/pages/home_user/map_order.dart';

class CartUser extends StatefulWidget {
  final String userName, userEmail, userPhone, userImage, userAddress;

  const CartUser({
    super.key,
    required this.userName,
    required this.userEmail,
    required this.userPhone,
    required this.userImage,
    required this.userAddress,
  });

  @override
  _CartUserState createState() => _CartUserState();
}

class _CartUserState extends State<CartUser> {
  int _selectedIndex = 1;
  List<dynamic> orders = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    fetchAvailableOrders();
  }

  Future<void> fetchAvailableOrders() async {
    setState(() => isLoading = true);
    try {
      final response = await http.get(Uri.parse('https://back-deliverys.onrender.com/api/orders/'));
      if (response.statusCode == 200) {
        List<dynamic> allOrders = json.decode(response.body);
        setState(() {
          orders = allOrders.where((order) {
            bool hasValidOrders = order['items']
                .every((item) => item['orders'] != 0 && item['orders'] != 1);
            return order['recipient']['phone'] == widget.userPhone && hasValidOrders;
          }).toList();
        });
      } else {
        throw Exception('Failed to load orders');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('เกิดข้อผิดพลาดในการโหลดข้อมูล: $e')),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _refreshData() async => fetchAvailableOrders();

  Map<String, dynamic> getOrderStatusInfo(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return {'text': 'รอการยืนยัน', 'color': Colors.orange, 'icon': Icons.hourglass_empty};
      case 'processing':
        return {'text': 'กำลังดำเนินการ', 'color': Colors.blue, 'icon': Icons.sync};
      case 'shipped':
        return {'text': 'จัดส่งแล้ว', 'color': Colors.green, 'icon': Icons.local_shipping};
      case 'delivered':
        return {'text': 'จัดส่งสำเร็จ', 'color': Colors.teal, 'icon': Icons.check_circle};
      case 'cancelled':
        return {'text': 'ยกเลิกแล้ว', 'color': Colors.red, 'icon': Icons.cancel};
      default:
        return {'text': 'ไม่ทราบสถานะ', 'color': Colors.grey, 'icon': Icons.help_outline};
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('รายการทั้งหมด'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _refreshData),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _refreshData,
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : orders.isEmpty
                      ? const Center(child: Padding(
                          padding: EdgeInsets.only(top: 100),
                          child: Text('ไม่มีรายการอาหาร'),
                        ))
                      : ListView.builder(
                          itemCount: orders.length,
                          itemBuilder: (context, index) => _buildOrderCard(orders[index]),
                        ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
      floatingActionButton: _buildFloatingActionButton(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  Widget _buildHeader() => Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('รายการอาหาร', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text('รายการทั้งหมด: ${orders.length}', style: const TextStyle(fontSize: 16, color: Colors.grey)),
          ],
        ),
      );

  Widget _buildOrderCard(dynamic order) {
    final statusInfo = getOrderStatusInfo(order['status']);
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        children: [
          ListTile(
            leading: _buildOrderImage(order['imageUrls']),
            title: Text(order['items'][0]['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text('฿${order['totalAmount'].toStringAsFixed(2)}',
                    style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                _buildOrderStatusBadge(statusInfo),
              ],
            ),
            trailing: ElevatedButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => MapOrder(order: order)));
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              child: const Text('รายละเอียด'),
            ),
          ),
          if (order['imageUrls'].length > 1) _buildOrderImageGallery(order['imageUrls']),
        ],
      ),
    );
  }

  Widget _buildOrderImage(List<dynamic> imageUrls) {
    if (imageUrls.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.network(
          imageUrls[0],
          width: 60,
          height: 60,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => const Icon(Icons.image_not_supported),
        ),
      );
    }
    return const Icon(Icons.image_not_supported);
  }

  Widget _buildOrderImageGallery(List<dynamic> imageUrls) => Column(
        children: [
          const Divider(),
          SizedBox(
            height: 80,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: imageUrls.length,
              itemBuilder: (context, imageIndex) => Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    imageUrls[imageIndex],
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      width: 80,
                      height: 80,
                      color: Colors.grey[300],
                      child: const Icon(Icons.error),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      );

  Widget _buildOrderStatusBadge(Map<String, dynamic> statusInfo) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: statusInfo['color'].withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(statusInfo['icon'], size: 16, color: statusInfo['color']),
            const SizedBox(width: 4),
            Text(
              statusInfo['text'],
              style: TextStyle(color: statusInfo['color'], fontSize: 12),
            ),
          ],
        ),
      );

  Widget _buildBottomNavigationBar() => Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              spreadRadius: 1,
              blurRadius: 5,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: BottomAppBar(
          color: const Color(0xFFef2a38),
          shape: const CircularNotchedRectangle(),
          notchMargin: 8.0,
          child: SizedBox(
            height: 60,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                _buildNavItem(Icons.home, '', 0),
                _buildNavItem(Icons.person, '', 1),
                const SizedBox(width: 60),
                _buildNavItem(Icons.shopping_cart, '●', 2),
                _buildNavItem(Icons.favorite, '', 3),
              ],
            ),
          ),
        ),
      );

  Widget _buildNavItem(IconData icon, String label, int index) => InkWell(
        splashColor: Colors.transparent,
        onTap: () {
          setState(() => _selectedIndex = index);
          switch (_selectedIndex) {
            case 0:
              Navigator.push(context, MaterialPageRoute(
                builder: (context) => const FoodHomeScreen().animate().slideX(begin: -1, end: 0, curve: Curves.ease),
              ));
              break;
            case 1:
              Navigator.push(context, MaterialPageRoute(
                builder: (context) => const FoodProfileScreen().animate().slideX(begin: -1, end: 0, curve: Curves.ease),
              ));
              break;
            // เพิ่มเติมตามต้องการ
          }
        },
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white),
            Text(label, style: const TextStyle(color: Colors.white, fontSize: 10)),
          ],
        ),
      );

  Widget _buildFloatingActionButton() => Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.red,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.4),
              spreadRadius: 3,
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: InkWell(
          onTap: () {},
          child: const SizedBox(
            width: 65,
            height: 65,
            child: Icon(Icons.add, size: 35, color: Colors.white),
          ),
        ),
      );
}
