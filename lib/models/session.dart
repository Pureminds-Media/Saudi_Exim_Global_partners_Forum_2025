/// Model representing a single agenda session.
class Session {
  final String title;
  final String weekday;
  final String date;
  final String from;
  final String to;
  final List<String> points;

  const Session({
    required this.title,
    required this.weekday,
    required this.date,
    required this.from,
    required this.to,
    required this.points,
  });
}
