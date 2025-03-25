import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:intl/intl.dart';
import 'package:task_app/feature_card.dart';
import 'package:task_app/habit_tracker.dart';
import 'package:task_app/notes_page.dart';
import 'package:task_app/pages_nav.dart';
import 'package:task_app/screen/expense_track_page.dart';
import 'package:task_app/todo_page.dart';
import 'package:task_app/widget_card.dart';

class HomePage extends StatelessWidget {
  HomePage({super.key});
  final GlobalKey<HabitTrackerState> _habitTrackerKey = GlobalKey<HabitTrackerState>();

final List<Map<String, String>> listOfTasks = [
    {"title": "Expense Tracker", "imageUrl": "assets/accounting.png"},
    {"title": "To-Do", "imageUrl": "assets/accounting.png"},
    {"title": "Notes", "imageUrl": "assets/accounting.png"},
  ];

 final pages = [
  PagesNav(),
      //const ExpenseTrackPage(), // Page 1
      const TodoPage(), // Page 2
      const NotesPage(), // Page 3
    ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 90,
        leadingWidth: 100,
        title: BounceInDown(child: const Text("Task App")),
        leading: Container(
          height: 80,
          width: 80,
          padding: const EdgeInsets.all(8.0),
          margin: const EdgeInsets.symmetric(horizontal: 8),
          child: const CircleAvatar(
            backgroundImage: AssetImage('assets/logo.png'),
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color.fromRGBO(197, 239, 255, 1),
        actions: [
          IconButton(
            onPressed: () async{
               showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text("Log Out"),
                        content: Text("Are you sure you want to log out?"),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () async{
                               await FirebaseAuth.instance.signOut();
                              Navigator.pop(context);
                            },
                            child: Text('Logout'),
                          )
                        ],
                      ),
                    );
             
              
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            SizedBox(
              height: 120,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: 3,
                itemBuilder: (context, index) {
                  return WidgetCard(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => pages[index],
                        ),
                    
                      );

                    },
                    Title: listOfTasks[index]['title']!,
                    imageUrl: listOfTasks[index]["imageUrl"]!,
                  );
                },
              ),
            ),
            const Divider(
              color: Colors.grey,
              thickness: 1.0,
              height: 30.0,
            ),
            const SizedBox(height: 30),
            Row(
              children: [
                 Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Track your regular habit",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text( DateFormat('yMMMMd').format(DateTime.now()),),
                  ],
                ),
                const Spacer(),
                ElevatedButton(
                  onPressed: () {},
                  child: const Text("Clear All"),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Expanded(
              child: HabitTracker(),
            ),
          ],
        ),
      ),
    );
  }
}
