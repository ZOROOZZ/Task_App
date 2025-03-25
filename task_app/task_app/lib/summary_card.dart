
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Summarycard extends StatelessWidget {
  final String count,summary;
  Summarycard({super.key, required this.count, required this.summary});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18.0),
        child: SizedBox(
          width: 100,
          child: Column(
            children: [
              Text(count,style: Theme.of(context).textTheme.titleLarge,),
              Text(summary),
            ],
          ),
        ),
      ),
    );
  }
}