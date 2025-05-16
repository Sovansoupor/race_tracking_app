import 'package:flutter/material.dart';
import 'package:race_tracking_app/screens/result/widget/result_row.dart';
import 'package:race_tracking_app/screens/result/widget/result_table_header.dart';
import 'package:race_tracking_app/theme/theme.dart';
import 'package:race_tracking_app/widgets/display/race_divider.dart';

class ResultScreen extends StatelessWidget {
  const ResultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final results = [
      {
        'position': '1st',
        'name': 'Pen Povrajana',
        'bib': 'BIB 100',
        'start': '00:00:32.3',
        'finish': '01:44:45.3',
        'result': '01:44:45.3',
      },
      {
        'position': '2nd',
        'name': 'Eng Sovansoupor',
        'bib': 'BIB 101',
        'start': '00:00:32.3',
        'finish': '01:44:45.3',
        'result': '01:44:45.3',
      },
      {
        'position': '3rd',
        'name': 'Touch Livita',
        'bib': 'BIB 102',
        'start': '00:00:32.3',
        'finish': '01:44:45.3',
        'result': '01:44:45.3',
      },
      {
        'position': '4th',
        'name': 'Sou Por',
        'bib': 'BIB 103',
        'start': '00:00:32.3',
        'finish': '01:44:45.3',
        'result': '01:44:45.3',
      },
    ];

    return Scaffold(
      backgroundColor: RaceColors.backgroundAccent,
      appBar: AppBar(
        backgroundColor: RaceColors.backgroundAccentDark,
        toolbarHeight: 95,
        elevation: 0,
        title: Row(
          children: [
            Text(
              'Result',
              style: RaceTextStyles.heading.copyWith(color: RaceColors.white),
            ),
          ],
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            color: RaceColors.backgroundAccent,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Race Name
                Text(
                  'CADTO Marathon',
                  style: RaceTextStyles.body.copyWith(color: RaceColors.white),
                ),
                const SizedBox(height: 20),

                // Table header
                Padding(
                  padding: EdgeInsets.only(right: 16),
                  child: ResultTableHeader(),
                ),
              ],
            ),
          ),
          RaceDivider(),
          // Results List
          Expanded(
            child: ListView.separated(
              padding: EdgeInsets.zero,
              itemCount: results.length,
              separatorBuilder:
                  (context, index) => Divider(
                    height: 1,
                    color: RaceColors.white.withOpacity(0.1),
                    indent: 16,
                    endIndent: 16,
                  ),
              itemBuilder: (context, index) {
                final result = results[index];
                return ResultRow(
                  position: result['position']!,
                  name: result['name']!,
                  bib: result['bib']!,
                  start: result['start']!,
                  finish: result['finish']!,
                  result: result['result']!,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
