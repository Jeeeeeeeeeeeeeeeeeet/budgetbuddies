import 'package:BudgetBuddies/Sub%20Pages/settings.dart';
import 'package:BudgetBuddies/Sub%20Pages/trip.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  final user = FirebaseAuth.instance.currentUser!;

  int _selectedIndex = 0;

  static const List<Widget> _screens = <Widget>[
    Trip(),
    Settings(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: const Text('Budget Buddies', style: TextStyle(color: Colors.white),),
        actions: [
          IconButton (
            icon: const Icon(Icons.logout, color: Colors.white,),
            onPressed: () {
              FirebaseAuth.instance.signOut();
            },
          ),
        ],
      ),
      body: _screens.elementAt(_selectedIndex),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
            border: Border(
                top: BorderSide(
                  color: Colors.grey,
                  width: 0.5,
                )
            )
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: GNav(
            color: Colors.black,
            activeColor: Colors.black,
            gap: 40,
            tabBackgroundColor: Colors.blue[100]!,
            onTabChange: (index){
              _onItemTapped(index);
            },
            tabs: const [
              GButton(
                icon: Icons.home,
                text: 'Home',
              ),
              GButton(
                icon: Icons.account_circle,
                text: 'Settings',

              ),
            ],
          ),
        ),
      ),
    );
  }
}