part of 'users_bloc.dart';

@immutable
sealed class UsersState {} // Base state class

final class UsersInitial
    extends UsersState {} // Initial state before anything happens

final class UsersLoading
    extends UsersState {} // Loading state when fetching data

final class UsersLoaded extends UsersState {
  final List<UserModel> users;

  // State when data is successfully fetched
  UsersLoaded(this.users);
}

// User details
class UserDetailsLoaded extends UsersState {
  final UserModel user;

  UserDetailsLoaded(this.user);
}

final class UsersError extends UsersState {
  final String message;

  // State when an error occurs
  UsersError(this.message);
}

// Update User
final class UserUpdateSuccess extends UsersState {}

// User Update failed error
final class UserUpdateError extends UsersState {
  final String message;
  UserUpdateError(this.message);
}

// State when a user is successfully deleted
final class UserDeleteSuccess extends UsersState {
  final String message;

  UserDeleteSuccess(this.message);
}

// Deleting a user fails
final class UserDeleteError extends UsersState {
  final String message;

  UserDeleteError(this.message);
}
