import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert'; // Required for jsonEncode and jsonDecode

// Import all detailed recipe/dessert lists to find recipe data
import 'recipes/pakistani_recipe_details.dart';
import 'recipes/south_asian_recipe_details.dart';
import 'recipes/arabic_recipe_details.dart';
import 'recipes/chinese_recipe_details.dart'; // Ensure this matches your Chinese details file
import 'desserts/arabic_details.dart';
import 'desserts/asian_details.dart';
import 'desserts/western_details.dart';

class RecipeDetailPage extends StatefulWidget {
  final String? cuisine; // Made nullable to handle cases where recipeData is passed directly
  final String recipeName;
  final Map<String, dynamic>? recipeData; // New optional parameter

  const RecipeDetailPage({
    super.key,
    this.cuisine,
    required this.recipeName, // THIS IS REQUIRED
    this.recipeData, // Add to constructor
  });

  @override
  State<RecipeDetailPage> createState() => _RecipeDetailPageState();
}

class _RecipeDetailPageState extends State<RecipeDetailPage> {
  Map<String, dynamic>? _currentRecipe; // To store the found recipe
  bool _isFavorite = false; // New state variable for favorite status

  @override
  void initState() {
    super.initState();
    if (widget.recipeData != null && widget.recipeData!.isNotEmpty) {
      _currentRecipe = widget.recipeData;
      _checkIfFavorite();
    } else {
      _loadRecipeDetails(); // Only load if recipeData wasn't provided
    }
  }

  void _loadRecipeDetails() {
    if (widget.cuisine == null || widget.cuisine == 'User-Added') {
      // If cuisine is null or 'User-Added' and recipeData wasn't provided,
      // it means we don't have a lookup source in the predefined lists.
      // This should ideally not be hit if recipeData is always passed for User-Added.
      print('Warning: Attempted to load recipe details with null or User-Added cuisine without recipeData.');
      setState(() {
        _currentRecipe = {}; // Set to empty to indicate not found or not a lookup type
      });
      return;
    }

    List<Map<String, dynamic>>? sourceList;
    switch (widget.cuisine!) {
      case 'Pakistani':
        sourceList = pakistaniRecipeDetails;
        break;
      case 'South_Asian':
        sourceList = south_asianRecipeDetails;
        break;
      case 'Arabic':
        sourceList = arabicRecipeDetails;
        break;
      case 'Chinese':
        sourceList = chineseRecipeDetails;
        break;
      case 'Arabic Desserts':
        sourceList = arabicDessertRecipes;
        break;
      case 'Asian Desserts':
        sourceList = asianDessertDetails;
        break;
      case 'Western Desserts':
        sourceList = westernDessertDetails;
        break;
      default:
        sourceList = [];
    }

    setState(() {
      _currentRecipe = sourceList?.firstWhere(
        (recipe) => recipe['name'] == widget.recipeName,
        orElse: () => <String, dynamic>{},
      );
      _checkIfFavorite();
    });
  }

  Future<void> _checkIfFavorite() async {
    if (_currentRecipe == null || _currentRecipe!.isEmpty) return;

    final prefs = await SharedPreferences.getInstance();
    List<String> favorites = prefs.getStringList('favoriteRecipes') ?? [];
    setState(() {
      _isFavorite = favorites.contains(widget.recipeName);
    });
  }

  Future<void> _toggleFavorite() async {
    if (_currentRecipe == null || _currentRecipe!.isEmpty) return;

    final prefs = await SharedPreferences.getInstance();
    List<String> favorites = prefs.getStringList('favoriteRecipes') ?? [];

    setState(() {
      if (_isFavorite) {
        favorites.remove(widget.recipeName);
      } else {
        favorites.add(widget.recipeName);
      }
      _isFavorite = !_isFavorite;
    });
    await prefs.setStringList('favoriteRecipes', favorites);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _isFavorite
              ? '${widget.recipeName} added to favorites!'
              : '${widget.recipeName} removed from favorites!',
        ),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_currentRecipe == null || _currentRecipe!.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Recipe Not Found')),
        body: const Center(child: Text('Recipe details could not be loaded or found.')),
      );
    }

    final recipeName = _currentRecipe!['name'] as String? ?? 'Unknown Recipe';
    final imageUrl = _currentRecipe!['imageUrl'] as String? ?? '';
    final yields = _currentRecipe!['yields'] as String? ?? 'N/A';
    final time = _currentRecipe!['timeRequired'] as String? ?? _currentRecipe!['time'] as String? ?? 'N/A';

    final dynamic rawIngredients = _currentRecipe!['ingredients'];
    final Map<String, dynamic> ingredients = (rawIngredients is Map)
        ? Map<String, dynamic>.from(rawIngredients)
        : {};

    final instructions = _currentRecipe!['instructions'] as String? ?? 'No instructions provided.';
    final halalConsiderations = _currentRecipe!['halalConsiderations'] as String? ?? 'No specific halal considerations mentioned.';

    return Scaffold(
      appBar: AppBar(
        title: Text(recipeName),
        actions: [
          if (widget.cuisine != 'User-Added') // Only show favorite for pre-defined recipes
            IconButton(
              icon: Icon(
                _isFavorite ? Icons.favorite : Icons.favorite_border,
                color: _isFavorite ? Colors.red : null,
              ),
              onPressed: _toggleFavorite,
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (imageUrl.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: 200,
                  errorBuilder: (context, error, stackTrace) => Container(
                    height: 200,
                    color: Colors.grey[200],
                    child: const Icon(Icons.broken_image, size: 50, color: Colors.grey),
                  ),
                ),
              ),
            const SizedBox(height: 16),
            Text(
              recipeName,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),

            // --- START OF MODIFICATION TO HIDE YIELDS/TIME FOR USER-ADDED ---
            if (widget.cuisine != 'User-Added') // Only display this section if NOT a user-added recipe
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.people_alt, color: Theme.of(context).colorScheme.primary),
                      const SizedBox(width: 4),
                      Text('Yields: $yields'),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.access_time, color: Theme.of(context).colorScheme.primary),
                      const SizedBox(width: 4),
                      Text('Time: $time'),
                    ],
                  ),
                  const SizedBox(height: 16), // Add spacing after this section
                ],
              ),
            // --- END OF MODIFICATION ---

            if (ingredients.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Ingredients:',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: ingredients.entries.map((entry) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 4.0),
                        child: Text('• ${entry.key}: ${entry.value}'),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                ],
              ),

            Text(
              'Instructions:',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(instructions),
            const SizedBox(height: 16),
            Text(
              'Halal Considerations:',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(halalConsiderations),
          ],
        ),
      ),
    );
  }
}