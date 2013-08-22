

class GameApp extends ControlLoop {
  Game game;
  int current_level_id;
  float new_ball_radius;

  GameApp(Viewport viewport) {
    super(viewport);

    game = new Game();
    current_level_id = 0;
    new_ball_radius = -1; // no new ball yet.
  }


  void draw() {
    super.draw();
    fill(50);
    rect(viewport.origin.x, viewport.origin.y, viewport.origin.x + viewport.width, viewport.origin.y + viewport.height);

    Level current_level = game.getLevel(current_level_id);
    current_level.update(0.01);
    current_level.draw(viewport);

    // Draw the 'potential' new ball in a transparent way
    if (new_ball_radius > 0) {
      stroke(color(100, 100, 0, 64));
      fill(color(100, 100, 255, 64));
      ellipse(mouseX, mouseY, viewport.scaleValue(new_ball_radius), viewport.scaleValue(new_ball_radius));
    }

    if (mousePressed) {
      new_ball_radius += 0.001;
    }
  }

  void mousePressed () {
    if (isMouseInBounds()) {
      new_ball_radius = 0.0;
    }
  }

  void mouseReleased () {
    if (isMouseInBounds() && (new_ball_radius > 0)) {
      // Add new ball
      Level current_level = game.getLevel(current_level_id);
      PVector ball_position = viewport.getScreenToWorld(new PVector(mouseX, mouseY));
      Ball ball = new Ball(ball_position.x, ball_position.y, new_ball_radius, color(100, 100, 255));
      boolean success = current_level.addComponent(ball);
    }
    new_ball_radius = -1;
  }
}

