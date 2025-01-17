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

  @override
  void initState() {
    super.initState();
    _loadImages();
  }

  Future<void> _loadImages() async {
    final images = await DatabaseHelper.instance.getAllImages();
    setState(() {
      _imageFileList = images;
    });
  }

  Future<void> _pickImage() async {
    final pickedFiles = await _picker.pickMultiImage();

    if (pickedFiles != null && pickedFiles.isNotEmpty) {
      for (var pickedFile in pickedFiles) {
        final imageFile = File(pickedFile.path);
        final date = DateTime.now();

        // Simpan gambar ke database
        await DatabaseHelper.instance.insertImage(imageFile, date);

        // Load gambar terbaru dari database
        _loadImages();
      }
    }
  }

  Future<void> _deleteImage(int id) async {
    await DatabaseHelper.instance.deleteImage(id);

    // Load gambar terbaru setelah penghapusan
    _loadImages();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gallery'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _pickImage,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
          ),
          itemCount: _imageFileList.length,
          itemBuilder: (context, index) {
            final imageData = _imageFileList[index];
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
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              'Added on: ${imageData['date']}',
                              style: const TextStyle(fontSize: 14),
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              // Konfirmasi hapus gambar
                              showDialog(
                                context: context,
                                builder: (context) {
                                  return AlertDialog(
                                    title: const Text('Delete Image'),
                                    content: const Text('Are you sure you want to delete this image?'),
                                    actions: [
                                      TextButton(
                                        onPressed: () {
                                          // Hapus gambar jika ya
                                          _deleteImage(imageData['id']);
                                          Navigator.of(context).pop(); // Tutup dialog
                                          Navigator.of(context).pop(); // Tutup dialog gambar
                                        },
                                        child: const Text('Yes'),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          Navigator.of(context).pop(); // Tutup dialog
                                        },
                                        child: const Text('No'),
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                            child: const Text('Delete'),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
              child: Container(
                color: Colors.grey[300],
                child: image,
              ),
            );
          },
        ),
      ),
    );
  }
}