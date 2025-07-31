import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Import all recipe/dessert details files to retrieve full recipe data
import 'recipes/pakistani_recipe_details.dart';
import 'recipes/south_asian_recipe_details.dart';
import 'recipes/arabic_recipe_details.dart';
import 'recipes/chinese_recipe_details.dart'; // Ensure this matches your Chinese details file
import 'desserts/arabic_details.dart';
import 'desserts/asian_details.dart';
import 'desserts/western_details.dart';

// Import your recipe detail page to navigate to it
import 'recipe_detail_page.dart';

// Also import your recipe name lists to help identify cuisine (if needed for _identifyCuisine)
import 'recipes/pakistani_recipes.dart';
import 'recipes/south_asian_recipes.dart';
import 'recipes/arabic_recipes.dart';
import 'recipes/chinese_recipes.dart';
import 'desserts/arabic.dart';
import 'desserts/asian.dart';
import 'desserts/western.dart';

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key});

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  List<String> _favoriteRecipeNames = []; // List to hold just the names of favorited recipes

  @override
  void initState() {
    super.initState();
    _loadFavorites(); // Load favorites when the page initializes
  }

  // Method to load favorites from SharedPreferences
  Future<void> _loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _favoriteRecipeNames = prefs.getStringList('favoriteRecipes') ?? [];
    });
  }

  // Helper function to find full recipe data and its original cuisine based on recipe name
  Map<String, dynamic>? _getRecipeDataAndCuisine(String recipeName) {
    final Map<String, List<Map<String, dynamic>>> allDetailsLists = {
      'Pakistani': pakistaniRecipeDetails,
      'South Asian': south_asianRecipeDetails,
      'Arabic': arabicRecipeDetails,
      'Chinese': chineseRecipeDetails, // Ensure this points to your Chinese recipe details
      'Arabic Desserts': arabicDessertRecipes,
      'Asian Desserts': asianDessertDetails,
      'Western Desserts': westernDessertDetails,
    };

    for (var entry in allDetailsLists.entries) {
      final cuisineType = entry.key;
      final detailsList = entry.value;
      // Find the recipe in the current details list
      final recipe = detailsList.firstWhere(
        (r) => r['name'] == recipeName,
        orElse: () => {}, // Return an empty map if not found in this list
      );
      if (recipe.isNotEmpty) {
        return {'recipeData': recipe, 'cuisine': cuisineType};
      }
    }
    return null; // Recipe not found across all lists
  }

  @override
  Widget build(BuildContext context) {
    // Removed Scaffold and AppBar here as main.dart manages them for the entire app.
    return _favoriteRecipeNames.isEmpty
        ? const Center(child: Text("No favorite recipes added yet."))
        : ListView.builder(
            itemCount: _favoriteRecipeNames.length,
            itemBuilder: (context, index) {
              final recipeName = _favoriteRecipeNames[index];
              // Get both recipe data and its original cuisine
              final dataAndCuisine = _getRecipeDataAndCuisine(recipeName);
              final Map<String, dynamic>? recipeData = dataAndCuisine?['recipeData'];
              final String? actualCuisine = dataAndCuisine?['cuisine'];

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  title: Text(recipeName),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () async {
                      // Remove from favorites and refresh the list
                      final prefs = await SharedPreferences.getInstance();
                      List<String> currentFavorites = prefs.getStringList('favoriteRecipes') ?? [];
                      currentFavorites.remove(recipeName);
                      await prefs.setStringList('favoriteRecipes', currentFavorites);
                      _loadFavorites(); // Reload the list to update UI
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('$recipeName removed from favorites!')),
                      );
                    },
                  ),
                  onTap: () {
                    if (recipeData != null && recipeData.isNotEmpty && actualCuisine != null) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => RecipeDetailPage(
                            cuisine: actualCuisine, // Pass the identified cuisine
                            recipeName: recipeName,
                            recipeData: recipeData, // Pass the full data
                          ),
                        ),
                      ).then((_) {
                        // Reload favorites when returning from detail page
                        // This ensures the list is up-to-date if a recipe was unfavorited from the detail page
                        _loadFavorites();
                      });
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Details not found for $recipeName')),
                      );
                    }
                  },
                ),
              );
            },
          );
  }
}