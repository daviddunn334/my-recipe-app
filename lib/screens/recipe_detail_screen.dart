import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_theme.dart';
import '../services/supabase_service.dart';

class RecipeDetailScreen extends StatelessWidget {
  final Map<String, dynamic> recipe;

  const RecipeDetailScreen({
    super.key,
    required this.recipe,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(recipe['title'] ?? 'Recipe Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              context.push('/recipe/${recipe['id']}/edit', extra: recipe);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Recipe Image (if available)
            if (recipe['photo_url'] != null)
              Container(
                width: double.infinity,
                height: 200,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: NetworkImage(recipe['photo_url']),
                    fit: BoxFit.cover,
                  ),
                ),
              ),

            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    recipe['title'] ?? 'Untitled Recipe',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: AppTheme.largeTitleTextColor,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 16),

                  // Categories
                  if (recipe['category'] != null && (recipe['category'] as List).isNotEmpty)
                    Wrap(
                      spacing: 8,
                      children: (recipe['category'] as List).map<Widget>((category) {
                        return Chip(
                          label: Text(category.toString()),
                          backgroundColor: AppTheme.accentColor1.withOpacity(0.2),
                          labelStyle: TextStyle(color: AppTheme.accentColor1),
                        );
                      }).toList(),
                    ),
                  const SizedBox(height: 16),

                  // Description
                  if (recipe['description'] != null) ...[
                    Text(
                      'Description',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      recipe['description'],
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Ingredients
                  if (recipe['ingredients'] != null && (recipe['ingredients'] as List).isNotEmpty) ...[
                    Text(
                      'Ingredients',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 8),
                    ...(recipe['ingredients'] as List).map<Widget>((ingredient) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Row(
                          children: [
                            const Icon(Icons.circle, size: 8),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                ingredient.toString(),
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                    const SizedBox(height: 24),
                  ],

                  // Steps
                  if (recipe['steps'] != null && (recipe['steps'] as List).isNotEmpty) ...[
                    Text(
                      'Steps',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 8),
                    ...(recipe['steps'] as List).asMap().entries.map<Widget>((entry) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                color: AppTheme.accentColor1,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Center(
                                child: Text(
                                  '${entry.key + 1}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                entry.value.toString(),
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
} 