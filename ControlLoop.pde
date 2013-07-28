
abstract class ControlLoop {
  protected Viewport viewport;
  private boolean mouseInBounds = false;  

  public ControlLoop(Viewport viewport) {
    this.viewport = viewport;
  }

  public void setup() {
  }

  public void draw() {
    mouseInBounds = viewport.isMousePresent();
  }

  public boolean isMouseInBounds() {
    return mouseInBounds;
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
