
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
          if (colliding_pairs != null)
            colliding_pairs.add(new Pair(j, i));
        }
      }
    }
    return colliding;
  }

  boolean isColliding() {
    return isColliding(null);
  }


  void Play(float time_step) {
    for (int i=0 ; i<components.size() ; ++i) {
      if (components.get(i) instanceof PlayableComponent)
        ((PlayableComponent)components.get(i)).Play(time_step);
    }
  }

  // Physics engine is internal to the GameState
  // TODO(ciaran)
}

