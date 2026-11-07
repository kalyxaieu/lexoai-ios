# Lexo AI — iOS

Application iOS native de Lexo AI, développée en SwiftUI, avec une interface adaptée de l'application Android Kalyx AI.

## Backend existant — réutilisé
- Projet Supabase : `odiafnwopeibwfypkgpb` (région `eu-central-2`)
- Authentification Supabase par e-mail / mot de passe
- Inscription sécurisée via `lexo-android-signup` (déclaration d'âge et acceptation des conditions côté serveur)
- Edge Function `lexo-android-stream` pour les réponses progressives
- Edge Function `lexo-ai` pour charger l'historique déchiffré
- Tables existantes `conversations`, `messages` et `profiles`
- Historique partagé avec les autres clients qui utilisent ces tables/fonctions
- RLS activé sur les tables utilisées
- Aucune clé `service_role` ou clé secrète n'est embarquée dans l'application.

## Interface
- Écran de connexion avec le logo officiel Lexo AI
- Écran de chat avec réponses en streaming
- Menu latéral, nouvelle conversation et recherche d'historique
- Sélection, renommage et suppression des conversations
- Paramètres du profil
- Thème système, clair ou sombre
- Mise en page SwiftUI adaptative iPhone/iPad

## Ouvrir dans Xcode
1. Dans Xcode, choisir **Clone Git Repository**.
2. Coller `https://github.com/kalyxaieu/lexoai-ios.git`.
3. Ouvrir `LexoAI.xcodeproj`.
4. Laisser Xcode télécharger le package `supabase-swift`.
5. Choisir un simulateur iPhone (iOS 17 ou supérieur) et cliquer sur **Run**.

Bundle ID : `eu.kalyxai.lexo.ios`.

## Connexion Google
Le bouton est présent dans l'interface. La connexion Google native iOS nécessite un client OAuth iOS créé avec le Bundle ID ci-dessus et ajouté au fournisseur Google de Supabase. Le client OAuth Android existant ne remplace pas ce client iOS. La connexion e-mail fonctionne indépendamment.

## État
Première base native connectée au projet Supabase existant. La compilation et les flux réels doivent être validés dans Xcode Simulator avec un compte de test avant toute publication.
