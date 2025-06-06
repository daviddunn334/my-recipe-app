import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../services/supabase_service.dart';
import '../theme/app_theme.dart';

class EditRecipeScreen extends StatefulWidget {
  final Map<String, dynamic> recipe;

  const EditRecipeScreen({
    super.key,
    required this.recipe,
  });

  @override
  State<EditRecipeScreen> createState() => _EditRecipeScreenState();
}

class _EditRecipeScreenState extends State<EditRecipeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final List<String> _ingredients = [];
  final List<String> _steps = [];
  final List<String> _tags = [];
  String? _photoUrl;
  bool _isLoading = false;

  final _ingredientController = TextEditingController();
  final _stepController = TextEditingController();

  File? _imageFile;
  bool _isUploadingPhoto = false;
  String? _currentPhotoUrl;

  @override
  void initState() {
    super.initState();
    // Pre-populate the form with existing recipe data
    _titleController.text = widget.recipe['title'] ?? '';
    _descriptionController.text = widget.recipe['description'] ?? '';
    _ingredients.addAll(List<String>.from(widget.recipe['ingredients'] ?? []));
    _steps.addAll(List<String>.from(widget.recipe['steps'] ?? []));
    _tags.addAll(List<String>.from(widget.recipe['category'] ?? []));
    _currentPhotoUrl = widget.recipe['photo_url'];
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _ingredientController.dispose();
    _stepController.dispose();
    super.dispose();
  }

  Future<void> _handlePhotoUpload() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1200,
        maxHeight: 1200,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _imageFile = File(image.path);
          _isUploadingPhoto = true;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to capture photo: $e')),
        );
      }
    }
  }

  void _addIngredient() {
    if (_ingredientController.text.isNotEmpty) {
      setState(() {
        _ingredients.add(_ingredientController.text);
        _ingredientController.clear();
      });
    }
  }

  void _addStep() {
    if (_stepController.text.isNotEmpty) {
      setState(() {
        _steps.add(_stepController.text);
        _stepController.clear();
      });
    }
  }

  void _removeIngredient(int index) {
    setState(() {
      _ingredients.removeAt(index);
    });
  }

  void _removeStep(int index) {
    setState(() {
      _steps.removeAt(index);
    });
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_ingredients.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add at least one ingredient')),
      );
      return;
    }
    if (_steps.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add at least one step')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // If we have a new photo, upload it first
      String? photoUrl = _currentPhotoUrl;
      if (_imageFile != null) {
        try {
          // Delete old photo if it exists
          if (_currentPhotoUrl != null) {
            await SupabaseService().deleteRecipePhoto(_currentPhotoUrl!);
          }

          // Upload new photo
          photoUrl = await SupabaseService().uploadRecipePhoto(
            widget.recipe['id'],
            _imageFile!.path,
          );
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Photo update failed: $e')),
            );
          }
        }
      }

      // Update the recipe
      await SupabaseService().updateRecipe(
        widget.recipe['id'],
        {
          'title': _titleController.text,
          'description': _descriptionController.text,
          'ingredients': _ingredients,
          'steps': _steps,
          'category': _tags,
          'photo_url': photoUrl,
        },
      );
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Recipe updated successfully!')),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _isUploadingPhoto = false;
        });
      }
    }
  }

  Widget _buildCategoryChip(String category) {
    final isSelected = _tags.contains(category);
    return FilterChip(
      label: Text(category),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          if (selected) {
            _tags.add(category);
          } else {
            _tags.remove(category);
          }
        });
      },
      backgroundColor: Colors.white,
      selectedColor: AppTheme.accentColor1.withOpacity(0.2),
      checkmarkColor: AppTheme.accentColor1,
      labelStyle: TextStyle(
        color: isSelected ? AppTheme.accentColor1 : Colors.black87,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: isSelected ? AppTheme.accentColor1 : Colors.grey.shade300,
          width: 1,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Recipe'),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppTheme.mainBackgroundColor,
              AppTheme.mainBackgroundColor.withOpacity(0.8),
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Edit Recipe',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: AppTheme.largeTitleTextColor,
                          fontWeight: FontWeight.bold,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  
                  // Title
                  Container(
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
                    child: TextFormField(
                      controller: _titleController,
                      decoration: InputDecoration(
                        labelText: 'Recipe Title',
                        prefixIcon: const Icon(Icons.title),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a title';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Description
                  Container(
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
                    child: TextFormField(
                      controller: _descriptionController,
                      decoration: InputDecoration(
                        labelText: 'Recipe Description',
                        prefixIcon: const Icon(Icons.description),
                        alignLabelWithHint: true,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      maxLines: 3,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a description';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Photo Upload
                  Container(
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
                    child: Column(
                      children: [
                        if (_imageFile != null) ...[
                          Container(
                            height: 200,
                            width: double.infinity,
                            margin: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              image: DecorationImage(
                                image: FileImage(_imageFile!),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ] else if (_currentPhotoUrl != null) ...[
                          Container(
                            height: 200,
                            width: double.infinity,
                            margin: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              image: DecorationImage(
                                image: NetworkImage(_currentPhotoUrl!),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ],
                        const SizedBox(height: 8),
                        ElevatedButton.icon(
                          onPressed: _isUploadingPhoto ? null : _handlePhotoUpload,
                          icon: _isUploadingPhoto
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(Icons.photo_camera),
                          label: Text(_imageFile != null || _currentPhotoUrl != null 
                              ? 'Change Photo' 
                              : 'Add Photo'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.accentColor1,
                            minimumSize: const Size(double.infinity, 56),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Ingredients Section
                  Text(
                    'Ingredients',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Container(
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
                    child: Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _ingredientController,
                            decoration: InputDecoration(
                              labelText: 'Add Ingredient',
                              hintText: 'e.g., 2 cups flour',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                              filled: true,
                              fillColor: Colors.white,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: _addIngredient,
                          icon: const Icon(Icons.add_circle),
                          color: AppTheme.accentColor1,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  ..._ingredients.asMap().entries.map((entry) {
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
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
                        title: Text(entry.value),
                        trailing: IconButton(
                          icon: const Icon(Icons.remove_circle),
                          onPressed: () => _removeIngredient(entry.key),
                          color: Colors.red,
                        ),
                      ),
                    );
                  }),
                  const SizedBox(height: 24),

                  // Steps Section
                  Text(
                    'Steps',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Container(
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
                    child: Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _stepController,
                            decoration: InputDecoration(
                              labelText: 'Add Step',
                              hintText: 'e.g., Preheat oven to 350°F',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                              filled: true,
                              fillColor: Colors.white,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: _addStep,
                          icon: const Icon(Icons.add_circle),
                          color: AppTheme.accentColor1,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  ..._steps.asMap().entries.map((entry) {
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
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
                        title: Text('${entry.key + 1}. ${entry.value}'),
                        trailing: IconButton(
                          icon: const Icon(Icons.remove_circle),
                          onPressed: () => _removeStep(entry.key),
                          color: Colors.red,
                        ),
                      ),
                    );
                  }),
                  const SizedBox(height: 24),

                  // Categories Section
                  Text(
                    'Categories',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _buildCategoryChip('Breakfast'),
                      _buildCategoryChip('Lunch'),
                      _buildCategoryChip('Dinner'),
                      _buildCategoryChip('Dessert'),
                    ],
                  ),
                  const SizedBox(height: 32),

                  // Submit Button
                  Container(
                    decoration: BoxDecoration(
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
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _handleSubmit,
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 56),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _isLoading
                          ? const CircularProgressIndicator()
                          : const Text('Update Recipe'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
} 