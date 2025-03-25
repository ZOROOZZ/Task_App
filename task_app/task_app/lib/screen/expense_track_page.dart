import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:task_app/home_page.dart';
import 'package:task_app/screen/add_transaction.dart';
import 'package:task_app/screen/borrow_and_lend_page.dart';
import 'package:task_app/screen/date_selector.dart';
import 'package:task_app/screen/expense_card.dart';
import 'package:intl/intl.dart';
import 'package:task_app/screen/expense_chart.dart';

class ExpenseTrackPage extends StatefulWidget {
  const ExpenseTrackPage({super.key});

  @override
  State<ExpenseTrackPage> createState() => _ExpenseTrackPageState();
}

class _ExpenseTrackPageState extends State<ExpenseTrackPage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: StreamBuilder(
          stream: FirebaseFirestore.instance.collection('ExpenseTracker').where("creator",isEqualTo: FirebaseAuth.instance.currentUser!.uid).snapshots(),
          builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const Center(child: Text("No Transactions Available"));
            }

            double totalIncome = 0;
            double totalExpense = 0;
            double dailyIncome = 0;
            double dailyExpense = 0;
            DateTime today = DateTime.now();

            for (var doc in snapshot.data!.docs) {
              String type = doc['type'];
              double amount = (doc['amount'] as num).toDouble();
              DateTime date = doc['created_at'].toDate();

              if (type == "Income") {
                totalIncome += amount;
                if (_isSameDay(date, today)) {
                  dailyIncome += amount;
                }
              } else if (type == "Expense") {
                totalExpense += amount;
                if (_isSameDay(date, today)) {
                  dailyExpense += amount;
                }
              }
            }

            double balance = totalIncome - totalExpense;

            return Column(
              children: [
                // Expense Cards (Total Income, Total Expense, Balance)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(child: ExpenseCard(title: "Total Income", amount: totalIncome)),
                    const SizedBox(width: 10),
                    Expanded(child: ExpenseCard(title: "Total Expense", amount: totalExpense)),
                    const SizedBox(width: 10),
                    Expanded(child: ExpenseCard(title: "Total Balance", amount: balance)),
                  ],
                ),
                const SizedBox(height: 10),
                const DateSelector(),

                // Divider with "Daily Transaction" title
                Row(
                  children: const [
                    Expanded(
                      child: Divider(color: Colors.grey, thickness: 2.0),
                    ),
                    Text("  Daily Transaction  "),
                    Expanded(
                      child: Divider(color: Colors.grey, thickness: 2.0),
                    ),
                  ],
                ),

                // Daily total income and expense
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _dailyTotalCard("Daily Income", dailyIncome, Colors.green),
                    _dailyTotalCard("Daily Expense", dailyExpense, Colors.red),
                  ],
                ),

                // Transactions List
                Expanded(
                  child: ListView.builder(
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (context, index) {
                      var doc = snapshot.data!.docs[index];
                      String docId = doc.id;
                      String type = doc['type'];
                      double amount = (doc['amount'] as num).toDouble();
                      String title = doc['title'];
                      DateTime date = doc['created_at'].toDate();

                      return Card(
                        color: type == "Income" ? Colors.green[100] : Colors.red[100],
                        margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        child: ListTile(
                          leading: Icon(
                            type == "Income" ? Icons.attach_money : Icons.money_off,
                            color: type == "Income" ? Colors.green : Colors.red,
                          ),
                          title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text(DateFormat('dd-MM-yyyy HH:mm').format(date)),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                "\$${amount.toString()}",
                                style: TextStyle(
                                  color: type == "Income" ? Colors.green : Colors.red,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () {
                                  _deleteTransaction(docId);
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),

      // Floating Action Button
      floatingActionButton: FloatingActionButton(
        heroTag: "add_transaction_fab",
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddTransaction()),
          );
        },
        backgroundColor: Colors.green,
        child: const Icon(Icons.add, size: 30),
      ),

      // Bottom Navigation Bar
    
    );
  }

  // Delete transaction function
  void _deleteTransaction(String docId) {
    FirebaseFirestore.instance.collection('ExpenseTracker').doc(docId).delete();
  }

  // Function to check if two dates are the same day
  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year && date1.month == date2.month && date1.day == date2.day;
  }

  // Widget for daily income and expense cards
  Widget _dailyTotalCard(String title, double amount, Color color) {
    return Card(
      color: color.withOpacity(0.2),
      margin: const EdgeInsets.all(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
        child: Column(
          children: [
            Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: color)),
            Text("\$${amount.toStringAsFixed(2)}", style: TextStyle(fontSize: 16, color: color)),
          ],
        ),
      ),
    );
  }
}
