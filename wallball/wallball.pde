
private ControlLoop currentLoop, editorApp, gameApp;
private Area uiArea;
private String activeLoopTitle = "Game";

void setup() {
  int totalWidth = 1200;
  int totalHeight = 800;
  int uiHeight = 200;
  
  Area mainArea = new Area(0, 0, totalWidth, totalHeight);
  Area appArea = new Area(0, 0, totalWidth, totalHeight-uiHeight);
  uiArea = new Area(0, totalHeight-uiHeight, totalWidth, uiHeight);
  
  Viewport appViewport = new Viewport(appArea);
  
  editorApp = new LevelDesigner(appViewport);  
  
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
    if (currentLoop == editorApp) {
      currentLoop = gameApp;
      activeLoopTitle = "Game";
    } else {
      currentLoop = editorApp;
      activeLoopTitle = "Editor";
    }
  }
}

void drawUI() {
  stroke(0);
  fill(25);
  rect(uiArea.origin.x, uiArea.origin.y, uiArea.width, uiArea.height);
  fill(255);
  text(activeLoopTitle, uiArea.origin.x + 100, uiArea.origin.y + uiArea.height/2);
}

// NOTE: this must be a global function to work with selectOutput()
void onSaveLevel(File selection) {
  if (selection == null) {
    println("Window was closed or the user hit cancel.");
  } else {
    println("onSaveLevel: User selected " + selection.getAbsolutePath());    
    // call back to editor
    Editor editor = (Editor)((LevelDesigner)editorApp).getEditor();
    editor.saveLevelCallback(selection);
  }
}

// NOTE: this must be a global function to work with selectInput()
void onOpenLevel(File selection) {
  if (selection == null) {
    println("Window was closed or the user hit cancel.");
  } else {
    println("onOpenLevel: User selected " + selection.getAbsolutePath());    
    // call back to editor
    Editor editor = (Editor)((LevelDesigner)editorApp).getEditor();
    editor.openLevelCallback(selection);
  }
}
