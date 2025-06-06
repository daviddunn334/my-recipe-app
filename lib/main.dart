import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'screens/landing_screen.dart';
import 'screens/auth_screen.dart';
import 'screens/home_screen.dart';
import 'screens/create_recipe_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/shell_screen.dart';
import 'screens/recipe_detail_screen.dart';
import 'screens/edit_recipe_screen.dart';
import 'services/supabase_service.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SupabaseService.initialize();
  runApp(const MyApp());
}

final _router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const LandingScreen(),
    ),
    GoRoute(
      path: '/auth',
      builder: (context, state) => const AuthScreen(),
    ),
    ShellRoute(
      builder: (context, state, child) => ShellScreen(child: child),
      routes: [
        GoRoute(
          path: '/home',
          builder: (context, state) => const HomeScreen(),
        ),
        GoRoute(
          path: '/create-recipe',
          builder: (context, state) => const CreateRecipeScreen(),
        ),
        GoRoute(
          path: '/recipe/:id',
          builder: (context, state) {
            final recipeId = state.pathParameters['id']!;
            final recipe = state.extra as Map<String, dynamic>;
            return RecipeDetailScreen(recipe: recipe);
          },
        ),
        GoRoute(
          path: '/recipe/:id/edit',
          builder: (context, state) {
            final recipeId = state.pathParameters['id']!;
            final recipe = state.extra as Map<String, dynamic>;
            return EditRecipeScreen(recipe: recipe);
          },
        ),
        GoRoute(
          path: '/profile',
          builder: (context, state) => const ProfileScreen(),
        ),
      ],
    ),
  ],
);

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Recipe Sharing App',
      theme: AppTheme.theme,
      routerConfig: _router,
      debugShowCheckedModeBanner: false,
    );
  }
}
