public class LevelDesigner extends ControlLoop {
  private Component selectedComponent;
  private PVector mouseVector = new PVector(mouseX, mouseY);
  private Viewport gameScreen;
  private Viewport editorControlsScreen;
  private DesignRenderer designRenderer;
  private Editor editor;
  private boolean componentMovement = false;
  
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

    stroke(0);
    fill(0);
    rect(gameScreen.origin.x, gameScreen.origin.y, gameScreen.width, gameScreen.height);
    
    // TODO: a bit awkward
    // always refresh this as the editor may have removed or selected something new
    designRenderer.setSelectedComponent(editor.getSelectedComponent());
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
        if (selectedComponent.isPresent(mouseVector) || componentMovement) {
          selectedComponent.moveTo(mouseVector);
        }
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
      Component componentAtMouse = editor.getLevel().getInitialState().componentAt(mouseVector);
      if (componentAtMouse == null && gameScreen.isPresent(mouseX, mouseY)) {
        selectedComponent = null;
        designRenderer.setSelectedComponent(null);
        editor.setSelectedComponent(null);
        componentMovement = false;
      } else if (componentAtMouse != null) { 
        componentMovement = true;
        selectedComponent = componentAtMouse;
        designRenderer.setSelectedComponent(selectedComponent);
        editor.setSelectedComponent(selectedComponent);
      }
    }
    
    editor.mousePressed();
  }  

  @Override
    public void mouseReleased() {
      componentMovement = false;
      editor.mouseReleased();
    
  }
}
