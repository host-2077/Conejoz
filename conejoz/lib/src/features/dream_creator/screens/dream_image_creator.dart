import 'package:conejoz/src/repository/authentication_repository/authentication_repository.dart';
import 'package:conejoz/src/repository/user_repository/user_repository.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:loading_indicator/loading_indicator.dart';

class ImageCreator extends StatefulWidget {
  const ImageCreator({Key? key});

  @override
  _ImageCreatorState createState() => _ImageCreatorState();
}

class _ImageCreatorState extends State<ImageCreator> {
  final TextEditingController _textEditingController = TextEditingController();

  String? _imageUrl;
  File? _imageFile;
  bool _isLoading = false;

  @override
  void dispose() {
    _textEditingController.dispose();
    super.dispose();
  }

// This functions handles the image creation. Do not modify.
  Future<void> createImage(String text) async {
    final apiUrl = 'https://pyconejoz.onrender.com/process_text';

    setState(() {
      _isLoading =
          true; // Set the loading state to true when the request is being handled
    });

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        body: {'text': text},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final imageUrl = data['image_url'];

        if (imageUrl != null) {
          // Store the image file temporarily
          final imageFile = await getImageFileFromUrl(imageUrl);
          setState(() {
            _imageUrl = imageUrl;
            _imageFile = imageFile;
          });
        }
      } else {
        print('API request failed with status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error during API request: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<String?> uploadImageToFirebase(
      File imageFile, String imageName) async {
    try {
      final ref = firebase_storage.FirebaseStorage.instance
          .ref()
          .child('DREAM_PICTURES')
          .child(imageName);
      final uploadTask = ref.putFile(imageFile);
      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      print('Error uploading image to Firebase Storage: $e');
      return null;
    }
  }

  Future<File> getImageFileFromUrl(String imageUrl) async {
    final response = await http.get(Uri.parse(imageUrl));
    final tempDir = await getTemporaryDirectory();
    final tempFile = File('${tempDir.path}/dream_image_temp.jpg');
    await tempFile.writeAsBytes(response.bodyBytes);
    return tempFile;
  }

  Future<void> saveData() async {
    if (_imageUrl != null && _imageFile == null) {
      final imageFile = await getImageFileFromUrl(_imageUrl!);
      setState(() {
        _imageFile = imageFile;
      });
    }
    if (_imageFile != null) {
      final imageName =
          'dream_image_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final downloadUrl = await uploadImageToFirebase(_imageFile!, imageName);
      if (downloadUrl != null) {
        final user = AuthenticationRepository.instance.firebaseUser.value;
        if (user != null) {
          final userId = user.uid;
          await UserRepository.instance
              .addImageToUserGallery(userId, downloadUrl);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Add a callback to the WidgetsBinding to call the saveData function after the frame has been rendered.
    WidgetsBinding.instance?.addPostFrameCallback((_) {
      saveData();
    });
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: const Text("New Note Test"),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              const SizedBox(height: 16),
              SizedBox(
                height: 225,
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      if (_imageUrl != null)
                        Image(
                          image: _imageFile != null
                              ? FileImage(_imageFile!)
                              : NetworkImage(_imageUrl!)
                                  as ImageProvider<Object>,
                          fit: BoxFit.fitWidth,
                        ),
                      if (_imageUrl == null && _isLoading)
                        const Center(
                            child: LoadingIndicator(
                          indicatorType: Indicator.ballClipRotateMultiple,
                          colors: [Colors.grey],
                          strokeWidth: 2,
                          backgroundColor: Colors.transparent,
                          pathBackgroundColor: Colors.indigoAccent,
                        )),
                    ],
                  ),
                ),
              ),
              TextField(
                controller: _textEditingController,
                decoration: const InputDecoration(
                  hintText: 'Write the prompt here.',
                  border: InputBorder.none,
                ),
                maxLines: null,
              ),
              const SizedBox(
                height: 16,
              ),
            ],
          ),
        ),
        floatingActionButton: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            FloatingActionButton(
              onPressed: () {
                createImage(_textEditingController.text);
              },
              child: const Icon(Icons.android),
            ),
            const SizedBox(height: 16),
          ],
        ));
  }
}