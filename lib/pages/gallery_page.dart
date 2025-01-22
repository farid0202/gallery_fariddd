import 'dart:typed_data';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../helpers/database_helper.dart';

class GalleryPage extends StatefulWidget {
  const GalleryPage({Key? key}) : super(key: key);

  @override
  _GalleryPageState createState() => _GalleryPageState();
}

class _GalleryPageState extends State<GalleryPage> {
  final ImagePicker _picker = ImagePicker();
  List<Map<String, dynamic>> _imageFileList = [];
  Map<String, List<Map<String, dynamic>>> _groupedImages = {};

  @override
  void initState() {
    super.initState();
    _loadImages();
  }

  Future<void> _loadImages() async {
    final images = await DatabaseHelper.instance.getAllImages();
    setState(() {
      _imageFileList = images;
      _groupImagesByMonth(); // Group the images by month after loading them
    });
  }

  void _groupImagesByMonth() {
    _groupedImages.clear();
    for (var imageData in _imageFileList) {
      final date = DateTime.parse(
          imageData['date']); // Assuming date is stored as a string
      final formattedDate =
          '${date.day}-${date.month}-${date.year}'; // Format: day-month-year

      // Group images by date
      if (_groupedImages.containsKey(formattedDate)) {
        _groupedImages[formattedDate]!.add(imageData);
      } else {
        _groupedImages[formattedDate] = [imageData];
      }
    }
  }

  Future<void> _pickImage() async {
    final pickedFiles = await _picker.pickMultiImage();

    if (pickedFiles != null && pickedFiles.isNotEmpty) {
      for (var pickedFile in pickedFiles) {
        final imageFile = File(pickedFile.path);
        final date = DateTime.now();

        // Save image to database
        await DatabaseHelper.instance.insertImage(imageFile, date);

        // Reload the images from database and group them by month
        _loadImages();
      }

      // Show success alert with custom style
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: const [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 10),
              Text(
                'Gambar berhasil ditambahkan!',
                style: TextStyle(color: Colors.white),
              ),
            ],
          ),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  Future<void> _deleteImage(int id) async {
    await DatabaseHelper.instance.deleteImage(id);

    // Reload the images after deletion
    _loadImages();

    // Show success alert with custom style
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: const [
            Icon(Icons.check_circle, color: Colors.white),
            SizedBox(width: 10),
            Text(
              'Gambar berhasil dihapus!',
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gallery'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListView(
          children: _groupedImages.entries.map((entry) {
            final monthYear = entry.key;
            final images = entry.value;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Text(
                    monthYear, // Display the month-year header
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                  ),
                  itemCount: images.length,
                  itemBuilder: (context, index) {
                    final imageData = images[index];
                    final imageBytes = imageData['image'] as List<int>;
                    final image = Image.memory(Uint8List.fromList(imageBytes));

                    return GestureDetector(
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (context) {
                            return Dialog(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  image,
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.delete),
                                        onPressed: () {
                                          // Confirm delete image
                                          showDialog(
                                            context: context,
                                            builder: (context) {
                                              return AlertDialog(
                                                title:
                                                    const Text('Delete Image'),
                                                content: const Text(
                                                    'Are you sure you want to delete this image?'),
                                                actions: [
                                                  TextButton(
                                                    onPressed: () {
                                                      _deleteImage(
                                                          imageData['id']);
                                                      Navigator.of(context)
                                                          .pop(); // Close dialog
                                                      Navigator.of(context)
                                                          .pop(); // Close image dialog
                                                    },
                                                    child: const Text('Yes'),
                                                  ),
                                                  TextButton(
                                                    onPressed: () {
                                                      Navigator.of(context)
                                                          .pop(); // Close dialog
                                                    },
                                                    child: const Text('No'),
                                                  ),
                                                ],
                                              );
                                            },
                                          );
                                        },
                                      ),
                                      IconButton(
                                        icon: Icon(
                                          imageData['is_favorite'] == 1
                                              ? Icons.favorite
                                              : Icons.favorite_border,
                                          color: imageData['is_favorite'] == 1
                                              ? Colors.red
                                              : Colors.grey,
                                        ),
                                        onPressed: () {
                                          // Konfirmasi untuk menandai gambar sebagai favorit
                                          showDialog(
                                            context: context,
                                            builder: (context) {
                                              return AlertDialog(
                                                title: const Text(
                                                    'Favorit Gambar'),
                                                content: Text(
                                                  imageData['is_favorite'] == 1
                                                      ? 'Apakah Anda yakin ingin menghapus gambar ini dari favorit?'
                                                      : 'Apakah Anda yakin ingin menandai gambar ini sebagai favorit?',
                                                ),
                                                actions: [
                                                  TextButton(
                                                    onPressed: () async {
                                                      // Perbarui status favorit gambar
                                                      final isFavorite = imageData[
                                                              'is_favorite'] ==
                                                          1;
                                                      await DatabaseHelper
                                                          .instance
                                                          .updateFavoriteStatus(
                                                              imageData['id'],
                                                              !isFavorite);
                                                      await _loadImages(); // Refresh gallery untuk menampilkan status favorit yang diperbarui

                                                      // Menutup dialog
                                                      Navigator.of(context)
                                                          .pop(); // Tutup dialog konfirmasi
                                                      Navigator.of(context)
                                                          .pop(); // Tutup dialog gambar

                                                      // Menampilkan SnackBar setelah mengubah status favorit
                                                      ScaffoldMessenger.of(
                                                              context)
                                                          .showSnackBar(
                                                        SnackBar(
                                                          content: Row(
                                                            children: const [
                                                              Icon(
                                                                  Icons
                                                                      .check_circle,
                                                                  color: Colors
                                                                      .white),
                                                              SizedBox(
                                                                  width: 10),
                                                              Text(
                                                                'Status favorit berhasil diperbarui!',
                                                                style: TextStyle(
                                                                    color: Colors
                                                                        .white),
                                                              ),
                                                            ],
                                                          ),
                                                          backgroundColor:
                                                              Colors.green,
                                                          behavior:
                                                              SnackBarBehavior
                                                                  .floating,
                                                          shape:
                                                              RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        8),
                                                          ),
                                                          duration:
                                                              const Duration(
                                                                  seconds: 3),
                                                        ),
                                                      );
                                                    },
                                                    child: const Text('Ya'),
                                                  ),
                                                  TextButton(
                                                    onPressed: () {
                                                      Navigator.of(context)
                                                          .pop(); // Tutup dialog konfirmasi tanpa perubahan
                                                    },
                                                    child: const Text('Tidak'),
                                                  ),
                                                ],
                                              );
                                            },
                                          );
                                        },
                                      )
                                    ],
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      },
                      child: Stack(
                        children: [
                          Card(
                            clipBehavior: Clip.antiAlias,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Image.memory(
                              Uint8List.fromList(imageBytes),
                              fit: BoxFit
                                  .cover, // Ensures the image takes up full size in the card
                              width: double.infinity,
                              height: double.infinity,
                            ),
                          ),
                          if (imageData['is_favorite'] ==
                              1) // Check if the image is marked as favorite
                            Positioned(
                              top: 8,
                              right: 8,
                              child: GestureDetector(
                                onTap: () async {
                                  final isFavorite =
                                      imageData['is_favorite'] == 1;
                                  await DatabaseHelper.instance
                                      .updateFavoriteStatus(
                                          imageData['id'], !isFavorite);
                                  _loadImages();
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(isFavorite
                                          ? 'Removed from favorites!'
                                          : 'Added to favorites!'),
                                      duration: const Duration(seconds: 2),
                                    ),
                                  );
                                },
                                child: Icon(
                                  Icons.favorite,
                                  color: Colors.red,
                                  size: 30,
                                ),
                              ),
                            ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            );
          }).toList(),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation
          .endFloat, // Positioned at the bottom-right
      floatingActionButton: FloatingActionButton(
        onPressed: _pickImage,
        child: const Icon(Icons.add),
      ),
    );
  }
}
