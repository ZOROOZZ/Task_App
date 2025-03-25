import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class HabitTracker extends StatefulWidget {
  @override
  HabitTrackerState createState() => HabitTrackerState();
}

class HabitTrackerState extends State<HabitTracker> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  /// 🔹 Stream to listen for real-time updates from Firestore
Stream<Map<String, List<Map<String, dynamic>>>> getTasksStream() {
  return firestore.collection("habitTracker").snapshots().map((snapshot) {
    if (snapshot.docs.isEmpty) {
      print("Firestore is empty!");  // 🚨 Check if Firestore has data
    }

    Map<String, List<Map<String, dynamic>>> tempTasks = {};
    for (var doc in snapshot.docs) {
      print("Document Found: ${doc.id}, Data: ${doc.data()}");  // 🧐 Debugging
      if (doc.exists && doc.data().containsKey("tasks")) {
        tempTasks[doc.id] = List<Map<String, dynamic>>.from(doc["tasks"]);
      }
    }
    return tempTasks;
  });
}


  /// 🔹 Update a task's completion status in Firestore
  Future<void> updateTask(String category, String title, bool completed) async {
    List<Map<String, dynamic>> updatedTasks = [];

    // Fetch existing tasks
    DocumentSnapshot docSnapshot = await firestore.collection("habitTracker").doc(category).get();
    if (docSnapshot.exists) {
      List<Map<String, dynamic>> tasks = List<Map<String, dynamic>>.from(docSnapshot["tasks"]);

      // Update the specific task
      updatedTasks = tasks.map((task) {
        if (task["title"] == title) {
          return {"title": title, "completed": completed};
        }
        return task;
      }).toList();

      // Update Firestore document
      await firestore.collection("habitTracker").doc(category).update({
        "tasks": updatedTasks,
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Habit Tracker")),
      body: StreamBuilder<Map<String, List<Map<String, dynamic>>>>(
        stream: getTasksStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator()); // 🔄 Loading indicator
          }
          if (snapshot.hasError) {
            return Center(child: Text("Error loading habits"));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text("No habits found!"));
          }

          // 🔹 Firestore data updates automatically
          Map<String, List<Map<String, dynamic>>> tasks = snapshot.data!;

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: ListView(
              children: tasks.keys.map((category) {
                return _buildCard(category, tasks[category]!);
              }).toList(),
            ),
          );
        },
      ),
    );
  }

  /// 🔹 Builds category cards with tasks
  Widget _buildCard(String title, List<Map<String, dynamic>> taskList) {
    int completedTasks = taskList.where((task) => task['completed']).length;
    double progress = taskList.isEmpty ? 0 : completedTasks / taskList.length;

    return Container(
      margin: EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 6,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                SizedBox(height: 8),
                LinearProgressIndicator(
                  value: progress,
                  backgroundColor: Colors.grey[300],
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
                ),
                SizedBox(height: 8),
                Text("${(progress * 100).toStringAsFixed(0)}% Completed", style: TextStyle(color: Colors.grey)),
              ],
            ),
          ),
          Divider(height: 1, color: Colors.grey[300]),
          Column(
            children: taskList.map((task) {
              return CheckboxListTile(
                title: Text(task["title"]),
                value: task['completed'],
                onChanged: (bool? value) {
                  if (value != null) {
                    updateTask(title, task["title"], value);
                  }
                },
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
