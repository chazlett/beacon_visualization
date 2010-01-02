 // Serial Variables
 import processing.serial.*;
 Serial myPort;    // The serial port: 
 int baudRate = 38400; //make sure this matches the baud rate in the arduino program.
 int lf = 10;

// Font Settings
 PFont font;
 float radianMultiplier;
 int[] angles; 

 // Sensor Variables
 String direction = "N";
 int sensorReading;
 int angle;
 int degreeIncrement = 6;
 int startAngle = 0;
 int endAngle = 180;
 int totalReadings = 0;

 void setup(){
   smooth();
   size(600, 400);
  
   //270 is Helvetica-Neue (my current favorite) to get a list use println(PFont.list());
   font = createFont(PFont.list()[270], 24); 
   textFont(font); 
   radianMultiplier = PI / 180;
   
   totalReadings = (endAngle - startAngle)/degreeIncrement;
   angles = new int[totalReadings];
   for (int i = 0; i < totalReadings; i++){
     angles[i] = 0;
   }
   
   myPort = new Serial(this, Serial.list()[0], baudRate);
   myPort.bufferUntil(lf);
  
   noLoop();
 }

void draw()
{
  background(#266014);
  renderClear();
  renderScan();
  renderDirection();

}

void serialEvent(Serial p) {
  String inString;
  int pipeIndex = -1;
  int semicolonIndex = -1; 
  
  String angleString;
  String sensorString;
  String dirString;
  
  String newString;
  String stepString;

  try {
    // the string is shaped like so: [angle]|[sensorReading];[direction] -- 6|450;N
    inString = (myPort.readString());
    pipeIndex = inString.indexOf('|');               //find the pipe
    semicolonIndex = inString.indexOf(';');               //find the semicolon
    
    if (pipeIndex != -1) {                           //if we found the pipe
      angleString = inString.substring(0, pipeIndex);  //parse angle reading
      sensorString = inString.substring(pipeIndex+1, semicolonIndex); 
      dirString = inString.substring(semicolonIndex + 1, inString.length()-2); //length()-2 <- strips off the linefeed
      angle = int(angleString);
      sensorReading = int(sensorString);
      direction = dirString;
      angles[(angle/degreeIncrement) - 1] = sensorReading;     
    }
  }
  catch(Exception e) {
    println(e);
  }
  redraw();
}


// Render Functions
void renderReadings(int angle, int sensor){
  noStroke();

  mediumFont();
  text("Angle: " + angle, 139, 50);
  text("Sensor: " + sensor, 123, 90);
}

void renderScan(){
  noStroke();
  fill(#424242);
  rect(0,0,400,600);
  
  stroke(#000000);
  for (int x=0; x<totalReadings; x++) {
    boolean objectDetected = angles[x] >= 450;
    if(objectDetected == true){
      fill(#980f0f, 400);
    }else{
      fill(#ffffff, 100);
    }

    int angle = (x * degreeIncrement) - 180;
    noStroke();
    arc(200, 325, angles[x], angles[x], radians(angle), radians(angle + 6));
    if(objectDetected == true){renderAlert();}
    //renderReadings(x, angles[x]);
  }

  fill(#ffffff);
  rect(175,325,50,65);
}

void renderDirection(){
  fill(#e38a20);
  rect(400,0,200,200);
  smallFont();
  noStroke();
  renderNorth(direction.equals("N"));
  renderSouth(direction.equals("S"));
  renderWest(direction.equals("W"));
  renderEast(direction.equals("E")); 
}

void renderNorth(boolean isCurrent){
  if(isCurrent == true){
    fill(#2b2b2b);
    arc(500, 100, 175, 175, radians(225), radians(315)); 
  }else{
    fill(#696969, 475);
    arc(500, 100, 150, 150, radians(225), radians(315));
  } 
  fill(#ffffff);
  text("N", 492, 50);
}

void renderSouth(boolean isCurrent){
  if(isCurrent==true){
    fill(#2b2b2b);
    arc(500, 100, 175, 175, radians(45), radians(135));
  }else{
    fill(#696969, 475);
    arc(500, 100, 150, 150, radians(45), radians(135));
  }  
  fill(#ffffff);
  text("S", 492, 165);
}

void renderWest(boolean isCurrent){
  if(isCurrent==true){
    fill(#2b2b2b);
    arc(500, 100, 175, 175, radians(135), radians(225));
  }else{
    fill(#464646, 475);
    arc(500, 100, 150, 150, radians(135), radians(225));
  }  
  fill(#ffffff);
  text("W", 435, 110);
}

void renderEast(boolean isCurrent){
  // the 405 angle here is weird, you'd think that because you're starting at 315
  // it would be 45 (the beginning of the South arc), but
  // you have to continue around the circle adding angles
  // in when you pass the 360/0 degrees mark
  if(isCurrent==true){
    fill(#2b2b2b);
    arc(500, 100, 175, 175, radians(315), radians(405));
  }else{
    fill(#464646, 475);
    arc(500, 100, 150, 150, radians(315), radians(405));
  }  
  fill(#ffffff);
  text("E", 553, 110);
}

void renderAlert(){
  largeFont();
  fill(#980f0f);
  rect(400,200,200,200);
  fill(#ffffff);
  text("ALERT", 440, 305);
}

void renderClear(){
  mediumFont();
  fill(#ffffff);
  text("CLEAR", 450, 305);
}

void smallFont(){  textFont(font, 24); }
void mediumFont(){ textFont(font, 30); }
void largeFont(){  textFont(font, 40); }
