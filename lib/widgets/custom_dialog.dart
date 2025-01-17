import 'dart:io';
import 'package:flutter/material.dart';

class CustomDialog extends StatelessWidget {
  final String imagePath;
  final String date;

  const CustomDialog({Key? key, required this.imagePath, required this.date}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.file(File(imagePath)),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text('Added on: $date'),
          ),
        ],
      ),
    );
  }
}
