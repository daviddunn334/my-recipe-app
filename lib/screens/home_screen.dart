import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../services/supabase_service.dart';
import '../theme/app_theme.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Map<String, dynamic>>? _recipes;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadRecipes();
  }

  Future<void> _loadRecipes() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final recipes = await SupabaseService().getRecipes();
      if (mounted) {
        setState(() {
          _recipes = recipes;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Recipes'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _recipes?.isEmpty == true
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'No recipes yet',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              color: AppTheme.largeTitleTextColor,
                            ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => context.go('/create-recipe'),
                        child: const Text('Create Your First Recipe'),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _recipes?.length ?? 0,
                  itemBuilder: (context, index) {
                    final recipe = _recipes?[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.2),
                              spreadRadius: 2,
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          title: Text(
                            recipe?['title'] ?? 'Untitled Recipe',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          subtitle: Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              recipe?['description'] ?? 'No description',
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 14,
                              ),
                            ),
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _showDeleteConfirmation(recipe?['id'] ?? ''),
                          ),
                          onTap: () {
                            if (recipe != null) {
                              context.push('/recipe/${recipe['id']}', extra: recipe);
                            }
                          },
                        ),
                      ),
                    );
                  },
                ),
    );
  }

  Future<void> _showDeleteConfirmation(String recipeId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Recipe'),
        content: const Text('Are you sure you want to delete this recipe? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await SupabaseService().deleteRecipe(recipeId);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Recipe deleted successfully')),
          );
          // Refresh the recipes list
          setState(() {
            _recipes = null;
          });
          _loadRecipes();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(e.toString())),
          );
        }
      }
    }
  }
} 