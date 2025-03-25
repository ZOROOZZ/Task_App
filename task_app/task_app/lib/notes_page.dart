import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:task_app/add_notes_screen.dart';
import 'package:task_app/edit_notes.dart';

class NotesPage extends StatefulWidget {
  const NotesPage({super.key});

  @override
  State<NotesPage> createState() => _NotesPageState();
}

class _NotesPageState extends State<NotesPage> {
  List<Map<String, dynamic>> notes = [
    {
      'title': 'Note 1',
      'content': 'Content for Note 1',
      'color': Colors.lightGreen
    },
    {'title': 'Note 2', 'content': 'Content for Note 2', 'color': Colors.amber},
    {
      'title': 'Note 3',
      'content': 'Content for Note 3',
      'color': Colors.redAccent
    },
    {
      'title': 'Note 4',
      'content': 'Content for Note 4',
      'color': Colors.orangeAccent
    },
  ];

  // Remove a note
  void removeNoteAt(String id) {
    FirebaseFirestore.instance.collection("Notes").doc(id).delete();
    setState(() {
      //notes.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(Icons.arrow_back_ios),
        ),
        backgroundColor: Colors.green,
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                notes.clear(); // Clear all notes
              });
            },
            icon: Icon(Icons.delete),
          ),
        ],
      ),
      body: notes.isEmpty
          ? Center(child: Text('No notes added yet.'))
          : Padding(
              padding: const EdgeInsets.all(8.0),
              child: StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection("Notes")
                    .where("creator",
                        isEqualTo: FirebaseAuth.instance.currentUser!.uid)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Text("No data here!");
                  }
                  return GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                    ),
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (context, index) {
                      var note = snapshot.data!.docs[index]; // Get the document
                      var data = note.data() as Map<String, dynamic>;
                      // Safe retrieval of Firestore data
                      String title = data['Title'] ?? 'Untitled';
                      String content =
                          data['Content'] ?? 'No content available';

                      // Convert Firestore color (integer) to a Flutter Color object
                      int colorValue =
                          data['Color'] ?? 0xFFFFFFFF; // Default: White
                      Color color = Color(colorValue);
                      return NotesCard(
                        title: title,
                        content: content,
                        color: color,
                        noteId: note.id,
                        onDelete: () {
                          removeNoteAt(note.id); // Callback to delete note
                        },
                      );
                    },
                  );
                },
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddNotesScreen(
                onSave: (String title, String content, Color color) {
                  setState(() {
                    notes.add(
                        {'title': title, 'content': content, 'color': color});
                  });
                },
              ),
            ),
          );
        },
        child: Icon(Icons.add),
        backgroundColor: Colors.green,
      ),
    );
  }
}

class NotesCard extends StatefulWidget {
  const NotesCard({
    super.key,
    required this.noteId,
    required this.title,
    required this.content,
    required this.color,
    required this.onDelete,
  });
  final String noteId;
  final String title;
  final String content;
  final Color color;
  final VoidCallback onDelete;

  @override
  State<NotesCard> createState() => _NotesCardState();
}

class _NotesCardState extends State<NotesCard> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: widget.color,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.title,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            SizedBox(height: 5),
            Expanded(
              child: Text(
                widget.content,
                style: TextStyle(fontSize: 14),
                overflow: TextOverflow.ellipsis,
                maxLines: 3,
              ),
            ),
            Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: Icon(Icons.copy),
                  onPressed: () {
                    final snackBar = SnackBar(content: Text('Note copied!'));
                    ScaffoldMessenger.of(context).showSnackBar(snackBar);
                  },
                ),
                IconButton(
                  icon: Icon(Icons.visibility),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text(widget.title),
                        content: Text(widget.content),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text('Close'),
                          ),
                          TextButton(
                           onPressed: () {
  Navigator.pop(context); // Close the dialog first

  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => EditNotes(
        initialTitle: widget.title, // Pass existing title
        initialContent: widget.content, // Pass existing content
        initialColor: widget.color, // Pass existing color
        onSave: (String title, String content, Color color) async {
          await FirebaseFirestore.instance
              .collection("Notes")
              .doc(widget.noteId)
              .update({
            'Title': title,
            'Content': content,
            'Color': color.value, // Store color as an integer
          });
        },
      ),
    ),
  );
},

                            child: Text('Edit'),
                          )
                        ],
                      ),
                    );
                  },
                ),
                IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: widget.onDelete, // Use the delete callback
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
