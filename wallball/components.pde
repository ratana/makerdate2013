/**
 * ComponentFactory - constructs components from JSON
 */
public class ComponentFactory {
  public Component componentForJSONObject(JSONObject json) {
    String objectClass = json.getString("object_class");
    println("compoent for: " + objectClass);
    if (objectClass.equals("Ball")) {
      return new Ball(json);
    } 
    else if (objectClass.equals("Wall")) {
      return new Wall(json);
    } 
    else if (objectClass.equals("Box")) {
      return new Box(json);
    } 
    else {
      println("unrecognized type: " + objectClass);
      return null;
    }
  }
}

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

  /**
   * serialized JSONObject
   */
  public JSONObject toJSONObject();
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
  protected float len; // length of wall (distance between endpoints).
  protected PVector unit; // unit vector in the direction along the wall, from the first to the second endpoint.

  public Wall(JSONObject json) {
    this(new Point(json.getJSONObject("a")), new Point(json.getJSONObject("b")), color(unhex(json.getString("color"))));
  }

  public Wall(Point a, Point b, color objColor) {
    this.a = a;
    this.b = b;
    this.objColor = objColor;

    this.boundingBox = new Area(min(a.center.x, b.center.x), min(a.center.y, b.center.y), abs(a.center.x-b.center.x), abs(a.center.y-b.center.y));
    updateGeometry();
  }

  public Wall(float topX, float topY, float botX, float botY, color objColor) {
    this(new Point(topX, topY, CONTROL_RADIUS, objColor), new Point(botX, botY, CONTROL_RADIUS, objColor), objColor);
  }

  public boolean isColliding(Component other) {
    if (other instanceof Ball) {
      Ball ball = (Ball)other;
      return ball.isColliding(this);
    }

    // Walls are not considered colliding with each other, even if they overlap.    
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
    unit = PVector.sub(b.center, a.center);
    unit.normalize();
    println("Wall unit vector = "+unit);

    // resize control point/endpoint size
    float length = sqrt((a.center.x - b.center.x)*(a.center.x - b.center.x) + (a.center.y-b.center.y)*(a.center.y-b.center.y));
    float newRadius = min(MAX_CONTROL_RADIUS, max(length/10, MIN_CONTROL_RADIUS));
    a.setRadius(newRadius);
    b.setRadius(newRadius);
  }

  public Component componentAt(PVector location) {
    if (a.isPresent(location)) {
      return a;
    } 
    else if (b.isPresent(location)) {
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

  public JSONObject toJSONObject() {
    JSONObject json = new JSONObject();
    json.setString("object_class", "Wall");
    json.setJSONObject("a", a.toJSONObject());
    json.setJSONObject("b", b.toJSONObject());    
    json.setString("color", hex(objColor)); 
    return json;
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

  // NOTE FROM ADAM: I believe that the boundingbox is only computed when drawbounds is called, and that is only done in the design renderer -- but I agree,
  // this is a clunky way to do things, and it should be refactored.. The level editor should perhaps instead "decorate" these objects and add such things, rather than
  // they be inherent to the objects themselves if not necessary.

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
    if (other instanceof Point) {
      // TODO(ciaran): update this to return false if they're moving away.
      Point point = (Point)other;
      if (center.dist(point.center) < (radius + point.radius)) {
        return true;
      }
      return false;
    }

    if (other instanceof Wall) {
      Wall w = (Wall)other;
      float line_dist = PointLineDistance(center, w);
      return line_dist < radius;
    }
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
  
  public Point(JSONObject json) {
    this(PVectorFromJSONObject(json.getJSONObject("center")).x, PVectorFromJSONObject(json.getJSONObject("center")).y,
      json.getFloat("radius"), color(unhex(json.getString("color"))));
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

  public JSONObject toJSONObject() {
    JSONObject json = new JSONObject();
    json.setString("object_class", "Point");
    json.setJSONObject("center", PVectorToJSONObject(center));
    json.setFloat("radius", radius);
    json.setString("color", hex(objColor)); 
    return json;
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

  public Ball(JSONObject json) {
    this(PVectorFromJSONObject(json.getJSONObject("center")), 
    json.getFloat("radius"), 
    color(unhex(json.getString("color"))), 
    PVectorFromJSONObject(json.getJSONObject("velocity")), 
    json.getFloat("mass")
      );
  }

  public Ball(PVector centerPoint, float radius, color objColor, PVector velocityVector, float mass) {
    this(centerPoint.x, centerPoint.y, radius, objColor, velocityVector.x, velocityVector.y, mass);
  }

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

      Wall w = (Wall)other;
      PVector ball_pos = center;
      PVector ball_vel = velocity;
      float d1 = PVector.dist(w.a.center, center);
      float d2 = PVector.dist(w.b.center, center);
      float distance_along_wall = (w.len*w.len + d1*d1 - d2*d2) / (2*w.len);

      PVector q;  // point on the wall closest to the ball's center
      if (distance_along_wall <= 0) {
        q = w.a.center.get();
      } 
      else if (distance_along_wall >= w.len) {
        q = w.b.center.get();
      } 
      else {
        PVector v_unit = w.unit.get();
        v_unit.mult(distance_along_wall);
        q = PVector.add(w.a.center, v_unit); // .add(w.unit.multiply(distance_along_wall));
      }

      q.sub(center);
      q.normalize();
      velocity = DoImpact(velocity, q, -1.0);
    } 
    else if (other instanceof Ball) {
      Ball ball = (Ball)other;
      PVector n = ball.center.get();
      n.sub(center);
      n.normalize();

      PVector other_vel = ball.velocity;
      PVector original_v1 = velocity.get(); 
      original_v1.sub(other_vel);

      velocity = DoImpact(original_v1, n, (mass-ball.mass)/(mass+ball.mass));
      velocity.add(other_vel);
      ball.velocity = n.get();
      ball.velocity.mult(2*mass/(mass+ball.mass) * original_v1.dot(n));
      ball.velocity.add(other_vel);
    } 
    else {
      println("Unknown type: " + other);
    }
  }


  public boolean isColliding(Component other) {
    if (other instanceof Point) {
      return super.isColliding(other);
    } 
    else if (other instanceof Wall) {
      Wall w = (Wall)other;

      float d1 = PVector.dist(w.a.center, center);
      float d2 = PVector.dist(w.b.center, center);
      float distance_along_wall = (w.len*w.len + d1*d1 - d2*d2) / (2*w.len);
      // q = point on the wall closest to the ball's center: a + distance_along_wall * unit
      PVector q = PVector.add(w.a.center, PVector.mult(w.unit, distance_along_wall));

      if ((distance_along_wall > 0) && (distance_along_wall < w.len)) {
        // Ball will hit in the middle of the wall somewhere.
        float line_dist = PointLineDistance(center, w);
        if (line_dist > radius) return false;
        return !MovingAway(center, q, velocity);
      } 
      else if (distance_along_wall <= 0) {
        // Ball will hit end-point 1.
        if (d1 > radius) return false;
        return !MovingAway(center, w.a.center, velocity);
      } 
      else {
        assert (distance_along_wall >= w.len);
        // Ball will hit end-point 2.
        if (d2 > radius) return false;
        return !MovingAway(center, w.b.center, velocity);
      }
    }
    return false;
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
    } 
    else if (b.isPresent(location)) {
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
  public JSONObject toJSONObject() {
    JSONObject json = new JSONObject();
    json.setString("object_class", "Ball");
    json.setString("color", hex(objColor));
    json.setJSONObject("center", PVectorToJSONObject(center));
    json.setJSONObject("velocity", PVectorToJSONObject(velocity));
    json.setFloat("radius", radius);    
    json.setFloat("mass", mass);
    return json;
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
  protected float topX, topY, botX, botY;

  public Box(JSONObject json) {
    this(json.getFloat("topX"), json.getFloat("topY"), json.getFloat("botX"), json.getFloat("botY"), color(unhex(json.getString("color"))));
  }

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
    } 
    else if (b.isPresent(location)) {
      return b;
    }
    return this;
  }

  public JSONObject toJSONObject() {
    JSONObject json = new JSONObject();
    json.setString("object_class", "Box");
    json.setString("color", hex(objColor));
    json.setFloat("topX", boundingBox.origin.x);
    json.setFloat("topY", boundingBox.origin.y);
    json.setFloat("botX", boundingBox.origin.x + boundingBox.width);
    json.setFloat("botY", boundingBox.origin.y + boundingBox.height);
    return json;
  }
}


// static utlity methods
public static JSONObject PVectorToJSONObject(PVector vector) {
  JSONObject json = new JSONObject();
  json.setFloat("x", vector.x);
  json.setFloat("y", vector.y);
  return json;
}

public static PVector PVectorFromJSONObject(JSONObject json) {
  return new PVector(json.getFloat("x"), json.getFloat("y"));
}
