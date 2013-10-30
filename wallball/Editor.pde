public class Editor extends ControlLoop {

  private Level level;
  private Button wallButton, ballButton, boxButton;
  private Button newButton, saveButton, openButton, flagButton, startingAreaButton, removeComponentButton;
  private Component selectedComponent;
  private Slider redSlider, greenSlider, blueSlider, velocityXSlider, velocityYSlider, massSlider;
  private ArrayList<Button> buttons = new ArrayList<Button>();
  private ArrayList<Slider> sliders = new ArrayList<Slider>();

  public Component getSelectedComponent() { 
    return selectedComponent;
  }
  public Level getLevel() { 
    return level;
  }

  public void setLevel(Level level) {
    this.level = level;
  }

  // TODO: implement flag
  // TODO: implement starting area
  public Editor(Viewport viewport, Level level) {
    super(viewport);
    this.level = level;
    float buttonWidth = 0.25; // in pct of viewport width
    float buttonHeight = 0.1; // in pct of viewport height
    float buttonMargin = buttonWidth/2;
    float buttonTopMargin = 0.1;
    float sliderHeight = 0.1;

    // place buttons centered in viewport
    newButton = new Button("New", viewport.origin.x + buttonMargin*viewport.width, viewport.origin.y + (buttonTopMargin)*viewport.height, buttonWidth * viewport.width, buttonHeight * viewport.height);
    openButton = new Button("Open", viewport.origin.x + buttonMargin*viewport.width, viewport.origin.y + (buttonTopMargin+buttonHeight)*viewport.height, buttonWidth * viewport.width, buttonHeight * viewport.height);
    saveButton = new Button("Save", viewport.origin.x + buttonMargin*viewport.width, viewport.origin.y + (buttonTopMargin+buttonHeight*2)*viewport.height, buttonWidth * viewport.width, buttonHeight * viewport.height);
    ballButton = new Button("Ball", viewport.origin.x + buttonMargin*viewport.width, viewport.origin.y +(buttonTopMargin+buttonHeight*3.5)*viewport.height, buttonWidth * viewport.width, buttonHeight * viewport.height);
    wallButton = new Button("Wall", viewport.origin.x + buttonMargin*viewport.width, viewport.origin.y + (buttonTopMargin+buttonHeight*4.5)*viewport.height, buttonWidth * viewport.width, buttonHeight * viewport.height);
    boxButton = new Button("Box", viewport.origin.x + buttonMargin*viewport.width, viewport.origin.y + (buttonTopMargin+buttonHeight*5.5)*viewport.height, buttonWidth * viewport.width, buttonHeight * viewport.height);
    flagButton = new Button("Flag", viewport.origin.x + buttonMargin*viewport.width, viewport.origin.y + (buttonTopMargin+buttonHeight*6.5)*viewport.height, buttonWidth * viewport.width, buttonHeight * viewport.height);
    startingAreaButton = new Button("Starting Area", viewport.origin.x + buttonMargin*viewport.width, viewport.origin.y + (buttonTopMargin+buttonHeight*7.5)*viewport.height, buttonWidth * viewport.width, buttonHeight * viewport.height);

    // component editing items
    redSlider = new Slider("Red", viewport.origin.x + viewport.width*0.5, viewport.origin.y + buttonTopMargin * viewport.height, buttonWidth * viewport.width, sliderHeight * viewport.height);
    greenSlider = new Slider("Green", viewport.origin.x + viewport.width*0.5, viewport.origin.y + (buttonTopMargin * viewport.height) + sliderHeight*viewport.height, buttonWidth * viewport.width, sliderHeight * viewport.height);
    blueSlider = new Slider("Blue", viewport.origin.x + viewport.width*0.5, viewport.origin.y + (buttonTopMargin * viewport.height) + sliderHeight*2*viewport.height, buttonWidth * viewport.width, sliderHeight * viewport.height);

    velocityXSlider = new Slider("X Velocity", viewport.origin.x + viewport.width*0.5, viewport.origin.y + buttonTopMargin * viewport.height + sliderHeight*3.5*viewport.height, buttonWidth * viewport.width, sliderHeight * viewport.height);
    velocityYSlider = new Slider("Y Velocity", viewport.origin.x + viewport.width*0.5, viewport.origin.y + (buttonTopMargin * viewport.height) + sliderHeight*4.5*viewport.height, buttonWidth * viewport.width, sliderHeight * viewport.height);
    massSlider = new Slider("Mass", viewport.origin.x + viewport.width*0.5, viewport.origin.y + (buttonTopMargin * viewport.height) + sliderHeight*6*viewport.height, buttonWidth * viewport.width, sliderHeight * viewport.height);

    removeComponentButton = new Button("Remove", viewport.origin.x + viewport.width*0.5, viewport.origin.y + (buttonTopMargin+buttonHeight*7.5)*viewport.height, buttonWidth * viewport.width, buttonHeight * viewport.height);

    buttons.add(ballButton);
    buttons.add(wallButton);
    buttons.add(boxButton);
    buttons.add(newButton);
    buttons.add(saveButton);
    buttons.add(openButton);
    buttons.add(flagButton);
    buttons.add(startingAreaButton);
    buttons.add(removeComponentButton);

    sliders.add(redSlider);
    sliders.add(greenSlider);
    sliders.add(blueSlider);
    sliders.add(velocityXSlider);
    sliders.add(velocityYSlider);
    sliders.add(massSlider);

    setSelectedComponent(null);
  }

  // TODO: get rid of all this instanceof stuff -- take a look at components
  public void setSelectedComponent(Component component) {
    selectedComponent = component;
    if (selectedComponent != null) {
      if (selectedComponent instanceof Ball) {
        Ball cast = (Ball) selectedComponent;
        redSlider.setPosition((cast.objColor >> 16 & 0xFF) / 255.0);
        greenSlider.setPosition((cast.objColor >> 8 & 0xFF) / 255.0);
        blueSlider.setPosition((cast.objColor & 0xFF) / 255.0);
        velocityXSlider.setPosition(cast.velocity.x);
        velocityYSlider.setPosition(cast.velocity.y);
        massSlider.setPosition(cast.mass);

        velocityXSlider.setVisible(true);
        velocityYSlider.setVisible(true);
        massSlider.setVisible(true);
      } 
      else if (selectedComponent instanceof Box) {
        Box cast = (Box) selectedComponent;
        redSlider.setPosition((cast.objColor >> 16 & 0xFF) / 255.0);
        greenSlider.setPosition((cast.objColor >> 8 & 0xFF) / 255.0);
        blueSlider.setPosition((cast.objColor & 0xFF) / 255.0);

        velocityXSlider.setVisible(false);
        velocityYSlider.setVisible(false);
        massSlider.setVisible(false);
      }
      else if (selectedComponent instanceof Wall) {
        Wall cast = (Wall) selectedComponent;
        redSlider.setPosition((cast.objColor >> 16 & 0xFF) / 255.0);
        greenSlider.setPosition((cast.objColor >> 8 & 0xFF) / 255.0);
        blueSlider.setPosition((cast.objColor & 0xFF) / 255.0);

        velocityXSlider.setVisible(false);
        velocityYSlider.setVisible(false);
        massSlider.setVisible(false);
      }
      redSlider.setVisible(true);
      greenSlider.setVisible(true);
      blueSlider.setVisible(true);

      removeComponentButton.setVisible(true);
    } 
    else {
      removeComponentButton.setVisible(false);
      for (Slider slider : sliders) {
        slider.setVisible(false);
      }
    }
  }


  public void draw() {
    stroke(128);
    fill(30);
    rect(viewport.origin.x, viewport.origin.y, viewport.width, viewport.height);

    for (Button button : buttons) {
      button.draw();
    }
    for (Slider slider : sliders) {
      slider.draw();
    }
  }

  @Override 
    public void mouseDragged() {
    for (Slider slider : sliders) {
      slider.mouseDragged();
    }
    boolean colorUpdate = (redSlider.isActive() || greenSlider.isActive() || blueSlider.isActive()); 
    boolean velocityUpdate = (velocityXSlider.isActive() || velocityYSlider.isActive());
    boolean massUpdate = massSlider.isActive();
    int red = (int)(redSlider.getPosition() * 255);
    int green = (int)(greenSlider.getPosition() * 255);
    int blue = (int)(blueSlider.getPosition() * 255);    
    
    if (selectedComponent instanceof Ball) {
      Ball cast = (Ball) selectedComponent;
      if (colorUpdate) {
        cast.objColor = color(red, green, blue);
      }
      if (velocityUpdate) {
        cast.velocity.x = velocityXSlider.getPosition();
        cast.velocity.y = velocityYSlider.getPosition();
      }
      if (massUpdate) {
        cast.mass = massSlider.getPosition();
      }
    } 
    else if (selectedComponent instanceof Wall) {
      Wall cast = (Wall) selectedComponent;
      if (colorUpdate) {
        cast.objColor = color(red, green, blue);
      }
    } else if (selectedComponent instanceof Box) {
      Box cast = (Box) selectedComponent;
      if (colorUpdate) {
        cast.objColor = color(red, green, blue);
      }        
    }
  }

  // Control Loop methods
  @Override
    public void mousePressed() {
    for (Button button : buttons) {
      button.mousePressed();
    }
    for (Slider slider : sliders) {
      slider.mousePressed();
    }
  }

  @Override
    public void mouseReleased() {
    if (wallButton.isActive()) {
      Wall wall = new Wall(0.4, 0.4, 0.6, 0.6, color(255, 255, 255));
      level.getInitialState().addComponent(wall);
      setSelectedComponent(wall);
    } 
    else if (ballButton.isActive()) {
      Ball ball = new Ball(0.5, 0.5, 0.05, color(255, 255, 255));
      level.getInitialState().addComponent(ball);
      setSelectedComponent(ball);
    } 
    else if (boxButton.isActive()) {
      Box box = new Box(0.4, 0.4, 0.6, 0.6, color(255, 255, 255));
      level.getInitialState().addComponent(box);
      setSelectedComponent(box);
    } 
    else if (newButton.isActive()) {
      level.getInitialState().clear();
    } 
    else if (saveButton.isActive()) {
      // invokes global function callback "onSaveLevel" - this has to be a global function, it's not visible otherwise.
      selectOutput("Select a filename to save this Level to.", "onSaveLevel");
    } 
    else if (openButton.isActive()) {
      selectInput("Select a Level file to open.", "onOpenLevel");
    } 
    else if (removeComponentButton.isActive()) {
      level.getInitialState().removeComponent(selectedComponent);
      setSelectedComponent(null);
    }
    for (Button button : buttons) {
      button.mouseReleased();
    }
    for (Slider slider : sliders) {
      slider.mouseReleased();
    }
  }

  public void saveLevelCallback(File selection) {
    saveJSONObject(level.toJSONObject(), selection.getAbsolutePath());
  }

  public void openLevelCallback(File selection) {
    setLevel(new Level(loadJSONObject(selection.getAbsolutePath())));
  }
}

