public class LevelDesigner extends ControlLoop {
  private Component selectedComponent;
  private PVector mouseVector = new PVector(mouseX, mouseY);
  private Viewport gameScreen;
  private Viewport editorScreen;
  private Renderer gameRenderer, editorRenderer;
  private Level currentLevel;

  // TODO: would be nice to be able to test the game view, maybe put a bouncing ball in it, with a reset button

  public LevelDesigner(Viewport viewport) {
    super(viewport);
    currentLevel = new Level(); // TODO: pass this to the level designer
    gameRenderer = new GameRenderer();
    editorRenderer = new DesignRenderer();
    gameScreen = new Viewport(viewport.origin.x, viewport.origin.y, viewport.width/2, viewport.height);
    editorScreen = new Viewport(viewport.origin.x + viewport.width/2, viewport.origin.y, viewport.width/4, viewport.height/2);
  }

  @Override
  public void draw() {
    super.draw();
    stroke(0);
    fill(50);
    rect(0,0,width,height);
    
    stroke(100);
    fill(100);
    rect(editorScreen.origin.x, editorScreen.origin.y, editorScreen.width, editorScreen.height);
    editorRenderer.draw(currentLevel.getCurrentState(), editorScreen);
    
    stroke(0);
    fill(0);
    rect(gameScreen.origin.x, gameScreen.origin.y, gameScreen.width, gameScreen.height);
    gameRenderer.draw(currentLevel.getCurrentState(), gameScreen);
  }

  @Override
  public void mouseDragged() {
    if (isMouseInBounds()) {
      if (selectedComponent != null) {
        mouseVector.x = mouseX;
        mouseVector.y = mouseY;
        editorScreen.screenToWorld(mouseVector);
        selectedComponent.moveTo(mouseVector);
      }
    }
  }
  
  @Override
  public void mousePressed() {
    // select a game state component when the mouse is first pressed.
    if (isMouseInBounds()) {
      mouseVector.x = mouseX;
      mouseVector.y = mouseY;
      editorScreen.screenToWorld(mouseVector);
      selectedComponent = currentLevel.getCurrentState().componentAt(mouseVector);
    }
  }  
}
