


Vector rotateVector(Vector v, float theta) {
  float r = v.length();
  float angle = v.angle() + theta;
  return new Vector(r*cos(angle), r*sin(angle));
}

float PointLineDistance(Vector point, Vector point1, Vector point2) {
  // Compute point-line distance
  // http://en.wikipedia.org/wiki/Distance_from_a_point_to_a_line
  Vector a = point1;
  Vector n = point2.subtract(point1).unit();
  Vector ap = a.subtract(point);
  return ap.subtract(n.multiply(ap.dot(n))).length();
}

float PointLineDistance(Vector point, Wall w) {
  return PointLineDistance(point, w.p1, w.p2);
}

float distance(Vector a, Vector b) {
  return dist(a.x, a.y, b.x, b.y);
}

color RandomColor() {
  return color(random(255), random(255), random(255));
}

color MixColors(color c1, color c2, float factor) {
  return color(red(c1)*factor + red(c2)*(1.0-factor),
               green(c1)*factor + green(c2)*(1.0-factor),
               blue(c1)*factor + blue(c2)*(1.0-factor));
}

color Darken(color c, float factor) {
  return color(red(c)*factor, green(c)*factor, blue(c)*factor);
}

Ball RandomBall() {
  return new Ball(random(width), random(height), random(10, 20), random(6, width/40), random(-1, 1), random(-1, 1));
}

Wall RandomWall() {
  return new Wall(random(width), random(height), random(width), random(height));
}

// Returns new velocity after impact.
// velocity = initial velocity vector of moving ball (ball it hits is assumed to be stationary)
// impact_dir_unit: unit vector in the direction of ball 1 to ball 2 (stationary ball)
// multiplier: multiply the velocity component in the direction parallel to the impact by this.
Vector DoImpact(Vector velocity, Vector impact_dir_unit, float multiplier) {
  float parallel_speed = velocity.dot(impact_dir_unit);
  return velocity.add(impact_dir_unit.multiply(parallel_speed * (multiplier - 1.0)));
}

// Is point A moving away from (stationary) point B?
boolean MovingAway(Vector a, Vector b, Vector vel_a) {
  // unit vector in the direction from B to A
  Vector n = (a.subtract(b)).unit();
  // If the part of A's velocity that is along the B-->A direction is positive, then it's moving away.
  return (vel_a.dot(n)) > 0;
}



