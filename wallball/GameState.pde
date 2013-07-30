
class GameState implements ComponentCollection {
  private ArrayList<Component> components = new ArrayList<Component>();
  
  public ArrayList<Component> getComponents() { return components; }

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
  
  public void Play(float time_step) {
    for (int i=0 ; i<components.size() ; ++i)
      components.get(i).Play(time_step);
  }
  
  // Physics engine is internal to the GameState
  // TODO(ciaran)
}
