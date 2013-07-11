

// Colored ball that shines temporarily on impact.
class ColorBall extends Ball {
  color c;
  int impact_countdown, maxc;

  ColorBall(float nx, float ny, float nm, float nr, float nvx, float nvy) {
    super(nx, ny, nm, nr, nvx, nvy);
    c = RandomColor();
    impact_countdown = 0;
  }

  void Draw() {
    if (impact_countdown > 0) {
      fill(MixColors(c, color(255,255,255), 1.0 - 1.0*impact_countdown/maxc));
    } else {
      fill(c);
    }
    ellipse(x, y, r*2, r*2);
    impact_countdown--;
  }

  void Deflect(Wall w) {
    super.Deflect(w);
    maxc = 60;
    impact_countdown = maxc;
  }

  void Deflect(Ball other) {
    super.Deflect(other);
    maxc = 60;
    impact_countdown = maxc;
  }
}

