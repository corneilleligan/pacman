class Menu
{
  boolean _afficher;
  int _optionSelectionnee;
  int _nbOptions;
  String[] _options;
  String _modeMenu;

  Menu() {
    _afficher = false;
    _optionSelectionnee = 0;
    _modeMenu = "pause";
    definirOptions();
  }

  void definirOptions() {
    if (_modeMenu.equals("pause")) {
      _options = new String[]{
        "Reprendre la partie",
        "Recommencer",
        "Sauvegarder",
        "Charger une partie",
        "Meilleurs scores",
        "Menu principal"
      };
    } else if (_modeMenu.equals("defaite")) {
      _options = new String[]{
        "Rejouer",
        "Meilleurs scores",
        "Menu principal"
      };
    } else {
      _options = new String[]{
        "Reprendre la partie",
        "Recommencer",
        "Sauvegarder",
        "Charger une partie",
        "Meilleurs scores",
        "Menu principal"
      };
    }
    _nbOptions = _options.length;
  }

  void setMode(String mode) {
    _modeMenu = mode;
    definirOptions();
    _optionSelectionnee = 0;
  }

  void toggle() {
    _afficher = !_afficher;
    _optionSelectionnee = 0;
  }

  void naviguer(int direction) {
    _optionSelectionnee += direction;

    if (_optionSelectionnee < 0) {
      _optionSelectionnee = _nbOptions - 1;
    }
    if (_optionSelectionnee >= _nbOptions) {
      _optionSelectionnee = 0;
    }
  }

  int getOptionSelectionnee() {
    return _optionSelectionnee;
  }

  String getOptionTexte() {
    return _options[_optionSelectionnee];
  }

  void drawIt() {
    if (!_afficher) return;

    fill(0, 0, 0, 200);
    rect(0, 0, width, height);

    fill(#4FC3F7);
    textAlign(CENTER);
    textSize(50);

    if (_modeMenu.equals("defaite")) {
      fill(255, 0, 0);
      text("GAME OVER", width * 0.5, 100);
    } else {
      text("PAUSE", width * 0.5, 100);
    }

    dessinerOptions();
    dessinerInstructions();
  }

  void dessinerOptions() {
    textSize(30);
    for (int i = 0; i < _nbOptions; i++) {
      float y = 200 + i * 50;

      if (i == _optionSelectionnee) {
        fill(0, 255, 255);
        triangle(width * 0.5 - 160, y - 10, width * 0.5 - 180, y - 18, width * 0.5 - 180, y - 2);
      } else {
        fill(255);
      }

      text(_options[i], width * 0.5, y);
    }
  }

  void dessinerInstructions() {
    fill(150);
    textSize(16);
    text("Utilisez HAUT/BAS pour naviguer et ENTREE pour valider", width * 0.5, height - 50);
  }

  void afficherMeilleursScores() {
    fill(0, 0, 0, 220);
    rect(0, 0, width, height);

    fill(#00E5FF);
    textAlign(CENTER);
    textSize(50);
    text("MEILLEURS SCORES", width * 0.5, 80);

    String[] lignes = loadStrings("data/scores.txt");

    if (lignes == null || lignes.length == 0) {
      afficherAucunScore();
    } else {
      afficherListeScores(lignes);
    }

    afficherInstructionRetour();
  }

  void afficherAucunScore() {
    fill(255);
    textSize(25);
    text("Aucun score enregistre", width * 0.5, height * 0.5);
  }

  void afficherListeScores(String[] lignes) {
    fill(255);
    textSize(30);
    int y = 150;

    for (int i = 0; i < min(5, lignes.length); i++) {
      String[] partie = split(lignes[i], ':');
      if (partie.length == 2) {
        text((i+1) + ". " + partie[0] + " - " + partie[1] + " points", width * 0.5, y);
        y += 50;
      }
    }
  }

  void afficherInstructionRetour() {
    textSize(20);
    fill(0, 255, 255);
    text("Appuyez sur ECHAP pour revenir", width * 0.5, height - 50);
    textAlign(LEFT);
  }
}

class MenuDemarrage
{
  int selectedOption;
  String[] options;
  int numOptions;
  float titlePulse;
  float pulseSpeed;
  float titleY;
  float optionsStartY;
  float optionSpacing;

  MenuDemarrage() {
    selectedOption = 0;
    options = new String[]{"JOUER", "QUITTER"};
    numOptions = options.length;
    titlePulse = 0;
    pulseSpeed = 0.04;
    titleY = height * 0.25;
    optionsStartY = height * 0.65;
    optionSpacing = 70;
  }

  void drawIt() {
    background(0);
    titlePulse += pulseSpeed;

    dessinerTitre();
    dessinerDecorations();
    dessinerOptions();
  }

  void dessinerTitre() {
    float pulseSize = sin(titlePulse) * 10;
    textAlign(CENTER, CENTER);
    fill(0, 255, 255);
    textSize(80 + pulseSize);
    text("PAC-MAN", width/2, titleY);
  }

  void dessinerDecorations() {
    fill(0, 200, 255);
    noStroke();
    int numDots = 12;
    float radius = 220;

    for (int i = 0; i < numDots; i++) {
      float angle = TWO_PI * i / numDots + titlePulse * 0.5;
      float x = width/2 + cos(angle) * radius;
      float y = titleY + sin(angle) * radius * 0.6;
      float dotSize = 8 + sin(titlePulse + i) * 3;
      ellipse(x, y, dotSize, dotSize);
    }
  }

  void dessinerOptions() {
    textSize(25);
    for (int i = 0; i < numOptions; i++) {
      float y = optionsStartY + i * optionSpacing;

      if (i == selectedOption) {
        fill(0, 255, 255);
        text(">", width/2 - 95, y);
        text("<", width/2 + 95, y);
        fill(255, 255, 0);
        textSize(40);
      } else {
        fill(200);
        textSize(30);
      }

      fill(255);
      text(options[i], width/2, y);
    }
  }

  void handleKey(int k) {
    if (k == CODED) {
      if (keyCode == UP) {
        naviguerHaut();
      } else if (keyCode == DOWN) {
        naviguerBas();
      }
    } else if (k == ENTER || k == RETURN) {
      selectOption();
    }
  }

  void naviguerHaut() {
    selectedOption--;
    if (selectedOption < 0) {
      selectedOption = numOptions - 1;
    }
  }

  void naviguerBas() {
    selectedOption++;
    if (selectedOption >= numOptions) {
      selectedOption = 0;
    }
  }

  void handleClick(int mx, int my) {
    for (int i = 0; i < numOptions; i++) {
      float y = optionsStartY + i * optionSpacing;
      if (my > y - 30 && my < y + 30) {
        selectedOption = i;
        selectOption();
        break;
      }
    }
  }

  void selectOption() {
    switch(selectedOption) {
    case 0:
      startGame();
      break;
    case 1:
      exit();
      break;
    }
  }
}
