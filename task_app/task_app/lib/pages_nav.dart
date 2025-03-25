import 'package:flutter/material.dart';
import 'package:task_app/screen/borrow_and_lend_page.dart';
import 'package:task_app/screen/expense_chart.dart';
import 'package:task_app/screen/expense_track_page.dart';

class PagesNav extends StatefulWidget {
  const PagesNav({super.key});

  @override
  State<PagesNav> createState() => _PagesNavState();
}

class _PagesNavState extends State<PagesNav> {

  
  int _selectedIndex= 0;
   final List<Widget> _pages = [
    ExpenseTrackPage(),      // Replace with your actual home page
    ExpenseChartPage(),     // Replace with your actual chart page
    BorrowAndLendPage() // Replace with your actual borrow & lend page
  ];


  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;  // Update selected page index
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(

      appBar: AppBar(
        toolbarHeight: 90,
        leadingWidth: 50,
        title: (_selectedIndex == 0)?Text("Expense Tracker"):(_selectedIndex == 1)?Text("Expense Chart "):Text("Borrow and Lend Money"),
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.delete),
          ),
        ],
        //centerTitle: true,
        backgroundColor: const Color.fromRGBO(197, 239, 255, 100),
      ),
   body: _pages[_selectedIndex],

        bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home, ), label: 'Tracker', ),
          BottomNavigationBarItem(icon: Icon(Icons.pie_chart), label: 'Chart' , ),
          BottomNavigationBarItem(icon: Icon(Icons.swap_horiz), label: 'Borrow & Lend'),
        ],
        selectedItemColor: Colors.green,
        unselectedItemColor: Colors.grey,
        backgroundColor: Colors.white,
      ),
    );
  }
}