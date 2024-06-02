import 'package:firebase_database/firebase_database.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class Report extends StatefulWidget {
  const Report({Key? key, required this.tripid}) : super(key: key);

  final String tripid;

  @override
  State<Report> createState() => _ReportState();
}

class _ReportState extends State<Report> {
  late DatabaseReference ref;
  List<Map<dynamic, dynamic>> _expenseList = [];
  late int budget = 0, usedmoney = 0;
  Map<String, int> userExpense = {};

  @override
  void initState() {
    super.initState();
    ref = FirebaseDatabase.instance.ref('trip').child(widget.tripid);
    fetchData();
    _fetchExpenses();
  }

  void _fetchExpenses() {
    ref.child('expenses').onValue.listen((event) {
      final expensesData = event.snapshot.value;
      if (expensesData != null && expensesData is Map<dynamic, dynamic>) {
        final List<Map<dynamic, dynamic>> tempList = [];
        final Map<String, int> tempUserExpense = {};

        expensesData.forEach((key, value) {
          String user = value['done_by'];
          int amount = int.parse(value['amount'].toString());

          tempList.add({
            'id': key,
            'done_by': user,
            'amount': amount,
          });

          tempUserExpense.update(
            user,
                (existingValue) => existingValue + amount,
            ifAbsent: () => amount,
          );
        });

        setState(() {
          _expenseList = tempList;
          userExpense = tempUserExpense;
        });
      } else {
        setState(() {
          _expenseList = [];
          userExpense = {};
        });
      }
    });
  }

  void fetchData() {
    ref.child('used_money').get().then((value) {
      String data = value.value.toString();
      setState(() {
        usedmoney = int.parse(data);
      });
    });
    ref.child('budget').get().then((value) {
      String data = value.value.toString();
      setState(() {
        budget = int.parse(data);
      });
    });
  }

  bool isLow() {
    double per = 0.0;
    per = (usedmoney / budget) * 100;
    return per >= 90.0;
  }

  Color getBudgetColor(int usedMoney, int budget) {
    double percentage = (usedMoney / budget) * 100;
    percentage = percentage.clamp(0.0, 100.0);
    return Color.lerp(Colors.blue, Colors.red, percentage / 100)!;
  }

  List<PieChartSectionData> showingSections() {
    return List.generate(userExpense.length, (i) {
      final host = userExpense.keys.toList()[i];
      final value = userExpense.values.toList()[i];
      return PieChartSectionData(
        color: Colors.primaries[i],
        value: value.toDouble(),
        title: '$value by $host',
        radius: 80.0,
        titleStyle: const TextStyle(
          fontSize: 20,
          color: Color(0xffffffff),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const SizedBox(height: 25),
              Text(
                'Total Budget : $budget',
                style: TextStyle(fontSize: isLow() ? 20 : 30, color: getBudgetColor(usedmoney, budget)),
              ),
              const SizedBox(height: 25,),
              Text('Money Left : ${budget - usedmoney}', style: const TextStyle(fontSize: 20)),
              Text(
                'Total Expense : $usedmoney',
                style: TextStyle(fontSize: isLow() ? 30 : 20, color: getBudgetColor(usedmoney, budget)),
              ),
              Text(
                'Total Budget Percentage Used : ${((usedmoney / budget) * 100).toStringAsFixed(2)} %',
                style: TextStyle(fontSize: 20, color: getBudgetColor(usedmoney, budget)),
              ),
              const SizedBox(height: 25,),
              Table(
                border: TableBorder.all(),
                columnWidths: const {0: FlexColumnWidth(0.5), 1: FlexColumnWidth(0.5)},
                children: [
                  const TableRow(
                    children: [
                      Center(child: Text('Member', style: TextStyle(fontSize: 20, color: Colors.black, fontWeight: FontWeight.bold),)),
                      Center(child: Text('Amount', style: TextStyle(fontSize: 20, color:Colors.black, fontWeight: FontWeight.bold),)),
                    ],
                  ),
                  if (_expenseList.isNotEmpty)
                    for (var i = 0; i < userExpense.length; i++)
                      TableRow(
                        children: [
                          Center(child: Text(userExpense.keys.elementAt(i), style: const TextStyle(fontSize: 20),)),
                          Center(child: Text(userExpense.values.elementAt(i).toString(), style: const TextStyle(fontSize: 20),)),
                        ],
                      )
                  else const TableRow(
                    children: [
                      Center(child: Text('-', style: TextStyle(fontSize: 20),)),
                      Center(child: Text('-', style: TextStyle(fontSize: 20),)),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 25,),
              const Divider(color: Colors.black,),
              (usedmoney / userExpense.length).isNaN
                  ? const Center(child: Text('Divided amount : 0', style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),))
                  : Center(child: Text('Divided amount : ${(usedmoney / userExpense.length).toStringAsFixed(0)}', style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold),)),
              const SizedBox(height: 25,),
              ...userExpense.entries.map((entry) {
                return Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          const SizedBox(width: 10,),
                          Text(entry.key, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          const SizedBox(width: 20,),
                          (int.parse(entry.value.toString()) > usedmoney / userExpense.length)
                              ? const Text('Amount to pay : 0', style: TextStyle(fontSize: 20),)
                              : Text('Amount to pay : ${(usedmoney / userExpense.length) - (int.parse(entry.value.toString()))}', style: const TextStyle(fontSize: 20),),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          const SizedBox(width: 20,),
                          (int.parse(entry.value.toString()) < usedmoney / userExpense.length)
                              ? const Text('Amount to be received : 0', style: TextStyle(fontSize: 20),)
                              : Text('Amount to be received : ${(int.parse(entry.value.toString()) - (usedmoney / userExpense.length)).toStringAsFixed(0)}', style: const TextStyle(fontSize: 20),),
                        ],
                      ),
                      const Divider(color: Colors.black, thickness: 0.5,),
                    ]
                );
              }),
              const SizedBox(height: 25,),
              Container(
                height: 300.0,
                decoration: BoxDecoration(
                  color: Colors.black26,
                  borderRadius: BorderRadius.circular(10.0),
                  shape: BoxShape.rectangle,
                ),
                margin: const EdgeInsets.symmetric(vertical: 10.0),
                child: PieChart(
                  swapAnimationDuration: const Duration(seconds: 1),
                  PieChartData(
                    startDegreeOffset: -90.0,
                    sections: showingSections(),
                    borderData: FlBorderData(show: false),
                    sectionsSpace: 0,
                    centerSpaceRadius: 40,
                  ),
                ),
              ),
              const SizedBox(height: 25,),
            ],
          ),
        ),
      ),
    );
  }
}
