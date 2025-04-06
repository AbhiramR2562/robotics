import 'dart:convert';
import 'dart:developer';

import 'package:http/http.dart' as http;
import 'package:robotics_app/models/user_model.dart';

class ApiService {
  // Base Url
  final String baseUrl = "https://gorest.co.in/public/v2/users";

  // Authorization Token
  final String? _token =
      "090a4d13b368ea5cbc5c1f05cd08a2b0cb5cd4234b51f1b2aa2a8e6a4edaf183";

  // reusable Header
  Map<String, String> get _header => {
    'Content-Type': 'application/json',
    if (_token != null) 'Authorization': 'Bearer $_token',
  };

  // Get Request
  Future<List<dynamic>> _getRequest(String endpoint) async {
    final response = await http.get(
      Uri.parse('$baseUrl$endpoint'),
      headers: _header,
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception("Failed to fetch data");
    }
  }

  // fetch Users
  Future<List<UserModel>> fetchUsers({
    required int page,
    int perPage = 5,
  }) async {
    try {
      final data = await _getRequest("?page=$page&per_page=$perPage");
      return data.map((user) => UserModel.fromJson(user)).toList();
    } catch (e) {
      throw Exception("Error fetching users: $e");
    }
  }

  // Fetch Single User details
  Future<UserModel> fetchUserDetails(String userId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/$userId'),
        headers: _header,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return UserModel.fromJson(data);
      } else {
        throw Exception(
          "Failed to fetch user details: ${response.reasonPhrase}",
        );
      }
    } catch (e) {
      throw Exception("Error fetching user details: $e");
    }
  }

  // Update User
  Future<bool> updateUser(UserModel user) async {
    try {
      final url = Uri.parse('$baseUrl/${user.id}');
      final response = await http.put(
        url,
        headers: _header,
        body: jsonEncode({
          'name': user.name,
          'email': user.email,
          'gender': user.gender,
          'status': user.status,
        }),
      );

      return response.statusCode == 200;
    } catch (e) {
      log("Exception in updateUser: $e");
      throw Exception("Error updating user: $e");
    }
  }

  // Delete User
  Future<bool> deleteUser(String userId) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/$userId'),
        headers: _header,
      );
      if (response.statusCode == 200 || response.statusCode == 204) {
        return true;
      } else {
        throw Exception("Failed to delete user: ${response.reasonPhrase}");
      }
    } catch (e) {
      throw Exception("Error deleting user: $e");
    }
  }
}
