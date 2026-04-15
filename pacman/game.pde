class Game
{
  Board _board;
  Hero _hero;
  String _levelName;

  //tableaux pour les 4 fantomes
  PVector[] _fantomesPos;
  PVector[] _fantomesPosInitiale;
  PVector[] _fantomesDirection;
  color[] _fantomesCouleur;
  float[] _fantomesVitesse;
  boolean[] _fantomesVulnerable;
  int[] _fantomesTempsVulnerable;
  boolean[] _fantomesSorti;
  int[] _fantomesTempsAvantSortie;

  //gestion du jeu
  int _score;
  int _vies;
  boolean _partieTerminee;
  int _tempsDebut;
  int _tempsFin;
  boolean _invincible;
  int _tempsInvincibilite;

  //Super Pac-Gomme
  boolean _modeSuperPacGomme;
  int _tempsDebutSuper;
  int _fantomesMangés;

  //bonus
  int _tempsProchainBonus;
  int _delaiBonus;
  boolean _bonusPresent;
  PVector _positionBonus;
  int _tempsDepartBonus;
  int _dureeBonus;

  //score
  boolean _demandeNom;
  String _nomJoueur;

  //son
  PApplet parent;
  GestionnaireSons _sons;
  float _boutonSonX;
  float _boutonSonY;
  float _boutonSonTaille;
  boolean _victoire;

  Game(PApplet p) {
    parent = p;
    _score = 0;
    _vies = 2;
    _partieTerminee = false;
    _demandeNom = false;
    _nomJoueur = "";
    _tempsDebut = millis();
    _modeSuperPacGomme = false;
    _tempsDebutSuper = 0;
    _fantomesMangés = 0;
    _invincible = false;
    _tempsInvincibilite = 0;

    //bonus
    _bonusPresent = false;
    _delaiBonus = 15000;
    _tempsProchainBonus = millis() + _delaiBonus;
    _positionBonus = null;
    _dureeBonus = 8000;
    _tempsDepartBonus = 0;

    //son
    _sons = new GestionnaireSons(parent);
    _boutonSonTaille = 80;
    _boutonSonX = width - _boutonSonTaille - 10;
    _boutonSonY = 10;
    _victoire = false;

    //creation du plateau
    int nbColonnes = 23;
    int nbLignes = 22;
    int tailleCellule = 20;
    float posX = (width - nbColonnes * tailleCellule) / 2;
    float posY = (height - nbLignes * tailleCellule) / 2;

    _board = new Board(new PVector(posX, posY), nbColonnes, nbLignes, tailleCellule);
    _levelName = "levels/level1.txt";
    _board.chargerDepuisFichier(_levelName);

    _hero = new Hero();
    initialiserFantomes();
  }


  void initialiserFantomes() {
    _fantomesPos = new PVector[4];
    _fantomesPosInitiale = new PVector[4];
    _fantomesDirection = new PVector[4];
    _fantomesCouleur = new color[4];
    _fantomesVitesse = new float[4];
    _fantomesVulnerable = new boolean[4];
    _fantomesTempsVulnerable = new int[4];
    _fantomesSorti = new boolean[4];
    _fantomesTempsAvantSortie = new int[4];

    _fantomesPosInitiale[0] = new PVector(10, 9);
    _fantomesPosInitiale[1] = new PVector(11, 9);
    _fantomesPosInitiale[2] = new PVector(12, 9);
    _fantomesPosInitiale[3] = new PVector(13, 9);

    _fantomesCouleur[0] = color(255, 0, 0);
    _fantomesCouleur[1] = color(255, 184, 255);
    _fantomesCouleur[2] = color(0, 255, 255);
    _fantomesCouleur[3] = color(255, 184, 82);

    int[] delais = {0, 3000, 6000, 9000};

    for (int i = 0; i < 4; i++) {
      _fantomesPos[i] = _fantomesPosInitiale[i].copy();
      _fantomesDirection[i] = new PVector(0, -1);
      _fantomesVitesse[i] = VITESSE_FANTOME;
      _fantomesVulnerable[i] = false;
      _fantomesTempsVulnerable[i] = 0;
      _fantomesSorti[i] = false;
      _fantomesTempsAvantSortie[i] = millis() + delais[i];
    }
  }

  void recommencer() {
    _score = 0;
    _vies = 2;
    _partieTerminee = false;
    _demandeNom = false;
    _nomJoueur = "";
    _tempsDebut = millis();
    _modeSuperPacGomme = false;
    _fantomesMangés = 0;
    _invincible = false;
    _tempsInvincibilite = 0;

    _bonusPresent = false;
    _tempsProchainBonus = millis() + _delaiBonus;
    _positionBonus = null;

    _board.chargerDepuisFichier(_levelName);
    _hero = new Hero();
    initialiserFantomes();
    
    _sons.jouerDebut();

    println("Partie recommencee !");
  }


  void sauvegarderPartie() {
    _board.sauvegarderDansFichier("data/save.txt");

    String[] infos = new String[4];
    infos[0] = "score:" + _score;
    infos[1] = "vies:" + _vies;
    infos[2] = "position:" + _hero._cellPosition.x + "," + _hero._cellPosition.y;
    infos[3] = "temps:" + (millis() - _tempsDebut);
    saveStrings("data/save_info.txt", infos);

    println("Partie sauvegardee !");
  }

  void chargerPartie() {
    _board.chargerDepuisFichier("data/save.txt");

    String[] infos = loadStrings("data/save_info.txt");
    if (infos != null && infos.length >= 4) {
      _score = int(split(infos[0], ':')[1]);
      _vies = int(split(infos[1], ':')[1]);

      String[] pos = split(split(infos[2], ':')[1], ',');
      _hero._cellPosition = new PVector(float(pos[0]), float(pos[1]));

      int tempsEcoule = int(split(infos[3], ':')[1]);
      _tempsDebut = millis() - tempsEcoule;
    }

    _partieTerminee = false;
    println("Partie chargee !");
  }


  void ajouterPoints(int points) {
    int ancienScore = _score;
    _score += points;

    if (ancienScore < POINTS_VIE_BONUS && _score >= POINTS_VIE_BONUS) {
      _vies++;
      println("VIE BONUS GAGNEE !");
    }
  }

  boolean estMeilleurScore(int score) {
    String[] lignes = loadStrings("data/scores.txt");

    if (lignes == null || lignes.length < 5) {
      return true;
    }

    for (int i = 0; i < lignes.length; i++) {
      String[] partie = split(lignes[i], ':');
      if (partie.length == 2) {
        int scoreEnregistre = int(partie[1]);
        if (score > scoreEnregistre) {
          return true;
        }
      }
    }

    return false;
  }

  void ajouterScore(String nom, int score) {
    String[] lignes = loadStrings("data/scores.txt");

    if (lignes == null) {
      lignes = new String[0];
    }

    String[] nouveauxScores = new String[lignes.length + 1];
    for (int i = 0; i < lignes.length; i++) {
      nouveauxScores[i] = lignes[i];
    }
    nouveauxScores[lignes.length] = nom + ":" + score;

    for (int i = 0; i < nouveauxScores.length - 1; i++) {
      for (int j = i + 1; j < nouveauxScores.length; j++) {
        int scoreI = int(split(nouveauxScores[i], ':')[1]);
        int scoreJ = int(split(nouveauxScores[j], ':')[1]);

        if (scoreJ > scoreI) {
          String temp = nouveauxScores[i];
          nouveauxScores[i] = nouveauxScores[j];
          nouveauxScores[j] = temp;
        }
      }
    }

    String[] top5 = new String[min(5, nouveauxScores.length)];
    for (int i = 0; i < top5.length; i++) {
      top5[i] = nouveauxScores[i];
    }

    saveStrings("data/scores.txt", top5);
    println("Score sauvegarde : " + nom + " - " + score);
  }

  void saisirNom(char c) {
    if (c == BACKSPACE && _nomJoueur.length() > 0) {
      _nomJoueur = _nomJoueur.substring(0, _nomJoueur.length() - 1);
    } else if (c == ENTER || c == RETURN) {
      if (_nomJoueur.length() > 0) {
        ajouterScore(_nomJoueur, _score);
        _demandeNom = false;
      }
    } else if (c >= 32 && c <= 126 && _nomJoueur.length() < 15) {
      _nomJoueur += c;
    }
  }


  void perdreVie() {
    _vies--;
    _sons.arreterTous();
    _sons.jouerMort();

    if (_vies <= 0) {
      terminerPartie();
    } else {
      _hero._cellPosition = new PVector(11, 16);
      _hero._direction = new PVector(0, 0);
      _hero._nextDirection = new PVector(0, 0);
      _hero._moving = false;

      _invincible = true;
      _tempsInvincibilite = millis();

      for (int i = 0; i < 4; i++) {
        retournerFantomePosition(i);
      }

      println("Vie perdue ! Vies restantes : " + _vies);
    }
  }

  void retournerFantomePosition(int index) {
    _fantomesPos[index] = _fantomesPosInitiale[index].copy();
    _fantomesDirection[index] = new PVector(0, -1);
    _fantomesSorti[index] = false;
    _fantomesTempsAvantSortie[index] = millis() + 2000;
  }


  void mangerGomme(int i, int j) {
    if (_board._cells[i][j] == TypeCell.DOT) {
      _board._cells[i][j] = TypeCell.EMPTY;
      ajouterPoints(POINTS_PAC_GOMME);

      if (!_modeSuperPacGomme) {
        _sons.jouerGomme();
      }
    } else if (_board._cells[i][j] == TypeCell.SUPER_DOT) {
      _board._cells[i][j] = TypeCell.EMPTY;
      ajouterPoints(POINTS_SUPER_PAC_GOMME);
      _sons.jouerSuperGomme();

      _modeSuperPacGomme = true;
      _tempsDebutSuper = millis();
      _fantomesMangés = 0;

      _sons.jouerSuperMode();

      for (int k = 0; k < 4; k++) {
        _fantomesVulnerable[k] = true;
        _fantomesTempsVulnerable[k] = millis();
        _fantomesVitesse[k] = VITESSE_FANTOME_RALENTI;
      }
    } else if (_board._cells[i][j] == TypeCell.BONUS) {
      _board._cells[i][j] = TypeCell.EMPTY;
      ajouterPoints(POINTS_BONUS);
      _sons.jouerBonus();
      println("Bonus mangé ! +" + POINTS_BONUS + " points");
    }
  }


  boolean fantomeAuCroisement(int index) {
    int i = int(_fantomesPos[index].y);
    int j = int(_fantomesPos[index].x);

    float distCentreY = abs(_fantomesPos[index].y - i);
    float distCentreX = abs(_fantomesPos[index].x - j);
    if (distCentreY > 0.3 || distCentreX > 0.3) {
      return false;
    }

    int nbDirections = 0;
    if (i > 0 && _board._cells[i-1][j] != TypeCell.WALL) nbDirections++;
    if (i < _board._nbCellsY-1 && _board._cells[i+1][j] != TypeCell.WALL) nbDirections++;
    if (j > 0 && _board._cells[i][j-1] != TypeCell.WALL) nbDirections++;
    if (j < _board._nbCellsX-1 && _board._cells[i][j+1] != TypeCell.WALL) nbDirections++;

    return nbDirections > 2;
  }

  void choisirDirectionBlinky(int index) {
    ArrayList<PVector> directionsValides = new ArrayList<PVector>();

    int i = int(_fantomesPos[index].y);
    int j = int(_fantomesPos[index].x);

    if (i > 0 && _board._cells[i-1][j] != TypeCell.WALL) {
      directionsValides.add(new PVector(0, -1));
    }
    if (i < _board._nbCellsY-1 && _board._cells[i+1][j] != TypeCell.WALL) {
      directionsValides.add(new PVector(0, 1));
    }
    if (j > 0 && _board._cells[i][j-1] != TypeCell.WALL) {
      directionsValides.add(new PVector(-1, 0));
    }
    if (j < _board._nbCellsX-1 && _board._cells[i][j+1] != TypeCell.WALL) {
      directionsValides.add(new PVector(1, 0));
    }

    if (directionsValides.size() == 0) return;

    PVector meilleureDirection = directionsValides.get(0);
    float minDistance = 999999;

    for (PVector dir : directionsValides) {
      if (dir.x == -_fantomesDirection[index].x && dir.y == -_fantomesDirection[index].y) {
        continue;
      }

      float nouvX = _fantomesPos[index].x + dir.x;
      float nouvY = _fantomesPos[index].y + dir.y;

      float distance = dist(nouvX, nouvY, _hero._cellPosition.x, _hero._cellPosition.y);

      if (distance < minDistance) {
        minDistance = distance;
        meilleureDirection = dir;
      }
    }

    _fantomesDirection[index] = meilleureDirection.copy();
  }

  void choisirDirectionPinky(int index) {
    ArrayList<PVector> directionsValides = new ArrayList<PVector>();

    int i = int(_fantomesPos[index].y);
    int j = int(_fantomesPos[index].x);

    if (i > 0 && _board._cells[i-1][j] != TypeCell.WALL) {
      directionsValides.add(new PVector(0, -1));
    }
    if (i < _board._nbCellsY-1 && _board._cells[i+1][j] != TypeCell.WALL) {
      directionsValides.add(new PVector(0, 1));
    }
    if (j > 0 && _board._cells[i][j-1] != TypeCell.WALL) {
      directionsValides.add(new PVector(-1, 0));
    }
    if (j < _board._nbCellsX-1 && _board._cells[i][j+1] != TypeCell.WALL) {
      directionsValides.add(new PVector(1, 0));
    }

    if (directionsValides.size() == 0) return;

    float anticipationDistance = 4;
    float cibleX = _hero._cellPosition.x + _hero._direction.x * anticipationDistance;
    float cibleY = _hero._cellPosition.y + _hero._direction.y * anticipationDistance;

    if (_hero._direction.x == 0 && _hero._direction.y == 0) {
      cibleX = _hero._cellPosition.x;
      cibleY = _hero._cellPosition.y;
    }

    PVector meilleureDirection = directionsValides.get(0);
    float minDistance = 999999;

    for (PVector dir : directionsValides) {
      if (dir.x == -_fantomesDirection[index].x && dir.y == -_fantomesDirection[index].y) {
        continue;
      }

      float nouvX = _fantomesPos[index].x + dir.x;
      float nouvY = _fantomesPos[index].y + dir.y;

      float distance = dist(nouvX, nouvY, cibleX, cibleY);

      if (distance < minDistance) {
        minDistance = distance;
        meilleureDirection = dir;
      }
    }

    _fantomesDirection[index] = meilleureDirection.copy();
  }

  void choisirDirectionInky(int index) {
    ArrayList<PVector> directionsValides = new ArrayList<PVector>();

    int i = int(_fantomesPos[index].y);
    int j = int(_fantomesPos[index].x);

    if (i > 0 && _board._cells[i-1][j] != TypeCell.WALL) {
      directionsValides.add(new PVector(0, -1));
    }
    if (i < _board._nbCellsY-1 && _board._cells[i+1][j] != TypeCell.WALL) {
      directionsValides.add(new PVector(0, 1));
    }
    if (j > 0 && _board._cells[i][j-1] != TypeCell.WALL) {
      directionsValides.add(new PVector(-1, 0));
    }
    if (j < _board._nbCellsX-1 && _board._cells[i][j+1] != TypeCell.WALL) {
      directionsValides.add(new PVector(1, 0));
    }

    if (directionsValides.size() == 0) return;

    boolean fuir = random(1) < 0.3;

    PVector meilleureDirection = directionsValides.get(0);
    float distanceOptimale = fuir ? -999999 : 999999;

    for (PVector dir : directionsValides) {
      if (dir.x == -_fantomesDirection[index].x && dir.y == -_fantomesDirection[index].y) {
        continue;
      }

      float nouvX = _fantomesPos[index].x + dir.x;
      float nouvY = _fantomesPos[index].y + dir.y;

      float distance = dist(nouvX, nouvY, _hero._cellPosition.x, _hero._cellPosition.y);

      if (fuir) {
        if (distance > distanceOptimale) {
          distanceOptimale = distance;
          meilleureDirection = dir;
        }
      } else {
        if (distance < distanceOptimale) {
          distanceOptimale = distance;
          meilleureDirection = dir;
        }
      }
    }

    _fantomesDirection[index] = meilleureDirection.copy();
  }

  void choisirDirectionClyde(int index) {
    ArrayList<PVector> directionsValides = new ArrayList<PVector>();

    int i = int(_fantomesPos[index].y);
    int j = int(_fantomesPos[index].x);

    if (i > 0 && _board._cells[i-1][j] != TypeCell.WALL) {
      directionsValides.add(new PVector(0, -1));
    }
    if (i < _board._nbCellsY-1 && _board._cells[i+1][j] != TypeCell.WALL) {
      directionsValides.add(new PVector(0, 1));
    }
    if (j > 0 && _board._cells[i][j-1] != TypeCell.WALL) {
      directionsValides.add(new PVector(-1, 0));
    }
    if (j < _board._nbCellsX-1 && _board._cells[i][j+1] != TypeCell.WALL) {
      directionsValides.add(new PVector(1, 0));
    }

    ArrayList<PVector> sansDemiTour = new ArrayList<PVector>();
    for (PVector dir : directionsValides) {
      if (!(dir.x == -_fantomesDirection[index].x && dir.y == -_fantomesDirection[index].y)) {
        sansDemiTour.add(dir);
      }
    }

    if (sansDemiTour.size() > 0) {
      int idx = int(random(sansDemiTour.size()));
      _fantomesDirection[index] = sansDemiTour.get(idx).copy();
    } else if (directionsValides.size() > 0) {
      int idx = int(random(directionsValides.size()));
      _fantomesDirection[index] = directionsValides.get(idx).copy();
    }
  }

  void choisirDirectionFantome(int index) {
    switch(index) {
    case 0:
      choisirDirectionBlinky(index);
      break;
    case 1:
      choisirDirectionPinky(index);
      break;
    case 2:
      choisirDirectionInky(index);
      break;
    case 3:
      choisirDirectionClyde(index);
      break;
    }
  }

  void choisirDirectionFuite(int index) {
    ArrayList<PVector> directionsValides = new ArrayList<PVector>();

    int i = int(_fantomesPos[index].y);
    int j = int(_fantomesPos[index].x);

    if (i > 0 && _board._cells[i-1][j] != TypeCell.WALL) {
      directionsValides.add(new PVector(0, -1));
    }
    if (i < _board._nbCellsY-1 && _board._cells[i+1][j] != TypeCell.WALL) {
      directionsValides.add(new PVector(0, 1));
    }
    if (j > 0 && _board._cells[i][j-1] != TypeCell.WALL) {
      directionsValides.add(new PVector(-1, 0));
    }
    if (j < _board._nbCellsX-1 && _board._cells[i][j+1] != TypeCell.WALL) {
      directionsValides.add(new PVector(1, 0));
    }

    if (directionsValides.size() == 0) return;

    PVector meilleureDirection = directionsValides.get(0);
    float maxDistance = -1;

    for (PVector dir : directionsValides) {
      float nouvX = _fantomesPos[index].x + dir.x;
      float nouvY = _fantomesPos[index].y + dir.y;

      float distance = dist(nouvX, nouvY, _hero._cellPosition.x, _hero._cellPosition.y);

      if (distance > maxDistance) {
        maxDistance = distance;
        meilleureDirection = dir;
      }
    }

    _fantomesDirection[index] = meilleureDirection.copy();
  }

  boolean fantomePeutSeDeplacer(int index) {
    int nouvI = int(_fantomesPos[index].y + _fantomesDirection[index].y);
    int nouvJ = int(_fantomesPos[index].x + _fantomesDirection[index].x);

    if (nouvI < 0 || nouvI >= _board._nbCellsY) return false;
    if (nouvJ < 0 || nouvJ >= _board._nbCellsX) return false;

    return _board._cells[nouvI][nouvJ] != TypeCell.WALL;
  }

  void updateFantome(int index) {
    if (!_fantomesSorti[index]) {
      if (millis() > _fantomesTempsAvantSortie[index]) {
        _fantomesSorti[index] = true;
        choisirDirectionFantome(index);
      }
      return;
    }

    if (_fantomesVulnerable[index] && millis() - _fantomesTempsVulnerable[index] > DUREE_SUPER_GOMME) {
      _fantomesVulnerable[index] = false;
      _fantomesVitesse[index] = VITESSE_FANTOME;
    }

    if (fantomeAuCroisement(index)) {
      if (_fantomesVulnerable[index]) {
        choisirDirectionFuite(index);
      } else {
        choisirDirectionFantome(index);
      }
    }

    if (fantomePeutSeDeplacer(index)) {
      _fantomesPos[index].add(_fantomesDirection[index].copy().mult(_fantomesVitesse[index]));
    } else {
      choisirDirectionFantome(index);
    }
  }

  void drawFantome(int index) {
    PVector pos = _board.getCellCenter(int(_fantomesPos[index].y), int(_fantomesPos[index].x));

    float taille = _board._cellSize * 0.85;

    if (_fantomesVulnerable[index]) {
      int tempsRestant = DUREE_SUPER_GOMME - (millis() - _fantomesTempsVulnerable[index]);
      if (tempsRestant < 2000 && millis() % 400 < 200) {
        fill(255, 255, 255);
      } else {
        fill(_fantomesCouleur[index]);
      }
    } else {
      fill(_fantomesCouleur[index]);
    }

    noStroke();
    arc(pos.x, pos.y, taille, taille, PI, TWO_PI);
    rect(pos.x - taille/2, pos.y, taille, taille * 0.4);

    float basY = pos.y + taille * 0.4;
    int nbVagues = 3;
    float largeurVague = taille / nbVagues;

    for (int i = 0; i < nbVagues; i++) {
      float x1 = pos.x - taille/2 + i * largeurVague;
      float x2 = x1 + largeurVague;

      float offset = sin(millis() * 0.01 + index + i) * 2;

      beginShape();
      vertex(x1, basY);
      bezierVertex(x1, basY + taille * 0.15 + offset,
        x2, basY + taille * 0.15 + offset,
        x2, basY);
      endShape(CLOSE);
    }

    if (!_fantomesSorti[index]) {
      return;
    }

    float tailleOeil = taille * 0.25;
    float ecartYeux = taille * 0.25;
    float hauteurYeux = pos.y - taille * 0.1;

    fill(255);
    ellipse(pos.x - ecartYeux, hauteurYeux, tailleOeil, tailleOeil * 1.2);
    ellipse(pos.x + ecartYeux, hauteurYeux, tailleOeil, tailleOeil * 1.2);

    fill(0, 0, 150);
    float decalageX = _fantomesDirection[index].x * taille * 0.06;
    float decalageY = _fantomesDirection[index].y * taille * 0.06;

    float taillePupille = tailleOeil * 0.5;
    ellipse(pos.x - ecartYeux + decalageX, hauteurYeux + decalageY, taillePupille, taillePupille);
    ellipse(pos.x + ecartYeux + decalageX, hauteurYeux + decalageY, taillePupille, taillePupille);
  }

  boolean fantomeTouchePacman(int index) {
    if (!_fantomesSorti[index]) return false;

    PVector posFantome = _board.getCellCenter(int(_fantomesPos[index].y), int(_fantomesPos[index].x));
    PVector posPacman = _board.getCellCenter(int(_hero._cellPosition.y), int(_hero._cellPosition.x));

    float distancePixels = dist(posFantome.x, posFantome.y, posPacman.x, posPacman.y);

    return distancePixels < _board._cellSize * 0.7;
  }


  void faireApparaitreBonus() {
    ArrayList<PVector> positionsVides = new ArrayList<PVector>();

    for (int i = 0; i < _board._nbCellsY; i++) {
      for (int j = 0; j < _board._nbCellsX; j++) {
        if (_board._cells[i][j] == TypeCell.EMPTY && (_board._cellsInitiales[i][j] == TypeCell.DOT || _board._cellsInitiales[i][j] == TypeCell.SUPER_DOT)) {
          positionsVides.add(new PVector(j, i));
        }
      }
    }

    if (positionsVides.size() > 0) {
      int index = int(random(positionsVides.size()));
      _positionBonus = positionsVides.get(index);

      _board._cells[int(_positionBonus.y)][int(_positionBonus.x)] = TypeCell.BONUS;
      _bonusPresent = true;
      _tempsDepartBonus = millis();

      println("Bonus apparu !");
    }
  }

  void supprimerBonus() {
    if (_bonusPresent && _positionBonus != null) {
      if (_board._cells[int(_positionBonus.y)][int(_positionBonus.x)] == TypeCell.BONUS) {
        _board._cells[int(_positionBonus.y)][int(_positionBonus.x)] = TypeCell.EMPTY;
      }
      _bonusPresent = false;
      _positionBonus = null;
      println("Bonus disparu !");
    }
  }


  void verifierFinPartie() {
    if (_vies <= 0) {
      _victoire = false;
      terminerPartie();
    }

    if (_board.compterGommes() == 0) {
      _victoire = true;
      int tempsEcoule = (millis() - _tempsDebut) / 1000;
      int bonusTemps = max(0, 300 - tempsEcoule) * 10;
      ajouterPoints(bonusTemps);

      _sons.arreterTous();
      _sons.jouerVictoire();

      _partieTerminee = true;
      _tempsFin = millis();

      if (estMeilleurScore(_score)) {
        _demandeNom = true;
      }
    }
  }


  void terminerPartie() {
    _partieTerminee = true;
    _tempsFin = millis();
    _sons.arreterTous();

    if (estMeilleurScore(_score)) {
      _demandeNom = true;
    }
  }


  void updateIt() {
    if (_partieTerminee || _demandeNom) return;

    if (!_bonusPresent && millis() > _tempsProchainBonus) {
      faireApparaitreBonus();
      _tempsProchainBonus = millis() + _delaiBonus;
    }

    if (_bonusPresent && millis() - _tempsDepartBonus > _dureeBonus) {
      supprimerBonus();
    }

    if (_modeSuperPacGomme && millis() - _tempsDebutSuper > DUREE_SUPER_GOMME) {
      _modeSuperPacGomme = false;
      _sons.arreterSuperMode();
    }

    if (_invincible && millis() - _tempsInvincibilite > 2000) {
      _invincible = false;
    }

    _hero.updateIt(_board);

    for (int i = 0; i < 4; i++) {
      updateFantome(i);
    }

    int i = int(_hero._cellPosition.y);
    int j = int(_hero._cellPosition.x);
    mangerGomme(i, j);

    if (!_invincible) {
      for (int k = 0; k < 4; k++) {
        if (fantomeTouchePacman(k)) {
          if (_fantomesVulnerable[k]) {
            int points = POINTS_FANTOME * (int)pow(2, _fantomesMangés);
            ajouterPoints(points);
            _fantomesMangés++;
            retournerFantomePosition(k);
            _sons.jouerFantome();
            println("Fantome mange ! +" + points + " points");
          } else {
            println("Touche par un fantome !");
            perdreVie();
          }
        }
      }
    }

    verifierFinPartie();
  }


  void drawIt() {
    if (_modeSuperPacGomme) {
      background(10, 10, 50);
    } else {
      background(0);
    }

    _board.drawIt();

    for (int i = 0; i < 4; i++) {
      drawFantome(i);
    }

    _hero.drawIt(_board);

    if (_invincible && millis() % 300 < 150) {
      PVector pos = _board.getCellCenter(int(_hero._cellPosition.y), int(_hero._cellPosition.x));
      noFill();
      stroke(255);
      strokeWeight(2);
      ellipse(pos.x, pos.y, _board._cellSize * 1.5, _board._cellSize * 1.5);
    }

    int tempsEcoule;
    if (_partieTerminee) {
      tempsEcoule = (_tempsFin - _tempsDebut) / 1000;
    } else {
      tempsEcoule = (millis() - _tempsDebut) / 1000;
    }

    fill(255);
    textSize(24);
    textAlign(CENTER);

    String infoJeu = "Score: " + _score + "     Vies: " + _vies + "     Temps: " + tempsEcoule;
    text(infoJeu, width * 0.5, 30);


    if (_modeSuperPacGomme) {
      int tempsRestant = (DUREE_SUPER_GOMME - (millis() - _tempsDebutSuper)) / 1000;
      fill(0, 255, 255);
      textSize(15);
      text("SUPER MODE: " + tempsRestant + "s", width * 0.5, 80);
    }

    if (_partieTerminee && !_demandeNom) {
      fill(0, 0, 0, 200);
      rect(0, 0, width, height);

      fill(#00E5FF);
      textAlign(CENTER);
      textSize(50);
      text("PARTIE TERMINEE", width * 0.5, height * 0.5 - 80);

      fill(255);
      textSize(30);
      text("Score final : " + _score, width * 0.5, height * 0.5 - 20);

      int temps = (_tempsFin - _tempsDebut) / 1000;
      text("Temps : " + temps + " secondes", width * 0.5, height * 0.5 + 20);

      textSize(20);
      text("Appuyez sur ECHAP pour le menu", width * 0.5, height * 0.5 + 80);
    }

    if (_demandeNom) {
      fill(0, 0, 0, 220);
      rect(0, 0, width, height);

      fill(#00FF7F);
      textAlign(CENTER);
      textSize(50);
      text("NOUVEAU RECORD !", width * 0.5, height * 0.5 - 100);

      fill(255);
      textSize(30);
      text("Score : " + _score, width * 0.5, height * 0.5 - 40);
      text("Entrez votre nom :", width * 0.5, height * 0.5 + 20);

      fill(#E8F0FF);
      textSize(40);
      String affichage = _nomJoueur;
      if (millis() % 1000 < 500) {
        affichage += "_";
      }
      text(affichage, width * 0.5, height * 0.5 + 80);

      fill(200);
      textSize(20);
      text("Appuyez sur ENTREE pour valider", width * 0.5, height * 0.5 + 140);
    }

    if (!_partieTerminee) {
      dessinerBoutonSon();
    }
  }

  void dessinerBoutonSon() {
    if (_sons.actif) {
      fill(#79FF89);
    } else {
      fill(#F78998);
    }

    stroke(0, 255, 255);
    strokeWeight(2);
    rect(_boutonSonX, _boutonSonY, 80, 30, 20);

    fill(0);
    textAlign(CENTER, CENTER);
    textSize(14);
    text("SON", _boutonSonX + 40, _boutonSonY + 15);
    noStroke();
  }


  void gererClicSouris(int mx, int my) {
    if (menuPause._afficher) {
      return;
    }

    if (mx >= _boutonSonX && mx <= _boutonSonX + 80 &&
      my >= _boutonSonY && my <= _boutonSonY + 30) {
      _sons.activerDesactiver();
      if (!_sons.actif) {
        _sons.arreterTous();
      }
    }
  }
}
