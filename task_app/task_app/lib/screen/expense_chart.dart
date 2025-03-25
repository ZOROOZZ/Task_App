import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ExpenseChartPage extends StatefulWidget {
  const ExpenseChartPage({super.key});

  @override
  _ExpenseChartPageState createState() => _ExpenseChartPageState();
}

class _ExpenseChartPageState extends State<ExpenseChartPage> {
  List<BarChartGroupData> _barGroups = [];
  Map<int, String> _months = {}; // Stores month index to month name
  bool _isLoading = true; // Track loading state

  @override
  void initState() {
    super.initState();
    _fetchExpenses();
  }

  /// Fetch expenses from Firestore where type is 'Expense'
  Future<void> _fetchExpenses() async {
    try {
      print('Fetching data from Firestore...');

      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('ExpenseTracker')
          .where("creator",isEqualTo: FirebaseAuth.instance.currentUser!.uid)
          .where('type', isEqualTo: 'Expense')
          .get();

      print('Query completed. Documents found: ${querySnapshot.docs.length}');

      if (querySnapshot.docs.isEmpty) {
        print('No expense data found.');
        setState(() {
          _barGroups = [];
          _isLoading = false;
        });
        return;
      }

      Map<int, double> monthExpenseMap = {}; // Store monthly expenses

      for (var doc in querySnapshot.docs) {
        var data = doc.data() as Map<String, dynamic>;
        print('Processing document: $data');

        double amount = (data['amount'] as num?)?.toDouble() ?? 0.0;
        Timestamp? timestamp = data['created_at'] as Timestamp?;

        if (timestamp != null) {
          DateTime date = timestamp.toDate();
          int monthIndex = date.month;

          _months[monthIndex] = DateFormat.MMM().format(date); // "Jan", "Feb", etc.

          // Add expenses of the same month
          monthExpenseMap[monthIndex] = (monthExpenseMap[monthIndex] ?? 0) + amount;
        }
      }

      // Convert the map to bar chart data
      List<BarChartGroupData> tempBarGroups = monthExpenseMap.entries.map((entry) {
        return BarChartGroupData(
          x: entry.key, // Month index (1 for Jan, 2 for Feb)
          barRods: [
            BarChartRodData(
              toY: entry.value, // Expense amount
              color: Colors.red,
              width: 10,
            ),
          ],
        );
      }).toList();

      setState(() {
        _barGroups = tempBarGroups;
        _isLoading = false;
      });
    } catch (e) {
      print('Error fetching expenses: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator()) // Show loader
            : _barGroups.isEmpty
                ? const Center(child: Text('No Expense Data Available'))
                : BarChart(
                    BarChartData(
                      maxY: 10000, // Set a reasonable max value
                      barGroups: _barGroups,
                      titlesData: FlTitlesData(
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 40,
                            getTitlesWidget: (value, meta) =>
                                Text('${value.toInt()}'),
                          ),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              return Text(_months[value.toInt()] ?? '');
                            },
                          ),
                        ),
                      ),
                      gridData: FlGridData(show: true),
                      borderData: FlBorderData(
                        border: const Border(
                          top: BorderSide.none,
                          right: BorderSide.none,
                          left: BorderSide(width: 1),
                          bottom: BorderSide(width: 1),
                        ),
                      ),
                    ),
                  ),
      ),
    );
  }
}
