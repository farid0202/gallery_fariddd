import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:frd_gallery/helpers/database_helper.dart'; // Pastikan import benar

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({Key? key}) : super(key: key);

  @override
  _FavoritesPageState createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance; // Gunakan instance
  List<Map<String, dynamic>> _favoriteImages = [];

  // Memuat gambar favorit dari database
  _loadFavorites() async {
    List<Map<String, dynamic>> favorites = await _dbHelper.getFavorites(); // Mengambil gambar favorit
    setState(() {
      _favoriteImages = favorites;
    });
  }

  // Fungsi untuk menghapus gambar dari favorit
  _removeFromFavorites(int id) async {
    await _dbHelper.updateFavoriteStatus(id, false); // Update status favorit menjadi false
    _loadFavorites(); // Muat ulang gambar favorit setelah dihapus
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Image removed from favorites!')),
    );
  }

  @override
  void initState() {
    super.initState();
    _loadFavorites(); // Memuat gambar favorit ketika halaman dibuka
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorites'),
      ),
      body: _favoriteImages.isEmpty
          ? const Center(child: Text('No favorites yet!'))
          : GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: _favoriteImages.length,
              itemBuilder: (context, index) {
                final imageData = _favoriteImages[index];
                final imageBytes = imageData['image'] as List<int>;
                final image = Image.memory(
                  Uint8List.fromList(imageBytes),
                  fit: BoxFit.cover, // Agar gambar sesuai ukuran Card
                );

                return GestureDetector(
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) {
                        return Dialog(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.0), // Sudut membulat pada dialog
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12.0), // Membulatkan sudut gambar
                                child: image,
                              ),
                              TextButton(
                                onPressed: () {
                                  // Menghapus gambar dari favorit
                                  _removeFromFavorites(imageData['id']);
                                  Navigator.of(context).pop(); // Menutup dialog
                                },
                                child: const Text('Remove from Favorites'),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0), // Sudut membulat pada Card
                    ),
                    clipBehavior: Clip.antiAlias, // Memotong konten agar sesuai dengan border
                    child: image,
                  ),
                );
              },
          ),
    );
  }
}