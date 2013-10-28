public class LevelDesigner extends ControlLoop {
  private Component selectedComponent;
  private PVector mouseVector = new PVector(mouseX, mouseY);
  private Viewport gameScreen;
  private Viewport editorControlsScreen;
  private Renderer designRenderer;
  private Editor editor;
  
  public Editor getEditor() { return editor; }

  // TODO: would be nice to be able to test the game view, maybe put a bouncing ball in it, with a reset button
  public LevelDesigner(Viewport viewport) {
    super(viewport);
    designRenderer = new DesignRenderer();
    gameScreen = new Viewport(viewport.origin.x, viewport.origin.y, viewport.width/2, viewport.height);    
    editorControlsScreen = new Viewport(viewport.origin.x + viewport.width/2, viewport.origin.y, viewport.width/2, viewport.height);    
    editor = new Editor(editorControlsScreen, new Level());
  }

  @Override
    public void draw() {
    super.draw();
    stroke(0);
    fill(50);
    rect(0, 0, width, height);

//    stroke(100);
//    fill(100);
//    rect(editorScreen.origin.x, editorScreen.origin.y, editorScreen.width, editorScreen.height);
//    designRenderer.draw(currentLevel.getInitialState(), editorScreen);

    stroke(0);
    fill(0);
    rect(gameScreen.origin.x, gameScreen.origin.y, gameScreen.width, gameScreen.height);
    designRenderer.draw(editor.getLevel().getInitialState(), gameScreen);

    editor.draw();
  }

  @Override
    public void mouseDragged() {
    if (isMouseInBounds()) {
      if (selectedComponent != null) {
        mouseVector.x = mouseX;
        mouseVector.y = mouseY;
        gameScreen.screenToWorld(mouseVector);
        selectedComponent.moveTo(mouseVector);
      }
    }
    editor.mouseDragged();
  }

  @Override
    public void mousePressed() {
    // select a game state component when the mouse is first pressed.
    if (isMouseInBounds()) {
      mouseVector.x = mouseX;
      mouseVector.y = mouseY;
      gameScreen.screenToWorld(mouseVector);
      selectedComponent = editor.getLevel().getInitialState().componentAt(mouseVector);
    }
    editor.mousePressed();
  }  

  @Override
    public void mouseReleased() {
    editor.mouseReleased();
  }
}
