
abstract class ControlLoop {
  protected Viewport viewport;

  public ControlLoop(Viewport viewport) {
    this.viewport = viewport;
  }

  public void setup() {
  }

  public void draw() {
  }

  public boolean isMouseInBounds() {
    return viewport.isMousePresent();
  }

  public void mousePressed() {
  }

  public void mouseDragged() {
  }

  public void mouseReleased() {
  }

  public void mouseClicked() {
  }
}
