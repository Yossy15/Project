// ignore_for_file: library_private_types_in_public_api

import 'package:delivery_app/pages/list-on-profile-users/edit_profile.dart';
import 'package:delivery_app/pages/list-on-profile-users/histrory.dart';
import 'package:delivery_app/pages/home-rider/home-rider.dart';
import 'package:delivery_app/pages/login.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';

class RiderProfileScreen extends StatefulWidget {
  const RiderProfileScreen({super.key});

  @override
  _RiderProfileScreenState createState() => _RiderProfileScreenState();
}

class _RiderProfileScreenState extends State<RiderProfileScreen> {
  int _selectedIndex = 1;
  String userType = 'rider';

  // ตัวอย่างข้อมูล rider (ควรดึงจาก service จริงในอนาคต)
  final String userName = 'rider0';
  final String userEmail = 'rider0@gmail.com';
  final String userPhone = '0123456789';
  final String userImage = 'https://i.pinimg.com/564x/43/6b/47/436b47519f01232a329d90f75dbeb3f4.jpg';
  final String userAddress = '123 Rider Street';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: const Color(0xFFef2a38),
        elevation: 0,
        title: Text(
          'Rider Profile',
          style: GoogleFonts.lobster(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildProfileHeader().animate().fadeIn(),
            _buildProfileOptions().animate().fadeIn(),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
      floatingActionButton: _buildFloatingActionButton(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: const Color(0xFFef2a38),
      child: Row(
        children: [
          _buildProfileAvatar(),
          const SizedBox(width: 16),
          Expanded(child: _buildProfileInfo()),
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditProfile(
                    userName: userName,
                    userEmail: userEmail,
                    userPhone: userPhone,
                    userImage: userImage,
                    userAddress: userAddress,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildProfileAvatar() {
    return CircleAvatar(
      radius: 30,
      backgroundImage: NetworkImage(userImage),
    );
  }

  Widget _buildProfileInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          userName,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          userEmail,
          style: const TextStyle(color: Colors.white70),
        ),
      ],
    );
  }

  Widget _buildProfileOptions() {
    // ระบุ type ชัดเจน
    final List<List<dynamic>> options = [
      [Icons.history, 'Order History', () => OrderHistoryPage()],
      [Icons.payment, 'Payment Method', null],
      [Icons.location_on, 'My Address', null],
      [Icons.card_giftcard, 'My Promocodes', null],
      [Icons.favorite, 'My Favorite', null],
      [Icons.exit_to_app, 'Sign out', () => const LoginScreen().animate().moveX()],
    ];

    return Column(
      children: List.generate(options.length, (i) {
        final onTapFunc = options[i][2];
        return _buildOptionTile(
          options[i][0] as IconData,
          options[i][1] as String,
          i,
          onTap: onTapFunc is Function
              ? () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => onTapFunc()),
                  );
                }
              : null,
        );
      }),
    );
  }

  Widget _buildOptionTile(IconData icon, String title, int index, {VoidCallback? onTap}) {
    return ListTile(
      leading: Icon(icon, color: Colors.grey),
      title: Text(title, style: GoogleFonts.lato()),
      trailing: const Icon(Icons.chevron_right, color: Colors.grey),
      onTap: onTap,
    );
  }

  Widget _buildBottomNavigationBar() {
    return Container(
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
              _buildNavItem(Icons.person, '●', 1),
              const SizedBox(width: 60),
              _buildNavItem(Icons.shopping_cart, '', 2),
              _buildNavItem(Icons.favorite, '', 3),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    return InkWell(
      splashColor: Colors.transparent,
      onTap: () {
        setState(() {
          _selectedIndex = index;
        });
        switch (_selectedIndex) {
          case 0:
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const HomeRiderPage()
                    .animate()
                    .slideX(begin: -1, end: 0, curve: Curves.ease),
              ),
            );
            break;
          case 1:
            // Do nothing as it's the current screen
            break;
          case 2:
            // Handle Cart
            break;
          case 3:
            // Handle Favorites
            break;
        }
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white),
          Text(
            label,
            style: const TextStyle(color: Colors.white, fontSize: 10),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingActionButton() {
    return Container(
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
        onTap: () {
          // Action when tapped
        },
        child: const SizedBox(
          width: 65,
          height: 65,
          child: Icon(Icons.add, size: 35, color: Colors.white),
        ),
      ),
    );
  }
}
