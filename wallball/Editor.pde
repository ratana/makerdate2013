public class Editor extends ControlLoop {

  private Level level;
  private Button wallButton, ballButton, boxButton;
  private Button newButton, saveButton, openButton, flagButton, startingAreaButton;

  private ArrayList<Button> buttons = new ArrayList<Button>();

  public Level getLevel() { 
    return level;
  }
  
  public void setLevel(Level level) {
    this.level = level;
  }

  // TODO: component selection
  // TODO: edit characteristics of selected component
  //       - color
  //       - velocity
  //       - mass
  //       - etc
  // TODO: implement flag
  // TODO: implement starting area
  public Editor(Viewport viewport, Level level) {
    super(viewport);
    this.level = level;
    float buttonWidth = 0.25; // in pct of viewport width
    float buttonHeight = 0.1; // in pct of viewport height
    float buttonMargin = buttonWidth/2;
    float buttonTopMargin = 0.1;
    
    // place buttons centered in viewport
    newButton = new Button("New", viewport.origin.x + buttonMargin*viewport.width, viewport.origin.y + (buttonTopMargin)*viewport.height, buttonWidth * viewport.width, buttonHeight * viewport.height);
    openButton = new Button("Open", viewport.origin.x + buttonMargin*viewport.width, viewport.origin.y + (buttonTopMargin+buttonHeight)*viewport.height, buttonWidth * viewport.width, buttonHeight * viewport.height);
    saveButton = new Button("Save", viewport.origin.x + buttonMargin*viewport.width, viewport.origin.y + (buttonTopMargin+buttonHeight*2)*viewport.height, buttonWidth * viewport.width, buttonHeight * viewport.height);
    ballButton = new Button("Ball", viewport.origin.x + buttonMargin*viewport.width, viewport.origin.y +(buttonTopMargin+buttonHeight*3.5)*viewport.height, buttonWidth * viewport.width, buttonHeight * viewport.height);
    wallButton = new Button("Wall", viewport.origin.x + buttonMargin*viewport.width, viewport.origin.y + (buttonTopMargin+buttonHeight*4.5)*viewport.height, buttonWidth * viewport.width, buttonHeight * viewport.height);
    boxButton = new Button("Box", viewport.origin.x + buttonMargin*viewport.width, viewport.origin.y + (buttonTopMargin+buttonHeight*5.5)*viewport.height, buttonWidth * viewport.width, buttonHeight * viewport.height);
    flagButton = new Button("Flag", viewport.origin.x + buttonMargin*viewport.width, viewport.origin.y + (buttonTopMargin+buttonHeight*6.5)*viewport.height, buttonWidth * viewport.width, buttonHeight * viewport.height);
    startingAreaButton = new Button("Starting Area", viewport.origin.x + buttonMargin*viewport.width, viewport.origin.y + (buttonTopMargin+buttonHeight*7.5)*viewport.height, buttonWidth * viewport.width, buttonHeight * viewport.height);

    buttons.add(ballButton);
    buttons.add(wallButton);
    buttons.add(boxButton);
    buttons.add(newButton);
    buttons.add(saveButton);
    buttons.add(openButton);
    buttons.add(flagButton);
    buttons.add(startingAreaButton);
  }

  // render to its own viewport
  public void draw() {
    for (Button button : buttons) {
      button.draw();
    }
  }

  public void onSaveLevel(File selection) {
    println("in onSaveLevel(): " + selection.getAbsolutePath());
  }


  // Control Loop methods
  @Override
    public void mousePressed() {
    PVector mouseVector = new PVector(mouseX, mouseY);
    for (Button button : buttons) {
      button.active = button.isPresent(mouseVector);
    }
  }

  @Override
    public void mouseReleased() {
    if (wallButton.active) {
      level.getInitialState().addComponent(new Wall(0.4, 0.4, 0.6, 0.6, color(random(255), random(255), random(255))));
    } 
    else if (ballButton.active) {
      level.getInitialState().addComponent(new Ball(0.5, 0.5, 0.1, color(random(255), random(255), random(255))));
    } 
    else if (boxButton.active) {
      level.getInitialState().addComponent(new Box(0.4, 0.4, 0.6, 0.6, color(random(255), random(255), random(255))));
    } 
    else if (newButton.active) {
      level.getInitialState().clear();
    } 
    else if (saveButton.active) {
      // invokes global function callback "onSaveLevel" - this has to be a global function, it's not visible otherwise.
      selectOutput("Select a filename to save this Level to.", "onSaveLevel");
    } 
    else if (openButton.active) {
      selectInput("Select a Level file to open.", "onOpenLevel");
    }
    for (Button button : buttons) {
      button.active = false;
    }
  }

  public void saveLevelCallback(File selection) {
    saveJSONObject(level.toJSONObject(), selection.getAbsolutePath());
  }
  
  public void openLevelCallback(File selection) {
    // construct level
    setLevel(new Level(loadJSONObject(selection.getAbsolutePath())));
  }
}

