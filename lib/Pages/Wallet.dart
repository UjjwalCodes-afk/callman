import 'package:callman/Pages/DialPad.dart';
import 'package:callman/Pages/DoctorHome.dart';
import 'package:callman/Pages/HomePage.dart';
import 'package:flutter/material.dart';
// import 'Shop.dart';

class Wallet extends StatefulWidget {
  final String email;
  final String userName;

  const Wallet({Key? key, required this.email, required this.userName}) : super(key: key);

  @override
  State<Wallet> createState() => _WalletState();
}

class _WalletState extends State<Wallet> {
  int _selectedIndex = 3; // Wallet tab index

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
                Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => DialPadScreen()
    ),
  );
        break;
      case 3:
        // Already on Wallet, do nothing
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Wallet"),
      ),
      body: Center(
        child: Text("Wallet for ${widget.userName}"),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        selectedItemColor: const Color(0xFF00FFCB),
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: "Settings"),
          BottomNavigationBarItem(icon: Icon(Icons.call), label: "Shop"),
          BottomNavigationBarItem(icon: Icon(Icons.wallet), label: "Wallet"),
        ],
      ),
    );
  }
}
