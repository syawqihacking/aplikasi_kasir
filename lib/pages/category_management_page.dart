import 'package:flutter/material.dart';
import '../models/category.dart';
import '../services/category_service.dart';

class CategoryManagementPage extends StatefulWidget {
  const CategoryManagementPage({super.key});

  @override
  State<CategoryManagementPage> createState() => _CategoryManagementPageState();
}

class _CategoryManagementPageState extends State<CategoryManagementPage> {
  List<Category> categories = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    categories = await CategoryService.getAll();
    setState(() => isLoading = false);
  }

  Future<void> _showAddDialog() async {
    final nameCtrl = TextEditingController();
    final descCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Tambah Kategori'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameCtrl,
                decoration: InputDecoration(
                  labelText: 'Nama Kategori',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 12),
              TextField(
                controller: descCtrl,
                decoration: InputDecoration(
                  labelText: 'Deskripsi (Opsional)',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
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
              if (nameCtrl.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Nama kategori harus diisi')),
                );
                return;
              }

              await CategoryService.create(
                Category(
                  name: nameCtrl.text,
                  description: descCtrl.text,
                ),
              );

              if (mounted) {
                Navigator.pop(ctx);
                _load();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Kategori berhasil ditambahkan'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
            child: Text('Tambah'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteCategory(int id) async {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Hapus Kategori?'),
        content: Text('Kategori akan dihapus'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Batal'),
          ),
          TextButton(
            onPressed: () async {
              await CategoryService.delete(id);
              Navigator.pop(ctx);
              _load();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Kategori berhasil dihapus'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: Text('Hapus', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Manajemen Kategori'),
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
          : categories.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.category_outlined, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text('Belum ada kategori'),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: categories.length,
                  itemBuilder: (ctx, i) {
                    final cat = categories[i];
                    return ListTile(
                      leading: Icon(Icons.category, color: Color(0xFF667eea)),
                      title: Text(cat.name),
                      subtitle: Text(cat.description.isEmpty ? '-' : cat.description),
                      trailing: IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _deleteCategory(cat.id!),
                      ),
                    );
                  },
                ),
    );
  }
}
