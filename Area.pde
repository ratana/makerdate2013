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
  
  /**
   * determine if component is present at x,y, translated to the viewport
   */
   /*
  boolean isPresent(Component component, PVector location) {   
    return component.isPresent(getNormalized(location));
  }
  */
}
