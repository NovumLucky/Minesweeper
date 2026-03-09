
import de.bezier.guido.*;

int NUM_ROWS = 20;
int NUM_COLS = 20;

private MSButton[][] buttons;
private ArrayList<MSButton> mines;

boolean gameOver = false;
boolean gameWon = false;

void setup() {
  size(400, 400);
  textAlign(CENTER, CENTER);

  Interactive.make(this);

  buttons = new MSButton[NUM_ROWS][NUM_COLS];
  for (int r = 0; r < NUM_ROWS; r++) {
    for (int c = 0; c < NUM_COLS; c++) {
      buttons[r][c] = new MSButton(r, c);
    }
  }

  mines = new ArrayList<MSButton>();
  setMines();
}

void setMines() {
  while (mines.size() < 40) {
    int r = (int)(Math.random() * NUM_ROWS);
    int c = (int)(Math.random() * NUM_COLS);
    MSButton b = buttons[r][c];
    if (!mines.contains(b)) {
      mines.add(b);
    }
  }
}

void draw() {
  background(0);

  for (int r = 0; r < NUM_ROWS; r++) {
    for (int c = 0; c < NUM_COLS; c++) {
      buttons[r][c].draw();    
    }
  }

  if (gameOver) {
    textSize(32);
    fill(255, 255, 0);
    textAlign(CENTER, CENTER);
    if (gameWon) {
      text("You won! Play again!", width/2, height/2);
    } else {
      text("You lost! Try again!", width/2, height/2);
    }
  }
}

boolean isWon() {
  for (int r = 0; r < NUM_ROWS; r++) {
    for (int c = 0; c < NUM_COLS; c++) {
      MSButton b = buttons[r][c];
      if (!mines.contains(b) && !b.clicked) return false;
    }
  }
  return true;
}

void displayLosingMessage() {
  gameOver = true;
text("YOU LOST\nPress ENTER",width/2,height/2);
  for (MSButton b : mines) {
    b.clicked = true;
    b.setLabel("X");
  }
}

void displayWinningMessage() {
  gameOver = true;
  gameWon = true;
}

boolean isValid(int r, int c) {
  return r >= 0 && r < NUM_ROWS && c >= 0 && c < NUM_COLS;
}

int countMines(int row, int col) {
  int count = 0;
  for (int r = row - 1; r <= row + 1; r++) {
    for (int c = col - 1; c <= col + 1; c++) {
      if (isValid(r, c) && mines.contains(buttons[r][c])) {
        count++;
      }
    }
  }
  return count;
}

public class MSButton {
  int myRow, myCol;
  float x, y, width, height;
  boolean clicked = false;
  boolean flagged = false;
  String myLabel = "";

  MSButton(int row, int col) {
    myRow = row;
    myCol = col;
    width = 400.0 / NUM_COLS;
    height = 400.0 / NUM_ROWS;
    x = myCol * width;
    y = myRow * height;
    Interactive.add(this);
  }

  public void mousePressed() {
    if (gameOver) return;

    if (mouseButton == RIGHT) {
      flagged = !flagged;
      if (!flagged) clicked = false;
      return;
    }

    if (flagged || clicked) return;

    clicked = true;

    if (mines.contains(this)) {
      displayLosingMessage();
      return;
    }

    int count = countMines(myRow, myCol);
    if (count > 0) {
      setLabel(count);
    } else {
      for (int r = myRow - 1; r <= myRow + 1; r++) {
        for (int c = myCol - 1; c <= myCol + 1; c++) {
          if (isValid(r, c)) {
            MSButton neighbor = buttons[r][c];
            if (!neighbor.clicked && !neighbor.flagged && !mines.contains(neighbor)) {
              neighbor.mousePressed();
            }
          }
        }
      }
    }

    if (isWon()) displayWinningMessage();
  }

  public void draw() {
    if (flagged) fill(0);
    else if (clicked && mines.contains(this)) fill(255, 0, 0);
    else if (clicked) fill(200);
    else fill(100);

    rect(x, y, width, height);
    fill(0);
    text(myLabel, x + width/2, y + height/2);
  }

  public void setLabel(String label) { myLabel = label; }
  public void setLabel(int label) { myLabel = "" + label; }
  public boolean isFlagged() { return flagged; }
}
