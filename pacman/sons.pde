import processing.sound.*;

class GestionnaireSons {
  SoundFile sonDebut;
  SoundFile sonGomme;
  SoundFile sonSuperGomme;
  SoundFile sonFantome;
  SoundFile sonMort;
  SoundFile sonBonus;
  SoundFile sonVictoire;
  SoundFile sonSuperMode;

  boolean actif;
  PApplet parent;
  int _dernierSonGomme = 0;

  GestionnaireSons(PApplet p) {
    parent = p;
    actif = true;
    chargerSons();
  }

  void chargerSons() {
    sonDebut = new SoundFile(parent, "data/sounds/debut.wav");
    sonGomme = new SoundFile(parent, "data/sounds/manger_gomme.wav");
    sonSuperGomme = new SoundFile(parent, "data/sounds/manger_super_gomme.wav");
    sonFantome = new SoundFile(parent, "data/sounds/manger_fantome.wav");
    sonMort = new SoundFile(parent, "data/sounds/mort.wav");
    sonBonus = new SoundFile(parent, "data/sounds/bonus.wav");
    sonSuperMode = new SoundFile(parent, "data/sounds/super_mode.wav");
    sonVictoire = new SoundFile(parent, "data/sounds/victoire.wav");
  }

  void jouerDebut() {
    if (actif && sonDebut != null && !sonDebut.isPlaying()) {
      sonDebut.play();
    }
  }

  void jouerGomme() {
    if (actif && sonGomme != null) {
      if (millis() - _dernierSonGomme > 100) {
        sonGomme.stop();
        sonGomme.play();
        _dernierSonGomme = millis();
      }
    }
  }

  void jouerSuperGomme() {
    if (actif && sonSuperGomme != null && !sonSuperGomme.isPlaying()) {
      sonSuperGomme.play();
    }
  }

  void jouerFantome() {
    if (actif && sonFantome != null && !sonFantome.isPlaying()) {
      sonFantome.play();
    }
  }

  void jouerMort() {
    if (actif && sonMort != null && !sonMort.isPlaying()) {
      sonMort.play();
    }
  }

  void jouerBonus() {
    if (actif && sonBonus != null && !sonBonus.isPlaying()) {
      sonBonus.play();
    }
  }


  void jouerSuperMode() {
    if (actif && sonSuperMode != null) {
      if (sonGomme != null) sonGomme.stop();
      if (sonFantome != null) sonFantome.stop();
      if (sonMort != null) sonMort.stop();
      if (sonBonus != null) sonBonus.stop();

      sonSuperMode.stop();
      sonSuperMode.loop();
    }
  }


  void arreterSuperMode() {
    if (sonSuperMode != null) {
      sonSuperMode.stop();
    }
  }


  void jouerVictoire() {
    if (actif && sonVictoire != null && !sonVictoire.isPlaying()) {
      sonVictoire.play();
    }
  }

  void arreterTous() {
    if (sonGomme != null) sonGomme.stop();
    if (sonSuperGomme != null) sonSuperGomme.stop();
    if (sonFantome != null) sonFantome.stop();
    if (sonMort != null) sonMort.stop();
    if (sonBonus != null) sonBonus.stop();
    if (sonSuperMode != null) sonSuperMode.stop();
    if (sonVictoire != null) sonVictoire.stop();
  }

  void activerDesactiver() {
    actif = !actif;
  }
}
