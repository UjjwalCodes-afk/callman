import 'package:callman/Pages/Login.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  String? _userName;
  String? _email;
  String? _role;
  String? _department;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _controller = AnimationController(duration: Duration(milliseconds: 1200), vsync: this);
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _slideAnimation = Tween<Offset>(begin: Offset(0, 0.3), end: Offset.zero).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );
    _controller.forward();
  }

  void _loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _userName = prefs.getString('userName') ?? 'Sales Representative';
      _email = prefs.getString('userEmail') ?? 'user@company.com';
      _role = prefs.getString('role') ?? 'Senior Sales Executive';
      _department = prefs.getString('department') ?? 'Sales Department';
    });
  }
  void printAllSharedPrefs() async {
  final prefs = await SharedPreferences.getInstance();
  final keys = prefs.getKeys();

  if (keys.isEmpty) {
    print("No data found in SharedPreferences.");
  } else {
    for (String key in keys) {
      print('$key: ${prefs.get(key)}');
    }
  }
}

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _buildMetricCard(String title, String value, IconData icon, Color color, {String? subtitle}) {
    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 800),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, animValue, child) {
        return Transform.scale(
          scale: animValue,
          child: Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [color.withOpacity(0.8), color]),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [BoxShadow(color: color.withOpacity(0.3), blurRadius: 12, offset: Offset(0, 6))],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Icon(icon, color: Colors.white, size: 24),
                    if (subtitle != null)
                      Text(subtitle, style: TextStyle(color: Colors.white70, fontSize: 12)),
                  ],
                ),
                SizedBox(height: 12),
                Text(value, style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                Text(title, style: TextStyle(color: Colors.white70, fontSize: 13)),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildQuickAction(String title, IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: Duration(milliseconds: 300),
        padding: EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        margin: EdgeInsets.symmetric(vertical: 4),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 8, offset: Offset(0, 4))],
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            SizedBox(width: 16),
            Text(title, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
            Spacer(),
            Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCard() {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [Colors.green[400]!, Colors.teal[400]!]),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.green.withOpacity(0.3), blurRadius: 12, offset: Offset(0, 6))],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.trending_up, color: Colors.white, size: 28),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Performance Status', style: TextStyle(color: Colors.white70, fontSize: 14)),
                Text('Exceeding Targets', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                Text('Top 10% this quarter', style: TextStyle(color: Colors.white70, fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 280,
                pinned: true,
                backgroundColor: Colors.indigo[800],
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Colors.indigo[800]!, Colors.blue[600]!],
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Hero(
                          tag: 'profile-avatar',
                          child: Container(
                            padding: EdgeInsets.all(3),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 3),
                            ),
                            child: CircleAvatar(
                              radius: 50,
                              backgroundColor: Colors.indigo[100],
                              child: Text(
                                (_userName?.isNotEmpty == true) ? _userName![0].toUpperCase() : 'U',
                                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.indigo[800]),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 12),
                        Text(_userName ?? 'User Name', 
                          style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                        Text(_role ?? 'Role', 
                          style: TextStyle(color: Colors.white70, fontSize: 14)),
                        SizedBox(height: 8),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(_department ?? 'Department', 
                            style: TextStyle(color: Colors.white, fontSize: 12)),
                        ),
                      ],
                    ),
                  ),
                ),
                actions: [
                  IconButton(
                    icon: Icon(Icons.settings, color: Colors.white),
                    onPressed: () {},
                  ),
                ],
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildStatusCard(),
                      SizedBox(height: 20),
                      
                      Text('This Month', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey[800])),
                      SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(child: _buildMetricCard('Leads', '47', Icons.person_add, Colors.blue, subtitle: '+12%')),
                          SizedBox(width: 12),
                          Expanded(child: _buildMetricCard('Calls', '156', Icons.phone, Colors.orange, subtitle: '+8%')),
                        ],
                      ),
                      SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(child: _buildMetricCard('Meetings', '23', Icons.calendar_today, Colors.purple, subtitle: '+5%')),
                          SizedBox(width: 12),
                          Expanded(child: _buildMetricCard('Closed', '12', Icons.check_circle, Colors.green, subtitle: '+15%')),
                        ],
                      ),
                      
                      SizedBox(height: 24),
                      Text('Quick Actions', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey[800])),
                      SizedBox(height: 12),
                      
                      _buildQuickAction('Schedule Follow-up', Icons.schedule, Colors.blue, () {}),
                      _buildQuickAction('Add New Lead', Icons.person_add, Colors.green, () {}),
                      _buildQuickAction('View Pipeline', Icons.timeline, Colors.purple, () {}),
                      _buildQuickAction('Reports & Analytics', Icons.bar_chart, Colors.orange, () {}),
                      _buildQuickAction('Team Performance', Icons.group, Colors.teal, () {}),
                      
                      SizedBox(height: 20),
                      Container(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () async{
                            printAllSharedPrefs();
                              SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.remove('token'); // Remove the token
  printAllSharedPrefs(); // Optional: to verify token is removed

  // You can also clear all data if needed:
  // await prefs.clear();

  // Navigate to login screen or show a message
                    Navigator.push(context, MaterialPageRoute(builder: (context) => LoginPage()));
                            
                          },
                          icon: Icon(Icons.logout, color: Colors.white),
                          label: Text('Sign Out', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red[400],
                            padding: EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            elevation: 4,
                          ),
                        ),
                      ),
                      SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}