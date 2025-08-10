// ignore_for_file: file_names, depend_on_referenced_packages, library_private_types_in_public_api, prefer_final_fields, use_build_context_synchronously, deprecated_member_use

import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:delivery_app/config/config.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RealTimeMapPage extends StatefulWidget {
  final String orderId;
  const RealTimeMapPage({super.key, required this.orderId});

  @override
  _RealTimeMapPageState createState() => _RealTimeMapPageState();
}

class _RealTimeMapPageState extends State<RealTimeMapPage> with WidgetsBindingObserver {
  // --- Map & Location ---
  final MapController _mapController = MapController();
  final Location _location = Location();
  StreamSubscription<LocationData>? _locationSubscription;
  LatLng _currentPosition = const LatLng(0, 0);
  LatLng? _pickupLocation, _deliveryLocation, _riderLocation;
  bool _mapReady = false, _isFollowingUser = true;
  double _currentZoom = 16.0;

  // --- Rider & Order State ---
  String? userId, riderId;
  bool _isDelivered = false, _hasPickedUp = false, _isLoading = false;
  Timer? _locationUpdateTimer, _riderLocationTimer;
  List<File> _images = [];
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeLocation().then((_) {
      _loadOrderLocations();
      _getRiderId();
    });
    _getUserId();
  }

  // --- User & Rider ID ---
  Future<void> _getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    userId = prefs.getString('userId');
  }

  Future<void> _getRiderId() async {
    final prefs = await SharedPreferences.getInstance();
    riderId = prefs.getString('userId');
    if (riderId != null) _startRiderLocationTracking();
  }

  // --- Location & Map ---
  Future<void> _initializeLocation() async {
    try {
      if (!await _location.serviceEnabled() && !await _location.requestService()) {
        _showErrorDialog("กรุณาเปิด Location Service");
        return;
      }
      var permission = await _location.hasPermission();
      if (permission == PermissionStatus.denied && await _location.requestPermission() != PermissionStatus.granted) {
        _showErrorDialog("กรุณาอนุญาตการเข้าถึงตำแหน่ง");
        return;
      }
      final currentLocation = await _location.getLocation();
      setState(() {
        _currentPosition = LatLng(currentLocation.latitude ?? 0, currentLocation.longitude ?? 0);
        _mapReady = true;
      });
      _startLocationUpdates();
      _startPeriodicUpdates();
    } catch (e) {
      _showErrorDialog("ไม่สามารถเข้าถึงตำแหน่งได้\nError: $e");
    }
  }

  void _startLocationUpdates() {
    _locationSubscription = _location.onLocationChanged.listen((loc) {
      setState(() {
        _currentPosition = LatLng(loc.latitude!, loc.longitude!);
      });
      if (_isFollowingUser) {
        _mapController.move(_currentPosition, _mapController.camera.zoom);
      }
    });
  }

  void _startPeriodicUpdates() {
    _locationUpdateTimer = Timer.periodic(const Duration(seconds: 10), (_) => _updateLocationOnServer());
  }

  Future<void> _updateLocationOnServer() async {
    try {
      await http.post(
        Uri.parse(updateLocation),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: jsonEncode({
          'userId': userId,
          'latitude': _currentPosition.latitude,
          'longitude': _currentPosition.longitude,
          'orderId': widget.orderId,
          'timestamp': DateTime.now().toIso8601String(),
        }),
      );
    } catch (_) {}
  }

  // --- Order & Rider Location ---
  Future<void> _loadOrderLocations() async {
    try {
      final response = await http.get(
        Uri.parse('$getOrderLocations/${widget.orderId}'),
        headers: {'Content-Type': 'application/json'},
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final pickup = data['pickupLocation'], delivery = data['deliveryLocation'];
        if (pickup == null || delivery == null) throw Exception('Missing location data');
        setState(() {
          _pickupLocation = LatLng(double.parse(pickup['latitude'].toString()), double.parse(pickup['longitude'].toString()));
          _deliveryLocation = LatLng(double.parse(delivery['latitude'].toString()), double.parse(delivery['longitude'].toString()));
          if (_mapReady) _updateMapView();
        });
      } else {
        throw Exception('Failed to load locations');
      }
    } catch (e) {
      _showErrorDialog("ไม่สามารถโหลดข้อมูลพิกัดได้\nError: $e");
    }
  }

  void _updateMapView() {
    final centerLat = (_pickupLocation!.latitude + _deliveryLocation!.latitude + _currentPosition.latitude) / 3;
    final centerLng = (_pickupLocation!.longitude + _deliveryLocation!.longitude + _currentPosition.longitude) / 3;
    double maxLat = [ _pickupLocation!.latitude, _deliveryLocation!.latitude, _currentPosition.latitude ].reduce(max);
    double minLat = [ _pickupLocation!.latitude, _deliveryLocation!.latitude, _currentPosition.latitude ].reduce(min);
    double maxLng = [ _pickupLocation!.longitude, _deliveryLocation!.longitude, _currentPosition.longitude ].reduce(max);
    double minLng = [ _pickupLocation!.longitude, _deliveryLocation!.longitude, _currentPosition.longitude ].reduce(min);
    double latZoom = log(360 / (maxLat - minLat)) / log(2);
    double lngZoom = log(360 / (maxLng - minLng)) / log(2);
    double zoom = min(latZoom, lngZoom) - 1;
    zoom = zoom.clamp(5.0, 15.0);
    _mapController.move(LatLng(centerLat, centerLng), zoom);
  }

  void _startRiderLocationTracking() {
    _riderLocationTimer?.cancel();
    _riderLocationTimer = Timer.periodic(const Duration(seconds: 10), (_) => _fetchRiderLocation());
    _fetchRiderLocation();
  }

  Future<void> _fetchRiderLocation() async {
    if (riderId == null || riderId!.isEmpty) return;
    try {
      final response = await http.get(
        Uri.parse('$getRiderLocation/$riderId'),
        headers: {'Content-Type': 'application/json'},
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final lat = double.tryParse(data['latitude'].toString());
        final lng = double.tryParse(data['longitude'].toString());
        if (lat != null && lng != null) setState(() => _riderLocation = LatLng(lat, lng));
      }
    } catch (_) {}
  }

  // --- Photo & Upload ---
  Future<void> _takePhoto() async {
    try {
      final picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.camera, imageQuality: 80, maxWidth: 1024, maxHeight: 1024);
      if (image != null) setState(() => _images.add(File(image.path)));
    } catch (_) {
      _showErrorDialog("ไม่สามารถถ่ายรูปได้");
    }
  }

  Future<void> _uploadImages() async {
    try {
      var request = http.MultipartRequest('POST', Uri.parse('$uploadDeliveryImages/${widget.orderId}/images'));
      request.fields['userId'] = userId ?? '';
      request.fields['timestamp'] = DateTime.now().toIso8601String();
      request.fields['location'] = '${_currentPosition.latitude},${_currentPosition.longitude}';
      for (var image in _images) {
        request.files.add(await http.MultipartFile.fromPath('images', image.path));
      }
      var response = await request.send();
      if (response.statusCode == 200) setState(() => _images.clear());
    } catch (_) {
      _showErrorDialog("ไม่สามารถอัพโหลดรูปภาพได้");
    }
  }

  // --- Validate & Confirm ---
  Future<bool> _validateDistance(LatLng? target) async {
    if (target == null) {
      _showErrorDialog("ไม่พบข้อมูลพิกัด");
      return false;
    }
    final distance = const Distance().as(LengthUnit.Meter, _currentPosition, target);
    if (distance > 20) {
      _showErrorDialog("กรุณาเข้าใกล้จุดหมายมากกว่านี้ (ระยะห่างไม่เกิน 20 เมตร)\nระยะห่างปัจจุบัน: ${distance.toStringAsFixed(1)} เมตร");
      return false;
    }
    return true;
  }

  void _confirmPickup() async {
    try {
      if (!await _validateDistance(_pickupLocation)) return;
      await _takePhoto();
      if (_images.isEmpty) {
        _showErrorDialog("กรุณาถ่ายรูปสินค้า");
        return;
      }
      await _uploadImages();
      final response = await http.put(
        Uri.parse('$updateOrderStatus/${widget.orderId}/status'),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: jsonEncode({
          'status': 'shipped',
          'riderId': userId,
          'pickupTime': DateTime.now().toIso8601String(),
          'pickupLocation': {
            'latitude': _currentPosition.latitude,
            'longitude': _currentPosition.longitude,
          },
        }),
      );
      if (response.statusCode == 200) {
        setState(() => _hasPickedUp = true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('รับสินค้าเรียบร้อยแล้ว'), backgroundColor: Colors.green),
        );
      } else {
        throw Exception('ไม่สามารถอัพเดทสถานะได้');
      }
    } catch (_) {
      _showErrorDialog("เกิดข้อผิดพลาด กรุณาลองใหม่");
    }
  }

  void _completeDelivery() async {
    try {
      if (!await _validateDistance(_deliveryLocation)) return;
      await _takePhoto();
      if (_images.isNotEmpty) {
        await _uploadImages();
        final response = await http.post(
          Uri.parse('$completeDelivery/${widget.orderId}/complete'),
          headers: {'Content-Type': 'application/json; charset=UTF-8'},
          body: jsonEncode({
            'riderId': userId,
            'deliveryTime': DateTime.now().toIso8601String(),
            'deliveryLocation': {
              'latitude': _currentPosition.latitude,
              'longitude': _currentPosition.longitude,
            },
          }),
        );
        if (response.statusCode == 200) {
          setState(() => _isDelivered = true);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('การส่งสินค้าเสร็จสมบูรณ์'), backgroundColor: Colors.green),
          );
          await Future.delayed(const Duration(seconds: 2));
          if (mounted) Navigator.of(context).popUntil((route) => route.isFirst);
        }
      }
    } catch (_) {
      _showErrorDialog("เกิดข้อผิดพลาดในการส่งสินค้า");
    }
  }

  // --- UI Helper ---
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("แจ้งเตือน"),
        content: Text(message),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("ตกลง")),
        ],
      ),
    );
  }

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('คำแนะนำการใช้งาน'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('• กดปุ่ม 📍 เพื่อกลับไปที่ตำแหน่งปัจจุบัน'),
            Text('• กดปุ่ม + - เพื่อซูมแผนที่เข้า-ออก'),
            Text('• ต้องอยู่ในระยะ 20 เมตรจากจุดรับ-ส่งสินค้า'),
            Text('• ต้องถ่ายรูปเพื่อยืนยันการรับ-ส่งสินค้า'),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('เข้าใจแล้ว')),
        ],
      ),
    );
  }

  // --- Widget Build ---
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        key: _scaffoldKey,
        appBar: _buildAppBar(),
        body: Stack(
          children: [
            if (_mapReady) _buildEnhancedMap(),
            if (!_mapReady)
              _buildLoadingMap(),
            if (_isLoading)
              _buildLoadingOverlay(),
            _buildBottomPanel(),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() => AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('ติดตามการจัดส่ง', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            Text('Order ID: ${widget.orderId}', style: TextStyle(fontSize: 14, color: Colors.grey[600])),
          ],
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        automaticallyImplyLeading: false,
        elevation: 2,
        actions: [
          IconButton(icon: const Icon(Icons.help_outline), onPressed: _showHelpDialog),
        ],
      );

  Widget _buildLoadingMap() => Container(
        color: Colors.white,
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('กำลังโหลดแผนที่...', style: TextStyle(fontSize: 16)),
            ],
          ),
        ),
      );

  Widget _buildLoadingOverlay() => Container(
        color: Colors.black54,
        child: const Center(
          child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.white)),
        ),
      );

  Widget _buildEnhancedMap() {
    return FlutterMap(
      mapController: _mapController,
      options: MapOptions(
        initialCenter: _currentPosition,
        initialZoom: _currentZoom,
        minZoom: 5,
        maxZoom: 18,
        onPositionChanged: (position, hasGesture) {
          if (hasGesture) setState(() => _isFollowingUser = false);
        },
        interactionOptions: const InteractionOptions(flags: InteractiveFlag.all),
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.example.delivery_app',
        ),
        PolylineLayer(polylines: _buildRoutePolylines()),
        MarkerLayer(markers: _buildEnhancedMarkers()),
      ],
    );
  }

  List<Polyline> _buildRoutePolylines() {
    List<Polyline> polylines = [];
    if (_riderLocation != null && _pickupLocation != null && !_hasPickedUp) {
      polylines.add(Polyline(points: [_riderLocation!, _pickupLocation!], color: Colors.blue.withOpacity(0.7), strokeWidth: 3.0));
    }
    if (_hasPickedUp && !_isDelivered && _riderLocation != null && _deliveryLocation != null) {
      polylines.add(Polyline(points: [_riderLocation!, _deliveryLocation!], color: Colors.green.withOpacity(0.7), strokeWidth: 3.0));
    }
    return polylines;
  }

  List<Marker> _buildEnhancedMarkers() {
    List<Marker> markers = [];
    if (_riderLocation != null) {
      markers.add(_buildMarker(_riderLocation!, Icons.delivery_dining, Colors.blue));
    }
    if (_pickupLocation != null && !_hasPickedUp) {
      markers.add(_buildMarker(_pickupLocation!, Icons.store, Colors.green));
    }
    if (_deliveryLocation != null && _hasPickedUp && !_isDelivered) {
      markers.add(_buildMarker(_deliveryLocation!, Icons.location_on, Colors.red));
    }
    return markers;
  }

  Marker _buildMarker(LatLng point, IconData icon, Color color) => Marker(
        point: point,
        width: 50,
        height: 50,
        child: Container(
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2),
            boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(0, 2))],
          ),
          child: Icon(icon, color: Colors.white, size: 30),
        ),
      );

  Widget _buildBottomPanel() => Positioned(
        bottom: 0,
        left: 0,
        right: 0,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, -2))],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildStatusIndicator(),
              const SizedBox(height: 16),
              _buildActionButtons(),
              const SizedBox(height: 8),
              _buildMapControls(),
            ],
          ),
        ),
      );

  Widget _buildStatusIndicator() {
    IconData icon;
    Color color;
    String text;
    if (_isDelivered) {
      icon = Icons.check_circle;
      color = Colors.green;
      text = 'จัดส่งเสร็จสิ้น';
    } else if (_hasPickedUp) {
      icon = Icons.local_shipping;
      color = Colors.blue;
      text = 'กำลังจัดส่ง';
    } else {
      icon = Icons.pending;
      color = Colors.orange;
      text = 'รอรับสินค้า';
    }
    return Row(
      children: [
        Icon(icon, color: color),
        const SizedBox(width: 8),
        Text(text, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        if (!_hasPickedUp)
          ElevatedButton(
            onPressed: _confirmPickup,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              minimumSize: const Size(double.infinity, 48),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('ยืนยันการรับสินค้า', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ),
        if (_hasPickedUp && !_isDelivered) ...[
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: _completeDelivery,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              minimumSize: const Size(double.infinity, 48),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('ยืนยันการส่งสินค้า', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ),
        ],
      ],
    );
  }

  Widget _buildMapControls() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        FloatingActionButton(
          heroTag: "my_location",
          mini: true,
          onPressed: () {
            setState(() {
              _isFollowingUser = true;
              _mapController.move(_currentPosition, _currentZoom);
            });
          },
          child: const Icon(Icons.my_location),
        ),
        const SizedBox(width: 8),
        Column(
          children: [
            FloatingActionButton(
              heroTag: "zoom_in",
              mini: true,
              onPressed: () {
                setState(() {
                  _currentZoom = min(_currentZoom + 1.0, 18.0);
                  _mapController.move(_mapController.camera.center, _currentZoom);
                });
              },
              child: const Icon(Icons.add),
            ),
            const SizedBox(height: 8),
            FloatingActionButton(
              heroTag: "zoom_out",
              mini: true,
              onPressed: () {
                setState(() {
                  _currentZoom = max(_currentZoom - 1.0, 5.0);
                  _mapController.move(_mapController.camera.center, _currentZoom);
                });
              },
              child: const Icon(Icons.remove),
            ),
          ],
        ),
      ],
    );
  }

  @override
  void dispose() {
    _riderLocationTimer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    _locationSubscription?.cancel();
    _locationUpdateTimer?.cancel();
    _mapController.dispose();
    for (var image in _images) {
      try {
        image.deleteSync();
      } catch (_) {}
    }
    super.dispose();
  }
}
