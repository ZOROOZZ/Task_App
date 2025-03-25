import 'package:flutter/material.dart';

class EditNotes extends StatefulWidget {
  final Future<void> Function(String title, String content, Color color)? onSave;
  final String initialTitle;
  final String initialContent;
  final Color initialColor;

  const EditNotes({
    super.key,
    required this.onSave,
    required this.initialTitle,
    required this.initialContent,
    required this.initialColor,
  });

  @override
  State<EditNotes> createState() => _EditNotesState();
}

class _EditNotesState extends State<EditNotes> {
  late TextEditingController titleController;
  late TextEditingController contentController;
  late Color selectedColor;

  @override
  void initState() {
    super.initState();
    titleController = TextEditingController(text: widget.initialTitle);
    contentController = TextEditingController(text: widget.initialContent);
    selectedColor = widget.initialColor;
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
        title: Text('Edit Note'),
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
              onPressed: () {
                if (widget.onSave != null) {
                  widget.onSave!(
                    titleController.text,
                    contentController.text,
                    selectedColor,
                  );
                }
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
              ? Border.all(color: Colors.black, width: 2)
              : null,
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    );
  }
}
