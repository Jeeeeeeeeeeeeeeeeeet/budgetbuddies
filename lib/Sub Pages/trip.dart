import 'dart:math';

import 'package:BudgetBuddies/trip_data.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class Trip extends StatefulWidget {
  const Trip({super.key});

  @override
  State<Trip> createState() => _TripState();
}

class _TripState extends State<Trip> {

  DatabaseReference ref = FirebaseDatabase.instance.ref('trip');
  late String id;

  final _tripname = TextEditingController();
  final _budget = TextEditingController();
  final _username = TextEditingController();
  List<Map<dynamic, dynamic>> _dataList = [];

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  void _fetchData() async {
    String uid =  FirebaseAuth.instance.currentUser!.uid;
    ref.onValue.listen((event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>;
      final List<Map<dynamic, dynamic>> tempList = [];
      data.forEach((key, value) {
        if(value['members'].toString().contains(uid)) {
          final trip = Map<String, dynamic>.from(value);
          trip['id'] = key;
          tempList.add(trip);
        }
      });
      setState(() {
        _dataList = tempList;
      });

    });
  }

  void showModal(String mode) {
    showDialog(context: context, builder: (context){
      if(mode == 'add') {
        return AlertDialog(
          title: const Text('Creating a new trip!'),
          actions: [
            TextField(
              controller: _tripname,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Trip Name',
              ),
            ),
            const SizedBox(height: 10,),
            TextField(
              controller: _budget,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Enter Budget',
              ),
            ),
            TextButton(onPressed: () {
              addData(_tripname);
              Navigator.pop(context);
            }, child: const Text('Create Trip')),
          ],
        );
      }
      else if(mode == 'join') {
        return AlertDialog(
          title: const Text('Joining a trip!'),
          actions: [
            TextField(
              controller: _tripname,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Trip Code',
              ),
            ),
            TextButton(onPressed: () {
              joinTrip(_tripname);
              Navigator.pop(context);
            }, child: const Text('Join Trip')),
          ],
        );
      }else if(mode == 'edit') {
        return AlertDialog(
          content: const Text('Editing trip!'),
          actions: [
            TextField(
              controller: _tripname,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Trip Name',
              ),
            ),
            const SizedBox(height: 10,),
            TextField(
              controller: _budget,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Enter Budget',
              ),
            ),
            TextButton(onPressed: () {
              addData(_tripname);
              Navigator.pop(context);
            }, child: const Text('Edit Trip')),
          ],
        );
      }
      else{
        return AlertDialog(
          content: const Text('Something went wrong!'),
          actions: [
            TextButton(onPressed: () {
              Navigator.pop(context);
            }, child: const Text('OK')),
          ],
        );
      }
    });
  }

  void addData(tripname){

    const String chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz1234567890';
    Random random = Random();

    String code = String.fromCharCodes(Iterable.generate(
        6, (_) => chars.codeUnitAt(random.nextInt(chars.length))
    ));

    ref.child(code).set({
      'members' : [FirebaseAuth.instance.currentUser!.uid],
      'name': tripname.text,
      'budget' : _budget.text,
      'start_date' : '${DateTime.now().day}-${DateTime.now().month}-${DateTime.now().year}',
      'used_money' : 0,
    });

    tripname.clear();
    _budget.clear();
    setState(() {
      _fetchData();
    });
  }

  void joinTrip(tripCode) {
    DatabaseReference membersRef = ref.child(tripCode.text).child('members');

    membersRef.once().then((value) {
      List<dynamic> members = [];
      if (value.snapshot.value != null) {
        members = List.from(value.snapshot.value as List<dynamic>);
        if (members.contains(FirebaseAuth.instance.currentUser!.uid)) {
          showDialog(context: context, builder: (context) {
            return const AlertDialog(
              content: SizedBox(
                height: 20.0,
                child: Text('Already joined!'),
              ),
            );
          });
        }
        else {
          members.add(FirebaseAuth.instance.currentUser!.uid);
          membersRef.set(members);
        }
      }
      else {
        showDialog(context: context, builder: (context) {
          return const AlertDialog(
            content: SizedBox(
              height: 50.0,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('No such trip exists!'),
                  Text('Check Trip Code again!'),
                ],
              ),
            ),
          );
        });
      }

      tripCode.clear();
      setState(() {
        _fetchData();
      });

    });
  }

  @override
  Widget build(BuildContext context) {
    return
      (FirebaseAuth.instance.currentUser!.displayName == null)
          ? Center(child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Let\'s Get yourself an unique username!', style: TextStyle(fontSize: 20, ), textAlign: TextAlign.center, softWrap: true,),
            const SizedBox(height: 20,),
            TextField(
              controller: _username,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Enter Username',
              ),
            ),
            const SizedBox(height: 20,),
            ElevatedButton(
                style: ButtonStyle(
                  fixedSize: WidgetStateProperty.all(const Size(100, 50)),
                  backgroundColor: WidgetStateProperty.all(Colors.black),
                  foregroundColor: WidgetStateProperty.all(Colors.white),
                  shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                ),
                onPressed: () {
                  if (_username.text.isEmpty) {
                    Fluttertoast.showToast(msg: 'Please enter a username!');
                    return;
                  }else{
                    setState(() {
                      FirebaseAuth.instance.currentUser!.updateDisplayName(_username.text);
                      Fluttertoast.showToast(msg: 'Username updated!');
                      Navigator.pop(context);
                    });
                  }
                },
                child: const Text('Submit')
            ),
          ],
        ),
      ))
          : Scaffold(
        body: _dataList.isEmpty
            ? Center(
          child: Container(
            height: 200.0,
            width: 200.0,
            decoration: BoxDecoration(
              color: Colors.white70,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.black),
            ),
            child: const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Create a new trip by tapping on the + button', style: TextStyle(fontSize: 20, ), textAlign: TextAlign.center, softWrap: true,),
              ],
            ),
          ),
        )
            : Center(
          child: ListView.builder(
            itemCount: _dataList.length,
            itemBuilder: (context, index) {
              return ListTile(
                  title: Text(_dataList[index]['name'], style: const TextStyle(fontWeight: FontWeight.bold)), // Customize based on your data structure
                  subtitle: Text(_dataList[index]['start_date']),
                  trailing: (_dataList[index]['budget'] == "")
                      ? const Text("-", style: TextStyle(fontSize: 20))
                      : Text("₹${_dataList[index]['budget']}", style: const TextStyle(fontSize: 20)),
                  onTap: () {
                    Navigator.push(
                      context,
                      PageRouteBuilder(
                        transitionDuration: const Duration(milliseconds: 500),
                        pageBuilder: (context, animation, secondaryAnimation) => TripData(
                          name: _dataList[index]['name'],
                          code: _dataList[index]['id'],
                        ),
                        transitionsBuilder: (context, animation, secondaryAnimation, child) {
                          return SlideTransition(
                            position: Tween<Offset>(
                              begin: const Offset(1.0, 0.0),
                              end: Offset.zero,
                            ).animate(animation),
                            child: child,
                          );
                        },
                      ),
                    );
                  },
                  shape: const ContinuousRectangleBorder(
                    side: BorderSide(color: Colors.black),
                  )
              );
            },
          ),
        ),
        floatingActionButton: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                FloatingActionButton(
                  mini: true,
                  shape: const CircleBorder(),
                  onPressed: () {
                    showModal("join");
                  },
                  child: const Icon(Icons.attach_file, size: 20,),
                ),
                const SizedBox(height: 10,),
                FloatingActionButton(
                  child: const Icon(Icons.add),
                  onPressed: () {
                    showModal("add");
                  },
                ),
              ],
            ),
          ],
        ),
      );
  }
}