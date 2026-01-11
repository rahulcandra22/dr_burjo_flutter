import 'dart:io';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart'; 
import '../database/db_helper.dart';
import '../models/menu.dart';    
import 'menu_form_screen.dart'; 
import 'login_screen.dart'; 

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Menu> menus = [];
  List<Menu> filteredMenus = []; 
  bool isLoading = true;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _refreshData();
  }

  Future<void> _orderViaWhatsApp(Menu menu) async {
    final String phoneNumber = "6281247585432"; 
    final String message = "Halo, Burjo DR Semarang!, saya ingin memesan *${menu.name}*.\n\nDetail: ${menu.description}\nHarga: Rp ${menu.price}\n\nApakah tersedia?";
    
    final Uri whatsappUrl = Uri.parse(
      "https://wa.me/$phoneNumber?text=${Uri.encodeComponent(message)}"
    );
    
    try {
      bool launched = await launchUrl(whatsappUrl, mode: LaunchMode.externalApplication);
      if (!launched) throw 'Tidak dapat membuka WhatsApp';
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Gagal: $e"), backgroundColor: Colors.red),
      );
    }
  }

  void _filterMenus(String query) {
    setState(() {
      if (query.isEmpty) {
        filteredMenus = menus;
      } else {
        filteredMenus = menus
            .where((m) => m.name.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  Future<void> _refreshData() async {
    setState(() => isLoading = true);
    try {
      final List<Map<String, dynamic>> data = await DBHelper.getMenus();
      _updateLocalList(data);
    } catch (e) {
      debugPrint("Error refresh data: $e");
    } finally {
      setState(() => isLoading = false);
    }
  }

  void _updateLocalList(List<Map<String, dynamic>> data) {
    setState(() {
      menus = data.map((e) => Menu.fromMap(e)).toList();
      filteredMenus = _searchController.text.isEmpty 
          ? menus 
          : menus.where((m) => m.name.toLowerCase().contains(_searchController.text.toLowerCase())).toList();
    });
  }

  void _deleteMenu(int id) async {
    await DBHelper.deleteMenu(id);
    _refreshData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Warung DR Burjo', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        centerTitle: true,
        backgroundColor: Colors.orange,
        leading: IconButton(
          icon: const Icon(Icons.logout, color: Colors.white),
          onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const LoginScreen())),
        ),
        actions: [
          IconButton(onPressed: _refreshData, icon: const Icon(Icons.refresh, color: Colors.white)),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.orange,
        onPressed: () async {
          final result = await Navigator.push(context, MaterialPageRoute(builder: (context) => const MenuFormScreen()));
          if (result == true) _refreshData();
        },
        label: const Text('Tambah', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        icon: const Icon(Icons.add, color: Colors.white),
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator(color: Colors.orange))
                : _buildListMenu(),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: TextField(
        controller: _searchController,
        onChanged: _filterMenus,
        decoration: InputDecoration(
          hintText: 'Cari menu...',
          prefixIcon: const Icon(Icons.search, color: Colors.orange),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
        ),
      ),
    );
  }

  Widget _buildListMenu() {
    if (filteredMenus.isEmpty) {
      return const Center(child: Text("Menu tidak ditemukan"));
    }
    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 85),
      itemCount: filteredMenus.length,
      itemBuilder: (context, index) {
        final m = filteredMenus[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          child: ListTile(
            contentPadding: const EdgeInsets.all(10),
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Container(
                width: 60,
                height: 60,
                color: Colors.orange[50],
                child: m.imagePath != null && File(m.imagePath!).existsSync()
                    ? Image.file(File(m.imagePath!), fit: BoxFit.cover)
                    : const Icon(Icons.fastfood, color: Colors.orange),
              ),
            ),
            title: Text(m.name, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(m.description, maxLines: 2, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 4),
                Text('Rp ${m.price}', style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.message, color: Colors.green),
                  onPressed: () => _orderViaWhatsApp(m),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  onPressed: () => _showDeleteDialog(m),
                ),
              ],
            ),
            onTap: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => MenuFormScreen(menu: m)),
              );
              if (result == true) _refreshData();
            },
          ),
        );
      },
    );
  }

  void _showDeleteDialog(Menu m) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Hapus Menu"),
        content: Text("Yakin ingin menghapus ${m.name}?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Batal")),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              if (m.id != null) _deleteMenu(m.id!);
            }, 
            child: const Text("Hapus", style: TextStyle(color: Colors.red))
          ),
        ],
      ),
    );
  }
}