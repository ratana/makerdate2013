
private ControlLoop currentLoop, demoApp, gameApp;
private Area uiArea;

void setup() {
  int totalWidth = 1200;
  int totalHeight = 800;
  int uiHeight = 200;
  
  Area mainArea = new Area(0, 0, totalWidth, totalHeight);
  Area appArea = new Area(0, 0, totalWidth, totalHeight-uiHeight);
  uiArea = new Area(0, totalHeight-uiHeight, totalWidth, uiHeight);
  
  Viewport appViewport = new Viewport(appArea);
  
  demoApp = new LevelDesigner(appViewport);  
  
  gameApp = new GameApp(appViewport);
  
  currentLoop = gameApp;

  size(totalWidth, totalHeight);
  frameRate(30);
  ellipseMode(RADIUS);
  
  smooth(4);
}

void draw() {
  currentLoop.draw();
  drawUI();
}

void mousePressed() {
  currentLoop.mousePressed();
}

void mouseDragged() {
  currentLoop.mouseDragged();
}

void mouseReleased() {
  currentLoop.mouseReleased();
}

void mouseClicked () {
  currentLoop.mouseClicked();

  if (uiArea.isPresent(new PVector(mouseX, mouseY))) {
    if (currentLoop == demoApp) {
      currentLoop = gameApp;
    } else {
      currentLoop = demoApp;
    }
  }
}

void drawUI() {
  stroke(0);
  fill(25);
  rect(uiArea.origin.x, uiArea.origin.y, uiArea.width, uiArea.height);
  fill(255);
  text("click here to switch control loops", uiArea.origin.x + 100, uiArea.origin.y + uiArea.height/2);
}
