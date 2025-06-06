import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:io';

class SupabaseService {
  static SupabaseClient get client => Supabase.instance.client;

  static Future<void> initialize() async {
    await Supabase.initialize(
      url: 'https://qqhkaxopgiqiwtayesbf.supabase.co',
      anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InFxaGtheG9wZ2lxaXd0YXllc2JmIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDkyMzUxMjksImV4cCI6MjA2NDgxMTEyOX0.Fz46cE0g_YODhRaWH2cW6wF7rwbs0dgVhN2drRf36hY',
    );
  }

  // Authentication methods
  Future<AuthResponse> signUp({
    required String email,
    required String password,
  }) async {
    return await client.auth.signUp(
      email: email,
      password: password,
    );
  }

  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    return await client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  Future<void> signOut() async {
    await client.auth.signOut();
  }

  Future<void> resetPassword(String email) async {
    await client.auth.resetPasswordForEmail(email);
  }

  // Recipe methods
  Future<List<Map<String, dynamic>>> getRecipes() async {
    final response = await client
        .from('recipes')
        .select()
        .order('created_at', ascending: false);
    return List<Map<String, dynamic>>.from(response);
  }

  Future<Map<String, dynamic>> createRecipe(Map<String, dynamic> recipeData) async {
    try {
      final user = client.auth.currentUser;
      if (user == null) throw 'User not authenticated';

      final response = await client
          .from('recipes')
          .insert({
            'title': recipeData['title'],
            'description': recipeData['description'],
            'ingredients': recipeData['ingredients'],
            'steps': recipeData['steps'],
            'tags': recipeData['tags'],
            'photo_url': recipeData['photo_url'],
            'user_id': user.id,
          })
          .select()
          .single();

      return response;
    } catch (e) {
      throw 'Failed to create recipe: $e';
    }
  }

  Future<void> deleteRecipe(String recipeId) async {
    try {
      final user = client.auth.currentUser;
      if (user == null) throw 'User not authenticated';

      // First verify that the recipe belongs to the current user
      final recipe = await client
          .from('recipes')
          .select()
          .eq('id', recipeId)
          .single();

      if (recipe['user_id'] != user.id) {
        throw 'You can only delete your own recipes';
      }

      // Delete the recipe
      await client
          .from('recipes')
          .delete()
          .eq('id', recipeId);

    } catch (e) {
      throw 'Failed to delete recipe: $e';
    }
  }

  Future<void> updateRecipe(String recipeId, Map<String, dynamic> recipeData) async {
    try {
      final user = client.auth.currentUser;
      if (user == null) throw 'User not authenticated';

      // First verify that the recipe belongs to the current user
      final recipe = await client
          .from('recipes')
          .select()
          .eq('id', recipeId)
          .single();

      if (recipe['user_id'] != user.id) {
        throw 'You can only edit your own recipes';
      }

      // Update the recipe
      await client
          .from('recipes')
          .update({
            'title': recipeData['title'],
            'description': recipeData['description'],
            'ingredients': recipeData['ingredients'],
            'steps': recipeData['steps'],
            'category': recipeData['category'],
            'photo_url': recipeData['photo_url'],
          })
          .eq('id', recipeId);

    } catch (e) {
      throw 'Failed to update recipe: $e';
    }
  }

  Future<String> uploadRecipePhoto(String recipeId, String localFilePath) async {
    final user = client.auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    final file = File(localFilePath);
    final fileExt = localFilePath.split('.').last;
    final fileName = '${DateTime.now().millisecondsSinceEpoch}.$fileExt';
    final filePath = '${user.id}/$fileName';

    try {
      await client.storage
          .from('recipe-photos')
          .upload(filePath, file);

      final photoUrl = client.storage
          .from('recipe-photos')
          .getPublicUrl(filePath);

      return photoUrl;
    } catch (e) {
      throw Exception('Failed to upload photo: $e');
    }
  }

  Future<void> deleteRecipePhoto(String photoUrl) async {
    try {
      // Extract the file path from the URL
      final uri = Uri.parse(photoUrl);
      final pathSegments = uri.pathSegments;
      final filePath = pathSegments.sublist(2).join('/');

      await client.storage
          .from('recipe-photos')
          .remove([filePath]);
    } catch (e) {
      throw Exception('Failed to delete photo: $e');
    }
  }
} 