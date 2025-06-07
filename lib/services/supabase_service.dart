import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;

class SupabaseService {
  static SupabaseClient get client => Supabase.instance.client;

  static Future<void> initialize() async {
    try {
      await Supabase.initialize(
        url: 'https://qqhkaxopgiqiwtayesbf.supabase.co',
        anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InFxaGtheG9wZ2lxaXd0YXllc2JmIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDkyMzUxMjksImV4cCI6MjA2NDgxMTEyOX0.Fz46cE0g_YODhRaWH2cW6wF7rwbs0dgVhN2drRf36hY',
      );
    } catch (e) {
      print('Error initializing Supabase: $e');
      // Continue without Supabase for web demo
    }
  }

  // Authentication methods
  Future<AuthResponse> signUp({
    required String email,
    required String password,
  }) async {
    try {
      return await client.auth.signUp(
        email: email,
        password: password,
      );
    } catch (e) {
      print('Error signing up: $e');
      // For web demo, simulate successful signup
      if (kIsWeb) {
        // Create a mock session for web demo
        final mockUser = User(
          id: 'mock-user-id',
          appMetadata: {},
          userMetadata: {},
          aud: 'authenticated',
          createdAt: DateTime.now().toIso8601String(),
        );
        
        return AuthResponse(
          session: Session(
            accessToken: 'mock-token',
            tokenType: 'bearer',
            user: mockUser,
            expiresIn: 3600,
            refreshToken: 'mock-refresh-token',
          ),
          user: mockUser,
        );
      } else {
        rethrow;
      }
    }
  }

  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    try {
      return await client.auth.signInWithPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      print('Error signing in: $e');
      // For web demo, simulate successful login
      if (kIsWeb) {
        // Create a mock session for web demo
        final mockUser = User(
          id: 'mock-user-id',
          appMetadata: {},
          userMetadata: {},
          aud: 'authenticated',
          createdAt: DateTime.now().toIso8601String(),
        );
        
        return AuthResponse(
          session: Session(
            accessToken: 'mock-token',
            tokenType: 'bearer',
            user: mockUser,
            expiresIn: 3600,
            refreshToken: 'mock-refresh-token',
          ),
          user: mockUser,
        );
      } else {
        rethrow;
      }
    }
  }

  Future<void> signOut() async {
    await client.auth.signOut();
  }

  Future<void> resetPassword(String email) async {
    await client.auth.resetPasswordForEmail(email);
  }

  // Recipe methods
  Future<List<Map<String, dynamic>>> getRecipes() async {
    try {
      final response = await client
          .from('recipes')
          .select()
          .order('created_at', ascending: false);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Error getting recipes: $e');
      // For web demo, return mock recipes
      if (kIsWeb) {
        return [
          {
            'id': '1',
            'title': 'Chocolate Chip Cookies',
            'description': 'Classic homemade chocolate chip cookies',
            'ingredients': ['2 cups flour', '1 cup sugar', '1/2 cup butter', '2 eggs', '1 cup chocolate chips'],
            'steps': ['Preheat oven to 350°F', 'Mix ingredients', 'Bake for 10-12 minutes'],
            'category': ['Dessert'],
            'user_id': 'mock-user-id',
            'created_at': DateTime.now().toIso8601String(),
          },
          {
            'id': '2',
            'title': 'Spaghetti Carbonara',
            'description': 'Classic Italian pasta dish',
            'ingredients': ['1 lb spaghetti', '4 eggs', '1 cup parmesan cheese', '8 oz bacon', 'Black pepper'],
            'steps': ['Cook pasta', 'Fry bacon', 'Mix eggs and cheese', 'Combine all ingredients'],
            'category': ['Dinner', 'Italian'],
            'user_id': 'mock-user-id',
            'created_at': DateTime.now().toIso8601String(),
          },
        ];
      } else {
        rethrow;
      }
    }
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

  Future<String> uploadRecipePhoto(String recipeId, String localFilePath, {Uint8List? bytes}) async {
    final user = client.auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    final fileExt = localFilePath.split('.').last;
    final fileName = '${DateTime.now().millisecondsSinceEpoch}.$fileExt';
    final filePath = '${user.id}/$fileName';

    try {
      if (kIsWeb && bytes != null) {
        // For web, use the bytes directly
        await client.storage
            .from('recipe-photos')
            .uploadBinary(filePath, bytes, fileOptions: FileOptions(contentType: 'image/$fileExt'));
      } else {
        // For mobile, use the file path
        final file = File(localFilePath);
        await client.storage
            .from('recipe-photos')
            .upload(filePath, file);
      }

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
