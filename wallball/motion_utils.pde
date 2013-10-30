

// Returns new velocity after impact.
// velocity = initial velocity vector of moving ball (ball it hits is assumed to be stationary)
// impact_dir_unit: unit vector in the direction of ball 1 to ball 2 (stationary ball)
// multiplier: multiply the velocity component in the direction parallel to the impact by this.
PVector DoImpact(PVector velocity, PVector impact_dir_unit, float multiplier) {
  float q = velocity.get().dot(impact_dir_unit) * (multiplier - 1.0);
  return PVector.add(velocity, PVector.mult(impact_dir_unit, q));
}

// Is point A moving away from (stationary) point B?
boolean MovingAway(PVector a, PVector b, PVector vel_a) {
  // n = unit vector in the direction from B to A
  PVector n = a.get();
  n.sub(b);
  n.normalize();

  // If the part of A's velocity that is along the B-->A direction is positive, then it's moving away.
  return (vel_a.dot(n)) > 0;
}

void setRandomVelocity(Ball b) {
  b.velocity = new PVector(random(-1, 1), random(-1, 1));
}


// Distance from point to a line defined by (point1-->point2)
float PointLineDistance(PVector point, PVector point1, PVector point2) {
  // Compute point-line distance
  // http://en.wikipedia.org/wiki/Distance_from_a_point_to_a_line
  PVector n = PVector.sub(point2, point1);
  n.normalize();
  PVector ap = PVector.sub(point1, point);
  return PVector.sub(ap, PVector.mult(n, ap.dot(n))).mag();
}


// Distance from point to a line defined by wall 'w'.
float PointLineDistance(PVector point, Wall w) {
  // Compute point-line distance
  // http://en.wikipedia.org/wiki/Distance_from_a_point_to_a_line
  PVector n = w.unit;
  PVector ap = PVector.sub(w.a.center, point);
  return PVector.sub(ap, PVector.mult(n, ap.dot(n))).mag();
}



