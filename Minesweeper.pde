import de.bezier.guido.*;
//Declare and initialize constants NUM_ROWS and NUM_COLS = 20
final int NUM_ROWS = 20;
final int NUM_COLS = 20;

private MSButton[][] buttons; //2d array of minesweeper buttons
private ArrayList <MSButton> mines; //ArrayList of just the minesweeper buttons that are mined
boolean gameOver = false;
boolean gameWon = false;
void setup ()
{
    size(400, 400);
    textAlign(CENTER,CENTER);
    
    // make the manager
    Interactive.make( this );
    
    //your code to initialize buttons goes here
    buttons = new MSButton[NUM_ROWS][NUM_COLS];
    mines = new ArrayList<MSButton>();
    
    float w = 400.0/NUM_COLS;
    float h = 400.0/NUM_ROWS;
    
    for(int r=0;r<NUM_ROWS;r++)
    {
        for(int c=0;c<NUM_COLS;c++)
        {
            buttons[r][c] = new MSButton(r,c);
            buttons[r][c].width = w;
            buttons[r][c].height = h;
            buttons[r][c].x = c*w;
            buttons[r][c].y = r*h;
        }
    }
    
    
    setMines();
}
public void setMines()
{
    //your code
    int total = 40;
    while(mines.size() < total)
    {
        int r = (int)random(NUM_ROWS);
        int c = (int)random(NUM_COLS);
        MSButton b = buttons[r][c];
        if(!mines.contains(b))
            mines.add(b);
    }
}

public void draw ()
{
    background( 0 );

    if(gameWon)
        displayWinningMessage();

    if(gameOver)
        displayLosingMessage();
}
public boolean isWon()
{
    //your code here
    for(int r=0;r<NUM_ROWS;r++)
    {
        for(int c=0;c<NUM_COLS;c++)
        {
            MSButton b = buttons[r][c];
            if(!mines.contains(b) && !b.clicked)
                return false;
        }
    }
    return true;
}
public void displayLosingMessage()
{
    //your code here
    fill(0,150);
    rect(0,0,width,height);
    fill(255,0,0);
    textSize(40);
    text("YOU LOST\nPRESS ENTER",200,200);
}
public void displayWinningMessage()
{
    //your code here
    fill(0,150);
    rect(0,0,width,height);
    fill(255,0,0);
    textSize(40);
    text("YOU WON\nPRESS ENTER",200,200);
}
public boolean isValid(int r, int c)
{
    //your code here
    return r>=0 && r<NUM_ROWS && c>=0 && c<NUM_COLS;
}
public int countMines(int row, int col)
{
    int numMines = 0;
    //your code here
    for(int r=row-1;r<=row+1;r++)
    {
        for(int c=col-1;c<=col+1;c++)
        {
            if(isValid(r,c) && mines.contains(buttons[r][c]))
                numMines++;
        }
    }
    return numMines;
}
public void revealEmpty(int row,int col)
{
    if(!isValid(row,col)) return;
    MSButton b = buttons[row][col];
    if(b.clicked) return;
    
    b.clicked = true;
    int n = countMines(row,col);
    
    if(n>0)
    {
        b.setLabel(n);
        return;
    }
    
    for(int r=row-1;r<=row+1;r++)
        for(int c=col-1;c<=col+1;c++)
            revealEmpty(r,c);
}

public void keyPressed()
{
    if(keyCode == ENTER && (gameOver || gameWon))
    {
        gameOver = false;
        gameWon = false;
        setup();
    }
}
public class MSButton
{
    private int myRow, myCol;
    private float x,y, width, height;
    private boolean clicked, flagged;
    private String myLabel;
    
    public MSButton ( int row, int col )
    {
        width = 400/NUM_COLS;
        height = 400/NUM_ROWS;
        myRow = row;
        myCol = col; 
        x = myCol*width;
        y = myRow*height;
        myLabel = "";
        flagged = clicked = false;
        Interactive.add( this ); // register it with the manager
    }

    // called by manager
       public void mousePressed () {
        if(gameOver || gameWon) return;
        if(mouseButton == RIGHT){
            if(!clicked)
                flagged = !flagged;
            return;
        }
        if(flagged) return;
        clicked = true;
        //your code here
        if(mines.contains(this)){
            gameOver = true;
        }
        else {
            int n = countMines(myRow,myCol);
            if(n>0)
                setLabel(n);
            else
                revealEmpty(myRow,myCol);
            if(isWon())
                gameWon = true;
        }
    }
    public void draw () 
    {    
        if (flagged)
             fill(0);
        else if( clicked && mines.contains(this) ) 
             fill(255,0,0);
        else if(clicked)
            fill( 200 );
        else 
            fill( 100 );

        rect(x, y, width, height);
        fill(0);
        text(myLabel,x+width/2,y+height/2);
    }
    public void setLabel(String newLabel)
    {
        myLabel = newLabel;
    }
    public void setLabel(int newLabel)
    {
        myLabel = ""+ newLabel;
    }
    public boolean isFlagged()
    {
        return flagged;
    }
}
