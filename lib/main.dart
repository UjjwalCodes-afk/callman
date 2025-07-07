
// import 'package:callman/Pages/PostCallsDetailsScreen.dart';
import 'package:callman/Pages/SplashScreen.dart';
import 'package:callman/Provider/TrueCallerOverLay.dart';
// import 'package:callman/Provider/CallProvider.dart';
import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';



void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyWidget());
}

@pragma("vm:entry-point")
void overlayMain() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: OverlayScreen(callerName: 'Mohit', callerNumber: '7986969580')
  ));
}



class MyWidget extends StatelessWidget {
  const MyWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Callman',
      debugShowCheckedModeBanner: false,
      darkTheme: ThemeData(
        brightness: Brightness.dark
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SplashScreen(),
    );
  }
}