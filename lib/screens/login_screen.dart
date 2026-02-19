import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import 'user_list_screen.dart';
import 'product_list_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _usernameCtrl = TextEditingController(text: 'johnd'); // Default ID 1
  final _passwordCtrl = TextEditingController(text: 'm38rmF\$');
  final _formKey = GlobalKey<FormState>();
  bool _isObscure = true;

  void _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    final userProvider = context.read<UserProvider>();
    
    // 1. โหลดข้อมูลถ้ายังไม่มี
    if (userProvider.users.isEmpty) {
      await userProvider.loadUsers();
    }

    final inputUser = _usernameCtrl.text.trim();
    final inputPass = _passwordCtrl.text.trim(); // รหัสที่กรอก

    try {
      // 2. ค้นหา User จาก username
      final user = userProvider.users.firstWhere(
        (u) => u.username == inputUser,
        orElse: () => throw Exception("User not found"),
      );

      // --- จุดที่ต้องเพิ่ม ---
      // 3. ตรวจสอบรหัสผ่าน (ของเดิมไม่มีบรรทัดนี้)
      if (user.password != inputPass) {
        throw Exception("Incorrect password"); // ถ้ารหัสไม่ตรง ให้โยน Error
      }
      // --------------------

      // 4. ถ้าผ่านหมด ให้เช็ค ID เพื่อแยกหน้า
      if (!mounted) return;
      
      if (user.id == 1) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const UserListScreen()),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const ProductListScreen()),
        );
      }

    } catch (e) {
      if (!mounted) return;
      // แจ้งเตือนเมื่อ Username หรือ Password ผิด
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Invalid Username or Password'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
  @override
  Widget build(BuildContext context) {
    // ใช้ isLoading ของ userProvider เพื่อแสดงสถานะตอนกำลังดึงข้อมูลมาเช็ค
    final isLoading = context.select<UserProvider, bool>((p) => p.isLoading);

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.store, size: 80, color: Colors.blue),
                const SizedBox(height: 16),
                const Text('FakeStore Login', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                const SizedBox(height: 32),
                
                TextFormField(
                  controller: _usernameCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Username',
                    border: OutlineInputBorder(),
                    helperText: "Try 'johnd' (ID 1) or 'mor_2314' (ID 2)",
                  ),
                  validator: (v) => v!.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passwordCtrl,
                  obscureText: _isObscure,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: Icon(_isObscure ? Icons.visibility : Icons.visibility_off),
                      onPressed: () => setState(() => _isObscure = !_isObscure),
                    ),
                  ),
                  validator: (v) => v!.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 24),
                
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: FilledButton(
                    onPressed: isLoading ? null : _handleLogin,
                    child: isLoading 
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Login'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}