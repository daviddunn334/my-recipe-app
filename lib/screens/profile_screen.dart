import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../services/supabase_service.dart';
import '../theme/app_theme.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  Future<void> _handleSignOut(BuildContext context) async {
    try {
      await SupabaseService().signOut();
      if (context.mounted) {
        context.go('/');
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    }
  }

  String _formatDate(String? dateString) {
    if (dateString == null) return 'Unknown';
    try {
      final date = DateTime.parse(dateString);
      return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    } catch (e) {
      return 'Unknown';
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = SupabaseService.client.auth.currentUser;

    return Scaffold(
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
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Profile',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: AppTheme.largeTitleTextColor,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 32),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ListTile(
                          leading: const CircleAvatar(
                            child: Icon(Icons.person),
                          ),
                          title: Text(
                            user?.email ?? 'No email',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          subtitle: Text(
                            'Member since ${_formatDate(user?.createdAt)}',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ),
                        const Divider(),
                        ListTile(
                          leading: const Icon(Icons.logout),
                          title: const Text('Sign Out'),
                          onTap: () => _handleSignOut(context),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
} 