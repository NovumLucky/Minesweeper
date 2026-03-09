import de.bezier.guido.*;

final int NUM_ROWS = 20;
final int NUM_COLS = 20;

private MSButton[][] buttons;
private ArrayList<MSButton> mines;
boolean gameOver = false;
boolean gameWon = false;

void setup() {
  size(400, 400);
  textAlign(CENTER, CENTER);
  rectMode(CENTER);
  
  Interactive.make(this);
  
  buttons = new MSButton[NUM_ROWS][NUM_COLS];
  mines = new ArrayList<MSButton>();
  
  float w = 400.0 / NUM_COLS;
  float h = 400.0 / NUM_ROWS;
  
  for (int r = 0; r < NUM_ROWS; r++) {
    for (int c = 0; c < NUM_COLS; c++) {
      buttons[r][c] = new MSButton(r, c);
      buttons[r][c].width = w;
      buttons[r][c].height = h;
      buttons[r][c].x = c * w + w/2; // center of rect
      buttons[r][c].y = r * h + h/2; // center of rect
    }
  }
  
  setMines();
}

void setMines() {
  int total = 40;
  while (mines.size() < total) {
    int r = (int)random(NUM_ROWS);
    int c = (int)random(NUM_COLS);
    MSButton b = buttons[r][c];
    if (!mines.contains(b))
      mines.add(b);
  }
}

void draw() {
  background(0);
  
  if (gameWon || gameOver) {
    fill(0, 150);
    rect(width/2, height/2, width, height);
    fill(255, 0, 0);
    textSize(40);
    text(gameWon ? "YOU WON\nPRESS ENTER" : "YOU LOST\nPRESS ENTER", width/2, height/2);
  }
}

public boolean isWon() {
  for (int r = 0; r < NUM_ROWS; r++) {
    for (int c = 0; c < NUM_COLS; c++) {
      MSButton b = buttons[r][c];
      if (!mines.contains(b) && !b.clicked)
        return false;
    }
  }
  return true;
}

public boolean isValid(int r, int c) {
  return r >= 0 && r < NUM_ROWS && c >= 0 && c < NUM_COLS;
}

public int countMines(int row, int col) {
  int numMines = 0;
  for (int r = row - 1; r <= row + 1; r++) {
    for (int c = col - 1; c <= col + 1; c++) {
      if (isValid(r, c) && mines.contains(buttons[r][c]))
        numMines++;
    }
  }
  return numMines;
}

public void revealEmpty(int row, int col) {
  if (!isValid(row, col)) return;
  MSButton b = buttons[row][col];
  if (b.clicked || b.flagged) return;
  
  b.clicked = true;
  int n = countMines(row, col);
  
  if (n > 0) {
    b.setLabel(n);
    return;
  }
  
  for (int r = row - 1; r <= row + 1; r++)
    for (int c = col - 1; c <= col + 1; c++)
      revealEmpty(r, c);
}

void keyPressed() {
  if (keyCode == ENTER && (gameOver || gameWon)) {
    gameOver = false;
    gameWon = false;
    setup();
  }
}

public class MSButton {
  private int myRow, myCol;
  private float x, y, width, height;
  private boolean clicked, flagged;
  private String myLabel;
  
  public MSButton(int row, int col) {
    width = 400.0 / NUM_COLS;
    height = 400.0 / NUM_ROWS;
    myRow = row;
    myCol = col;
    x = myCol * width + width/2;
    y = myRow * height + height/2;
    myLabel = "";
    flagged = clicked = false;
    Interactive.add(this);
  }

  public void mousePressed() {
    if (gameOver || gameWon) return;
    
    if (mouseButton == RIGHT) {
      if (!clicked)
        flagged = !flagged;
      return;
    }
    
    if (flagged) return;
    
    if (mines.contains(this)) {
      clicked = true;
      gameOver = true;
      for (MSButton m : mines)
        m.clicked = true;
      return;
    }
    
    clicked = true;
    int n = countMines(myRow, myCol);
    if (n > 0)
      setLabel(n);
    else
      revealEmpty(myRow, myCol);
    
    if (isWon())
      gameWon = true;
  }
  
  public void draw() {
    if (flagged)
      fill(0);
    else if (clicked && mines.contains(this))
      fill(255, 0, 0);
    else if (clicked)
      fill(200);
    else
      fill(100);
    
    rect(x, y, width, height);
    fill(0);
    textSize(16);
    text(myLabel, x, y);
  }
  
  public void setLabel(String newLabel) {
    myLabel = newLabel;
  }
  
  public void setLabel(int newLabel) {
    myLabel = "" + newLabel;
  }
  
  public boolean isFlagged() {
    return flagged;
  }
}
