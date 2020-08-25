import oscP5.*;
import netP5.*;
OscP5 oscIn;


//boolean celebMode = true;

enum Mode{
  NORMAL, 
  CELEB, 
  COVID
}

Mode layoutMode = Mode.COVID;

PFont font;
PFont boldFont;
PFont largeFont;

String[][] sortedData;

String correctText      =  "0 Correct";
String wrongText        =  "0 Wrong";
String impossibleText   =  "0 Impossible";

String numA             = "0";
String numB             = "0";
String numC             = "0";
String prizePot         = "0";
String R1Q              = "1";
String stillIn          = "24";

int    topScorers       = 0;
int    topScore         = 0;
int    questionInt      = 1;

String impossibleAnswer = "-";
String correctAnswer    = "-";
String wrongAnswer      = "-";

int questionNumber      = 1;

String[] OSCaddress;

color bgColour    = color( 130, 20, 20 );
color blockColour = color(  80, 30, 30 );

color textColour       = color( 255, 255, 255 );
color impossibleColour = color( 255, 0, 0 );
color correctColour    = color(   0, 255, 0 );
color unansweredColour = color( 180, 180, 180 );
color outColour        = color(   0, 0, 0 );
color finalistColour   = color( 220, 255, 0 );

color[]  gridBgColour;
color[]  gridTextColour;
String[] gridName;

int NUM_CONTS     = 21;
int NUM_PER_ROW   = 7;


void setup()
{
  fullScreen( P3D, 0 );
  
  switch(layoutMode)
  {
    case CELEB:
      NUM_CONTS   = 18;
      NUM_PER_ROW = 6;
      stillIn     = "18";
      break;
    case COVID:
      NUM_CONTS   = 12;
      NUM_PER_ROW = 4;
      stillIn     = "12";
      break;
    case NORMAL:
      NUM_CONTS   = 21;
      NUM_PER_ROW = 7;
      stillIn     = "21";
  }
  
  oscIn = new OscP5( this, 7000 );

  font      = createFont( "futura-condensed-normal.ttf", 33 ); // Used for all data in table
  boldFont  = createFont( "futura-condensed-bold.ttf", 28   ); // Used for the row headers
  largeFont = createFont( "futura-condensed-normal.ttf", 60 ); // Used for the info on right of screen

  sortedData   = new String[22][9];
  OSCaddress   = new String[2];

  sortedData[0][0] = "PODIUM";
  sortedData[0][1] = "NAME";
  sortedData[0][2] = "LAST ANSWER";
  sortedData[0][3] = "T : R/W/I";
  sortedData[0][4] = "STATE";
  sortedData[0][5] = "ANSWER";
  sortedData[0][6] = "TIME";
  sortedData[0][7] = "TOTAL TIME";
  sortedData[0][8] = "POINTS";
  

  gridBgColour   = new color[  NUM_CONTS ];
  gridTextColour = new color[  NUM_CONTS ];
  gridName       = new String[ NUM_CONTS ];

  for ( int row=1; row<NUM_CONTS+1; row++ ) 
  {
    gridBgColour[row-1]   = color( 50 );
    gridTextColour[row-1] = color( 70 );
    gridName[row-1]       = "";
    for ( int col=0; col<9; col++ ) 
    {
      sortedData[row][col]   = "-";
    }

    sortedData[row][0]     = Integer.toString(row);         // Add a podium position
    sortedData[row][1]     = "Cont "+Integer.toString(row); // Add a name
    sortedData[row][2]     = "0";                           // Add a lastAnswered
  }
}


void draw()
{
  background( bgColour );
  noStroke();

  textAlign(CENTER, CENTER);

  float xStart   = 90;
  float yStart   = 32;
  float xSpacing = 150;
  float ySpacing = 48;
  float xPos     = xStart;
  float yPos     = yStart;
  
  
    switch(layoutMode)
  {
    case CELEB:
      ySpacing = 55;
      break;
    case COVID:
      ySpacing = 83;
      break;
    default:
      ySpacing = 48;
  }
  
  textFont( boldFont );

  topScorers          = 0;
  topScore            = 0;
  int tempScore       = 0;
  boolean stillInPlay = true;

  // Find how many contestants are on the top score
  for ( int i=1; i<NUM_CONTS+1; i++ )
  {
    if ( sortedData[i][4].equals("OUT - Imposs") || sortedData[i][4].equals("OUT - No Answer") )
    {
      stillInPlay = false;
    }
    if ( stillInPlay )
    {
      if ( !sortedData[i][8].equals("-") ) 
      {
        tempScore = Integer.parseInt(sortedData[i][8]);
      }
      if ( tempScore > topScore )
      {
        topScore   = tempScore;
        topScorers = 1;
      } else if ( tempScore == topScore )
      {
        if ( sortedData[i][0] != "-" )
        {
          topScorers += 1;
        }
      }
    }
  }

  // Draw the table of sorted data
  for ( int row=0; row<NUM_CONTS+1; row++ )
  {
    // Draw boxes on alternating lines
    if ( row % 2 == 1 ) 
    {
      rectMode( CORNERS );
      fill( blockColour );
      rect( xStart-(xSpacing/2), yPos-(ySpacing/2), xStart+(xSpacing*6), yPos+(ySpacing/2) );
    }

    // Set colour according to contestant's state
    setTextColour( sortedData[row][ 4 ] );

    // Draw the data (NEW COMPACTED VERSION)
    if ( row==0 )
    {
      text( "CONTESTANT", xPos+30,           yPos );
      text( "T : R/W/I",  xPos+xSpacing*1.3, yPos );
      text( "STATE",      xPos+xSpacing*2.3, yPos );
      text( "ANSWER",     xPos+xSpacing*3.2, yPos );
      text( "TIME",       xPos+xSpacing*4.0, yPos );
      text( "TOTAL",      xPos+xSpacing*4.8, yPos );
      text( "POINTS",     xPos+xSpacing*5.6, yPos );
    } else
    {
      // Contestant position and name 
      textAlign(LEFT, CENTER);
      String posStr = sortedData[row][0];
      if ( Integer.parseInt(posStr)<10 )
      {
        posStr +=  "  ";
      }
      text( posStr+"  "+sortedData[row][1], xPos-50, yPos-3 );

      textAlign(CENTER, CENTER);
      text( sortedData[row][3], xPos+xSpacing*1.3, yPos-3 ); // T:R/W/I
      text( sortedData[row][4], xPos+xSpacing*2.3, yPos-3 ); // State
      text( sortedData[row][5], xPos+xSpacing*3.2, yPos-3 ); // Answer 
      text( sortedData[row][6], xPos+xSpacing*4.0, yPos-3 ); // Time
      text( sortedData[row][7], xPos+xSpacing*4.8, yPos-3 ); // Total Time
      text( sortedData[row][8], xPos+xSpacing*5.6, yPos-3 ); // Points
    }

    textFont( font );
    xPos  = xStart;
    yPos += ySpacing;
  }

  fill( textColour );
  float textX = xStart*2+(xSpacing*7.5);

  textFont(largeFont);
  textAlign(CENTER, CENTER);

  textX = 1420;
  textSize( 70 );
  fill(255);

  questionInt = Integer.parseInt( R1Q );
  if ( questionInt > 0 )
  {
    if ( questionInt < 6 ) {
      text( "Question " +questionInt+ " of Round 1", textX, 50 );
    } else if ( questionInt < 11 ) {
      text( "Question " +(questionInt-5)+ " of Round 2", textX, 50 );
    } else if ( questionInt < 16 ) {
      text( "Question " +(questionInt-10)+ " of Round 3", textX, 50 );
    } else {
      text( "Not in Gameplay", textX, 50 );
    }
  }

  String stillInStr = stillIn    + " still in play, "+topScorers+ " on " +topScore+ " point";
  if ( topScore != 1)
  {
    stillInStr += "s";
  }
  text( stillInStr, textX, 130 );


  setCorrectWrongImpossText();
  textSize( 100 );
  fill( 0, 255, 0 );
  text( correctText, textX, 260 );
  fill( 255, 0, 0 );
  text( impossibleText, textX, 370 );
  fill( 100 );
  text( wrongText, textX, 480 );

  drawGrid();
  
  textSize(90);
  fill(255);
  text( "£" + prizePot +" Prize Pot", textX, 1000 );
}

void drawGrid()
{
  pushStyle();
  rectMode( CORNER );
  textAlign( CENTER, CENTER );
  fill( 100, 100, 100 );

  float xPos  = 0;
  float yPos  = 0;
  float rowX  = 1010;
  float rowY  = 800;
  float rectW = 125;
  float rectH = 105;
  float sp    = 3;
  int nameFontSize = 31;
  
  switch(layoutMode)
  {
    case CELEB:
      rowX  = 1005;
      rectW = 148;
      nameFontSize = 35;
      break;
    case COVID:
      rowX  = 1005;
      rectW = 222;
      nameFontSize = 40;
      break;
    case NORMAL:
      rowX  = 1010;
      rectW = 125;
      nameFontSize = 31;
      break;
  }
  
  int contIndex = 1;

  noStroke();
  for ( int y=0; y<3; y++ )
  {  
    for ( int x=0; x<NUM_PER_ROW; x++ )
    {
      xPos = rowX + x*(rectW+sp);
      yPos = rowY - y*(rectH+sp);

      setGridStyle();

      fill( gridBgColour[contIndex-1] );  
      rect( xPos, yPos, rectW, rectH );
      
      textFont(boldFont);
      textSize( 60 );
      fill( gridTextColour[contIndex-1] );
      text( contIndex, xPos+rectW/2, -25+yPos+rectH/2 );
      
      textFont(largeFont);
      textSize( nameFontSize );
      text( gridName[contIndex-1], xPos+rectW/2, 25+yPos+rectH/2 );

      contIndex+=1;
    }
  }

  popStyle();
}


void setGridStyle( )
{
  boolean answersExist = false;
  for ( int i=1; i<NUM_CONTS; i++ )
  {
    String stateStr  = sortedData[ i ][ 4 ];
    if ( stateStr.equals("Answered") )
    {
      answersExist = true;
      break;
    }
  }

  for ( int i=1; i<NUM_CONTS+1; i++ )
  {
    String stateStr  = sortedData[ i ][ 4 ];
    String answerStr = sortedData[ i ][ 5 ];
    int podiumIndex  = Integer.parseInt(sortedData[ i ][ 0 ]);

    gridName[ podiumIndex-1 ] = sortedData[ i ][ 1 ]; 

    if ( stateStr.equals("OUT - Imposs") || stateStr.equals("OUT - No Answer") ) 
    {
      gridBgColour[podiumIndex-1]   = color( 120, 20, 20 );
      gridTextColour[podiumIndex-1] = color( 120, 20, 20 );
    } else if ( stateStr.equals("FINALIST_1") || stateStr.equals("FINALIST_2") || stateStr.equals("FINALIST_3") )
    {
      gridBgColour[podiumIndex-1]   = color( 147, 34, 14 );
      gridTextColour[podiumIndex-1] = color( 147, 34, 14 );
      //gridTextColour[podiumIndex-1] = color( 180, 180, 14 );
    } else
    {
      answerStr = sortedData[ i ][ 5 ];
      gridBgColour[podiumIndex-1] = color(0);

      if ( answerStr.equals( correctAnswer ) )
      {
        if ( stateStr.equals( "Answered" ) )
        {
          gridBgColour[podiumIndex-1]   = color(0, 50, 0);
          gridTextColour[podiumIndex-1] = color(0, 255, 0);
        } else
        {
          gridBgColour[podiumIndex-1]   = blockColour;
          gridTextColour[podiumIndex-1] = color(0, 150, 0);
        }
      } else if ( answerStr.equals( impossibleAnswer ) )
      {
        if ( stateStr.equals( "Answered" ) )
        {
          gridBgColour[podiumIndex-1]   = color(0, 0, 0);
          gridTextColour[podiumIndex-1] = color(255, 0, 0);
        } else
        {
          gridBgColour[podiumIndex-1]   = blockColour;
          gridTextColour[podiumIndex-1] = color(150, 0, 0);
        }
      } else if ( answerStr.equals( wrongAnswer ) )
      {
        gridBgColour[podiumIndex-1]   = blockColour;
        gridTextColour[podiumIndex-1] = color(100);
      } else
      {
        if ( answersExist )
        {
          int lastAnswered = Integer.parseInt(sortedData[i][2]);
          if ( lastAnswered == Integer.parseInt(R1Q) )
          {
            gridBgColour[podiumIndex-1] = color(255, 0, 0);
            gridTextColour[podiumIndex-1] = color(0, 0, 0);
          }
        } else
        {
          gridBgColour[podiumIndex-1]   = blockColour;
          gridTextColour[podiumIndex-1] = color(100);
        }
      }
    }
  }
}


void setCorrectWrongImpossText()
{
  if (        correctAnswer.equals( "A" ) ) { 
    correctText  = numA + " (A) Correct";
  } else if ( correctAnswer.equals( "B" ) ) { 
    correctText  = numB + " (B) Correct";
  } else if ( correctAnswer.equals( "C" ) ) { 
    correctText  = numC + " (C) Correct";
  }

  if (        wrongAnswer.equals( "A" ) ) { 
    wrongText    = numA + " (A) Wrong";
  } else if ( wrongAnswer.equals( "B" ) ) { 
    wrongText    = numB + " (B) Wrong";
  } else if ( wrongAnswer.equals( "C" ) ) { 
    wrongText    = numC + " (C) Wrong";
  }

  if (          impossibleAnswer.equals( "A" ) ) { 
    impossibleText = numA + " (A) !mpossible";
  } else if (   impossibleAnswer.equals( "B" ) ) { 
    impossibleText = numB + " (B) !mpossible";
  } else if (   impossibleAnswer.equals( "C" ) ) { 
    impossibleText = numC + " (C) !mpossible";
  }
}


void setTextColour( String state )
{
  fill( textColour );

  if ( state.equals( "Correct" ) ) 
  {
    fill( correctColour );
  } else if ( state.equals( "Impossible" ) ) 
  {
    fill( impossibleColour );
  } else if ( state.equals("OUT - Imposs") || state.equals("OUT - No Answer") ) 
  {
    fill( outColour );
  } else if ( state.equals("Unanswered") ) 
  {
    fill( unansweredColour );
  } else if ( state.equals("FINALIST_1") || state.equals("FINALIST_2") || state.equals("FINALIST_3") )
  {
    fill( finalistColour );
  }
}


void oscEvent(OscMessage theOscMessage) 
{    
  OSCaddress = theOscMessage.addrPattern().split("_");
  int rowNum = Integer.parseInt(OSCaddress[1]);

  if ( OSCaddress[0].equals("/sorted") )
  {
    sortedData[ (int)rowNum ][ 0 ] = theOscMessage.get( 0 ).stringValue();
    sortedData[ (int)rowNum ][ 1 ] = theOscMessage.get( 1 ).stringValue();
    sortedData[ (int)rowNum ][ 2 ] = theOscMessage.get( 2 ).stringValue();
    sortedData[ (int)rowNum ][ 3 ] = theOscMessage.get( 3 ).stringValue();
    sortedData[ (int)rowNum ][ 4 ] = theOscMessage.get( 4 ).stringValue();
    sortedData[ (int)rowNum ][ 5 ] = theOscMessage.get( 5 ).stringValue();
    sortedData[ (int)rowNum ][ 6 ] = theOscMessage.get( 6 ).stringValue();
    sortedData[ (int)rowNum ][ 7 ] = theOscMessage.get( 7 ).stringValue();
    sortedData[ (int)rowNum ][ 8 ] = theOscMessage.get( 8 ).stringValue();
  }

  if ( OSCaddress[0].equals("/stats") )
  {
    //println( "GOT STATS" );
    numA             = theOscMessage.get( 0 ).stringValue();
    numB             = theOscMessage.get( 1 ).stringValue();
    numC             = theOscMessage.get( 2 ).stringValue();
    prizePot         = theOscMessage.get( 3 ).stringValue();
    impossibleAnswer = theOscMessage.get( 4 ).stringValue();
    correctAnswer    = theOscMessage.get( 5 ).stringValue();
    wrongAnswer      = theOscMessage.get( 6 ).stringValue();
    R1Q              = theOscMessage.get( 7 ).stringValue();
    stillIn          = theOscMessage.get( 8 ).stringValue();
    //println( "CORR : " + correctAnswer + " IMPOSS : " +impossibleAnswer+ " WRONG : " + wrongAnswer);
  }
}
