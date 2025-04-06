import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:robotics_app/models/user_model.dart';
import 'package:robotics_app/services/api_service.dart';

part 'users_event.dart';
part 'users_state.dart';

class UsersBloc extends Bloc<UsersEvent, UsersState> {
  // Injected API service
  final ApiService _apiService;

  UsersBloc(this._apiService) : super(UsersInitial()) {
    // Hold all users across pages for pagination support
    List<UserModel> _allUsers = [];

    // Handle FetchUserEvent
    on<FetchUserEvent>((event, emit) async {
      if (event.page == 1) {
        emit(UsersLoading());
        // Clear previous list
        _allUsers.clear();
      }

      try {
        final users = await _apiService.fetchUsers(page: event.page);

        if (event.page > 1) {
          // // Append new users to the list if not page 1
          _allUsers.addAll(users);
        } else {
          // To start fresh
          _allUsers.clear();
          // Add  new user from the first page
          _allUsers.addAll(users);
        }

        emit(UsersLoaded(List.from(_allUsers)));
      } catch (e) {
        emit(UsersError("Failed to load users: $e"));
      }
    });

    // Fetch a Single users details
    on<FetchUserDetailsEvent>((event, emit) async {
      emit(UsersLoading());
      try {
        final user = await _apiService.fetchUserDetails(event.userId);
        // Emit user details
        emit(UserDetailsLoaded(user));
      } catch (e) {
        emit(UsersError("Failed to load user details: $e"));
      }
    });

    // Update user
    on<UpdateUserEvent>((event, emit) async {
      emit(UsersLoading());
      try {
        final success = await _apiService.updateUser(event.user);
        if (success) {
          emit(UserUpdateSuccess());
        } else {
          emit(UserUpdateError("Update operation failed"));
        }
      } catch (e) {
        emit(UserUpdateError("Failed to update user: $e"));
      }
    });

    // Delete User
    on<DeleteUserEvent>((event, emit) async {
      emit(UsersLoading());
      try {
        final isDeleted = await _apiService.deleteUser(event.userId);

        if (isDeleted) {
          // Remove user from the local list
          _allUsers.removeWhere((user) => user.id.toString() == event.userId);

          emit(UserDeleteSuccess("User deleted successfully"));
          // Emit updated list
          emit(UsersLoaded(List.from(_allUsers)));
        } else {
          emit(UserDeleteError("Failed to delete user"));
        }
      } catch (e) {
        emit(UserDeleteError("Failed to delete user: $e"));
      }
    });
  }
}
