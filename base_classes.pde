


class Pair {
  int i, j;

  Pair(int a, int b) {
    i=a; 
    j=b;
  }
}


class Vector {
  float x, y;

  Vector(float x, float y) {
    this.x=x; 
    this.y=y;
  }

  void Print() {
    Print("");
  }
  
  void Print(String s) {
    if (s.length() == 0) 
      println("X="+x+" Y="+y);
    else
      println(s+": X="+x+" Y="+y);
  }

  float length() { 
    return sqrt(x*x + y*y);
  }
  float angle() { 
    return atan2(y, x);
  }

  float dot(Vector other) { 
    return x*other.x + y*other.y;
  }
  Vector add(Vector other) { 
    return new Vector(x+other.x, y+other.y);
  }
  Vector subtract(Vector other) { 
    return new Vector(x-other.x, y-other.y);
  }
  Vector multiply(float f) { 
    return new Vector(x*f, y*f);
  }
  Vector unit() { 
    return multiply( 1.0 / length() );
  }
}


class Ball {
  float x, y, m, r;
  float vx, vy;

  Ball(float nx, float ny, float nm, float nr, float nvx, float nvy) {
    x=nx; 
    y=ny; 
    m=nm; 
    r=nr;
    vx=nvx; 
    vy=nvy;
  }

  void Play(float timestep) {
    x += vx*timestep;
    y += vy*timestep;
  }

  void Draw() {
    ellipse(x, y, r*2, r*2);
  }

  float GetEnergy() {
    return 0.5 * m * (vx*vx + vy*vy);
  }

  float speed() { 
    return sqrt(vx*vx + vy*vy);
  }

  boolean isColliding(Ball other) {
    if (MovingAway(new Vector(x, y), new Vector(other.x, other.y), new Vector(vx-other.vx, vy-other.vy))) return false;
    float d = dist(x, y, other.x, other.y);
    return (d < (r+other.r));
  }

  void Deflect(Wall w) {
    // Assume ball will collide with the wall in the next time step if we don't change its velocity
    // Assume ball moving towards wall currently.

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
  }

  // http://gamedev.tutsplus.com/tutorials/implementation/create-custom-2d-physics-engine-aabb-circle-impulse-resolution/
  void Deflect(Ball other) {
    Vector n = new Vector(other.x-x, other.y-y).unit();
    Vector other_vel = new Vector(other.vx, other.vy);
    Vector original_v1 = new Vector(vx, vy).subtract(other_vel);
    Vector new_v1 = DoImpact(original_v1, n, (m-other.m)/(m+other.m)).add(other_vel);
    Vector new_v2 = n.multiply(2*m/(m+other.m) * original_v1.dot(n)).add(other_vel);

    vx = new_v1.x;
    vy = new_v1.y;
    other.vx = new_v2.x;
    other.vy = new_v2.y;
  }
}


class Wall {
  Vector p1, p2, unit;
  float line_len;
  float angle;

  Wall(float nx1, float ny1, float nx2, float ny2) {
    p1 = new Vector(nx1, ny1);
    p2 = new Vector(nx2, ny2);
    unit = p2.subtract(p1).unit();
    line_len = p2.subtract(p1).length();
    angle = (new Vector(nx2-nx1, ny2-ny1)).angle();
  }

  void Draw() {
    line(p1.x, p1.y, p2.x, p2.y);
  }

  boolean isColliding(Ball ball) {
    Vector ball_pos = new Vector(ball.x, ball.y);
    Vector ball_vel = new Vector(ball.vx, ball.vy);

    float d1 = dist(p1.x, p1.y, ball.x, ball.y);
    float d2 = dist(p2.x, p2.y, ball.x, ball.y);
    float distance_along_wall = (line_len*line_len + d1*d1 - d2*d2) / (2*line_len);
    // q = point on the wall closest to the ball's center
    Vector q = p1.add(unit.multiply(distance_along_wall));

    if ((distance_along_wall > 0) && (distance_along_wall < line_len)) {
      // Ball will hit in the middle of the wall somewhere.
      float line_dist = PointLineDistance(ball_pos, this);
      if (line_dist > ball.r) return false;
      return !MovingAway(ball_pos, q, ball_vel);
    } else if (distance_along_wall <= 0) {
      // Ball will hit end-point 1.
      if (d1 > ball.r) return false;
      return !MovingAway(ball_pos, p1, ball_vel);
    } else {
      assert (distance_along_wall >= line_len);
      // Ball will hit end-point 2.
      if (d2 > ball.r) return false;
      return !MovingAway(ball_pos, p2, ball_vel);
    }
  }

  Vector unit() {
    return unit;
  }
}

