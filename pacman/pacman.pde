enum GameState {
  MENU_DEMARRAGE, PLAYING
}

GameState currentState;
Game game;
Menu menuPause;
MenuDemarrage menuDemarrage;
boolean afficherMeilleursScores;

void setup() {
  size(800, 800);
  currentState = GameState.MENU_DEMARRAGE;
  game = new Game(this);
  menuPause = new Menu();
  menuDemarrage = new MenuDemarrage();
  afficherMeilleursScores = false;
}

void draw() {
  background(0);

  if (currentState == GameState.MENU_DEMARRAGE) {
    menuDemarrage.drawIt();
  } else if (currentState == GameState.PLAYING) {
    if (!menuPause._afficher && !afficherMeilleursScores) {
      game.updateIt();
    }
    game.drawIt();

    if (menuPause._afficher) {
      menuPause.drawIt();
    }
    if (afficherMeilleursScores) {
      menuPause.afficherMeilleursScores();
    }
  }
}

void keyPressed() {
  if (currentState == GameState.MENU_DEMARRAGE) {
    menuDemarrage.handleKey(key);
    return;
  }
  if (game._demandeNom) {
    game.saisirNom(key);
    return;
  }
  if (key == 's' || key == 'S') {
    game._sons.activerDesactiver();
    if (!game._sons.actif) {
      game._sons.arreterTous();
    }
    return;
  }
  if (key == ESC) {
    key = 0;
    if (afficherMeilleursScores) {
      afficherMeilleursScores = false;
    } else {
      if (!menuPause._afficher) {
        game._sons.arreterTous();
        if (game._partieTerminee && game._vies <= 0) {
          menuPause.setMode("defaite");
        } else {
          menuPause.setMode("pause");
        }
      }
      menuPause.toggle();
    }
    return;
  }
  if (menuPause._afficher) {
    if (keyCode == UP) {
      menuPause.naviguer(-1);
    } else if (keyCode == DOWN) {
      menuPause.naviguer(1);
    } else if (key == ENTER || key == RETURN) {
      executerOptionMenu();
    }
    return;
  }
  if (!game._partieTerminee) {
    gererDeplacementPacman();
  }
}


void executerOptionMenu() {
  String optionTexte = menuPause.getOptionTexte();
  
  if (optionTexte.equals("Reprendre la partie")) {
    menuPause.toggle();
  } else if (optionTexte.equals("Recommencer") || optionTexte.equals("Rejouer")) {
    game.recommencer();
    menuPause.toggle();
  } else if (optionTexte.equals("Sauvegarder")) {
    game.sauvegarderPartie();
  } else if (optionTexte.equals("Charger une partie")) {
    game.chargerPartie();
    menuPause.toggle();
  } else if (optionTexte.equals("Meilleurs scores")) {
    afficherMeilleursScores = true;
    menuPause.toggle();
  } else if (optionTexte.equals("Menu principal")) {
    currentState = GameState.MENU_DEMARRAGE;
    menuPause._afficher = false;
  }
}


void gererDeplacementPacman() {
  if (key == 'z' || key == 'Z' || keyCode == UP) {
    game._hero.changerDirection(new PVector(0, -1));
  } else if (key == 's' || key == 'S' || keyCode == DOWN) {
    game._hero.changerDirection(new PVector(0, 1));
  } else if (key == 'q' || key == 'Q' || keyCode == LEFT) {
    game._hero.changerDirection(new PVector(-1, 0));
  } else if (key == 'd' || key == 'D' || keyCode == RIGHT) {
    game._hero.changerDirection(new PVector(1, 0));
  }
}

void mousePressed() {
  if (currentState == GameState.MENU_DEMARRAGE) {
    menuDemarrage.handleClick(mouseX, mouseY);
  } else if (currentState == GameState.PLAYING && !menuPause._afficher && !afficherMeilleursScores) {
    game.gererClicSouris(mouseX, mouseY);
  }
}

void startGame() {
  currentState = GameState.PLAYING;
  game = new Game(this);
  game._sons.jouerDebut();
}
