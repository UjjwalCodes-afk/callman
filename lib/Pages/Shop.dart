import 'package:flutter/material.dart';
import 'DoctorHome.dart';
import 'HomePage.dart';
import 'Wallet.dart';

class Shop extends StatefulWidget {
  final String email;
  final String userName;

  const Shop({Key? key, required this.email, required this.userName}) : super(key: key);

  @override
  State<Shop> createState() => _ShopState();
}

class _ShopState extends State<Shop> {
  int _selectedIndex = 2; // Shop tab index

  void _onItemTapped(int index) {
    if (index == _selectedIndex) return;

    switch (index) {
      case 0:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => DoctorHomeScreen(
              email: widget.email,
              userName: widget.userName,
            ),
          ),
        );
        break;
      case 1:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => AppointmentScreen(
              email: widget.email,
              userName: widget.userName,
            ),
          ),
        );
        break;
      case 2:
        // Already on Shop
        break;
      case 3:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => Wallet(
              email: widget.email,
              userName: widget.userName,
            ),
          ),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Shop"),
      ),
      body: Center(child: Text("Shop for ${widget.userName}")),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        selectedItemColor: const Color(0xFF00FFCB),
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.call_missed_outgoing), label: "Settings"),
          BottomNavigationBarItem(icon: Icon(Icons.shopping_cart), label: "Shop"),
          BottomNavigationBarItem(icon: Icon(Icons.wallet), label: "Wallet"),
        ],
      ),
    );
  }
}
