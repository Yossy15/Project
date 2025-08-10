// ignore_for_file: library_private_types_in_public_api, use_build_context_synchronously

import 'package:delivery_app/pages/home-user-sender/home-sender.dart';
import 'package:delivery_app/pages/list-on-profile-users/edit_profile.dart';
import 'package:delivery_app/pages/list-on-profile-users/my-addr.dart';
import 'package:delivery_app/pages/list-on-profile-users/payment.dart';
import 'package:delivery_app/pages/home_user/home-re.dart';
import 'package:delivery_app/pages/login.dart';
import 'package:delivery_app/services/user_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String kDefaultProfileImage =
    'https://i.pinimg.com/564x/43/6b/47/436b47519f01232a329d90f75dbeb3f4.jpg';

class FoodProfileScreen extends StatefulWidget {
  const FoodProfileScreen({super.key});

  @override
  _FoodProfileScreenState createState() => _FoodProfileScreenState();
}

class _FoodProfileScreenState extends State<FoodProfileScreen> {
  String userType = 'user';

  // User data fields
  String userName = '';
  String userEmail = '';
  String userPhone = '';
  String userImage = '';
  String userAddress = '';

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('userId');
      if (userId != null) {
        final userData = await UserService().getUserByIdd(userId);
        setState(() {
          userName = userData['name'] ?? 'User';
          userEmail = userData['email'] ?? 'user@example.com';
          userPhone = userData['phone'] ?? '';
          userImage = userData['profileImage'] ?? kDefaultProfileImage;
          userAddress = userData['address'] ?? '';
        });
      }
    } catch (e) {
      // print('Error loading user data: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading user data: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: const Color(0xFFef2a38),
        elevation: 0,
        title: Text(
          'My Profile',
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

  /// Avatar Widget แยกออกมาให้ใช้ซ้ำง่าย
  Widget _buildProfileAvatar() {
    return CircleAvatar(
      radius: 30,
      backgroundColor: Colors.white,
      child: ClipOval(
        child: CachedNetworkImage(
          imageUrl: userImage.isNotEmpty ? userImage : kDefaultProfileImage,
          width: 60,
          height: 60,
          fit: BoxFit.cover,
          placeholder: (context, url) => const CircularProgressIndicator(),
          errorWidget: (context, url, error) =>
              const Icon(Icons.person, size: 60, color: Colors.grey),
        ),
      ),
    );
  }

  /// Header Profile
  Widget _buildProfileHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: const Color(0xFFef2a38),
      child: Row(
        children: [
          _buildProfileAvatar(),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
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
                  userPhone,
                  style: const TextStyle(color: Colors.white70),
                ),
                if (userAddress.isNotEmpty)
                  Text(
                    userAddress,
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
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

  /// Profile Options
  Widget _buildProfileOptions() {
    // ระบุ type ชัดเจน
    final List<List<dynamic>> options = [
      [Icons.payment, 'Payment Method', () => const PaymentMethodPage()],
      [Icons.location_on, 'My Address', () => const AddressScreen()],
      [Icons.card_giftcard, 'Market', () => const HomesenderPage().animate().moveX()],
      [Icons.favorite, 'My Favorite', null],
      [Icons.exit_to_app, 'Sign out', () => const LoginScreen().animate().moveX()],
    ];

    return Column(
      children: List.generate(options.length, (i) {
        return _buildOptionTile(
          options[i][0] as IconData,
          options[i][1] as String,
          i + 1,
          onTap: options[i][2] != null
              ? () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => options[i][2]!()),
                  );
                }
              : null,
        );
      }),
    );
  }

  Widget _buildOptionTile(IconData icon, String title, int index,
      {VoidCallback? onTap}) {
    return Column(
      children: [
        ListTile(
          leading: Icon(icon, color: Colors.grey),
          title: Text(
            title,
            style: GoogleFonts.lato(),
          ),
          trailing: const Icon(Icons.chevron_right, color: Colors.grey),
          onTap: onTap,
        ),
      ],
    );
  }

  /// Bottom Navigation Bar
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
        });
        if (index == 0) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const FoodHomeScreen()
                  .animate()
                  .slideX(begin: -1, end: 0, curve: Curves.ease),
            ),
          );
        }
        // เพิ่มเติมตามต้องการ
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: Colors.white,
          ),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  /// Floating Action Button
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
