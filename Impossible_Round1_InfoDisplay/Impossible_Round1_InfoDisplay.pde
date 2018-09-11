import oscP5.*;
import netP5.*;


OscP5 oscIn;

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


void setup()
{
  size(1920, 1080, P3D);

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

  for ( int row=1; row<22; row++ ) 
  {
    for ( int col=0; col<9; col++ ) 
    {
      sortedData[row][col]   = "-";
    }
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

  textFont( boldFont );

  topScorers          = 0;
  topScore            = 0;
  int tempScore       = 0;
  boolean stillInPlay = true;

  // Find how many contestants are on the top score
  for ( int i=1; i<22; i++ )
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
  //println( "High Score : " +topScore+ " - " +topScorers+ " contestants on high score" );

  // Draw the table of sorted data
  for ( int row=0; row<22; row++ )
  {
    // Draw boxes on alternating lines
    if ( row % 2 == 1 ) 
    {
      rectMode( CORNERS );
      fill( blockColour );
      rect( xStart-(xSpacing/2), yPos-(ySpacing/2), xStart+(xSpacing*8.45), yPos+(ySpacing/2) );
    }

    // Set colour according to contestant's state
    setTextColour( sortedData[row][ 4 ] );

    // Draw the data
    for ( int col=0; col<9; col++ ) 
    {
      text( sortedData[row][col], xPos, yPos-3 );
      xPos += xSpacing;
    }

    textFont( font );
    xPos  = xStart;
    yPos += ySpacing;
  }

  fill( textColour );
  float textX = xStart*2+(xSpacing*7.5);

  textFont(largeFont);
  textAlign(LEFT);
  textX = 1400;
  textSize( 60 );
  fill(255);
  
  questionInt = Integer.parseInt( R1Q );
  if ( questionInt > 0 )
  {
    if ( questionInt < 6 ) 
    {
      text( "Question " +questionInt+ " (round 1)", textX, 100 );
    } else if ( questionInt < 11 ) 
    {
      text( "Question " +(questionInt-5)+ " (round 2)", textX, 100 );
    } else if ( questionInt < 16 ) 
    {
      text( "Question " +(questionInt-10)+ " (round 3)", textX, 100 );
    } else 
    {
      text( "Not in Gameplay", textX, 100 );
    }
  }

  text( stillIn    + " contestants in play",                  textX, 200 );
  text( topScorers + " contestants on " +topScore+ " points", textX, 300 );

  setCorrectWrongImpossText();
  fill( 0, 255, 0 );
  text( correctText,    textX, 470 );
  fill( 0 );
  text( wrongText,      textX, 570 );
  fill( 255, 0, 0 );
  text( impossibleText, textX, 670 );

  fill( 255, 255, 255 );
  text( "Prize Pot : £" + prizePot, textX,      840 );
  text( "A : "          + numA,     textX+20,  1000 );
  text( "B : "          + numB,     textX+200, 1000 );
  text( "C : "          + numC,     textX+370, 1000 );
  
}


void setCorrectWrongImpossText()
{
  if (        correctAnswer.equals( "A" ) ) { 
    correctText  = numA + " Correct (A)";
  } else if ( correctAnswer.equals( "B" ) ) { 
    correctText  = numB + " Correct (B)";
  } else if ( correctAnswer.equals( "C" ) ) { 
    correctText  = numC + " Correct (C)";
  }

  if (        wrongAnswer.equals( "A" ) ) { 
    wrongText    = numA + " Wrong (A)";
  } else if ( wrongAnswer.equals( "B" ) ) { 
    wrongText    = numB + " Wrong (B)";
  } else if ( wrongAnswer.equals( "C" ) ) { 
    wrongText    = numC + " Wrong (C)";
  }

  if (          impossibleAnswer.equals( "A" ) ) { 
    impossibleText = numA + " !mpossible (A)";
  } else if (   impossibleAnswer.equals( "B" ) ) { 
    impossibleText = numB + " !mpossible (B)";
  } else if (   impossibleAnswer.equals( "C" ) ) { 
    impossibleText = numC + " !mpossible (C)";
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
