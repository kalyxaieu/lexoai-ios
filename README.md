# Lexo AI — iOS

Application iOS native de Lexo AI, développée en SwiftUI.

## Backend existant
- Projet Supabase : odiafnwopeibwfypkgpb (région eu-central-2)
- Authentification Supabase
- Edge Function `lexo-android-stream` pour les réponses en streaming
- Edge Function `lexo-ai` pour récupérer l'historique déchiffré
- Tables existantes `conversations`, `messages` et `profiles`
- Aucune clé service_role ou clé secrète n'est embarquée dans l'application.

## Ouvrir dans Xcode
1. Cloner ce dépôt.
2. Ouvrir `LexoAI.xcodeproj`.
3. Attendre la résolution du package `supabase-swift`.
4. Choisir un simulateur iPhone et lancer avec Run.

Le code utilise la clé Supabase publishable du projet. Elle est conçue pour être utilisée dans les clients publics ; les données restent protégées par les politiques RLS et les Edge Functions.

## État
Base native SwiftUI initiale. Les flux d'authentification et de chat doivent être testés dans le simulateur avec un compte de test avant publication.
