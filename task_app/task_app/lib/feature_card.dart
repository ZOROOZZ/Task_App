import 'package:flutter/material.dart';

class FeatureCard extends StatelessWidget {
  const FeatureCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.amber[100],
      child: SizedBox(
        height: 160,
        width: 160,
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(

            children: [
              const SizedBox(height: 20,),
              const CircleAvatar(
                minRadius: 35,
                backgroundColor: Colors.lightGreen,
                child: ImageIcon(AssetImage('assets/accounting.png')),
              ),
              const SizedBox(height:10),
              const Text("Health and Fitness"),
               const SizedBox(height:10),
               LinearProgressIndicator(
                  value: 0.6, // Progress value between 0.0 and 1.0
                  backgroundColor: Colors.grey[300],
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.green),
                  borderRadius: BorderRadius.circular(10),
                ),
            ],
          ),
        ),
      ),
    );
  }
}