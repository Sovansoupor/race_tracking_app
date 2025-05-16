import 'package:flutter/material.dart';
import 'package:race_tracking_app/theme/theme.dart';

class ResultRow extends StatelessWidget {
  final String position;
  final String name;
  final String bib;
  final String start;
  final String finish;
  final String result;
  const ResultRow({
    super.key,
    required this.position,
    required this.name,
    required this.bib,
    required this.start,
    required this.finish,
    required this.result,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: RaceColors.backgroundAccent,
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          // Position indicator
          SizedBox(
            width: 80,
            child: Container(
              margin: const EdgeInsets.only(left: 16, right: 10),
              padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
              decoration: BoxDecoration(
                color: RaceColors.primary,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                position,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          // Participant details
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  bib,
                  style: TextStyle(
                    color: RaceColors.white.withOpacity(0.7),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          // Start time
          Expanded(
            flex: 2,
            child: Text(
              start,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          // Finish time
          Expanded(
            flex: 2,
            child: Text(
              finish,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          // Result time
          Expanded(
            flex: 2,
            child: Text(
              result,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
