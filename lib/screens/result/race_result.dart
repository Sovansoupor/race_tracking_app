import 'package:race_tracking_app/models/participant/participant.dart';

class RaceResult {
  final String rank;
  final String name;
  final String bib;
  final String result;

  RaceResult({
    required this.rank,
    required this.name,
    required this.bib,
    required this.result,
  });

  // Create a RaceResult from a Participant and calculated data
  static RaceResult fromParticipant({
    required Participant participant,
    required int position,
    required Duration totalTime,
  }) {
    // Format rank
    final String rankString =
        position == 1
            ? '1st'
            : position == 2
            ? '2nd'
            : position == 3
            ? '3rd'
            : '${position}th';

    // Format time
    final String timeString = _formatDuration(totalTime);

    return RaceResult(
      rank: rankString,
      name: '${participant.firstName} ${participant.lastName}',
      bib: 'BIB ${participant.bibNumber}',
      result: timeString,
    );
  }

  // Format duration as string
  static String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');

    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    final milliseconds = duration.inMilliseconds
        .remainder(1000)
        .toString()
        .padLeft(3, '0');

    return '$hours:$minutes:$seconds.${milliseconds[0]}';
  }
}
