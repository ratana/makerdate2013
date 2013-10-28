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
    fillColor = color(0,0,0), 
    activeColor = color(0, 0, 255), 
    textColor = color(255, 255, 255);
  public boolean active;
  
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

  public void draw() {
    stroke(strokeColor);
    fill(active ? activeColor : fillColor);
    rect(origin.x, origin.y, width, height);
    fill(textColor);
    textSize(textSize);
    text(title, origin.x + width/2 - textWidth(title)/2, origin.y + height/2 + textSize/2);
  }
}


