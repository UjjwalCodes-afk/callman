
import 'package:callman/Pages/DialPad.dart';
import 'package:callman/Pages/HomePage.dart';
import 'package:callman/Pages/Login.dart';
import 'package:callman/Pages/Notifications.dart';
import 'package:callman/Pages/UserInformation.dart';
// import 'package:callman/Pages/Shop.dart';
import 'package:callman/Pages/Wallet.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const DoctorHomeScreen(
        email: "example@example.com",
        userName: "Alexa",
      ),
    );
  }
}

class DoctorHomeScreen extends StatefulWidget {
  final String email;
  final String userName;

  

  const DoctorHomeScreen({
    Key? key,
    required this.email,
    required this.userName,
  }) : super(key: key);

  @override
  State<DoctorHomeScreen> createState() => _DoctorHomeScreenState();
}

class _DoctorHomeScreenState extends State<DoctorHomeScreen> {

  

  // Add this inside the _DoctorHomeScreenState class

Drawer _buildDrawer() {
  return Drawer(
    child: ListView(
      padding: EdgeInsets.zero,
      children: [
        DrawerHeader(
          decoration: const BoxDecoration(
            color: Color(0xFF00FFCB),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const CircleAvatar(
                radius: 30,
                backgroundImage: AssetImage("images/profilepic.jpg"),
              ),
              const SizedBox(height: 10),
              Text(
                widget.userName,
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                widget.email,
                style: const TextStyle(
                  color: Colors.black87,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
        ListTile(
          leading: const Icon(Icons.person),
          title: const Text('Profile'),
          onTap: () {
            
            Navigator.push(context, MaterialPageRoute(builder: (context) => UserProfilePage(avatarUrl: '', username: 'Mohit', phoneNumber: '9877358790')));
            // Navigate or show profile logic
          },
        ),
        ListTile(
          leading: const Icon(Icons.notifications),
          title: const Text('Notifications'),
          onTap: () {
            Navigator.pop(context);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => NotificationScreen(
                  email: widget.email,
                  userName: widget.userName,
                ),
              ),
            );
          },
        ),
ListTile(
  leading: const Icon(Icons.logout),
  title: const Text('Logout'),
  onTap: () async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.remove('token');
    print('Token removed.');

    // Optional: Check if token is really removed
    final token = prefs.getString('token');
    if (token == null) {
      print('✅ Token successfully removed.');
    } else {
      print('❌ Token still exists: $token');
    }

    // Navigate to login page and clear navigation stack
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
      (Route<dynamic> route) => false,
    );
  },
),

      ],
    ),
  );
}



  String searchQuery = "";
  int _selectedIndex = 0;

void _onItemTapped(int index) {
  setState(() {
    _selectedIndex = index;
  });

  if (index == 1) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AppointmentScreen(
          email: widget.email,
          userName: widget.userName,
        ),
      ),
    );
  } else if (index == 2) {
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (_) => DialPadScreen(
      userName: widget.userName,
      email: widget.email,
    ),
  ),
);

  } else if (index == 3) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => Wallet(
          email: widget.email,
          userName: widget.userName,
        ),
      ),
    );
    
  }
  else if (index == 4) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => DialPadScreen()
    ),
  );
}

}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: _buildDrawer(),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Top Section
            Stack(
              children: [
                Container(
                  height: 250,
                  decoration: const BoxDecoration(
                    color: Color(0xFF00FFCB),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(30),
                      bottomRight: Radius.circular(30),
                    ),
                  ),
                ),
  Padding(
  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
Row(
  mainAxisAlignment: MainAxisAlignment.spaceBetween,
  children: [
    Builder(
      builder: (context) => IconButton(
        icon: const Icon(Icons.menu, size: 28, color: Colors.black),
        onPressed: () {
          Scaffold.of(context).openDrawer();
        },
      ),
    ),
    IconButton(
      icon: const Icon(Icons.notifications, size: 28, color: Colors.black),
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => NotificationScreen(
              email: widget.email,
              userName: widget.userName,
            ),
          ),
        );
      },
    ),
  ],
),

      const SizedBox(height: 40),
      Text(
        "Welcome, ${widget.userName}",
        style: const TextStyle(
          color: Colors.black,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
      const Text(
        "Have a Nice day",
        style: TextStyle(
          color: Colors.black54,
          fontSize: 16,
        ),
      ),
      const SizedBox(height: 20),
      Container(
        height: 50,
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(25),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 4,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: TextField(
          onChanged: (value) {
            setState(() {
              searchQuery = value;
            });
          },
          decoration: const InputDecoration(
            hintText: "Search...",
            hintStyle: TextStyle(color: Colors.white54),
            prefixIcon: Icon(Icons.search, color: Colors.white),
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 14),
          ),
          style: const TextStyle(color: Colors.white),
        ),
      ),
    ],
  ),
),

              ],
            ),

            // Manage Packages Section
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Manage Packages",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  PackageCard(label: "Silver"),
                  PackageCard(label: "Gold"),
                  PackageCard(label: "Diamond"),
                ],
              ),
            ),

            // Upcoming Appointments Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text(
                    "Upcoming Appointments",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    "See all",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.blue,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF00FFCB),
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.all(15),
                child: Row(
                  children: [
                    const CircleAvatar(
                      radius: 30,
                      backgroundImage: AssetImage("images/profilepic.jpg"),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "${widget.userName}",
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Text(
                            "13 Aug, 2023",
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.black54,
                            ),
                          ),
                          Text(
                            "${widget.email}",
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      onPressed: () {
                        print("Call History clicked");
                      },
                      child: const Text("Call History"),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        selectedItemColor: const Color(0xFF00FFCB),
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.call_missed_outgoing), label: "Settings"),
          BottomNavigationBarItem(icon: Icon(Icons.call), label: "Shop"),
          BottomNavigationBarItem(icon: Icon(Icons.wallet), label: "Wallet"),
          //  BottomNavigationBarItem(icon: Icon(Icons.call), label: "Call"),
        ],
      ),
    );
  }
}

class PackageCard extends StatelessWidget {
  final String label;

  const PackageCard({Key? key, required this.label}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(15),
      ),
      child: Center(
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
