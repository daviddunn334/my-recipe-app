# Firebase Deployment Guide for My Recipe App

This guide explains how to deploy the My Recipe App to Firebase Hosting.

## Prerequisites

- [Firebase CLI](https://firebase.google.com/docs/cli) installed
- [Flutter SDK](https://flutter.dev/docs/get-started/install) installed
- A Firebase project created in the [Firebase Console](https://console.firebase.google.com/)

## Initial Setup (Already Completed)

The following steps have already been completed for this project:

1. Firebase project created: `my-recipe-app-9d8f6`
2. Firebase CLI installed and logged in
3. Firebase initialized in the project with `firebase init`
4. Firebase configuration added to the app

## Deployment Steps

### Manual Deployment

To manually deploy the app to Firebase Hosting:

1. Build the Flutter web app:
   ```
   flutter build web
   ```

2. Deploy to Firebase Hosting:
   ```
   firebase deploy --only hosting
   ```

3. Access your deployed app at: https://my-recipe-app-9d8f6.web.app

### Automatic Deployment via GitHub

This project is set up for automatic deployment via GitHub Actions:

1. When you push changes to the `master` branch, GitHub Actions will automatically:
   - Set up Flutter
   - Build the web app
   - Deploy to Firebase Hosting

2. For pull requests, a preview deployment will be created automatically.

## Firebase Configuration

The app is configured to use the following Firebase services:

- **Firebase Authentication**: For user authentication
- **Cloud Firestore**: For storing recipe data
- **Firebase Storage**: For storing recipe images
- **Firebase Analytics**: For tracking app usage

## Updating Firebase Configuration

If you need to update the Firebase configuration:

1. Get your Firebase configuration from the Firebase Console:
   - Go to Project Settings > General
   - Scroll down to "Your apps" section
   - Select your web app
   - Copy the Firebase configuration object

2. Update the configuration in:
   - `web/index.html` (for web)
   - `lib/services/firebase_service.dart` (for Flutter)

## Troubleshooting

- **Build Errors**: Make sure all dependencies are installed with `flutter pub get`
- **Deployment Errors**: Check the Firebase CLI output for specific error messages
- **Runtime Errors**: Check the browser console for JavaScript errors

## Additional Resources

- [Firebase Hosting Documentation](https://firebase.google.com/docs/hosting)
- [Flutter Web Documentation](https://flutter.dev/docs/deployment/web)
- [GitHub Actions Documentation](https://docs.github.com/en/actions)
