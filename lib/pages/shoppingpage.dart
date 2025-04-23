import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'DatabaseHelper.dart';
import 'package:navbar/colors/hexcolorhelper.dart';

class ArticleScreen extends StatefulWidget {
  @override
  _ArticleScreenState createState() => _ArticleScreenState();
}

class _ArticleScreenState extends State<ArticleScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  List<Map<String, dynamic>> _articles = [];

  // Controllers for input fields
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();

  // Image picker
  final ImagePicker _picker = ImagePicker();
  String? _imagePath;

  @override
  void initState() {
    super.initState();
    _loadArticles();
  }

  // Load articles from the database
  void _loadArticles() async {
    List<Map<String, dynamic>> articles = await _dbHelper.getArticles();
    setState(() {
      _articles = articles;
    });
  }

  // Add a new article
  void _addArticle() async {
    if (_nameController.text.isEmpty ||
        _descriptionController.text.isEmpty ||
        _priceController.text.isEmpty ||
        _imagePath == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill all fields and select an image')),
      );
      return;
    }

    Map<String, dynamic> newArticle = {
      'name': _nameController.text,
      'description': _descriptionController.text,
      'price': double.parse(_priceController.text),
      'imagePath': _imagePath,
    };
    await _dbHelper.insertArticle(newArticle);
    _loadArticles(); // Refresh the list

    // Clear input fields and reset image
    _resetDialog();
  }

  // Update an article
  void _updateArticle(int id) async {
    if (_nameController.text.isEmpty ||
        _descriptionController.text.isEmpty ||
        _priceController.text.isEmpty ||
        _imagePath == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill all fields and select an image')),
      );
      return;
    }

    Map<String, dynamic> updatedArticle = {
      'id': id,
      'name': _nameController.text,
      'description': _descriptionController.text,
      'price': double.parse(_priceController.text),
      'imagePath': _imagePath,
    };
    await _dbHelper.updateArticle(updatedArticle);
    _loadArticles(); // Refresh the list

    // Clear input fields and reset image
    _resetDialog();
  }

  // Delete an article
  void _deleteArticle(int id) async {
    await _dbHelper.deleteArticle(id);
    _loadArticles(); // Refresh the list
  }

  // Pick an image from the gallery or camera
  Future<void> _pickImage({required ImageSource source}) async {
    final XFile? image = await _picker.pickImage(source: source);
    if (image != null) {
      setState(() {
        _imagePath = image.path;
      });
    }
  }

  // Reset the dialog fields
  void _resetDialog() {
    _nameController.clear();
    _descriptionController.clear();
    _priceController.clear();
    setState(() {
      _imagePath = null;
    });
  }

  // Show a dialog for adding/updating an article
  void _showArticleDialog({Map<String, dynamic>? article}) {
    if (article != null) {
      _nameController.text = article['name'];
      _descriptionController.text = article['description'];
      _priceController.text = article['price'].toString();
      _imagePath = article['imagePath'];
    } else {
      _resetDialog(); // Reset the dialog when adding a new article
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(article == null ? 'Add Article' : 'Update Article'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _nameController,
                  decoration: InputDecoration(labelText: 'Name'),
                ),
                TextField(
                  controller: _descriptionController,
                  decoration: InputDecoration(labelText: 'Description'),
                ),
                TextField(
                  controller: _priceController,
                  decoration: InputDecoration(labelText: 'Price'),
                  keyboardType: TextInputType.number,
                ),
                SizedBox(height: 10),
                _imagePath != null
                    ? Image.file(File(_imagePath!)) // Display selected image
                    : Text('No image selected'),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: () => _pickImage(source: ImageSource.gallery),
                      child: Text('Gallery'),
                    ),
                    ElevatedButton(
                      onPressed: () => _pickImage(source: ImageSource.camera),
                      child: Text('Camera'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (article == null) {
                  _addArticle();
                } else {
                  _updateArticle(article['id']);
                }
                Navigator.of(context).pop();
              },
              child: Text(article == null ? 'Add' : 'Update'),
            ),
          ],
        );
      },
    );
  }
  BuildContext? _enlargedImageDialog;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: hexToColor('#656871'),
        title: Text('Online Shopping App'),
      ),
      body: ListView.builder(
        itemCount: _articles.length,
        itemBuilder: (context, index) {
          final article = _articles[index];
          return Dismissible(
            key: Key(article['id'].toString()),// Unique key for each item
            background: Container(
              color: Colors.green, // Background color for swipe-to-edit
              alignment: Alignment.centerLeft,
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Icon(Icons.edit, color: Colors.white),
            ),
            secondaryBackground: Container(
              color: Colors.red, // Background color for swipe-to-delete
              alignment: Alignment.centerRight,
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Icon(Icons.delete, color: Colors.white),
            ),
            confirmDismiss: (direction) async {
              if (direction == DismissDirection.startToEnd) {
                // Swipe to edit
                _showArticleDialog(article: article);
                return false; // Don't dismiss the item
              } else if (direction == DismissDirection.endToStart) {
                // Swipe to delete
                _deleteArticle(article['id']);
                return true; // Dismiss the item
              }
              return false;
            },
            child: GestureDetector(
              onLongPressStart: (details) {
                showDialog(
                  context: context,
                  barrierDismissible: false, // Prevent accidental dismissal
                  builder: (dialogContext) {
                    _enlargedImageDialog = dialogContext; // Store the dialog's context
                    return Dialog(
                      child: Image.file(File(article['imagePath']), fit: BoxFit.cover),
                    );
                  },
                );
              },
              onLongPressEnd: (details) {
                if (_enlargedImageDialog != null) {
                  Navigator.of(_enlargedImageDialog!).pop(); // Properly dismiss the dialog
                  _enlargedImageDialog = null; // Reset the variable
                }
              },
              child: ListTile(
                leading: article['imagePath'] != null
                    ? Image.file(File(article['imagePath']), width: 50, height: 50, fit: BoxFit.cover)
                    : Icon(Icons.image),
                title: Text(article['name']),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(article['description']),
                    Text('\$${article['price'].toString()}'),
                  ],
                ),
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showArticleDialog(),
        child: Icon(Icons.add),
      ),
    );
  }
}