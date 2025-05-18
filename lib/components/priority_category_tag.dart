import 'package:flutter/material.dart';

class PriorityTag extends StatelessWidget {
  final String priority;
  const PriorityTag(this.priority, {super.key});

  Color get color {
    switch (priority.toLowerCase()) {
      case 'high':
        return Colors.redAccent.shade100;
      case 'medium':
        return Colors.orangeAccent.shade100;
      case 'low':
      default:
        return Colors.green.shade100;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topLeft,
      child: Container(
        decoration: BoxDecoration(
          color: color,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(8),
            bottomRight: Radius.circular(8),
          ),
        ),
        constraints: const BoxConstraints(minWidth: 80),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        alignment: Alignment.center,
        child: Text(
          priority[0].toUpperCase() + priority.substring(1),
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

class CategoryTag extends StatelessWidget {
  final String category;
  const CategoryTag(this.category, {super.key});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topRight,
      child: Container(
        decoration: const BoxDecoration(
          color: Color(0xFF3F51B5),
          borderRadius: BorderRadius.only(
            topRight: Radius.circular(8),
            bottomLeft: Radius.circular(8),
          ),
        ),
        constraints: const BoxConstraints(minWidth: 80),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        alignment: Alignment.center,
        child: Text(
          category,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
