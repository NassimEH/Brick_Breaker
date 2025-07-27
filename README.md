# 🎮 Brick Breaker - Jeu Flutter

Un jeu classique de Brick Breaker développé en Flutter avec des contrôles modernes pour PC et mobile.

## 📱 Aperçu du Projet

Ce projet implémente le jeu classique Brick Breaker où le joueur contrôle une raquette pour faire rebondir une balle et détruire toutes les briques colorées. Le jeu comprend une physique réaliste, des contrôles multiples et un système de score.

## 🚀 Fonctionnalités

### ✨ Gameplay
- **Physique de balle réaliste** avec rebonds naturels
- **30 briques colorées** organisées en 5 rangées de 6 colonnes
- **Système de score** : 10 points par brique détruite
- **Détection de collisions** précise (balle, raquette, briques, murs)
- **Conditions de victoire/défaite** avec écrans dédiés
- **Restart automatique** pour rejouer instantanément

### 🎯 Contrôles
- **PC** : Flèches ← → pour déplacer la raquette
- **Souris** : Glisser pour contrôler la raquette
- **Mobile** : Glissement tactile
- **Démarrage** : Clic/tap n'importe où sur l'écran

### 🎨 Interface
- **Design moderne** avec fond noir gaming
- **Briques colorées** (rouge, orange, jaune, vert, bleu)
- **Interface claire** avec instructions intégrées
- **Responsive** : s'adapte à toutes les tailles d'écran

## 🛠️ Architecture Technique

### 📁 Structure du Code

```
lib/
├── main.dart          # Point d'entrée de l'application
└── homepage.dart      # Logique principale du jeu
```

### 🧩 Composants Principaux

#### **Variables d'État**
- `ballX, ballY` : Position de la balle (-1 à 1)
- `ballXDirection, ballYDirection` : Vecteurs de direction
- `playerX, playerWidth` : Position et taille de la raquette
- `bricks` : Grille 2D des briques (bool)
- `gameStarted, gameOver` : États du jeu
- `score` : Score du joueur

#### **Fonctions Clés**
- `resetGame()` : Initialise/remet à zéro le jeu
- `startGame()` : Démarre la boucle de jeu (60 FPS)
- `updateGame()` : Met à jour la physique à chaque frame
- `checkBrickCollision()` : Détecte les collisions avec les briques
- `buildBricks()` : Génère les widgets des briques

#### **Gestion des Événements**
- `handleKeyEvent()` : Contrôles flèches clavier
- `movePaddle()` : Contrôles souris/tactile
- `Timer.periodic()` : Boucle de jeu 60 FPS

## 💻 Installation et Exécution

### Prérequis
- Flutter SDK installé
- Un navigateur web ou un émulateur mobile

### 🚀 Lancement en Mode Développement
```bash
# Naviger vers le dossier du projet
cd brick_breaker

# Lancer sur Chrome
flutter run -d chrome

# Ou lancer sur un émulateur Android/iOS
flutter run
```

### 📦 Build pour Production
```bash
# Build web
flutter build web

# Servir avec Live Server
live-server build/web --port=5500
```

## 🎮 Comment Jouer

### Démarrage
1. Ouvrez l'application
2. Lisez les instructions à l'écran
3. **Cliquez/tapez** n'importe où pour commencer

### Contrôles
- **PC** : Utilisez les flèches ← → pour déplacer la raquette
- **Souris** : Maintenez le clic et bougez la souris
- **Mobile** : Glissez votre doigt sur l'écran

### Objectif
- Empêchez la balle de tomber en bas
- Détruisez toutes les briques colorées
- Maximisez votre score (10 points par brique)

### Fin de Partie
- **Victoire** : Toutes les briques détruites → "YOU WIN!"
- **Défaite** : Balle tombée → "GAME OVER"
- **Restart** : Cliquez pour recommencer

## 🔧 Logique Technique Détaillée

### 🎯 Système de Coordonnées
Le jeu utilise un système de coordonnées normalisé :
- **X** : -1 (gauche) à +1 (droite)
- **Y** : -1 (haut) à +1 (bas)
- **Centre** : (0, 0)

### ⚡ Boucle de Jeu
```dart
Timer.periodic(Duration(milliseconds: 16), (timer) {
  // 1. Gestion des inputs clavier
  // 2. Mouvement de la balle
  // 3. Détection des collisions
  // 4. Mise à jour de l'interface
});
```

### 🎱 Physique de la Balle
- **Vitesse constante** : 0.01 unité par frame
- **Rebonds** : Inversion des vecteurs de direction
- **Collisions** : Détection rectangulaire précise

### 🧱 Système de Briques
- **Grille** : 5 rangées × 6 colonnes = 30 briques
- **Couleurs** : Cycle à travers 5 couleurs
- **Destruction** : Changement de `true` à `false`

## 📈 Optimisations Performances

- **setState() localisé** : Seules les parties nécessaires sont redessinées
- **Widgets const** : Optimisation des éléments statiques
- **Timer cleanup** : Prévention des fuites mémoire
- **Collision early return** : Une seule collision par frame

## 🎨 Personnalisation

### Modifier la Vitesse
```dart
// Dans updateGame()
ballX += ballXDirection * 0.01; // Changer 0.01 pour ajuster la vitesse
```

### Changer les Couleurs
```dart
// Dans buildBricks()
List<Color> colors = [
  Colors.red,     // Personnalisez ces couleurs
  Colors.orange,
  // ...
];
```

### Ajuster la Difficulté
```dart
// Taille de la raquette
double playerWidth = 0.4; // Plus petit = plus difficile

// Nombre de briques
for (int i = 0; i < 5; i++) { // Changer 5 pour plus/moins de rangées
  for (int j = 0; j < 6; j++) { // Changer 6 pour plus/moins de colonnes
```

## 🐛 Résolution de Problèmes

### La balle est trop rapide/lente
Modifiez la valeur dans `ballX += ballXDirection * 0.01`

### Les contrôles ne répondent pas
Vérifiez que le `KeyboardListener` a le focus avec `requestFocus()`

### Problèmes de performance
Réduisez la fréquence du timer : `Duration(milliseconds: 32)` (30 FPS)

## 📄 Licence

Ce projet est développé à des fins éducatives et de démonstration.

## 👨‍💻 Développement

Développé avec Flutter en utilisant :
- **Material Design** pour l'interface
- **Custom Painting & Positioning** pour le rendu du jeu
- **Event Handling** pour les contrôles
- **State Management** avec StatefulWidget

---