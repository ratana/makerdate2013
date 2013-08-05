/**
 * Renderer - 
 */
public interface Renderer {  
  /**
   * draws the gamestate to the viewport
   */
  public void draw(GameState gameState, Viewport viewport);
}

/**
 * A game component
 */
public interface Component {
  /**
   * Returns whether the component is present at the query location, i.e., the mouse position
   */
  public boolean isPresent(PVector objLocation);
  /**
   * move the component such that the center becomes objLocation in object space
   */
  public void moveTo(PVector objLocation);
  /** 
   * draw the component to the viewport
   */
  public void draw(Viewport viewport);
  /**
   * draws the bounds of the component
   */
  public void drawBounds(Viewport viewport);

  /*
  Are these two components colliding?
   */
  public boolean isColliding(Component other);
}


// Components that move (can be played forward in time)
public interface PlayableComponent extends Component {
  /*
  Play forward in time by 'time_step' units of time.
   */
  public void Play(float time_step);

  /*
    Deflect off other component. Handle impact dynamics.
   */
  public void Deflect(Component other);
}


/**
 * A collection of components - a single component can also implement ComponentCollection, such as a Wall which will have 2 endpoints which can be interacted with
 */
public interface ComponentCollection {
  /**
   * Returns the first component at the query location, or null if none is present.
   */
  public Component componentAt(PVector objLocation);
}

/**
 * Represents a Wall, made up of a line between two points
 */
public class Wall implements Component, ComponentCollection {
  private static final float CONTROL_RADIUS = 0.01;
  private static final float MIN_CONTROL_RADIUS = 0.005;
  private static final float MAX_CONTROL_RADIUS = 0.02;
  protected Point a, b; // control points
  protected Area boundingBox;
  protected color objColor;
  protected float len;

  public Wall(float topX, float topY, float botX, float botY, color objColor) {
    this.objColor = objColor;
    a = new Point(topX, topY, CONTROL_RADIUS, objColor);
    b = new Point(botX, botY, CONTROL_RADIUS, objColor);

    this.boundingBox = new Area(min(a.center.x, b.center.x), min(a.center.y, b.center.y), abs(a.center.x-b.center.x), abs(a.center.y-b.center.y));
    updateGeometry();
  }

  public boolean isColliding(Component other) {
    // TODO(ciaran): Implement collision detection
    return false;
  }

  public void moveTo(PVector objLocation) {
    // calculate the midpoint of the line, and set the new midpoint to (x, y) by moving the end points
    float midX = boundingBox.origin.x + boundingBox.width/2;
    float midY = boundingBox.origin.y + boundingBox.height/2;

    a.moveTo(a.center.x + (objLocation.x-midX), a.center.y + (objLocation.y-midY));
    b.moveTo(b.center.x + (objLocation.x-midX), b.center.y + (objLocation.y-midY));

    updateGeometry();
  }

  private void updateGeometry() {    
    boundingBox.origin.x = min(a.center.x-a.radius, b.center.x-b.radius);
    boundingBox.origin.y = min(a.center.y-a.radius, b.center.y-b.radius);
    boundingBox.width = abs((a.center.x)-(b.center.x)) + a.radius * 2;
    boundingBox.height = abs((a.center.y)-(b.center.y)) + a.radius * 2;

    len = a.center.dist(b.center);

    // resize control point/endpoint size
    float length = sqrt((a.center.x - b.center.x)*(a.center.x - b.center.x) + (a.center.y-b.center.y)*(a.center.y-b.center.y));
    float newRadius = min(MAX_CONTROL_RADIUS, max(length/10, MIN_CONTROL_RADIUS));
    a.setRadius(newRadius);
    b.setRadius(newRadius);
  }

  public Component componentAt(PVector location) {
    if (a.isPresent(location)) {
      return a;
    } else if (b.isPresent(location)) {
      return b;
    }
    return this;
  }

  public boolean isPresent(PVector location) {
    if (a.isPresent(location) || b.isPresent(location)) {
      return true;
    }
    if (boundingBox.isPresent(location)) {
      // determine that location is close enough to the line - can use refinement
      float length = sqrt((a.center.x - b.center.x)*(a.center.x - b.center.x) + (a.center.y-b.center.y)*(a.center.y-b.center.y));
      float midX = boundingBox.origin.x + boundingBox.width/2;
      float midY = boundingBox.origin.y + boundingBox.height/2;          
      PVector mid = new PVector(midX, midY);
      float distMid = location.dist(mid);
      float distA = location.dist(a.center);
      float distB = location.dist(b.center);

      if (distA < length / 3 || distB < length / 3) {
        return true;
      } 
      return degrees(asin(distMid/distA)) < 15 || degrees(asin(distMid/distB)) < 15;
    }
    return false;
  }

  public void drawBounds(Viewport viewport) {
    // update the bounding box before we draw, a component may have moved.  can implement some callbacks/parent update type stuff if necessary.
    updateGeometry();
    noFill();
    stroke(objColor);
    //rect(viewport.origin.x + viewport.scaleValue(boundingBox.origin.x), viewport.origin.y + viewport.scaleValue(boundingBox.origin.y), 
    //viewport.scaleValue(boundingBox.width), viewport.scaleValue(boundingBox.height));
    a.drawBounds(viewport);
    b.drawBounds(viewport);
  }

  public void draw(Viewport viewport) {
    noFill();
    stroke(objColor);
    line(viewport.origin.x + viewport.scaleValue(a.center.x), viewport.origin.y + viewport.scaleValue(a.center.y), 
    viewport.origin.x + viewport.scaleValue(b.center.x), viewport.origin.y + viewport.scaleValue(b.center.y));
  }
}

/**
 * Represents a point in space, whose radius determines its bounding box for hit-test purposes
 */
public class Point implements Component {
  // TODO(ciaran/adam): boundingBox is a redundant object, as it can be computed from center+radius at any point.
  // If 'isPresent' was being called much more frequently than moveTo or setRadius, then it would make sense to
  // compute it and save its value. However the ball will be in constant motion, meaning that each time center is
  // updated, the bounding box needs to be updated too.
  // This is pretty inefficient, given that the game does not use the bounding box. I'm worried it will slow the graphics down
  // when there are a lot of balls on screen.
  // Suggestion: (i) Remove boundingBox, and only compute it inside isPresent()
  // or (ii) If Component was implemented as an abstract class instead of an interface, you could give it an 'editable' boolean flag.
  // When set to true (in the LevelDesigner), it would update boundingBox. When false, in the game, it would not update it.
  protected Area boundingBox;
  protected PVector center;
  protected float radius;
  protected color objColor;

  public void moveTo(float objX, float objY) {
    center.x = objX;
    center.y = objY;
    boundingBox.origin.x = center.x-radius;
    boundingBox.origin.y = center.y-radius;
    boundingBox.width = radius*2;
    boundingBox.height = radius*2;
  }

  public boolean isColliding(Component other) {
    if (other instanceof Ball) {
      // TODO(ciaran): update this to return false if they're moving away.
      Ball ball = (Ball)other;
      if (center.dist(ball.center) < (radius + ball.radius)) {
        return true;
      }
      return false;
    }
    
    // TODO(ciaran): Implement WALL collision detection
    return false;
  }

  public void moveTo(PVector objLocation) {    
    moveTo(objLocation.x, objLocation.y);
  }

  public void setRadius(float radius) {
    this.radius = radius;
    boundingBox.origin.x = center.x-radius;
    boundingBox.origin.y = center.y-radius;
    boundingBox.width = radius*2;
    boundingBox.height = radius*2;
  }

  public Point(float x, float y, float radius, color objColor) {
    this.objColor = objColor;
    this.radius = radius;
    this.center = new PVector(x, y);
    this.boundingBox = new Area(new PVector(center.x-radius, center.y-radius), radius*2, radius*2);
  }

  public boolean isPresent(PVector location) {
    return boundingBox.isPresent(location);
  }

  public void drawBounds(Viewport viewport) {
    noFill();
    stroke(objColor);
    rect(viewport.origin.x + viewport.scaleValue(boundingBox.origin.x), 
    viewport.origin.y + viewport.scaleValue(boundingBox.origin.y), 
    viewport.scaleValue(boundingBox.width), 
    viewport.scaleValue(boundingBox.height));
  }

  public void draw(Viewport viewport) {
    stroke(objColor);
    fill(objColor);
    ellipse(viewport.origin.x + viewport.scaleValue(center.x), viewport.origin.y + viewport.scaleValue(center.y), viewport.scaleValue(radius), viewport.scaleValue(radius));
  }
}

/**
 * Represents a physical ball - with mass, velocity, etc.
 */
public class Ball extends Point implements PlayableComponent, ComponentCollection {

  private static final float CONTROL_RADIUS = 0.01;
  private static final float MIN_CONTROL_RADIUS = 0.005;
  private Point a, b; // control points for editing
  protected PVector velocity;
  float mass;


  public Ball(float x, float y, float radius, color objColor, float vx, float vy, float mass) {
    super(x, y, radius, objColor);
    a = new Point(center.x-radius+radius/4, center.y-radius+radius/4, radius/4, objColor);
    b = new Point(center.x+radius-radius/4, center.y+radius-radius/4, radius/4, objColor);
    this.mass = mass;
    this.velocity = new PVector(vx, vy);
  }

  public Ball(float x, float y, float radius, color objColor) {
    this(x, y, radius, objColor, 0, 0, 1.0);
  }

  public void Play(float time_step) {
    PVector tmp = velocity.get();
    tmp.mult(time_step);
    center.add(tmp);
  }

  void Deflect(Component other) {
    if (other instanceof Wall) {
      // Assume ball will collide with the wall in the next time step if we don't change its velocity
      // Assume ball moving towards wall currently.
      /*
      Vector ball_pos = new Vector(x, y);
      Vector ball_vel = new Vector(vx, vy);
      float d1 = distance(w.p1, ball_pos);
      float d2 = distance(w.p2, ball_pos);
      float distance_along_wall = (w.line_len*w.line_len + d1*d1 - d2*d2) / (2*w.line_len);

      Vector q;  // point on the wall closest to the ball's center
      if (distance_along_wall <= 0) {
        q = w.p1;
      } else if (distance_along_wall >= w.line_len) {
        q = w.p2;
      } else {
        q = w.p1.add(w.unit.multiply(distance_along_wall));
      }

      Vector new_ball_vel = DoImpact(ball_vel, q.subtract(ball_pos).unit(), -1.0);
      vx = new_ball_vel.x;
      vy = new_ball_vel.y;
      */
    } else if (other instanceof Ball) {
      Ball ball = (Ball)other;
      PVector n = ball.center.get();
      n.sub(center);
      n.normalize();
           
      //new Vector(other.x-x, other.y-y).unit();
      PVector other_vel = ball.velocity;
      PVector original_v1 = velocity.get(); //new Vector(vx, vy).subtract(other_vel);
      original_v1.sub(other_vel);
      
      velocity = DoImpact(original_v1, n, (mass-ball.mass)/(mass+ball.mass));
      velocity.add(other_vel);
      ball.velocity = n.get();
      ball.velocity.mult(2*mass/(mass+ball.mass) * original_v1.dot(n));
      ball.velocity.add(other_vel);

      //vx = new_v1.x;
      //vy = new_v1.y;
      //other.vx = new_v2.x;
      //other.vy = new_v2.y;
    } else {
      println("Unknown type: " + other);
    }
  }


  public void moveTo(float objX, float objY) {
    super.moveTo(objX, objY);

    // move control points
    a.moveTo(center.x-radius+a.radius, center.y-radius+a.radius);
    b.moveTo(center.x+radius-a.radius, center.y+radius-a.radius);
  }  

  public boolean isPresent(PVector location) {
    return super.isPresent(location) || a.isPresent(location) || b.isPresent(location);
  }

  public Component componentAt(PVector location) {
    if (a.isPresent(location)) {
      return a;
    } else if (b.isPresent(location)) {
      return b;
    }
    return this;
  }

  public void drawBounds(Viewport viewport) {
    updateGeometry();
    a.drawBounds(viewport);
    b.drawBounds(viewport);
  }

  public void draw(Viewport viewport) {
    super.draw(viewport);
  }

  private void updateGeometry() {
    radius = max(min(abs(a.center.x - b.center.x)+a.radius*2, abs(a.center.y-b.center.y)+a.radius*2)/2, MIN_CONTROL_RADIUS);

    boundingBox.origin.x = center.x - radius;
    boundingBox.origin.y = center.y - radius;
    boundingBox.width = radius * 2;
    boundingBox.height = radius * 2;

    float newPointRadius = radius/4;

    a.setRadius(newPointRadius);
    b.setRadius(newPointRadius);

    a.moveTo(center.x-radius+a.radius, center.y-radius+a.radius);
    b.moveTo(center.x+radius-a.radius, center.y+radius-a.radius);
  }
} 

/**
 * Represents a Rectangle
 */
public class Box implements Component, ComponentCollection {
  private static final float CONTROL_RADIUS = 0.02;
  protected Point a, b; // control points
  // TODO: add 2 more control points
  protected Area boundingBox;
  protected color objColor;  

  public Box(float topX, float topY, float botX, float botY, color objColor) {
    this.objColor = objColor;
    this.boundingBox = new Area(min(topX, botX), min(topY, botY), abs(topX-botX), abs(topY-botY));    
    a = new Point((botX-topX)/2, topY, CONTROL_RADIUS, objColor);
    b = new Point(botX, (botY-topY)/2, CONTROL_RADIUS, objColor);
  }  

  public boolean isColliding(Component other) {
    // TODO(ciaran): Implement collision detection
    return false;
  }

  public boolean isPresent(PVector location) {
    return boundingBox.isPresent(location) || a.isPresent(location) || b.isPresent(location);
  }

  public void moveTo(PVector objLocation) {
    // calculate the midpoint of the line, and set the new midpoint to (x, y) by moving the end points
    float midX = boundingBox.origin.x + boundingBox.width/2;
    float midY = boundingBox.origin.y + boundingBox.height/2;
    boundingBox.origin.x += (objLocation.x-midX);
    boundingBox.origin.y += (objLocation.y-midY);

    a.moveTo(boundingBox.origin.x + boundingBox.width/2, boundingBox.origin.y);
    b.moveTo(boundingBox.origin.x + boundingBox.width, boundingBox.origin.y + boundingBox.height/2);
  }

  private void updateGeometry() {
    boundingBox.width = abs(b.center.x - boundingBox.origin.x);
    //float oldHeight = boundingBox.height;
    boundingBox.height = abs(a.center.y - (boundingBox.origin.y + boundingBox.height));
    boundingBox.origin.y = a.center.y;

    a.moveTo(boundingBox.origin.x + boundingBox.width/2, boundingBox.origin.y);
    b.moveTo(boundingBox.origin.x + boundingBox.width, boundingBox.origin.y + boundingBox.height/2);
  }

  public void drawBounds(Viewport viewport) {
    // update the bounding box before we draw, a component may have moved.  can implement some callbacks/parent update type stuff if necessary.
    updateGeometry();
    noFill();
    stroke(objColor);
    a.drawBounds(viewport);
    b.drawBounds(viewport);
  }

  public void draw(Viewport viewport) {
    noFill();
    stroke(objColor);
    rect(viewport.origin.x + viewport.scaleValue(boundingBox.origin.x), viewport.origin.y + viewport.scaleValue(boundingBox.origin.y), 
    viewport.scaleValue(boundingBox.width), viewport.scaleValue(boundingBox.height));
  }


  public Component componentAt(PVector location) {
    if (a.isPresent(location)) {
      return a;
    } else if (b.isPresent(location)) {
      return b;
    }
    return this;
  }
}

