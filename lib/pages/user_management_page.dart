import 'package:flutter/material.dart';
import '../models/user.dart';
import '../services/user_service.dart';

class UserManagementPage extends StatefulWidget {
  const UserManagementPage({super.key});

  @override
  State<UserManagementPage> createState() => _UserManagementPageState();
}

class _UserManagementPageState extends State<UserManagementPage> {
  List<User> users = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    users = await UserService.getAll();
    setState(() => isLoading = false);
  }

  Future<void> _showAddDialog() async {
    final nameCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    final passwordCtrl = TextEditingController();
    String selectedRole = 'cashier';

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Tambah Kasir'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameCtrl,
                decoration: InputDecoration(
                  labelText: 'Nama',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 12),
              TextField(
                controller: emailCtrl,
                decoration: InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 12),
              TextField(
                controller: passwordCtrl,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: selectedRole,
                decoration: InputDecoration(
                  labelText: 'Role',
                  border: OutlineInputBorder(),
                ),
                items: ['admin', 'cashier']
                    .map((r) => DropdownMenuItem(
                          value: r,
                          child: Text(r.toUpperCase()),
                        ))
                    .toList(),
                onChanged: (v) {
                  selectedRole = v ?? 'cashier';
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (nameCtrl.text.isEmpty ||
                  emailCtrl.text.isEmpty ||
                  passwordCtrl.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Lengkapi semua field')),
                );
                return;
              }

              await UserService.create(
                User(
                  name: nameCtrl.text,
                  email: emailCtrl.text,
                  password: passwordCtrl.text, // TODO: Hash ini!
                  role: selectedRole,
                  createdAt: DateTime.now(),
                ),
              );

              if (mounted) {
                Navigator.pop(ctx);
                _load();
              }
            },
            child: Text('Tambah'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Manajemen Kasir'),
        backgroundColor: Color(0xFF667eea),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: _showAddDialog,
          ),
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : users.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.people_outline, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text('Belum ada kasir'),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: users.length,
                  itemBuilder: (ctx, i) {
                    final user = users[i];
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Color(0xFF667eea),
                        child: Icon(Icons.person, color: Colors.white),
                      ),
                      title: Text(user.name),
                      subtitle: Text(user.email),
                      trailing: Chip(
                        label: Text(user.role.toUpperCase()),
                        backgroundColor: user.role == 'admin'
                            ? Colors.red[100]
                            : Colors.blue[100],
                      ),
                      onTap: () {
                        // Edit user
                        showDialog(
                          context: context,
                          builder: (ctx2) => AlertDialog(
                            title: Text('Edit Kasir'),
                            content: Text('Fitur edit akan segera tersedia'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(ctx2),
                                child: Text('Tutup'),
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
