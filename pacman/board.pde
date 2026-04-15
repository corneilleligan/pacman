enum TypeCell
{
  EMPTY, WALL, DOT, SUPER_DOT, PACMAN, BONUS
}

class Board
{
  TypeCell _cells[][];
  TypeCell _cellsInitiales[][];
  PVector _position;
  int _nbCellsX;
  int _nbCellsY;
  int _cellSize;

  Board(PVector position, int nbCellsX, int nbCellsY, int cellSize) {
    _position = position;
    _nbCellsX = nbCellsX;
    _nbCellsY = nbCellsY;
    _cellSize = cellSize;
    _cells = new TypeCell[nbCellsY][nbCellsX];
    _cellsInitiales = new TypeCell[nbCellsY][nbCellsX];

    for (int i = 0; i < nbCellsY; i++) {
      for (int j = 0; j < nbCellsX; j++) {
        _cells[i][j] = TypeCell.EMPTY;
        _cellsInitiales[i][j] = TypeCell.EMPTY; 
      }
    }
  }

  PVector getCellCenter(int i, int j) {
    float x = _position.x + j * _cellSize + _cellSize * 0.5;
    float y = _position.y + i * _cellSize + _cellSize * 0.5;
    return new PVector(x, y);
  }

  void drawIt() {
    fill(20, 20, 80);
    noStroke();
    for (int i = 0; i < _nbCellsY; i++) {
      for (int j = 0; j < _nbCellsX; j++) {
        if (_cells[i][j] == TypeCell.WALL) {
          float x = _position.x + j * _cellSize;
          float y = _position.y + i * _cellSize;
          rect(x, y, _cellSize, _cellSize);
        }
      }
    }

    stroke(33, 33, 222);
    strokeWeight(3);
    for (int i = 0; i < _nbCellsY; i++) {
      for (int j = 0; j < _nbCellsX; j++) {
        if (_cells[i][j] == TypeCell.WALL) {
          float x = _position.x + j * _cellSize;
          float y = _position.y + i * _cellSize;

          boolean murHaut = (i > 0 && _cells[i-1][j] == TypeCell.WALL);
          boolean murBas = (i < _nbCellsY-1 && _cells[i+1][j] == TypeCell.WALL);
          boolean murGauche = (j > 0 && _cells[i][j-1] == TypeCell.WALL);
          boolean murDroite = (j < _nbCellsX-1 && _cells[i][j+1] == TypeCell.WALL);

          if (!murHaut) {
            line(x, y, x + _cellSize, y);
          }
          if (!murBas) {
            line(x, y + _cellSize, x + _cellSize, y + _cellSize);
          }
          if (!murGauche) {
            line(x, y, x, y + _cellSize);
          }
          if (!murDroite) {
            line(x + _cellSize, y, x + _cellSize, y + _cellSize);
          }
        }
      }
    }

    for (int i = 0; i < _nbCellsY; i++) {
      for (int j = 0; j < _nbCellsX; j++) {
        float x = _position.x + j * _cellSize;
        float y = _position.y + i * _cellSize;

        switch(_cells[i][j]) {
        case DOT:
          noStroke();
          fill(255, 255, 255);
          ellipse(x + _cellSize * 0.5, y + _cellSize * 0.5, 4, 4);
          break;

        case SUPER_DOT:
          noStroke();
          fill(255, 255, 255);
          float taille = 10 + sin(millis() * 0.005) * 2;
          ellipse(x + _cellSize * 0.5, y + _cellSize * 0.5, taille, taille);
          break;

        case BONUS:
          noStroke();
          fill(255, 0, 0);
          ellipse(x + _cellSize * 0.5 - _cellSize * 0.15, y + _cellSize * 0.5, _cellSize * 0.25, _cellSize * 0.25);
          ellipse(x + _cellSize * 0.5 + _cellSize * 0.15, y + _cellSize * 0.5, _cellSize * 0.25, _cellSize * 0.25);
          stroke(0, 255, 0);
          strokeWeight(2);
          line(x + _cellSize * 0.5, y + _cellSize * 0.5 - _cellSize * 0.15,
            x + _cellSize * 0.5, y + _cellSize * 0.5 - _cellSize * 0.35);
          break;

        case EMPTY:
        case WALL:
        case PACMAN:
          break;
        }
      }
    }
  }

  void chargerDepuisFichier(String nomFichier) {
    String[] lignes = loadStrings(nomFichier);

    for (int i = 1; i < lignes.length; i++) {
      String ligne = lignes[i];

      for (int j = 0; j < ligne.length(); j++) {
        if (i-1 < _nbCellsY && j < _nbCellsX) {
          char c = ligne.charAt(j);

          switch(c) {
          case 'x':
            _cells[i-1][j] = TypeCell.WALL;
            break;
          case 'V':
            _cells[i-1][j] = TypeCell.EMPTY;
            break;
          case 'o':
            _cells[i-1][j] = TypeCell.DOT;
            break;
          case 'O':
            _cells[i-1][j] = TypeCell.SUPER_DOT;
            break;
          case 'P':
            _cells[i-1][j] = TypeCell.PACMAN;
            break;
          case 'B':
            _cells[i-1][j] = TypeCell.BONUS;
            break;
          default:
            _cells[i-1][j] = TypeCell.EMPTY;
          }
        }
      }
    }

    for (int i = 0; i < _nbCellsY; i++) {
      for (int j = 0; j < _nbCellsX; j++) {
        _cellsInitiales[i][j] = _cells[i][j];
      }
    }

  }

  void sauvegarderDansFichier(String nomFichier) {
    String[] lignes = new String[_nbCellsY + 1];

    lignes[0] = "Partie sauvegardee";

    for (int i = 0; i < _nbCellsY; i++) {
      String ligne = "";

      for (int j = 0; j < _nbCellsX; j++) {
        char c = typeCellVersChar(_cells[i][j]);
        ligne += c;
      }

      lignes[i + 1] = ligne;
    }

    saveStrings(nomFichier, lignes);
    println("Plateau sauvegardé dans " + nomFichier);
  }

  char typeCellVersChar(TypeCell type) {
    switch(type) {
    case WALL:
      return 'x';
    case EMPTY:
      return 'V';
    case DOT:
      return 'o';
    case SUPER_DOT:
      return 'O';
    case PACMAN:
      return 'P';
    case BONUS:
      return 'B';
    default:
      return 'V';
    }
  }

  int compterGommes() {
    int compte = 0;
    for (int i = 0; i < _nbCellsY; i++) {
      for (int j = 0; j < _nbCellsX; j++) {
        if (_cells[i][j] == TypeCell.DOT || _cells[i][j] == TypeCell.SUPER_DOT) {
          compte++;
        }
      }
    }
    return compte;
  }
}
