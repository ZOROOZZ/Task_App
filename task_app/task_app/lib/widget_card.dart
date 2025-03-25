import 'package:flutter/material.dart';

class WidgetCard extends StatelessWidget {
  final VoidCallback onTap;
  final String Title;
  final String imageUrl;

  const WidgetCard({super.key,
  required this.onTap,
  required this.Title,
  required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Card(
        clipBehavior: Clip.hardEdge,
        child: InkWell(
          splashColor: Colors.blue.withAlpha(30),
          onTap: onTap,
          child: SizedBox(
            width: 120,
            height: 90, // Ensure this matches your design
            child: Column(
              mainAxisSize: MainAxisSize.min, // Take only the space required
              children: [
                const SizedBox(height: 8), // Reduced from 10
                Center(
                  child: Image.asset(
                    imageUrl,
                    height: 50, // Adjust to fit within the height
                    width: 50,
                  ),
                ),
                const SizedBox(height: 8), // Reduced from 16
                Text(
                  Title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14, // Adjust font size for better fit
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
