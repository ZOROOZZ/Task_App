import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:task_app/screen/date_selector.dart';
import 'package:task_app/summary_card.dart';
import 'package:task_app/task_card.dart';
import 'package:intl/intl.dart';

class TodoPage extends StatefulWidget {
  const TodoPage({super.key});

  @override
  State<TodoPage> createState() => _TodoPageState();
}

class _TodoPageState extends State<TodoPage> {
  List<String> status = ['Ongoing', 'Completed;', 'Canceled'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(onPressed: () {   Navigator.pop(context);}, icon: Icon(Icons.arrow_back)),
        backgroundColor: Colors.green,
        actions: [
          IconButton(onPressed: () {}, icon: Icon(Icons.delete)),
        ],
        title: const Text("To-Do List"),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Visibility(
              //visible: getsum==false,
              replacement: Center(child: CircularProgressIndicator()),
              child: SizedBox(
                height: 120,
                child: StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('To-do')
                        .where("creator",isEqualTo: FirebaseAuth.instance.currentUser!.uid)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(
                            child:
                                CircularProgressIndicator()); // Show loading state
                      }

                      // if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      //   return Center(child: Text("No tasks found")); // Handle empty data
                      // }
                      var todoData = snapshot.data!.docs; // Firestore data

                      int totalCount = todoData.length; // Total tasks count
                      int ongoingCount = 0;
                      int completedCount = 0;
                      int canceledCount = 0;

                      for (var doc in todoData) {
                        var data = doc.data() as Map<String, dynamic>;
                        String status = data['status'] ?? 'Unknown';

                        if (status == "Ongoing") {
                          ongoingCount++;
                        } else if (status == "Completed") {
                          completedCount++;
                        } else if (status == "Canceled") {
                          canceledCount++;
                        }
                      }

                      List<Map<String, String>> summaryData = [
                        {"summary": "Total", "count": totalCount.toString()},
                        {
                          "summary": "Ongoing",
                          "count": ongoingCount.toString()
                        },
                        {
                          "summary": "Completed",
                          "count": completedCount.toString()
                        },
                        {
                          "summary": "Canceled",
                          "count": canceledCount.toString()
                        },
                      ];

                      // Taskcount taskcoun=taskcountsummarymodel.data![index];
                      return ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: summaryData.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 8.0),
                            child: Summarycard(
                              count: summaryData[index]['count']!,
                              summary: summaryData[index]['summary']!,
                            ),
                          );
                        },
                      );
                    }),
              ),
            ),
            const DateSelector(),
            const Divider(thickness: 1, color: Colors.grey),
            Expanded(
              child: Visibility(
                //visible: completeinpro==false,
                visible: true,
                replacement: Center(child: CircularProgressIndicator()),
                child: RefreshIndicator(
                  onRefresh: () async {setState(() {});},
                  //getcompleted,
                  child: StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance.collection('To-do').where("creator",isEqualTo: FirebaseAuth.instance.currentUser!.uid).snapshots(),
                    builder: (context, snapshot) {
                     if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(
                            child:
                                CircularProgressIndicator()); // Show loading state
                      }

                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return Center(child: Text("No tasks found")); // Handle empty data
                      }
                        var todoData = snapshot.data!.docs;

                      return ListView.builder(
                          itemCount: todoData.length, //newtask.data?.length??0,
                          itemBuilder: (context, index) {
                            return Taskcard(
                              //task: newtask.data![index],
                                taskId: todoData[index].id,
                              onstatuschange: () {
                                //getcompleted();
                              },
                             // showprogress: (Inpgroo) {},
                              //  (Inpgroee ) {
                              //    completeinpro =Inpgroee;
                              //    if(mounted){
                              //      setState(() {
                      
                              //      });
                              //    }
                              //  },

                              title: todoData[index]['title'],
                              description: todoData[index]['description'],
                              status: todoData[index]['status'],
                              date:  DateFormat('yyyy-MM-dd').format(DateTime.tryParse(todoData[index]["date"]) ?? DateTime.now()),
                              time:todoData[index]['time'],
                            );
                          });
                    }
                  ),
                ),
              ),
            )
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            isScrollControlled: true,
            builder: (context) => Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 16.0,
                right: 16.0,
              ),
              child: const AddTask(),
            ),
          );
        },
        backgroundColor: Colors.green,
        child: Icon(Icons.add),
      ),
    );
  }
}

class AddTask extends StatefulWidget {
  const AddTask({super.key});

  @override
  State<AddTask> createState() => _AddTaskState();
}

class _AddTaskState extends State<AddTask> {
  String? statusController = "Ongoing";
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descController = TextEditingController();
  DateTime selectedDate = DateTime.now();
  TimeOfDay selectedTime = TimeOfDay.now();

  void addTask() async {
    await FirebaseFirestore.instance.collection('To-do').add({
      'title': titleController.text,
      'description': descController.text,
      'date': selectedDate.toIso8601String(),
      'time': selectedTime.format(context),
      'status': statusController,
      'creator':FirebaseAuth.instance.currentUser!.uid,
    });
   setState(() {
     
   });
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Add Task",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                labelText: "Title",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: descController,
              decoration: const InputDecoration(
                labelText: "Description",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Text(
                    "Date: ${selectedDate.toLocal().toString().split(' ')[0]}"),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () async {
                    DateTime? pickedDate = await showDatePicker(
                      context: context,
                      initialDate: selectedDate,
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2101),
                    );
                    if (pickedDate != null) {
                      setState(() {
                        selectedDate = pickedDate;
                      });
                    }
                  },
                  child: const Text("Pick Date"),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Text("Time: ${selectedTime.format(context)}"),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () async {
                    TimeOfDay? pickedTime = await showTimePicker(
                      context: context,
                      initialTime: selectedTime,
                    );
                    if (pickedTime != null) {
                      setState(() {
                        selectedTime = pickedTime;
                      });
                    }
                  },
                  child: const Text("Pick Time"),
                ),
              ],
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'Status',
                border: OutlineInputBorder(),
              ),
              value: statusController,
              items: ['Ongoing', 'Completed', 'Canceled']
                  .map((e) => DropdownMenuItem<String>(
                        value: e,
                        child: Text(e),
                      ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  statusController = value;
                });
              },
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                addTask();
                Navigator.pop(context);
              },
              child: const Text("Add Task"),
            ),
          ],
        ),
      ),
    );
  }
}
