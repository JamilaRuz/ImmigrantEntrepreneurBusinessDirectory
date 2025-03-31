#!/bin/bash

# Check if Firebase CLI is installed
if ! command -v firebase &> /dev/null; then
    echo "Firebase CLI is not installed. Please install it first."
    echo "You can install it with: npm install -g firebase-tools"
    exit 1
fi

echo "Logging in to Firebase..."
firebase login

echo "Deploying Firestore Security Rules..."
firebase deploy --only firestore:rules --project business-directory-7b50b

echo "Deploying Firestore Indexes..."
firebase deploy --only firestore:indexes --project business-directory-7b50b

echo "Deploying Storage Security Rules..."
firebase deploy --only storage --project business-directory-7b50b

echo "Firebase configuration deployed successfully!"

# Instructions for additional steps
echo ""
echo "====== ADDITIONAL STEPS NEEDED ======"
echo "1. Enable App Check in Firebase Console for additional security"
echo "2. Set up budget alerts to monitor costs"
echo "3. Enable Firebase Crashlytics reporting for production"
echo "4. Review Authentication providers in Firebase Console"
echo "======================================" 