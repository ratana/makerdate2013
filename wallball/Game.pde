public class Game {
  ArrayList<Level> levels;
  
  public Game() {
      // TODO: load levels from a level pack?
      levels = new ArrayList<Level>();
      //levels.add(new Level(loadJSONObject("/users/ratana/Desktop/wallball_test_3")));
      levels.add(new Level());
  }
  
  Level getLevel(int level_id) {
    return levels.get(level_id);
  }
}
