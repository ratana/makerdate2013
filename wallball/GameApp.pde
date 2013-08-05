

class GameApp extends ControlLoop {
  Game game;
  int current_level_id;

  GameApp(Viewport viewport) {
    super(viewport);
    
    game = new Game();
    current_level_id = 0;
  }
  
  
  void draw() {
    super.draw();
    fill(50);
    rect(viewport.origin.x, viewport.origin.y, viewport.origin.x + viewport.width, viewport.origin.y + viewport.height);
    
    Level current_level = game.getLevel(current_level_id);
    current_level.update(0.001);
    current_level.draw(viewport);
  }
  
  void mouseClicked () {
    if (isMouseInBounds()) {
      //
    }
  }
}
