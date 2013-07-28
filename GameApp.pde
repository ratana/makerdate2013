

class GameApp extends ControlLoop {
  // taken from "Bounce" example
  int rad = 60;        // Width of the shape
  float xpos, ypos;    // Starting position of shape    

  float xspeed = 5;  // Speed of the shape
  float yspeed = 4;  // Speed of the shape

  int xdirection = 1;  // Left or Right
  int ydirection = 1;  // Top to Bottom

  GameApp(Viewport viewport) {
    super(viewport);
    xpos = viewport.width/2;
    ypos = viewport.height/2;
  }
  void draw() {
    super.draw();
    fill(50);
    rect(viewport.origin.x, viewport.origin.y, viewport.origin.x + viewport.width, viewport.origin.y + viewport.height);
    // Update the position of the shape
    xpos = xpos + ( xspeed * xdirection );
    ypos = ypos + ( yspeed * ydirection );

    // Test to see if the shape exceeds the boundaries of the screen
    // If it does, reverse its direction by multiplying by -1
    if (xpos > viewport.width-rad || xpos < rad) {
      xdirection *= -1;
    }
    if (ypos > viewport.height-rad || ypos < rad) {
      ydirection *= -1;
    }

    // Draw the shape
    ellipse(xpos, ypos, rad, rad);
  }
  void mouseClicked () {
    if (isMouseInBounds()) {
      //
    }
  }
}
