class Hero
{
  PVector _position;
  PVector _posOffset;
  int _cellX, _cellY;
  float _size;

  PVector _direction;
  boolean _moving;

  PVector _cellPosition;
  PVector _nextDirection;
  float _vitesse;
  float _angleBouche;

  Hero() {
    _position = new PVector(0, 0);
    _posOffset = new PVector(0, 0);
    _cellX = 11;
    _cellY = 16;
    _size = 20;
    _direction = new PVector(0, 0);
    _moving = false;

    _cellPosition = new PVector(11, 16);
    _nextDirection = new PVector(0, 0);
    _vitesse = VITESSE_PACMAN;
    _angleBouche = 0;
  }

  void changerDirection(PVector nouvelleDirection) {
    _nextDirection = nouvelleDirection.copy();
  }

  boolean peutSeDeplacer(Board board, PVector direction) {
    float nouvI = _cellPosition.y + direction.y;
    float nouvJ = _cellPosition.x + direction.x;

    if (nouvI < 0) nouvI = board._nbCellsY - 1;
    if (nouvI >= board._nbCellsY) nouvI = 0;
    if (nouvJ < 0) nouvJ = board._nbCellsX - 1;
    if (nouvJ >= board._nbCellsX) nouvJ = 0;

    return board._cells[int(nouvI)][int(nouvJ)] != TypeCell.WALL;
  }

  void launchMove(PVector dir) {
    _nextDirection = dir.copy();
  }

  void move(Board board) {
    if (peutSeDeplacer(board, _direction)) {
      _cellPosition.add(_direction.copy().mult(_vitesse));

      if (_cellPosition.y < 0) _cellPosition.y = board._nbCellsY - 1;
      if (_cellPosition.y >= board._nbCellsY) _cellPosition.y = 0;
      if (_cellPosition.x < 0) _cellPosition.x = board._nbCellsX - 1;
      if (_cellPosition.x >= board._nbCellsX) _cellPosition.x = 0;

      _moving = true;
      _angleBouche = sin(millis() * 0.015) * 0.4;
    } else {
      _moving = false;
      _angleBouche = 0;
    }
  }

  void update(Board board) {
    if (_nextDirection.x != 0 || _nextDirection.y != 0) {
      if (peutSeDeplacer(board, _nextDirection)) {
        _direction = _nextDirection.copy();
        _nextDirection = new PVector(0, 0);
      }
    }

    move(board);

    _cellX = int(_cellPosition.x);
    _cellY = int(_cellPosition.y);
    _position = board.getCellCenter(_cellY, _cellX);
  }

  void updateIt(Board board) {
    update(board);
  }

  void drawIt() {
  }

  void drawIt(Board board) {
    PVector pos = board.getCellCenter(int(_cellPosition.y), int(_cellPosition.x));

    fill(255, 255, 0);
    noStroke();

    // angle de rotation
    float angle = 0;
    if (_direction.x > 0) angle = 0;
    else if (_direction.x < 0) angle = PI;
    else if (_direction.y < 0) angle = -HALF_PI;
    else if (_direction.y > 0) angle = HALF_PI;

    float rayonPacman = board._cellSize * 0.9 * 0.5;
    float ouvertureBouche = 0.5 + abs(_angleBouche);

    // Dessin du Pac-Man
    arc(pos.x, pos.y, rayonPacman * 2, rayonPacman * 2,
      angle + ouvertureBouche, angle + TWO_PI - ouvertureBouche, PIE);
  }
}
