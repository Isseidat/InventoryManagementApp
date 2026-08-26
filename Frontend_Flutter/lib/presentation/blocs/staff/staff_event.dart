abstract class StaffEvent {}

class StaffListRequested extends StaffEvent {}

class StaffCreated extends StaffEvent {
  final Map<String, dynamic> data;
  StaffCreated(this.data);
}

class StaffUpdated extends StaffEvent {
  final int id;
  final Map<String, dynamic> data;
  StaffUpdated(this.id, this.data);
}

class StaffDeleted extends StaffEvent {
  final int id;
  StaffDeleted(this.id);
}
