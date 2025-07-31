import 'package:flutter/material.dart';
import 'recipe_list_page.dart';
import 'favorites_page.dart';
import 'notes_page.dart';
import 'search_page.dart';

void main() {
  runApp(KitchenMasalaRecipeApp());
}

class KitchenMasalaRecipeApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Masala Kitchen Recipe',
      themeMode: ThemeMode.system,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepOrange,
          brightness: Brightness.dark,
        ),
      ),
      home: HomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  // Define the pages (only their content, no Scaffold or AppBar here)
  final List<Widget> _pages = [
    CuisineHome(), // Now this should NOT have its own Scaffold or AppBar
    FavoritesPage(), // Now this should NOT have its own Scaffold or AppBar
    NotesPage(), // Now this should NOT have its own Scaffold or AppBar
    SearchPage(), // Now this should NOT have its own Scaffold or AppBar
  ];

  // Titles for each navigation bar item
  final List<String> _pageTitles = const [
    'Masala Kitchen Recipe',
    'Favorites',
    'Notes',
    'Search Recipes',
  ];

  void _onNavTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_pageTitles[_selectedIndex]), // Dynamically change title
        centerTitle: true,
      ),
      body: _pages[_selectedIndex], // Display the selected page's content
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onNavTapped,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.restaurant_menu),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'Favorites',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.note_alt),
            label: 'Notes',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Search',
          ),
        ],
      ),
    );
  }
}

// Renamed from CuisineHomeContent and removed its Scaffold/AppBar
class CuisineHome extends StatelessWidget {
  final List<Map<String, dynamic>> cuisines = [
    {'name': 'Pakistani', 'emoji': '🇵🇰'},
    {'name': 'South Asian', 'emoji': '🍛'}, // Changed name and emoji
    {'name': 'Arabic', 'emoji': '🇸🇦'},
    {'name': 'Chinese', 'emoji': '🇨🇳'},
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Text(
            'Explore Authentic Recipes',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 20),

          // 🍨 Desserts Button (with bottom sheet)
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              minimumSize: Size.fromHeight(60),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              backgroundColor:
                  Theme.of(context).colorScheme.secondaryContainer,
            ),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                builder: (context) {
                  return Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ListTile(
                          leading: const Text('🍰', style: TextStyle(fontSize: 28)),
                          title: const Text('Desserts - Western'),
                          onTap: () {
                            Navigator.pop(context);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => RecipeListPage(cuisine: 'Western Desserts'),
                              ),
                            );
                          },
                        ),
                        ListTile(
                          leading: const Text('🍮', style: TextStyle(fontSize: 28)),
                          title: const Text('Desserts - Middle Eastern'),
                          onTap: () {
                            Navigator.pop(context);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => RecipeListPage(cuisine: 'Arabic Desserts'),
                              ),
                            );
                          },
                        ),
                        ListTile(
                          leading: const Text('🍡', style: TextStyle(fontSize: 28)),
                          title: const Text('Desserts - Asian'),
                          onTap: () {
                            Navigator.pop(context);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => RecipeListPage(cuisine: 'Asian Desserts'),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  );
                },
              );
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Text('🍨', style: TextStyle(fontSize: 32)),
                SizedBox(width: 12),
                Text(
                  'Desserts',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Cuisine Grid
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            children: cuisines.map((cuisine) {
              return ElevatedButton(
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: const EdgeInsets.all(16),
                  backgroundColor:
                      Theme.of(context).colorScheme.primaryContainer,
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          RecipeListPage(cuisine: cuisine['name']!),
                    ),
                  );
                },
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      cuisine['emoji']!,
                      style: const TextStyle(fontSize: 36),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      cuisine['name']!,
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}