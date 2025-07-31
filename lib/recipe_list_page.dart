import 'package:flutter/material.dart';
import 'recipe_detail_page.dart';

// Import all recipe name lists
import 'recipes/pakistani_recipes.dart';
import 'recipes/south_asian_recipes.dart';
import 'recipes/arabic_recipes.dart';
import 'recipes/chinese_recipes.dart';

// Import all dessert name lists (e.g., arabic.dart exports arabicDessertNames)
import 'desserts/arabic.dart'; // Holds arabicDessertNames
import 'desserts/asian.dart';   // Holds asianDessertNames
import 'desserts/western.dart'; // Holds westernDessertNames

// Import all detailed recipe lists (assuming these exist and export List<Map<String, dynamic>>)
import 'recipes/arabic_recipe_details.dart';   // Assumed to export arabicRecipeDetails
import 'recipes/south_asian_recipe_details.dart';   // Assumed to export south_asianRecipeDetails
import 'recipes/pakistani_recipe_details.dart';// Assumed to export pakistaniRecipeDetails
import 'recipes/chinese_recipe_details.dart';  // Assumed to export chineseRecipeDetails

// Import all detailed dessert recipe lists from the _details.dart files
import 'desserts/arabic_details.dart';   // Exports 'arabicDessertRecipes'
import 'desserts/asian_details.dart';    // Exports 'asianDessertDetails'
import 'desserts/western_details.dart';  // Exports 'westernDessertDetails'


class RecipeListPage extends StatelessWidget {
  final String cuisine;

  const RecipeListPage({super.key, required this.cuisine});

  List<String> getRecipeNames() {
    switch (cuisine) {
      case 'Pakistani':
        return pakistaniRecipes;
      case 'South Asian':
        return south_asianRecipes;
      case 'Arabic':
        return arabicRecipes;
      case 'Chinese':
        return chineseRecipes; // Assuming this is your list of Chinese recipe names
      case 'Arabic Desserts':
        return arabicDessertNames;
      case 'Asian Desserts':
        return asianDessertNames;
      case 'Western Desserts':
        return westernDessertNames;
      default:
        return [];
    }
  }

  // Function to find the full recipe details based on name and cuisine
  Map<String, dynamic>? _getRecipeDetails(String recipeName, String selectedCuisine) {
    List<Map<String, dynamic>>? sourceList;

    switch (selectedCuisine) {
      case 'Arabic':
        sourceList = arabicRecipeDetails;
        break;
      case 'South Asian':
        sourceList = south_asianRecipeDetails;
        break;
      case 'Pakistani':
        sourceList = pakistaniRecipeDetails;
        break;
      case 'Chinese':
        sourceList = chineseRecipeDetails; // Make sure this is the correct Chinese recipe details variable
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
        return null;
    }

    return sourceList?.firstWhere(
      (recipeMap) => recipeMap['name'] == recipeName,
      orElse: () => <String, dynamic>{},
    );
  }


  @override
  Widget build(BuildContext context) {
    final List<String> cuisineRecipes = getRecipeNames();

    return Scaffold(
      appBar: AppBar(
        title: Text('$cuisine Recipes'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: GridView.count(
          crossAxisCount: 3,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          children: cuisineRecipes.map((recipeName) {
            return InkWell(
              borderRadius: BorderRadius.circular(15),
              onTap: () {
                final recipeData = _getRecipeDetails(recipeName, cuisine);

                if (recipeData != null && recipeData.isNotEmpty) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => RecipeDetailPage(
                        cuisine: cuisine, // Pass cuisine
                        recipeName: recipeName, // Pass recipe name
                        recipeData: recipeData, // Pass the full data
                      ),
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Recipe details not found for $recipeName')),
                  );
                }
              },
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                color: Theme.of(context).colorScheme.primaryContainer,
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      recipeName,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}