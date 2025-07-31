import 'package:flutter/material.dart';
import 'recipe_detail_page.dart';

// Import all recipe name lists
import 'recipes/arabic_recipes.dart';
import 'recipes/south_asian_recipes.dart';
import 'recipes/pakistani_recipes.dart';
import 'recipes/chinese_recipes.dart';

// Import all dessert name lists
import 'desserts/arabic.dart'; // This file is assumed to export 'arabicDessertNames'
import 'desserts/asian.dart';   // This file is assumed to export 'asianDessertNames'
import 'desserts/western.dart'; // This file is assumed to export 'westernDessertNames'

// Import all detailed recipe lists.
import 'recipes/arabic_recipe_details.dart'; // Assuming this holds detailed Arabic recipes data
import 'recipes/south_asian_recipe_details.dart'; // Assuming this holds detailed South Asian recipes data
import 'recipes/pakistani_recipe_details.dart'; // Assuming this holds detailed Pakistani recipes data
import 'recipes/chinese_recipe_details.dart'; // Assuming this holds detailed Chinese recipes data

// Assuming your dessert files (e.g., arabic.dart) export the detailed maps
// If not, ensure these import paths and variable names match your actual structure
import 'desserts/arabic_details.dart';   // Exports 'arabicDessertRecipes'
import 'desserts/asian_details.dart';    // Exports 'asianDessertDetails'
import 'desserts/western_details.dart';  // Exports 'westernDessertDetails'


class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  List<String> _searchResults = []; // Stores just the names for display

  // Combine all recipe names into one list for searching
  late final List<String> _allRecipeNames;

  @override
  void initState() {
    super.initState();
    _allRecipeNames = [
      ...pakistaniRecipes,
      ...south_asianRecipes,
      ...arabicRecipes,
      ...chineseRecipes, // Assuming this is your list of Chinese recipe names
      ...arabicDessertNames,
      ...asianDessertNames,
      ...westernDessertNames,
    ];
  }

  void _performSearch(String query) {
    setState(() {
      if (query.isEmpty) {
        _searchResults = [];
      } else {
        _searchResults = _allRecipeNames
            .where((recipeName) =>
                recipeName.toLowerCase().contains(query.trim().toLowerCase()))
            .toList();
      }
    });
  }

  // This function identifies the cuisine based on the recipe name list
  String _identifyCuisine(String recipeName) {
    if (pakistaniRecipes.contains(recipeName)) return 'Pakistani';
    if (south_asianRecipes.contains(recipeName)) return 'South Asian';
    if (arabicRecipes.contains(recipeName)) return 'Arabic';
    if (chineseRecipes.contains(recipeName)) return 'Chinese'; // Assuming this is your Chinese recipe names list
    if (arabicDessertNames.contains(recipeName)) return 'Arabic Desserts';
    if (asianDessertNames.contains(recipeName)) return 'Asian Desserts';
    if (westernDessertNames.contains(recipeName)) return 'Western Desserts';
    return 'Unknown'; // Fallback if not found in any list
  }

  // This function retrieves the detailed recipe data based on name and cuisine type
  Map<String, dynamic>? _getRecipeDetails(String recipeName, String cuisine) {
    List<Map<String, dynamic>>? detailsList;
    switch (cuisine) {
      case 'Pakistani':
        detailsList = pakistaniRecipeDetails;
        break;
      case 'South Asian':
        detailsList = south_asianRecipeDetails;
        break;
      case 'Arabic':
        detailsList = arabicRecipeDetails;
        break;
      case 'Chinese':
        detailsList = chineseRecipeDetails; // Ensure this is the correct Chinese details variable
        break;
      case 'Arabic Desserts':
        detailsList = arabicDessertRecipes;
        break;
      case 'Asian Desserts':
        detailsList = asianDessertDetails;
        break;
      case 'Western Desserts':
        detailsList = westernDessertDetails;
        break;
      default:
        return null;
    }
    return detailsList
        ?.firstWhere((recipe) => recipe['name'] == recipeName, orElse: () => {});
  }

  @override
  Widget build(BuildContext context) {
    // Removed Scaffold and AppBar here as main.dart manages it.
    return Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              onChanged: _performSearch,
              decoration: InputDecoration(
                labelText: 'Search recipes',
                hintText: 'e.g., Chicken Karahi, Gulab Jamun',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _searchResults.length,
              itemBuilder: (context, index) {
                final recipeName = _searchResults[index];
                final cuisine = _identifyCuisine(recipeName); // Identify cuisine for navigation
                // We're getting the recipeData here explicitly for clarity,
                // although RecipeDetailPage can also find it.
                final recipeData = _getRecipeDetails(recipeName, cuisine);

                return ListTile(
                  title: Text(recipeName),
                  subtitle: Text(cuisine),
                  onTap: () {
                    // Pass all necessary info to RecipeDetailPage
                    if (recipeData != null && recipeData.isNotEmpty) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => RecipeDetailPage(
                            cuisine: cuisine, // Pass cuisine
                            recipeName: recipeName, // Pass recipe name (REQUIRED)
                            recipeData: recipeData, // Pass the full recipe data map (Optional, but good for efficiency)
                          ),
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Recipe details not found for $recipeName')),
                      );
                    }
                  },
                );
              },
            ),
          ),
        ],
      );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}