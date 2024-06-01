import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';

class Expenses extends StatefulWidget {
  const Expenses({super.key, required this.tripid});


  final tripid;

  @override
  State<Expenses> createState() => _ExpensesState();
}

class _ExpensesState extends State<Expenses> {
  late DatabaseReference ref;
  late String code;

  final _amountController = TextEditingController();
  final _categoryController = TextEditingController();
  final _descriptionController = TextEditingController();

  DatabaseReference moneyRef = FirebaseDatabase.instance.ref('trip');

  List<Map<dynamic, dynamic>> _expenseList = [];

  @override
  void initState() {
    super.initState();
    code = '${widget.tripid}';
    ref = FirebaseDatabase.instance.ref('trip/$code/expenses');
    moneyRef = moneyRef.child('$code/used_money');
    fetchUsedMoney();
    fetchData();
  }

  int fetchUsedMoney() {
    moneyRef.get().then((value) {
      String data = value.value.toString();
      return int.parse(data);
    });
    return 0;
  }

  void fetchData() {
    ref.onValue.listen((event) {
      final data = event.snapshot.value;
      if (data != null && data is Map<dynamic, dynamic>) {
        final List<Map<dynamic, dynamic>> tempList = [];
        data.forEach((key, value) {
          if (value is Map<dynamic, dynamic>) {
            final timeList = Map<String, dynamic>.from(value);
            timeList['time'] = DateFormat('dd-MM hh:mm a').format(DateTime.parse(value['date']));
            timeList['id'] = key;
            tempList.add(timeList);
          }
          tempList.sort((a, b) {
            final dateA = DateTime.parse(a['date']);
            final dateB = DateTime.parse(b['date']);
            return dateB.compareTo(dateA);
          });
        });
        setState(() {
          _expenseList = tempList;
        });
      } else {
        setState(() {
          _expenseList = [];
        });
      }
    });
  }

  void updateUsedMoney(int money, String mode) {
    if(mode == 'add') {
      moneyRef.get().then((value) {
        String data = value.value.toString();
        money = int.parse(data) + money;
        moneyRef.set(money);
      });
    }else if(mode == 'remove') {
      moneyRef.get().then((value) {
        String data = value.value.toString();
        money = int.parse(data) - money;
        moneyRef.set(money);
      });
    }
  }

  void addExpense(amountController, categoryController, descriptionController) async {
    DatabaseReference expenseRef = ref.push();


    try {
      expenseRef.set({
        'done_by': FirebaseAuth.instance.currentUser!.displayName,
        'amount': amountController.text,
        'category': categoryController.text,
        'description': descriptionController.text,
        'date': '${DateTime.now()}',
      });

      updateUsedMoney(int.parse(amountController.text), 'add');

      amountController.clear();
      categoryController.clear();
      descriptionController.clear();

      Navigator.pop(context);

      setState(() {
        fetchData();
      });
    } catch (e) {
      Fluttertoast.showToast(
        msg: 'Error adding expense: $e',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
    }
  }

  void showModal() {
    showDialog(context: context, builder: (context) {
      return AlertDialog(
        title: const Text('Add Expense'),
        actions: [
          TextField(
            controller: _amountController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              hintText: 'Amount',
            ),
          ),
          const SizedBox(height: 10,),
          Container(
            margin: const EdgeInsets.only(right: 50.0),
            child: DropdownMenu(
              dropdownMenuEntries: const [
                DropdownMenuEntry(value: 'Hotel', label: 'Hotel'),
                DropdownMenuEntry(value: 'Food', label: 'Food'),
                DropdownMenuEntry(value: 'Travel', label: 'Travel'),
                DropdownMenuEntry(value: 'Entertainment', label: 'Entertainment'),
                DropdownMenuEntry(value: 'Others', label: 'Others'),
              ],
              onSelected: (value) {
                _categoryController.text = value!;
              },
              hintText: 'Category',
              width: 283.5,
            ),
          ),
          const SizedBox(height: 10,),
          TextField(
            controller: _descriptionController,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              hintText: 'Description',
            ),
          ),
          TextButton(onPressed: () {
            if(_amountController.text.isEmpty || _categoryController.text.isEmpty || _descriptionController.text.isEmpty) {
              Fluttertoast.showToast(
                  msg: "Please fill all the fields!",
                  toastLength: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.BOTTOM);
            } else {
              addExpense(_amountController, _categoryController, _descriptionController);
            }
          }, child: const Text('Submit'))
        ],
      );
    });
  }

  @override
  void dispose() {
    _amountController.dispose();
    _categoryController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _expenseList.isEmpty
          ? const Center(
              child: Text('No expenses added yet!'),
            )
          : ListView.builder(
              itemCount: _expenseList.length,
              itemBuilder: (context, index) {
                final expense = _expenseList[index];
                return Dismissible(
                  key: Key(expense['id']),
                  direction: DismissDirection.endToStart,
                  onDismissed: (direction) {
                    ref.child(expense['id']).remove();
                    updateUsedMoney(int.parse(expense['amount']), 'remove');
                    setState(() {
                      _expenseList.removeAt(index);
                    });
                  },
                  background: Container(
                    padding: const EdgeInsets.only(right: 20.0),
                    color: Colors.red,
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children : [
                            Icon(
                              Icons.delete,
                              color: Colors.white,
                            ),
                            Text('Delete', style: TextStyle(color: Colors.white),)
                          ]
                        ),
                      ],
                    ),
                  ),

                  child: ListTile(
                    title: Text('${expense['category']} - ${expense['description']}'),
                    subtitle: Text('on ${expense['time']} - ${expense['done_by']}'),
                    trailing: Text('₹${expense['amount']}', style: const TextStyle(fontSize: 20),),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        elevation: 3.0,
        onPressed: showModal,
        child: const Icon(Icons.add),
      ),
    );
  }
}