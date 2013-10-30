class Area {
  public PVector origin;
  public float width, height;

  public boolean isPresent(PVector worldLocation) {
    if (worldLocation.x > this.origin.x && worldLocation.x < this.origin.x + this.width &&
      worldLocation.y > this.origin.y && worldLocation.y < this.origin.y + this.height) {
      return true;
    }
    return false;
  }

  public boolean isPresent(float x, float y) {
    if (x > this.origin.x && x < this.origin.x + this.width &&
      y > this.origin.y && y < this.origin.y + this.height) {
      return true;
    }
    return false;
  }

  public boolean isMousePresent() {    
    return isPresent(mouseX, mouseY);
  }

  Area (Area area) {
    this.origin = area.origin;
    this.width = area.width;
    this.height = area.height;
  }

  Area (PVector origin, float width, float height) {
    this.origin = origin;
    this.width = width;
    this.height = height;
  }

  Area (float x, float y, float width, float height) {
    this.origin = new PVector(x, y);
    this.width = width;
    this.height = height;
  }
}

class Viewport extends Area {
  Viewport (Area area) {
    super(area);
  }
  Viewport (PVector origin, float width, float height) {
    super(origin, width, height);
  }
  Viewport (float x, float y, float width, float height) {
    super (x, y, width, height);
  }

  public float scaleValue(float worldValue) {
    return worldValue * min(width, height);
  }

  /**
   * returns a normalized vector w/r/t the viewport
   */
  public PVector getScreenToWorld(PVector screenVector) {
    return new PVector((screenVector.x - origin.x)/min(width, height), (screenVector.y-origin.y)/min(width, height));
  }

  /**
   * normalize the given vector to the viewport
   */
  public void screenToWorld(PVector screenVector) {
    screenVector.x = (screenVector.x - origin.x)/min(width, height);
    screenVector.y = (screenVector.y-origin.y)/min(width, height);
  }
}

class Button extends Area {
  public String title;
  public int textSize = 14;
  public color strokeColor = color(127, 127, 127), 
  fillColor = color(0, 0, 0), 
  activeColor = color(0, 0, 255), 
  textColor = color(255, 255, 255);
  private boolean active = false, visible = true;
  public boolean isActive() { 
    return active;
  }

  public boolean isVisible() { 
    return visible;
  }
  public void setVisible(boolean visible) {
    this.visible = visible;
  }

  Button (PVector origin, float width, float height) {
    super(origin, width, height);
  }
  Button (float x, float y, float width, float height) {
    super (x, y, width, height);
  }
  Button (Area area) {
    super(area);
  }
  Button (String title, PVector origin, float width, float height) {
    this(origin, width, height);
    this.title = title;
  }
  Button (String title, float x, float y, float width, float height) {
    this (x, y, width, height);
    this.title = title;
  }
  Button (String title, Area area) {
    this(area);
    this.title = title;
  }

  public void mousePressed() {
    if (isPresent(mouseX, mouseY)) {
      active = true;
    }
  }

  public void mouseReleased() {
    active = false;
  }

  public void draw() {
    if (visible) {
      stroke(strokeColor);
      fill(active ? activeColor : fillColor);
      rect(origin.x, origin.y, width, height);
      fill(textColor);
      textSize(textSize);
      text(title, origin.x + width/2 - textWidth(title)/2, origin.y + height/2 + textSize/2);
    }
  }
}

class Slider extends Area {
  public String title;
  public int textSize = 14;
  private float position = 0; // [0...1] 
  public color strokeColor = color(127, 127, 127), 
  fillColor = color(0, 0, 0), 
  activeColor = color(0, 0, 255), 
  textColor = color(255, 255, 255);
  private boolean active = false, visible = true;
  private Area control;
  public float getPosition() { 
    return position;
  }
  public boolean isActive() { 
    return active;
  }
  public boolean isVisible() { 
    return visible;
  }
  public void setVisible(boolean visible) {
    this.visible = visible;
  }

  public void setPosition(float position) {
    // clamp to [0..1]
    float positionValue = min(max(0, position), 1);
    this.position = positionValue;
    float boxHeight = (height - (textSize*2)) / 2;
    float boxWidth = boxHeight;
    control.origin.x = origin.x + (positionValue * (width - boxWidth));
  }

  private void initControl() {
    float boxHeight = (height - (textSize*2)) / 2;
    float boxWidth = boxHeight;
    control = new Area(origin.x + (position * (width-boxWidth)), origin.y+textSize*2 + boxHeight/2, boxWidth, boxHeight);
  }

  Slider (PVector origin, float width, float height) {
    super(origin, width, height);
    initControl();
  }
  Slider (float x, float y, float width, float height) {
    super (x, y, width, height);
    initControl();
  }
  Slider (Area area) {
    super(area);
    initControl();
  }
  Slider (String title, PVector origin, float width, float height) {
    this(origin, width, height);
    this.title = title;
  }
  Slider (String title, float x, float y, float width, float height) {
    this (x, y, width, height);
    this.title = title;
  }
  Slider (String title, Area area) {
    this(area);
    this.title = title;
  }

  public void mousePressed() {
    if (control.isPresent(mouseX, mouseY)) {
      active = true;
    }
  }

  public void mouseReleased() {
    active = false;
  }

  public void mouseDragged() {
    if (active) {
      control.origin.x = min(max(origin.x, mouseX), origin.x + (width-control.width));
      position = (control.origin.x - origin.x) / (width-control.width);
      println("new position: " + position);
    }
  }

  public void draw() {
    if (visible) {
      stroke(strokeColor);
      float boxHeight = (height - (textSize*2)) / 2;
      float boxWidth = boxHeight;
  
      fill(textColor);
      textSize(textSize);
      text(title, origin.x, origin.y + (textSize*1.5)); //+ width/2 - textWidth(title)/2, origin.y + height/2 + textSize/2);
      line(origin.x + boxWidth/2, origin.y + (textSize*2) + (height - textSize*2)/2, origin.x + width - boxWidth/2, origin.y + textSize*2 + (height - textSize*2)/2);
      // draw control
      fill(active ? activeColor : fillColor);
      rect(control.origin.x, control.origin.y, control.width, control.height);
    }
  }
}

