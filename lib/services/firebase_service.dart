import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'dart:io';

class FirebaseService {
  static FirebaseAuth get auth => FirebaseAuth.instance;
  static FirebaseFirestore get firestore => FirebaseFirestore.instance;
  static FirebaseStorage get storage => FirebaseStorage.instance;
  static FirebaseAnalytics get analytics => FirebaseAnalytics.instance;

  static Future<void> initialize() async {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: "AIzaSyDnGxSsLoop2bPFYyXhI19zVXqKc-dET3M",
        appId: "1:395127364451:web:ade89b7acbe1e74296d156",
        projectId: "my-recipe-app-9d8f6",
        authDomain: "my-recipe-app-9d8f6.firebaseapp.com",
        storageBucket: "my-recipe-app-9d8f6.firebasestorage.app",
        messagingSenderId: "395127364451",
        measurementId: "G-0GQK60SLKX",
      ),
    );
  }

  // Authentication methods
  Future<UserCredential> signUp({
    required String email,
    required String password,
  }) async {
    return await auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<UserCredential> signIn({
    required String email,
    required String password,
  }) async {
    return await auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<void> signOut() async {
    await auth.signOut();
  }

  Future<void> resetPassword(String email) async {
    await auth.sendPasswordResetEmail(email: email);
  }

  // Recipe methods
  Future<List<Map<String, dynamic>>> getRecipes() async {
    final snapshot = await firestore
        .collection('recipes')
        .orderBy('created_at', descending: true)
        .get();
    
    return snapshot.docs.map((doc) {
      final data = doc.data();
      data['id'] = doc.id; // Add the document ID to the data
      return data;
    }).toList();
  }

  Future<Map<String, dynamic>> createRecipe(Map<String, dynamic> recipeData) async {
    try {
      final user = auth.currentUser;
      if (user == null) throw 'User not authenticated';

      // Add the recipe to Firestore
      final docRef = await firestore.collection('recipes').add({
        'title': recipeData['title'],
        'description': recipeData['description'],
        'ingredients': recipeData['ingredients'],
        'steps': recipeData['steps'],
        'tags': recipeData['tags'],
        'photo_url': recipeData['photo_url'],
        'user_id': user.uid,
        'created_at': FieldValue.serverTimestamp(),
        'updated_at': FieldValue.serverTimestamp(),
      });

      // Get the created recipe
      final docSnapshot = await docRef.get();
      final data = docSnapshot.data()!;
      data['id'] = docSnapshot.id;
      
      return data;
    } catch (e) {
      throw 'Failed to create recipe: $e';
    }
  }

  Future<void> deleteRecipe(String recipeId) async {
    try {
      final user = auth.currentUser;
      if (user == null) throw 'User not authenticated';

      // First verify that the recipe belongs to the current user
      final docSnapshot = await firestore
          .collection('recipes')
          .doc(recipeId)
          .get();
      
      if (!docSnapshot.exists) {
        throw 'Recipe not found';
      }
      
      final data = docSnapshot.data()!;
      if (data['user_id'] != user.uid) {
        throw 'You can only delete your own recipes';
      }

      // Delete the recipe
      await firestore
          .collection('recipes')
          .doc(recipeId)
          .delete();

      // Delete the photo if it exists
      if (data['photo_url'] != null && data['photo_url'].isNotEmpty) {
        await deleteRecipePhoto(data['photo_url']);
      }
    } catch (e) {
      throw 'Failed to delete recipe: $e';
    }
  }

  Future<void> updateRecipe(String recipeId, Map<String, dynamic> recipeData) async {
    try {
      final user = auth.currentUser;
      if (user == null) throw 'User not authenticated';

      // First verify that the recipe belongs to the current user
      final docSnapshot = await firestore
          .collection('recipes')
          .doc(recipeId)
          .get();
      
      if (!docSnapshot.exists) {
        throw 'Recipe not found';
      }
      
      final data = docSnapshot.data()!;
      if (data['user_id'] != user.uid) {
        throw 'You can only edit your own recipes';
      }

      // Update the recipe
      await firestore
          .collection('recipes')
          .doc(recipeId)
          .update({
            'title': recipeData['title'],
            'description': recipeData['description'],
            'ingredients': recipeData['ingredients'],
            'steps': recipeData['steps'],
            'tags': recipeData['tags'],
            'photo_url': recipeData['photo_url'],
            'updated_at': FieldValue.serverTimestamp(),
          });
    } catch (e) {
      throw 'Failed to update recipe: $e';
    }
  }

  Future<String> uploadRecipePhoto(String recipeId, String localFilePath) async {
    final user = auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    final file = File(localFilePath);
    final fileExt = localFilePath.split('.').last;
    final fileName = '${DateTime.now().millisecondsSinceEpoch}.$fileExt';
    final filePath = '${user.uid}/$fileName';

    try {
      // Upload the file to Firebase Storage
      final storageRef = storage.ref().child('recipe-photos/$filePath');
      await storageRef.putFile(file);

      // Get the download URL
      final photoUrl = await storageRef.getDownloadURL();
      return photoUrl;
    } catch (e) {
      throw Exception('Failed to upload photo: $e');
    }
  }

  Future<void> deleteRecipePhoto(String photoUrl) async {
    try {
      // Create a reference to the file to delete
      final storageRef = storage.refFromURL(photoUrl);
      await storageRef.delete();
    } catch (e) {
      throw Exception('Failed to delete photo: $e');
    }
  }
}
