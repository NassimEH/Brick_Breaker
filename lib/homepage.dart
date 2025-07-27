import 'package:flutter/material.dart'; // Importe les widgets Material Design de Flutter
import 'package:flutter/services.dart'; // Importe les services système (clavier, etc.)
import 'dart:async'; // Importe les outils pour la programmation asynchrone (Timer)

// Classe principale de la page d'accueil qui hérite de StatefulWidget
// StatefulWidget = widget qui peut changer d'état (données qui bougent)
class HomePage extends StatefulWidget {
  const HomePage({Key? key})
    : super(key: key); // Constructeur avec clé optionnelle

  @override
  _HomePageState createState() => _HomePageState(); // Crée l'état associé
}

// Classe qui gère l'état de la page HomePage
class _HomePageState extends State<HomePage> {
  // === VARIABLES DU JEU ===

  // Position de la balle (coordonnées entre -1 et 1)
  double ballX = 0; // Position horizontale de la balle (gauche-droite)
  double ballY = 0; // Position verticale de la balle (haut-bas)
  double ballXDirection =
      1; // Direction X de la balle (1 = droite, -1 = gauche)
  double ballYDirection = 1; // Direction Y de la balle (1 = bas, -1 = haut)

  // Variables de la raquette du joueur
  double playerX = -0.2; // Position horizontale de la raquette
  double playerWidth = 0.4; // Largeur de la raquette

  // Grille des briques (tableau 2D de booléens)
  List<List<bool>> bricks =
      []; // true = brique présente, false = brique détruite

  // États du jeu
  bool gameStarted = false; // Le jeu a-t-il commencé ?
  bool gameOver = false; // Le jeu est-il terminé ?
  int score = 0; // Score du joueur
  Timer? gameTimer; // Timer pour l'animation du jeu

  // Contrôles clavier : ensemble des touches pressées
  Set<LogicalKeyboardKey> pressedKeys = <LogicalKeyboardKey>{};

  // === MÉTHODES DU CYCLE DE VIE ===

  @override
  void initState() {
    super.initState(); // Appelle la méthode parent
    resetGame(); // Initialise le jeu
  }

  // Remet le jeu à zéro
  void resetGame() {
    ballX = 0; // Balle au centre horizontalement
    ballY = 0; // Balle au centre verticalement
    ballXDirection = 1; // Balle va vers la droite
    ballYDirection = 1; // Balle va vers le bas
    playerX = -0.2; // Raquette légèrement à gauche du centre
    gameStarted = false; // Jeu pas encore commencé
    gameOver = false; // Jeu pas terminé
    score = 0; // Score à zéro

    // Création de la grille de briques (5 rangées de 6 briques)
    bricks = []; // Vide la liste des briques
    for (int i = 0; i < 5; i++) {
      // Pour chaque rangée (0 à 4)
      List<bool> row = []; // Crée une nouvelle rangée
      for (int j = 0; j < 6; j++) {
        // Pour chaque colonne (0 à 5)
        row.add(true); // Ajoute une brique (true = présente)
      }
      bricks.add(row); // Ajoute la rangée à la grille
    }
  }

  // Démarre le jeu quand le joueur tape l'écran
  void startGame() {
    if (gameOver) {
      // Si le jeu est terminé
      resetGame(); // Recommence une nouvelle partie
      return; // Sort de la fonction
    }

    if (gameStarted) return; // Si déjà commencé, ne fait rien

    gameStarted = true; // Marque le jeu comme commencé
    gameTimer?.cancel(); // Annule l'ancien timer s'il existe

    // Crée un timer qui s'exécute toutes les 16ms (≈60 FPS)
    gameTimer = Timer.periodic(Duration(milliseconds: 16), (timer) {
      updateGame(); // Met à jour le jeu
      if (gameOver) {
        // Si le jeu est terminé
        timer.cancel(); // Arrête le timer
      }
    });
  }

  // Met à jour la logique du jeu à chaque frame
  void updateGame() {
    setState(() {
      // setState() redessine l'interface avec les nouvelles données

      // === GESTION DES CONTRÔLES CLAVIER ===

      // Si la flèche gauche est pressée
      if (pressedKeys.contains(LogicalKeyboardKey.arrowLeft)) {
        playerX -= 0.03; // Déplace la raquette vers la gauche
        if (playerX < -1) playerX = -1; // Limite à gauche de l'écran
      }
      // Si la flèche droite est pressée
      if (pressedKeys.contains(LogicalKeyboardKey.arrowRight)) {
        playerX += 0.03; // Déplace la raquette vers la droite
        // Limite à droite de l'écran (position + largeur ne doit pas dépasser 1)
        if (playerX + playerWidth > 1) playerX = 1 - playerWidth;
      }

      // === MOUVEMENT DE LA BALLE ===

      // Déplace la balle selon sa direction (0.01 = vitesse réduite)
      ballX += ballXDirection * 0.01; // Mouvement horizontal
      ballY += ballYDirection * 0.01; // Mouvement vertical

      // === COLLISIONS AVEC LES MURS ===

      // Si la balle touche les murs gauche ou droit
      if (ballX >= 1 || ballX <= -1) {
        ballXDirection = -ballXDirection; // Inverse la direction horizontale
      }

      // Si la balle touche le mur du haut
      if (ballY <= -1) {
        ballYDirection = -ballYDirection; // Inverse la direction verticale
      }

      // === COLLISION AVEC LA RAQUETTE (CORRIGÉE) ===

      // Vérifie si la balle touche la raquette
      if (ballY >= 0.85 && // Balle près de la raquette (zone élargie)
          ballY <= 0.95 && // Mais pas trop loin en dessous
          ballX >= playerX - 0.05 && // Zone légèrement élargie à gauche
          ballX <=
              playerX +
                  playerWidth +
                  0.05 && // Zone légèrement élargie à droite
          ballYDirection > 0) {
        // IMPORTANT: la balle doit descendre

        ballYDirection = -ballYDirection; // Fait rebondir la balle vers le haut

        // Ajoute un effet d'angle basé sur la position sur la raquette
        double hitPosition =
            (ballX - playerX) / playerWidth; // Position relative (0 à 1)
        ballXDirection =
            (hitPosition - 0.5) * 2; // Conversion en direction (-1 à 1)

        // Normalise la direction pour éviter des vitesses trop faibles
        if (ballXDirection.abs() < 0.3) {
          ballXDirection = ballXDirection > 0 ? 0.3 : -0.3;
        }
      }

      // === GAME OVER ===

      // Si la balle tombe en bas de l'écran
      if (ballY > 1) {
        gameOver = true; // Marque le jeu comme terminé
        gameStarted = false; // Arrête le jeu
      }

      // === VÉRIFICATION DES COLLISIONS ET CONDITIONS DE VICTOIRE ===

      checkBrickCollision(); // Vérifie si la balle touche des briques

      // Si toutes les briques sont détruites
      if (allBricksDestroyed()) {
        gameOver = true; // Jeu terminé (victoire)
        gameStarted = false; // Arrête le jeu
      }
    });
  }

  // Vérifie les collisions entre la balle et les briques
  void checkBrickCollision() {
    // Parcourt toutes les rangées de briques
    for (int i = 0; i < bricks.length; i++) {
      // Parcourt toutes les colonnes de la rangée actuelle
      for (int j = 0; j < bricks[i].length; j++) {
        // Si la brique existe encore (true)
        if (bricks[i][j]) {
          // Calcule la position de cette brique
          double brickX = -0.8 + j * 0.3; // Position X (espacement de 0.3)
          double brickY = -0.8 + i * 0.1; // Position Y (espacement de 0.1)

          // Vérifie si la balle touche cette brique (collision rectangulaire)
          if (ballX >= brickX && // Balle à droite du bord gauche
              ballX <= brickX + 0.25 && // Balle à gauche du bord droit
              ballY <= brickY + 0.05 && // Balle au-dessus du bord bas
              ballY >= brickY - 0.05) {
            // Balle en-dessous du bord haut

            bricks[i][j] = false; // Détruit la brique (false)
            ballYDirection = -ballYDirection; // Fait rebondir la balle
            score += 10; // Ajoute 10 points au score
            return; // Sort de la fonction (une seule collision par frame)
          }
        }
      }
    }
  }

  // Vérifie si toutes les briques ont été détruites
  bool allBricksDestroyed() {
    // Parcourt toutes les rangées
    for (List<bool> row in bricks) {
      // Parcourt toutes les briques de la rangée
      for (bool brick in row) {
        if (brick) return false; // Si une brique existe encore, retourne false
      }
    }
    return true; // Toutes les briques sont détruites
  }

  // Gère le mouvement de la raquette avec la souris
  void movePaddle(DragUpdateDetails details) {
    setState(() {
      // Calcule le déplacement basé sur le mouvement de la souris
      playerX += details.delta.dx / 100; // delta.dx = distance déplacée

      // Limite la raquette aux bords de l'écran
      if (playerX < -1) playerX = -1; // Limite gauche
      if (playerX + playerWidth > 1) playerX = 1 - playerWidth; // Limite droite
    });
  }

  // Gère les événements clavier (touches pressées/relâchées)
  bool handleKeyEvent(KeyEvent event) {
    if (event is KeyDownEvent) {
      // Si une touche est pressée
      pressedKeys.add(event.logicalKey); // Ajoute la touche à l'ensemble
    } else if (event is KeyUpEvent) {
      // Si une touche est relâchée
      pressedKeys.remove(event.logicalKey); // Retire la touche de l'ensemble
    }
    return true; // Indique que l'événement a été traité
  }

  // Nettoie les ressources quand le widget est détruit
  @override
  void dispose() {
    gameTimer?.cancel(); // Annule le timer pour éviter les fuites mémoire
    super.dispose(); // Appelle la méthode parent
  }

  // === CONSTRUCTION DE L'INTERFACE UTILISATEUR ===

  @override
  Widget build(BuildContext context) {
    return KeyboardListener(
      // Écoute les événements clavier
      focusNode: FocusNode()
        ..requestFocus(), // Demande le focus pour recevoir les événements
      onKeyEvent:
          handleKeyEvent, // Function appelée pour chaque événement clavier
      child: GestureDetector(
        // Détecte les gestes tactiles
        onTap: startGame, // Démarre le jeu au tap
        onPanUpdate: movePaddle, // Déplace la raquette au drag
        child: Scaffold(
          // Structure de base de la page
          backgroundColor: Colors.black, // Fond noir
          body: Center(
            // Centre le contenu
            child: Container(
              // Container prend toute la taille de l'écran
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              child: Stack(
                // Empile les widgets les uns sur les autres
                children: [
                  // === AFFICHAGE DU SCORE ===
                  Container(
                    alignment: Alignment.topCenter, // Aligné en haut au centre
                    child: Padding(
                      padding: EdgeInsets.only(top: 50), // Marge en haut
                      child: Text(
                        'Score: $score', // Affiche le score actuel
                        style: TextStyle(
                          color: Colors.white, // Texte blanc
                          fontSize: 24, // Taille 24
                          fontWeight: FontWeight.bold, // Gras
                        ),
                      ),
                    ),
                  ),

                  // === ÉCRAN D'INSTRUCTIONS ===
                  // Affiché seulement si le jeu n'a pas commencé ET n'est pas terminé
                  if (!gameStarted && !gameOver)
                    Container(
                      alignment: Alignment.center, // Centré à l'écran
                      child: Column(
                        // Colonne verticale de textes
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'BRICK BREAKER', // Titre du jeu
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 20), // Espace vertical
                          Text(
                            'Tap to start', // Instruction de démarrage
                            style: TextStyle(color: Colors.grey, fontSize: 18),
                          ),
                          SizedBox(height: 10),
                          Text(
                            'Use ← → arrow keys to move paddle', // Instructions clavier
                            style: TextStyle(color: Colors.grey, fontSize: 14),
                          ),
                          SizedBox(height: 5),
                          Text(
                            'Or drag with mouse', // Instructions souris
                            style: TextStyle(color: Colors.grey, fontSize: 12),
                          ),
                        ],
                      ),
                    ),

                  // === ÉCRAN DE FIN DE JEU ===
                  // Affiché seulement si le jeu est terminé
                  if (gameOver)
                    Container(
                      alignment: Alignment.center,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            // Affiche "YOU WIN!" si toutes les briques sont détruites, sinon "GAME OVER"
                            allBricksDestroyed() ? 'YOU WIN!' : 'GAME OVER',
                            style: TextStyle(
                              // Couleur verte pour victoire, rouge pour défaite
                              color: allBricksDestroyed()
                                  ? Colors.green
                                  : Colors.red,
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 20),
                          Text(
                            'Final Score: $score', // Affiche le score final
                            style: TextStyle(color: Colors.white, fontSize: 18),
                          ),
                          SizedBox(height: 20),
                          Text(
                            'Tap to restart', // Instruction pour recommencer
                            style: TextStyle(color: Colors.grey, fontSize: 16),
                          ),
                        ],
                      ),
                    ),

                  // === BRIQUES ===
                  // L'opérateur ... "spread" ajoute tous les widgets de la liste
                  ...buildBricks(),

                  // === BALLE ===
                  Container(
                    alignment: Alignment(
                      ballX,
                      ballY,
                    ), // Position basée sur ballX et ballY
                    child: Container(
                      height: 15, // Hauteur de la balle
                      width: 15, // Largeur de la balle
                      decoration: BoxDecoration(
                        color: Colors.white, // Couleur blanche
                        shape: BoxShape.circle, // Forme circulaire
                      ),
                    ),
                  ),

                  // === RAQUETTE DU JOUEUR ===
                  Container(
                    // Position centrée sur la raquette et près du bas (0.9)
                    alignment: Alignment(playerX + playerWidth / 2, 0.9),
                    child: Container(
                      height: 10, // Hauteur de la raquette
                      // Largeur proportionnelle à l'écran
                      width:
                          MediaQuery.of(context).size.width * playerWidth / 2,
                      decoration: BoxDecoration(
                        color: Colors.blue, // Couleur bleue
                        borderRadius: BorderRadius.circular(
                          5,
                        ), // Coins arrondis
                      ),
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

  // === CONSTRUCTION DES BRIQUES ===
  List<Widget> buildBricks() {
    List<Widget> brickWidgets =
        []; // Liste pour stocker les widgets des briques

    // Palette de couleurs pour les différentes rangées
    List<Color> colors = [
      Colors.red, // Rangée 0 : rouge
      Colors.orange, // Rangée 1 : orange
      Colors.yellow, // Rangée 2 : jaune
      Colors.green, // Rangée 3 : vert
      Colors.blue, // Rangée 4 : bleu
    ];

    // Parcourt toutes les rangées de briques
    for (int i = 0; i < bricks.length; i++) {
      // Parcourt toutes les colonnes de la rangée actuelle
      for (int j = 0; j < bricks[i].length; j++) {
        // Si la brique existe encore (n'a pas été détruite)
        if (bricks[i][j]) {
          // Calcule la position de la brique
          double brickX =
              -0.8 + j * 0.3; // Position X (commence à -0.8, espacement 0.3)
          double brickY =
              -0.8 + i * 0.1; // Position Y (commence à -0.8, espacement 0.1)

          // Crée le widget de la brique
          brickWidgets.add(
            Container(
              alignment: Alignment(brickX, brickY), // Position de la brique
              child: Container(
                height: 20, // Hauteur de la brique
                width: 50, // Largeur de la brique
                decoration: BoxDecoration(
                  color:
                      colors[i % colors.length], // Couleur basée sur la rangée
                  borderRadius: BorderRadius.circular(
                    3,
                  ), // Coins légèrement arrondis
                  border: Border.all(
                    color: Colors.white,
                    width: 0.5,
                  ), // Bordure blanche fine
                ),
              ),
            ),
          );
        }
      }
    }

    return brickWidgets; // Retourne la liste de tous les widgets de briques
  }
}
