
class Pair {
  int a, b;

  Pair(int a, int b) {
    this.a = a; 
    this.b = b;
  }
}



class GameState implements ComponentCollection {
  private ArrayList<Component> components = new ArrayList<Component>();

  public ArrayList<Component> getComponents() { 
    return components;
  }

  public void addComponent(Component component) {
    components.add(component);
  }

  public void removeComponent(Component component) {
    if (components.contains(component)) {
      components.remove(component);
    }
  }

  // This method is useful if you just added a component and it's colliding
  // with others, so you want to remove it.
  public void removeLastComponent() {
    removeComponent(components.get(components.size()-1));
  }

  public void clear() {
    components.clear();
  }

  public void draw(Viewport viewport) {
    for (Component component : components) {
      component.draw(viewport);
    }
  }

  public Component componentAt(PVector objLocation) {
    // TODO: search from last to first, or implement a z-Index
    for (Component component : components) {
      if (component.isPresent(objLocation)) {

        if (component instanceof ComponentCollection) {
          return ((ComponentCollection)component).componentAt(objLocation);
        }

        return component;
      }
    }
    return null;
  }


  // "In Processing, all fields and methods are public unless otherwise specified by the private keyword."

  // Returns true if some components are colliding. Populates 'colliding_pairs' with the indices
  // of the pairs of components that are colliding.
  private boolean isColliding(ArrayList<Pair> colliding_pairs) {
    int i, j;
    boolean colliding = false;
    if (colliding_pairs != null)
      colliding_pairs.clear();
    for (j=0 ; j<components.size() ; ++j) {
      for (i=(j+1) ; i<components.size() ; ++i) {
        if (components.get(j).isColliding(components.get(i))) {
          colliding = true;
          println("Colliding: " + i + " " + j);
          if (colliding_pairs != null) {
            colliding_pairs.add(new Pair(j, i));
          }
        }
      }
    }
    return colliding;
  }

  boolean isColliding() {
    return isColliding(null);
  }


  void HandleImpacts(ArrayList<Pair> colliding_pairs) {
    int i;
    for (i=0 ; i<colliding_pairs.size() ; ++i) {
      Pair p = colliding_pairs.get(i);
      Component obj1 = components.get(p.a);
      Component obj2 = components.get(p.b);
      if (obj1 instanceof PlayableComponent) {
        ((PlayableComponent)obj1).Deflect(obj2);
      } 
      else if (obj2 instanceof PlayableComponent) {
        ((PlayableComponent)obj2).Deflect(obj1);
      }
    }
  }


  void Play(float time_step) {
    for (int i=0 ; i<components.size() ; ++i) {
      if (components.get(i) instanceof PlayableComponent)
        ((PlayableComponent)components.get(i)).Play(time_step);
    }
  }

  // Physics engine is internal to the GameState
  // TODO(ciaran)


  void update(float required_timestep) {
    // The game should never start in a colliding state.
    assert ! isColliding();

    // Compute the maximum temporal step size
    float min_radius = 999999999.9;
    float max_speed = -999999999.9;
    for (int i=0 ; i<components.size() ; ++i) {
      if (!(components.get(i) instanceof Ball)) continue;
      Ball ball = (Ball)components.get(i);
      min_radius = min(min_radius, ball.radius);
      max_speed = max(max_speed, ball.velocity.mag());
    }
    float maxstep = 0.1 * min_radius / max_speed;
    final float minstep = 1e-4;


    float total_steps = 0.0;
    float step = maxstep;
    ArrayList<Pair> colliding_pairs = new ArrayList<Pair>();
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
      if (isColliding(colliding_pairs)) {
        Play(-step);
        total_steps -= step;
        if (step == minstep) {
          // Impacts array has been recorded in 'isColliding'
          HandleImpacts(colliding_pairs);
        } 
        else {
          step = max(step / 2.0, minstep);
        }
      } 
      else {
        step = min(step*2, maxstep);
      }
      counter += 1;
    } 
    while ( (total_steps < required_timestep) && (counter < 100));
  }
}

