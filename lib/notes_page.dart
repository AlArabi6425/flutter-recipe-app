import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert'; // Required for jsonEncode and jsonDecode

import 'recipe_detail_page.dart'; // Reuse RecipeDetailPage to display user-added recipes

class NotesPage extends StatefulWidget {
  const NotesPage({super.key});

  @override
  State<NotesPage> createState() => _NotesPageState();
}

class _NotesPageState extends State<NotesPage> {
  List<Map<String, String>> _userRecipes = [];
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>(); // Key for form validation

  @override
  void initState() {
    super.initState();
    _loadUserRecipes();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _loadUserRecipes() async {
    final prefs = await SharedPreferences.getInstance();
    final String? recipesString = prefs.getString('user_recipes');
    if (recipesString != null && recipesString.isNotEmpty) {
      final List<dynamic> decodedList = jsonDecode(recipesString);
      setState(() {
        _userRecipes = decodedList.map((item) => Map<String, String>.from(item)).toList();
      });
    } else {
      setState(() {
        _userRecipes = [];
      });
    }
  }

  Future<void> _saveUserRecipes() async {
    final prefs = await SharedPreferences.getInstance();
    final String encodedList = jsonEncode(_userRecipes);
    await prefs.setString('user_recipes', encodedList);
  }

  Future<void> _addOrEditRecipe({int? index, Map<String, String>? existingRecipe}) async {
    _titleController.text = existingRecipe?['title'] ?? '';
    _contentController.text = existingRecipe?['content'] ?? '';

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(existingRecipe == null ? 'Add New Recipe' : 'Edit Recipe'),
          content: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: _titleController,
                    decoration: const InputDecoration(labelText: 'Recipe Title'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Title cannot be empty';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _contentController,
                    decoration: const InputDecoration(labelText: 'Recipe Content'),
                    maxLines: null, // Allows multiple lines for content
                    keyboardType: TextInputType.multiline,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Content cannot be empty';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              child: const Text('Save'),
              onPressed: () {
                if (_formKey.currentState?.validate() ?? false) {
                  final newRecipe = {
                    'title': _titleController.text.trim(),
                    'content': _contentController.text.trim(),
                  };
                  setState(() {
                    if (index == null) {
                      _userRecipes.add(newRecipe);
                    } else {
                      _userRecipes[index] = newRecipe;
                    }
                  });
                  _saveUserRecipes();
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );

    // Clear controllers after dialog closes
    _titleController.clear();
    _contentController.clear();
  }

  Future<void> _deleteRecipe(int index) async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Recipe'),
          content: Text('Are you sure you want to delete "${_userRecipes[index]['title']}"?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop(false);
              },
            ),
            ElevatedButton(
              child: const Text('Delete'),
              onPressed: () {
                Navigator.of(context).pop(true);
              },
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      setState(() {
        _userRecipes.removeAt(index);
      });
      _saveUserRecipes();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Recipe deleted!'), duration: Duration(seconds: 1)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Recipes'),
        centerTitle: true,
      ),
      body: _userRecipes.isEmpty
          ? const Center(
              child: Text(
                'No recipes added yet. Click the + button to add your first recipe!',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            )
          : ListView.builder(
              itemCount: _userRecipes.length,
              itemBuilder: (context, index) {
                final recipe = _userRecipes[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ListTile(
                    title: Text(
                      recipe['title'] ?? 'Untitled Recipe',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      recipe['content'] ?? 'No content',
                      maxLines: 2, // Show a snippet of the content
                      overflow: TextOverflow.ellipsis,
                    ),
                    onTap: () {
                      // Navigate to RecipeDetailPage with user-added recipe data
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => RecipeDetailPage(
                            recipeName: recipe['title'] ?? 'Untitled Recipe',
                            // We pass cuisine as a dummy value or null as it's a user recipe
                            // RecipeDetailPage will prioritize recipeData if provided.
                            cuisine: 'User-Added', // A unique cuisine type for user recipes
                            recipeData: {
                              'name': recipe['title'],
                              'instructions': recipe['content'],
                              // Add other keys as needed for RecipeDetailPage to display them
                              // You might want to let the user add yields, time, ingredients etc.
                              // For now, only title and instructions are handled directly.
                              'yields': 'N/A',
                              'timeRequired': 'N/A',
                              'ingredients': {}, // Empty ingredients map
                              'halalConsiderations': 'User-added recipe',
                            },
                          ),
                        ),
                      );
                    },
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed: () => _addOrEditRecipe(index: index, existingRecipe: recipe),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _deleteRecipe(index),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addOrEditRecipe(), // Call without index to add new
        child: const Icon(Icons.add),
      ),
    );
  }
}