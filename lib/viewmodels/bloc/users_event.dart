part of 'users_bloc.dart';

@immutable
sealed class UsersEvent {} // Base event class (abstract)

class FetchUserEvent extends UsersEvent {
  final int page;

  // Event to fetch users by page
  FetchUserEvent({this.page = 1});
}

// Fetch user details
class FetchUserDetailsEvent extends UsersEvent {
  final String userId;

  FetchUserDetailsEvent(this.userId);
}

// Update User
class UpdateUserEvent extends UsersEvent {
  final UserModel user;
  UpdateUserEvent({required this.user});
}

// Delete User
class DeleteUserEvent extends UsersEvent {
  final String userId;
  final int page;

  DeleteUserEvent({required this.userId, required this.page});
}
