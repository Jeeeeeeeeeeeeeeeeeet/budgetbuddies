import 'package:BudgetBuddies/Sub%20Pages/expenses.dart';
import 'package:BudgetBuddies/Sub%20Pages/reports.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_nav_bar/google_nav_bar.dart';

class TripData extends StatefulWidget {
  const TripData({super.key, required this.name, required this.code});

  final String name;
  final String code;

  @override
  State<TripData> createState() => _TripDataState();
}

class _TripDataState extends State<TripData> {

  int _selectedIndex = 0;

  DatabaseReference ref = FirebaseDatabase.instance.ref('trip');
  DatabaseReference moneyRef = FirebaseDatabase.instance.ref('trip');

  late List<Widget> _screens;
  List<String> _membersList = <String>[];
  Map<String, int> userExpense = {};

  @override
  void initState() {
    super.initState();
    _screens = [
      Expenses(tripid: widget.code,),
      Report(tripid: widget.code,),
    ];
    ref = ref.child('${widget.code}/members');
    fetchMemberList();
    _fetchExpenses();
  }

  void fetchMemberList() async {
    ref.onValue.listen((event) {
      setState(() {
        String data = event.snapshot.value.toString();
        _membersList = data.substring(1, data.length - 1).split(', ');
      });
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Future<void> _fetchExpenses() async {
    final snapshot = await ref.child('expenses').get();
    final expenses = snapshot.value as Map<dynamic, dynamic>;

    expenses.forEach((key, value) {
      String user = value['done_by'];
      int amount = int.parse(value['amount'].toString());
      if(userExpense.containsKey(user)){
        userExpense[user] = userExpense[user]! + amount;
      }else{
        userExpense[user] = amount;
      }
    });

    setState(() {});
  }


  Future<String> fetchMemberName(String uid) async {
    DatabaseReference tempRef = FirebaseDatabase.instance.ref('users/$uid/username');
    DataSnapshot snapshot = await tempRef.get();
    if (snapshot.exists) {
      return snapshot.value.toString();
    } else {
      return 'Unknown user';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.name),
        actions: [
          ElevatedButton(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: widget.code),);
              Fluttertoast.showToast(
                msg: "Copied!",
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.BOTTOM,
              );
            },
            style: ElevatedButton.styleFrom(
              elevation: 0.0,
              side: const BorderSide(color: Colors.black, width: 1.0),
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              visualDensity: VisualDensity.comfortable,
            ),
            child: Row(
              children: [
                const Icon(Icons.copy, size: 15.0,),
                const SizedBox(width: 10.0,),
                Text(widget.code, style: const TextStyle(fontSize: 12.0,),),
              ],
            ),
          ),
          const SizedBox(width: 10.0,),
        ],
      ),
      body: _screens.elementAt(_selectedIndex),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
            border: Border(
                top: BorderSide(
                  color: Colors.black,
                  width: 0.5,
                )
            )
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: GNav(
            color: Colors.black,
            activeColor: Colors.black,
            gap: 20,
            tabBackgroundColor: Colors.blue[100]!,
            onTabChange: (index){
              _onItemTapped(index);
            },
            tabs: const [
              GButton(
                icon: Icons.money,
                text: 'Expenses',
              ),
              GButton(
                icon: Icons.bar_chart,
                text: 'Report',
              ),
            ],
          ),
        ),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Center(child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.account_circle, size: 50, color: Colors.white,),
                  Text('Members', style: TextStyle(color: Colors.white, fontSize: 20),),
                ],
              )),
            ),

            ListView.builder(
              shrinkWrap: true,
              itemCount: _membersList.length,
              itemBuilder: (context, index) {
                String uid = _membersList[index];
                return ListTile(
                  title: FutureBuilder<String>(
                    future: fetchMemberName(uid),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        return Text(snapshot.data!, style: const TextStyle(fontSize: 20),);
                      } else if (snapshot.hasError) {
                        return Text('${snapshot.error}');
                      }
                      return const Text('Loading...');
                    },
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}