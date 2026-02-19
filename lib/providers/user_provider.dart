import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/user_api_service.dart';

class UserProvider extends ChangeNotifier {
  final UserApiService _api = UserApiService();
  List<UserModel> users = [];
  bool isLoading = false;
  String? error;

  Future<void> loadUsers() async {
    isLoading = true;
    error = null;
    notifyListeners();
    try {
      users = await _api.fetchUsers();
    } catch (e) {
      error = e.toString();
    }
    isLoading = false;
    notifyListeners();
  }

  Future<void> addUser(UserModel newUser) async {
    isLoading = true;
    error = null;
    notifyListeners();
    try {
      // Simulate API delay because FakeStoreAPI is very fast
      await Future.delayed(const Duration(seconds: 1)); 
      
      // คำนวณ ID ใหม่จำลอง (เพราะ FakeStoreAPI ไม่ได้ save จริงในระยะยาว)
      final newId = users.isEmpty
          ? 1
          : (users.map((u) => u.id ?? 0).reduce((a, b) => a > b ? a : b) + 1);

      final created = UserModel(
        id: newId,
        email: newUser.email,
        username: newUser.username,
        password: newUser.password,
        name: newUser.name,
        address: newUser.address,
        phone: newUser.phone,
      );
      
      // เรียก API จริง (แต่ fake store จะไม่เก็บข้อมูลเราจริงๆ)
      // await _api.createUser(newUser); 
      
      users.insert(0, created); // เพิ่มข้อมูลลงใน list เพื่อให้ UI อัปเดต
    } catch (e) {
      error = e.toString();
    }
    isLoading = false;
    notifyListeners();
  }

  Future<void> editUser(int id, UserModel updatedUser) async {
    isLoading = true;
    error = null;
    notifyListeners();
    try {
      await Future.delayed(const Duration(seconds: 1)); // Simulate API delay
      
      // await _api.updateUser(id, updatedUser);

      final index = users.indexWhere((u) => u.id == id);
      if (index != -1) {
        users[index] = UserModel(
          id: id,
          email: updatedUser.email,
          username: updatedUser.username,
          password: updatedUser.password,
          name: updatedUser.name,
          address: updatedUser.address,
          phone: updatedUser.phone,
        );
      }
    } catch (e) {
      error = e.toString();
    }
    isLoading = false;
    notifyListeners();
  }

  Future<void> removeUser(int id) async {
    isLoading = true;
    error = null;
    notifyListeners();
    try {
      await _api.deleteUser(id);
      users.removeWhere((u) => u.id == id);
    } catch (e) {
      error = e.toString();
    }
    isLoading = false;
    notifyListeners();
  }
}