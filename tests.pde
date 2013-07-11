

// Functions that test basic physical interactions

void Test1() {
  state.clear();
  state.addWall(new Wall(100, 50, width-1, 50));
  state.addBall(new Ball(35.0, 50.0, 10.0, 12.0, 1.0, 0.0)); 
}

void Test2() {
  state.clear();
  state.addWall(new Wall(50, 100, 50, height-1));
  state.addBall(new Ball(50.0, 50.0, 10.0, 12.0, 0.0, 1.0)); 
}


void Test3() {
  state.clear();
  state.addWall(new Wall(40, 100, 50, height-1));
  state.addBall(new Ball(50.0, 50.0, 10.0, 12.0, 0.0, 1.0)); 
}


void TestA() {
  state.clear();
  state.addBall(new Ball(50.0, 50.0, 10.0, 12.0, 1.0, 0.0)); 
  state.addBall(new Ball(150.0, 50.0, 10.0, 12.0, -1.0, 0.0)); 
}


void TestB() {
  state.clear();
  state.addBall(new Ball(50.0, 50.0, 10.0, 12.0, 1.0, 1.0)); 
  state.addBall(new Ball(150.0, 150.0, 10.0, 12.0, -1.0, -1.0)); 
}


void TestC() {
  state.clear();
  state.addBall(new Ball(50.0, 50.0, 10.0, 12.0, 0.0, 1.0)); 
  state.addBall(new Ball(60.0, 200.0, 1000.0, 50.0, 0.0, -1.0)); 
}


