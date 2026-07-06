class DaySchedule {
  final bool enabled;
  final String start;
  final String end;
  final String pauseStart;
  final String pauseEnd;

  const DaySchedule({
    required this.enabled,
    required this.start,
    required this.end,
    required this.pauseStart,
    required this.pauseEnd,
  });

  factory DaySchedule.fromMap(
    Map<String, dynamic> data,
  ) {
    return DaySchedule(
      enabled: data['enabled'] ?? false,
      start: data['start'] ?? '',
      end: data['end'] ?? '',
      pauseStart: data['pauseStart'] ?? '',
      pauseEnd: data['pauseEnd'] ?? '',
    );
  }
}