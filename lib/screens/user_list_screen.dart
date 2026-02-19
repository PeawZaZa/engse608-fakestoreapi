import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import 'user_form_screen.dart';
import 'login_screen.dart'; // 1. Import หน้า Login

class UserListScreen extends StatefulWidget {
  const UserListScreen({super.key});

  @override
  State<UserListScreen> createState() => _UserListScreenState();
}

class _UserListScreenState extends State<UserListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<UserProvider>().loadUsers();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<UserProvider>();
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Users (FakeStoreAPI)'),
        actions: [
          // ปุ่ม Refresh เดิม
          IconButton(
            onPressed: provider.isLoading ? null : () => provider.loadUsers(),
            icon: const Icon(Icons.refresh),
          ),
          // 2. เพิ่มปุ่ม Logout ตรงนี้
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.red), // ใส่สีแดงให้เด่นว่าเป็นปุ่มออก
            tooltip: 'Logout',
            onPressed: () {
              // สร้าง Dialog ยืนยันก่อน Logout (Option เสริม)
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Logout'),
                  content: const Text('Are you sure you want to logout?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text('Cancel'),
                    ),
                    FilledButton(
                      onPressed: () {
                        Navigator.pop(ctx); // ปิด Dialog
                        // ย้ายไปหน้า Login และล้าง Stack เดิมทิ้ง
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (_) => const LoginScreen()),
                        );
                      },
                      child: const Text('Logout'),
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(width: 8), // เว้นระยะขวานิดหน่อย
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const UserFormScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
      body: Builder(
        builder: (context) {
          if (provider.isLoading && provider.users.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          if (provider.error != null && provider.users.isEmpty) {
            return Center(child: Text('Error: ${provider.error}'));
          }
          
          return ListView.separated(
            itemCount: provider.users.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (_, i) {
              final u = provider.users[i];
              final name = '${u.name.firstname} ${u.name.lastname}'.trim();
              
              return ListTile(
                title: Text(name.isEmpty ? '(no name)' : name),
                subtitle: Text('${u.username} \n${u.email}'),
                isThreeLine: true,
                trailing: Wrap(
                  spacing: 0,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () {
                        if (u.id == null) return;
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => UserFormScreen(editUser: u),
                          ),
                        );
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () async {
                        if (u.id == null) return;
                        final provider = context.read<UserProvider>();
                        
                        final ok = await showDialog<bool>(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: const Text('Confirm delete'),
                            content: Text('Delete user id=${u.id}?'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(ctx, false),
                                child: const Text('Cancel'),
                              ),
                              FilledButton(
                                onPressed: () => Navigator.pop(ctx, true),
                                child: const Text('Delete'),
                              ),
                            ],
                          ),
                        );

                        if (ok == true) {
                          await provider.removeUser(u.id!);
                          if (context.mounted && provider.error != null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(provider.error!)),
                            );
                          }
                        }
                      },
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}