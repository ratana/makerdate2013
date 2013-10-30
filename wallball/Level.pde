public class Level {
  private GameState initialState, currentState;
  private String name = "<< new level >>";
  private String author = "<< author >>";

  public void setLevelName(String name) {
    this.name = name;
  }
  public String getLevelName() { 
    return name;
  }

  public void setAuthor(String author) {
    this.author = author;
  }
  public String getAuthor() { 
    return author;
  }  

  public GameState getCurrentState() { 
    return currentState;
  }
  public GameState getInitialState() { 
    return initialState;
  }

  public Level(JSONObject json) {
    //TODO: construct from JSON.
    name = json.getString("name");
    author = json.getString("author");
    initialState = new GameState(json.getJSONObject("initialState"));
    // TODO: clone
    currentState = initialState;
  }

  public JSONObject toJSONObject() {
    JSONObject json = new JSONObject();
    json.setString("name", name);
    json.setString("author", author);
    json.setJSONObject("initialState", initialState.toJSONObject());
    return json;
  }

  public Level(GameState initialState) {
    this.initialState = initialState;
    // TODO: clone
    currentState = initialState;
  }

  //TODO: serialize/deserialize to text or json .. ie: public static Level fromJSON(JSONString) {} 
  public Level() {  
    initialState = new GameState();

    // TODO: this should be a cloned, mutable instance of initialState.
    currentState = initialState;

    // TODO: remove all this
    Component ball0 = new Ball(0.3, 0.3, 0.07, color(255, 0, 255));
    Component ball1 = new Ball(0.4, 0.4, 0.05, color(255, 0, 0));
    Component ball2 = new Ball(0.15, 0.45, 0.1, color(0, 255, 0));
    Component ball3 = new Ball(0.7, 0.7, 0.19, color(155, 0, 155));
    Component ballX = new Ball(0.5, 0.5, 0.02, color(155, 0, 155), 1.0, 0.0, 10);
    setRandomVelocity((Ball)ball0);
    setRandomVelocity((Ball)ball1);
    setRandomVelocity((Ball)ball2);

    Wall wall1 = new Wall(0.4, 0.6, 0.5, 0.7, color(0, 0, 255));
    Wall wall2 = new Wall(0.7, 0.8, 0.9, 0.2, color(0, 0, 255));

    Wall wall3 = new Wall(0.01, 0.01, 0.01, 0.99, color(0, 255, 255));
    Wall wall4 = new Wall(0.01, 0.01, 0.99, 0.01, color(0, 255, 255));
    Wall wall5 = new Wall(0.99, 0.01, 0.99, 0.99, color(0, 255, 255));
    Wall wall6 = new Wall(0.01, 0.99, 0.99, 0.99, color(0, 255, 255));

    Wall wallX = new Wall(0.7, 0.1, 0.85, 0.3, color(0, 255, 255));


    Box box = new Box(0.5, 0.5, 0.7, 0.7, color(255, 255, 0));
    Box box2 = new Box(0.3, 0.3, 0.4, 0.4, color(0, 255, 0));

    initialState.addComponent(ballX);
    initialState.addComponent(ball0);

    initialState.addComponent(ball1);
    initialState.addComponent(ball2);
    initialState.addComponent(ball3);

    /*
    
     initialState.addComponent(wall1);
     initialState.addComponent(wall2);//...
     */
    initialState.addComponent(wall3);
    initialState.addComponent(wall4);
    initialState.addComponent(wall5);
    initialState.addComponent(wall6);
    initialState.addComponent(wallX);

    //initialState.addComponent(box);
    //initialState.addComponent(box2);
  }

  boolean addComponent(Component obj) {
    currentState.addComponent(obj);
    if (currentState.isColliding()) {
      currentState.removeLastComponent();
      return false;
    }
    return true;
  }

  void draw(Viewport viewport) {
    currentState.draw(viewport);
  }

  void update(float time_step) {
    currentState.update(time_step);
  }
}

