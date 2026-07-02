/// Entity representing staff logs, attendance, and progress logs.
class StaffLog {
  final String id;
  final String name;
  final String attendance; // Present, Absent, Leave
  final String taskDescription;
  final DateTime date;

  const StaffLog({
    required this.id,
    required this.name,
    required this.attendance,
    required this.taskDescription,
    required this.date,
  });
}
