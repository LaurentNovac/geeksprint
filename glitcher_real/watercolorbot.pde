
int ServoUpPct = 70;    // Brush UP position, %  (higher number lifts higher). 
int ServoPaintPct = 30;    // Brush DOWN position, %  (higher number lifts higher). 
int ServoWashPct = 20;    // Brush DOWN position for washing brush, %  (higher number lifts higher). 

int  ServoUp = 7500 + 175 * ServoUpPct;    // Brush UP position, native units
int  ServoPaint = 7500 + 175 * ServoPaintPct;   // Brush DOWN position, native units. 
int  ServoWash = 7500 + 175 * ServoWashPct;     // Brush DOWN position, native units

// User Settings: 
float MotorSpeed = 1500.0;  // Steps per second, 1500 default

int xMotorPaperOffset = 1400;

int MotorMinX = xMotorPaperOffset;
int MotorMinY = 0;
int MotorMaxX = 6282 - xMotorPaperOffset;
int MotorMaxY = 3561;

int MousePaperLeft =  185;
int MousePaperRight =  769;
int MousePaperTop =  62;
int MousePaperBottom =  488;
int xMotorOffsetPixels = 0;  // Corrections to initial motor position w.r.t. lower plate (paints & paper)
int yMotorOffsetPixels = 4 ;
float MotorStepsPerPixel = 8.36;// Good for 1/8 steps-- standard behavior.

int targetW = MotorMaxX;
int targetH = MotorMaxY;

boolean debugWaterColorBot = false;


//======time management variables
int storeMillis = 0;
boolean doRaise = true;
boolean doMove = true;
boolean doLower = true;
boolean doMoveRelPos = true;
boolean doMoveRelNeg = true;
int delayRaise = 60;
int delayMove = 160;
int delayLower = 220;
int delayMoveRelPos = 280;
int delayMoveRelNeg = 340;
int indexPos = 0;
boolean doStart = false;

// - serial handling ---------
boolean plugged = false;
Serial myPort;  // Create object from Serial class
int baudrate = 38400;

//------- 
int currentX = 0;
int currentY = 0;
boolean isRaised = true;
boolean motorsOn;







//-------------FUNCTIONS


void initWaterColorBot() {

  MotorMaxX = int(floor(xMotorPaperOffset + float(MousePaperRight - MousePaperLeft) * MotorStepsPerPixel)) ;
  MotorMaxY = int(floor(float(MousePaperBottom - MousePaperTop) * MotorStepsPerPixel)) ;

  myPort = new Serial(this, "/dev/tty.usbmodem1451", baudrate);
  myPort.buffer(1);
  myPort.clear();
  println("request version number..");
  myPort.write("v\r");
  delay(50);
  while (myPort.available ()>0) {
    String inbuffer = myPort.readString();
    if (inbuffer !=null) {
      println("version number: "+inbuffer);
    }
  }
}


void configureColorBot() {
  write("EM,2\r");  //Configure both steppers to 1/8 step mode

    // Configure brush lift servo endpoints and speed
  write("SC,4," + str(ServoPaint) + "\r");  // Brush DOWN position, for painting
  write("SC,5," + str(ServoUp) + "\r");  // Brush UP position 

  //    myPort.write("SC,10,255\r"); // Set brush raising and lowering speed.
  write("SC,10,65535\r"); // Set brush raising and lowering speed.
}


void readOk(String msg) {
  delay(50);
  while (myPort.available ()>0) {
    String inbuffer = myPort.readString();
    if (inbuffer !=null) {
      if (inbuffer.equals("OK")) {
        println("error : "+msg );
      } else {
        println("ok : "+msg );
      }
    }
  }
}


void write(String command) {
  if (plugged) {
    myPort.write(command);  //Configure both steppers to 1/8 step mode
  }
  //readOk(command);
}

void raiseBrush() {
  write("SP,0\r");
}

void lowerBrush() {
  write("SP,1\r");
}

void moveToRel(int x_, int y_, int traveltime) {
  write("SM," + str(traveltime) + "," + str(x_) + "," + str(y_) + "\r");
  motorsOn = false;
}

void moveToAbs(int x_, int y_, int traveltime) {
  int newX = x_ - currentX; 
  int newY = y_ - currentY;
  moveToRel(newX, newY, traveltime);
  currentX = x_;
  currentY = y_;
}


///////////// main function to draw our image as a series of dots


void updateWaterColor() {
  if (indexPos < positions.size() && doStart) {
    PVector curPos = positions.get(indexPos);
    int xx = (int)curPos.x;
    int yy = (int)curPos.y;
    float x = map(xx, 0, photo.width, 0, 512);
    float y = map(yy, 0, photo.height, 0, 512);
    
    ellipse(x, y, 4, 4); //purely for visual reference
    
    int deltaT = millis() - storeMillis; //time based - fuck that delay shit
    
    if (deltaT > delayRaise && doRaise) {
      if (debugWaterColorBot){
       println("raise");
      }
      raiseBrush();
      doRaise = false;
    }
    if (deltaT > delayMove && doMove) {
      if (debugWaterColorBot){
       println("move");
      }
      moveToAbs((int)x, (int)y, 100);
      doMove = false;
    }
    if (deltaT > delayLower && doLower) {
      if (debugWaterColorBot){
       println("lower");
      }
      lowerBrush();

      doLower = false;
    }
    if (deltaT > delayMoveRelPos && doMoveRelPos) {
      if (debugWaterColorBot){
       println("pos");
      }
      moveToRel(2, 0, 50);

      doMoveRelPos = false;
    }
    if (deltaT > delayMoveRelNeg && doMoveRelNeg) {
      if (debugWaterColorBot){
       println("neg");
      }
      moveToRel(-2, 0, 50);

      storeMillis = millis();
      doMoveRelNeg = false;
      
      //reset all to true so we can iterate again the sequence for the next dot
      doRaise = true;
      doMove = true;
      doLower = true;
      doMoveRelPos = true;
      doMoveRelNeg = true;
      
      //increment positions index
      indexPos++;
    }
  }

  //reset back to the beginning position so we can draw again - tell the system we have finished, ready for another image

}





