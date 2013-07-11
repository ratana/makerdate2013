
GameState state;
GameStateRenderer renderer;
float ball_size = 0;

void setup() {
  size(640, 480);
  smooth(1);

  renderer = new GameStateRenderer();
  state = new GameState();
  int i;
  // Add some random walls
  for (i=0 ; i<6 ; ++i) {
    state.addWall(RandomWall());
  }
  // Add the boundary walls
  state.addWall(new Wall(0, 0, width-1, 0));
  state.addWall(new Wall(0, 0, 0, height-1));
  state.addWall(new Wall(width-1, height-1, width-1, 0));
  state.addWall(new Wall(width-1, height-1, 0, height-1));

  frameRate(60);

  // To test the engine, call test functions here
  // e.g. TestC();
}


void draw() {
  // Display the current state
  renderer.Render(state);

  // Click and hold the mouse button the create a ball
  if (mousePressed) {
    ball_size = max(5, (ball_size + 0.1) * 1.005);
  }

  if (ball_size > 0) {
    // Draw the ball you're creating (by click-and-hold), using semi-transparent blue.
    fill(color(100, 100, 255, 128));
    ellipse(mouseX, mouseY, ball_size*2, ball_size*2);
  }

  // The energy in a closed system should remain constant, but fluctuates due to floating-point imprecision & numerical approximations in impact equations.
  fill(255);
  text("Energy = "+state.GetEnergy(), 10, 15);

  state.Update(1.5);
}



void mouseReleased() {
  if (ball_size > 0) {
    state.addBall(new ColorBall(mouseX*1.0, mouseY*1.0, 10*ball_size /*10.0*/, ball_size, random(-1, 1), random(-1, 1)));
    if (state.isColliding()) {
      state.removeLastBall();
    }
    ball_size = 0.0;
  }
}



class GameState {
  ArrayList<Ball> balls;
  ArrayList<Wall> walls;
  float minstep;
  ArrayList<Pair> wall_collisions;
  ArrayList<Pair> ball_collisions;


  GameState() {
    balls = new ArrayList<Ball>();
    walls = new ArrayList<Wall>();
    ball_collisions = new ArrayList<Pair>();
    wall_collisions = new ArrayList<Pair>();
    minstep = 1e-3;
  }

  void addBall(Ball b) { 
    balls.add(b);
  }
  void addWall(Wall w) { 
    walls.add(w);
  }

  void removeLastBall() {
    assert balls.size() > 0;
    balls.remove(balls.size()-1);
  }

  void clear() {
    balls.clear();
    walls.clear();
  }

  float GetEnergy() {
    float energy = 0.0;
    for (int i=0 ; i<balls.size() ; ++i) {
      energy += balls.get(i).GetEnergy();
    }
    return energy;
  }

  void Play(float timestep) {
    for (int i=0 ; i<balls.size() ; ++i) {
      balls.get(i).Play(timestep);
    }
  }

  boolean isColliding() {
    int i, j;
    wall_collisions.clear();
    for (j=0 ; j<walls.size() ; ++j) {
      for (i=0 ; i<balls.size() ; ++i) {
        if (walls.get(j).isColliding(balls.get(i))) {
          wall_collisions.add(new Pair(j, i));
          //println("collision: wall="+j+"  ball="+i);
        }
      }
    }
    ball_collisions.clear();
    for (j=0 ; j<balls.size() ; ++j) {
      for (i=(j+1) ; i<balls.size() ; ++i) {
        if (balls.get(j).isColliding(balls.get(i))) {
          ball_collisions.add(new Pair(j, i));
          //println("collision: Ball="+j+"  Ball="+i);
        }
      }
    }
    return (ball_collisions.size() + wall_collisions.size()) > 0;
  }

  void HandleImpacts() {
    int i;
    for (i=0 ; i<wall_collisions.size() ; ++i) {
      Pair p = wall_collisions.get(i);
      balls.get(p.j).Deflect(walls.get(p.i));
    }
    for (i=0 ; i<ball_collisions.size() ; ++i) {
      Pair p = ball_collisions.get(i);
      balls.get(p.j).Deflect(balls.get(p.i));
    }
  }

  void Update(float required_timestep) {
    assert ! isColliding();

    float min_radius = 999999999.9;
    float max_speed = -999999999.9;
    for (int i=0 ; i<balls.size() ; ++i) {
      min_radius = min(min_radius, balls.get(i).r);
      max_speed = max(max_speed, balls.get(i).speed());
    }


    float maxstep = 0.1 * min_radius / max_speed;
    float total_steps = 0.0;
    float step = maxstep;
    int counter=0;
    do {

      // We play the system forward in time by 't' seconds   (t=step)
      // If there's been an impact, we rewind and take a smaller step (e.g. t/2)
      // repeating smaller and smaller steps until there's no collision, or until
      // the time step is 'minstep'. In which case, we handle the impact by
      // ensuring that any objects that would have hit each other should now be moving
      // away from each other.

      step = min(step, required_timestep - total_steps);
      Play(step);
      total_steps += step;
      if (isColliding()) {
        Play(-step);
        total_steps -= step;
        if (step == minstep) {
          // Impacts array has been recorded in 'isColliding'
          HandleImpacts();
        } else {
          step = max(step / 2.0, minstep);
        }
      } else {
        step = min(step*2, maxstep);
      }
      counter += 1;
    } 
    while ( (total_steps < required_timestep) && (counter < 100));
  }
}


// Very simple renderer. The drawing functionality for balls / walls has
// been put into the ball/wall object. It makes it easier to create new types
// of ball/wall, as they can draw themselves, instead of having to update the renderer
// to understand their new attributes.
class GameStateRenderer {

  void Render(GameState state) {
    background(0);
    stroke(255);
    int i;
    for (i=0 ; i<state.walls.size() ; ++i) {
      Wall w = state.walls.get(i);
      w.Draw();
    }
    fill(128);
    for (i=0 ; i<state.balls.size() ; ++i) {
      Ball b = state.balls.get(i);
      b.Draw();
    }
  }
}



