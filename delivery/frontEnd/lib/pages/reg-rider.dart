// ignore_for_file: library_private_types_in_public_api, file_names, depend_on_referenced_packages

import 'dart:convert';
import 'dart:io';
import 'package:delivery_app/pages/login.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

class SignUpRider extends StatefulWidget {
  const SignUpRider({super.key});

  @override
  _SignUpRiderState createState() => _SignUpRiderState();
}

class _SignUpRiderState extends State<SignUpRider> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _addressController = TextEditingController();
  final _latitudeController = TextEditingController(text: '13.736717');
  final _longitudeController = TextEditingController(text: '100.523186');
  final _vehicleNumberController = TextEditingController();

  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _isLoading = false;
  File? _image;

  // Validation flags
  bool _isNameValid = false;
  bool _isPhoneValid = false;
  bool _isAddressValid = false;
  bool _isVehicleNumberValid = false;

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            child: const Text('OK'),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
      maxWidth: 1024,
      maxHeight: 1024,
    );
    if (pickedFile != null) {
      setState(() => _image = File(pickedFile.path));
    }
  }

  Future<void> _registerUser() async {
    if (_image == null) {
      _showErrorDialog('กรุณาเลือกรูปโปรไฟล์');
      return;
    }
    if (!_formKey.currentState!.validate()) {
      _showErrorDialog('กรุณากรอกข้อมูลให้ครบถ้วนและถูกต้อง');
      return;
    }
    if (_passwordController.text != _confirmPasswordController.text) {
      _showErrorDialog('รหัสผ่านและยืนยันรหัสผ่านไม่ตรงกัน');
      return;
    }

    setState(() => _isLoading = true);

    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('https://back-deliverys.onrender.com/api/users/registration'),
      );
      request.fields.addAll({
        'name': _nameController.text.trim(),
        'phone': _phoneController.text.trim(),
        'password': _passwordController.text,
        'confpass': _confirmPasswordController.text,
        'type': 'rider',
        'address': _addressController.text.trim(),
        'latitude': _latitudeController.text.trim(),
        'longitude': _longitudeController.text.trim(),
        'vehicleNumber': _vehicleNumberController.text.trim(),
        'status': 'available'
      });

      if (_image != null) {
        var imageStream = http.ByteStream(_image!.openRead());
        var length = await _image!.length();
        var multipartFile = http.MultipartFile(
          'profileImage',
          imageStream,
          length,
          filename: 'profile_${DateTime.now().millisecondsSinceEpoch}.jpg',
          contentType: MediaType('image', 'jpeg'),
        );
        request.files.add(multipartFile);
      }

      request.headers.addAll({
        'Content-Type': 'multipart/form-data',
        'Accept': 'application/json',
      });

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 201 || response.statusCode == 200) {
        if (!mounted) return;
        _showSuccessDialog();
      } else {
        Map<String, dynamic>? errorResponse;
        try {
          errorResponse = json.decode(response.body);
        } catch (_) {}
        if (!mounted) return;
        _showErrorDialog(errorResponse?['message'] ?? 'การลงทะเบียนล้มเหลว กรุณาลองใหม่อีกครั้ง');
      }
    } catch (e) {
      if (!mounted) return;
      _showErrorDialog('เกิดข้อผิดพลาดในการเชื่อมต่อ กรุณาลองใหม่อีกครั้ง');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('สำเร็จ'),
        content: const Text('ลงทะเบียนเรียบร้อยแล้ว'),
        actions: [
          TextButton(
            child: const Text('ตกลง'),
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildProfileImage() {
    return Center(
      child: GestureDetector(
        onTap: _pickImage,
        child: Stack(
          children: [
            CircleAvatar(
              radius: 50,
              backgroundColor: Colors.grey[300],
              backgroundImage: _image != null ? FileImage(_image!) : null,
              child: _image == null
                  ? Icon(Icons.person, size: 50, color: Colors.grey[600])
                  : null,
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.edit, size: 20, color: Colors.grey[600]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    bool obscure = false,
    Widget? suffixIcon,
    String? Function(String?)? validator,
    void Function(String)? onChanged,
    TextInputType? keyboardType,
    bool enabled = true,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        suffixIcon: suffixIcon,
        border: const UnderlineInputBorder(),
      ),
      obscureText: obscure,
      validator: validator,
      onChanged: onChanged,
      keyboardType: keyboardType,
      enabled: enabled,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sign up Rider'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildProfileImage(),
                  const SizedBox(height: 24),
                  _buildTextField(
                    controller: _nameController,
                    label: 'NAME',
                    validator: (value) => value == null || value.isEmpty ? 'กรุณากรอกชื่อ' : null,
                    suffixIcon: _isNameValid ? const Icon(Icons.check, color: Colors.green) : null,
                    onChanged: (value) => setState(() => _isNameValid = value.isNotEmpty),
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _phoneController,
                    label: 'PHONE NUMBER',
                    keyboardType: TextInputType.phone,
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'กรุณากรอกเบอร์โทรศัพท์';
                      if (value.length != 10) return 'กรุณากรอกเบอร์โทรศัพท์ให้ครบ 10 หลัก';
                      return null;
                    },
                    suffixIcon: _isPhoneValid ? const Icon(Icons.check, color: Colors.green) : null,
                    onChanged: (value) => setState(() => _isPhoneValid = value.length == 10),
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _passwordController,
                    label: 'PASSWORD',
                    obscure: !_isPasswordVisible,
                    validator: (value) => value == null || value.isEmpty ? 'กรุณากรอกรหัสผ่าน' : null,
                    suffixIcon: IconButton(
                      icon: Icon(_isPasswordVisible ? Icons.visibility : Icons.visibility_off, color: Colors.grey),
                      onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _confirmPasswordController,
                    label: 'CONFIRM PASSWORD',
                    obscure: !_isConfirmPasswordVisible,
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'กรุณายืนยันรหัสผ่าน';
                      if (value != _passwordController.text) return 'รหัสผ่านไม่ตรงกัน';
                      return null;
                    },
                    suffixIcon: IconButton(
                      icon: Icon(_isConfirmPasswordVisible ? Icons.visibility : Icons.visibility_off, color: Colors.grey),
                      onPressed: () => setState(() => _isConfirmPasswordVisible = !_isConfirmPasswordVisible),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _addressController,
                    label: 'ADDRESS',
                    validator: (value) => value == null || value.isEmpty ? 'กรุณากรอกที่อยู่' : null,
                    suffixIcon: _isAddressValid ? const Icon(Icons.check, color: Colors.green) : null,
                    onChanged: (value) => setState(() => _isAddressValid = value.isNotEmpty),
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _vehicleNumberController,
                    label: 'VEHICLE NUMBER',
                    validator: (value) => value == null || value.isEmpty ? 'กรุณากรอกเลขทะเบียนรถ' : null,
                    suffixIcon: _isVehicleNumberValid ? const Icon(Icons.check, color: Colors.green) : null,
                    onChanged: (value) => setState(() => _isVehicleNumberValid = value.isNotEmpty),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.red,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    onPressed: _isLoading ? null : _registerUser,
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              strokeWidth: 2,
                            ),
                          )
                        : const Text('SIGN UP'),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Already have an account? '),
                      GestureDetector(
                        child: const Text('Sign in.', style: TextStyle(color: Colors.red)),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const LoginScreen()),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }
}
