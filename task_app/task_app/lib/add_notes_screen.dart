import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

class AddNotesScreen extends StatefulWidget {
  final Function(String title, String content, Color color)? onSave;
  const AddNotesScreen({super.key, required this.onSave});

  @override
  State<AddNotesScreen> createState() => _AddNotesScreenState();
}

class _AddNotesScreenState extends State<AddNotesScreen> {
   TextEditingController titleController = TextEditingController();

  TextEditingController contentController = TextEditingController();

  Color selectedColor = Colors.lightGreen; 
 // Default sele


@override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

 Future<void> uploadTaskToDb() async {
  try {
    final data= await FirebaseFirestore.instance.collection("Notes").add({
      "Title": titleController.text.trim(),
      "Content":contentController.text.trim(),
      "Color": selectedColor.value,
      "creator":FirebaseAuth.instance.currentUser!.uid,
    });

    print(data);
  } catch (e) {
    print(e);
  }
 }
  @override
  Widget build(BuildContext context) {
    return 
      Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(Icons.arrow_back_ios),
        ),
        backgroundColor: Colors.green,
        title: Text('Add Note'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                labelText: 'Title',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: contentController,
              decoration: const InputDecoration(
                labelText: 'Content',
                border: OutlineInputBorder(),
              ),
              maxLines: 5,
            ),
            const SizedBox(height: 16),
            const Text('Select Color:'),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _colorPicker(Colors.blue),
                _colorPicker(Colors.lightGreen),
                _colorPicker(Colors.lightGreenAccent),
                _colorPicker(Colors.red),
                _colorPicker(Colors.orange),
              ],
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: () async {
                // Save note logic
                await uploadTaskToDb();
                Navigator.pop(context);
              },
              child: Text('Save Note'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                minimumSize: Size(double.infinity, 50),
              ),
            ),
          ],
        ),
      ),
    );
  }


  Widget _colorPicker(Color color) {
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedColor = color;
        });
      },
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: color,
          border: selectedColor == color
              ? Border.all(color: const Color.fromARGB(255, 95, 35, 35), width: 2)
              : null,
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    );
  }

}