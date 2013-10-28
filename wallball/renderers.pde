/**
 * Draws bounding boxes around components underneath the mouse cursor
 */
public class DesignRenderer implements Renderer {
    private PVector mouseVector = new PVector();
    public void draw(GameState gameState, Viewport viewport) {
      stroke(0);
      fill(0);
      mouseVector.x = mouseX;
      mouseVector.y = mouseY;
      viewport.screenToWorld(mouseVector);
      if (gameState != null && gameState.getComponents() != null) {
        for (Component component : gameState.getComponents()) {
          if (component.isPresent(mouseVector)) {
            component.drawBounds(viewport);
          }
          component.draw(viewport);
        }
      }
  }
}

/**
 * Standard renderer - draw everything without decoration
 */ 
public class GameRenderer implements Renderer {
    public void draw(GameState gameState, Viewport viewport) {
      stroke(0);
      fill(0);
      for (Component component : gameState.getComponents()) {
        component.draw(viewport);
      }
  }
}
