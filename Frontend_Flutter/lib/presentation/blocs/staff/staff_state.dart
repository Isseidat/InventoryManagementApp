abstract class StaffState {}

class StaffInitial extends StaffState {}

class StaffLoading extends StaffState {}

class StaffLoaded extends StaffState {
  final List<dynamic> users;
  StaffLoaded(this.users);
}

class StaffFailure extends StaffState {
  final String error;
  StaffFailure(this.error);
}

class StaffActionSuccess extends StaffState {
  final String message;
  StaffActionSuccess(this.message);
}

class StaffActionFailure extends StaffState {
  final String error;
  StaffActionFailure(this.error);
}
