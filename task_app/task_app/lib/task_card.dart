//import 'package:apps/data_network_coller/data_utility/urls.dart';
//import 'package:apps/data_network_coller/model_api/newtask.dart';
//import 'package:apps/data_network_coller/network_coller.dart';
//import 'package:apps/data_network_coller/network_responce.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

enum TaskStatus {
  Ongoing,
  Completed,
  Cancelled,
}

class Taskcard extends StatefulWidget {
  Taskcard({
    super.key,
    // required this.task,
    required this.onstatuschange,
    required this.taskId,
    //required this.showprogress,
    required this.time,
    required this.title,
    required this.status,
    required this.date,
    required this.description,
  });

  //final Task task;

  final VoidCallback onstatuschange;
  //final Function(bool) showprogress;
  String title;
  String status = "Ongoing";
  String date ;
  String time;
  String description;
  String taskId;
  @override
  State<Taskcard> createState() => _TaskcardState();
}

class _TaskcardState extends State<Taskcard> {
  Future<void> updatetaskstatus(String status) async {
    //   widget.showprogress(true);
    FirebaseFirestore.instance
        .collection("To-do")
        
        .doc(widget.taskId) // Reference the specific task document
        
        .update({"status": status});
        setState(() {
      widget.status = status;
    });
    // widget.showprogress(false);
  }

  Future<void> delettask(String Deleid) async {
     try {
    await FirebaseFirestore.instance
        .collection("To-do")
        .doc(Deleid) // Reference the specific task document
        .delete(); // Only update the status field

    setState(() {
      
    });
  } catch (e) {
    print("Error deleting  task : $e");
  }
   }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            //widget.task.title ?? "",
            widget.title,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
          ),
          Text(
              //widget.task.description ??
              widget.description),
          Text("Date:${widget.date}"), //${widget.task.createdDate}
          Text("Time:${widget.time}"),
          //"),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Chip(
                label: Text(
                  /*widget.task.status ??*/ widget.status,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                backgroundColor: Colors.green,
              ),
              Wrap(
                children: [
                  IconButton(
                      onPressed: () {
                        delettask(widget.taskId);
                      },
                      icon: Icon(Icons.delete_forever)),
                  IconButton(
                    onPressed: () {
                      showupgrade();
                    },
                    icon: Icon(Icons.edit),
                  )
                ],
              )
            ],
          ),
        ],
      ),
    );
  }

  void showupgrade() {
    List<ListTile> items = TaskStatus.values
        .map((e) => ListTile(
              title: Text("${e.name}"),
              onTap: () {
                updatetaskstatus(e.name);

                Navigator.pop(context);
              },
            ))
        .toList();
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("Upgrade Task"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: items,
            ),
            actions: [
              OverflowBar(
                children: [
                  TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text("Cancelled")),
                ],
              )
            ],
          );
        });
  }
}
