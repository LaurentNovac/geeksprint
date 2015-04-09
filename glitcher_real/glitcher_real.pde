import processing.serial.*;
//======time management variable
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
//======

boolean plugged = false;
Serial myPort;  // Create object from Serial class
int baudrate = 38400;

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


int currentX = 0;
int currentY = 0;

boolean isRaised = true;
boolean motorsOn;


PImage photo;
int pointSize = 4;

int targetW = MotorMaxX;
int targetH = MotorMaxY;

float threshold = 180;

ArrayList<PVector> positions;

int MousePaperLeft =  185;
int MousePaperRight =  769;
int MousePaperTop =  62;
int MousePaperBottom =  488;
int xMotorOffsetPixels = 0;  // Corrections to initial motor position w.r.t. lower plate (paints & paper)
int yMotorOffsetPixels = 4 ;
float MotorStepsPerPixel = 8.36;// Good for 1/8 steps-- standard behavior.
void initData() {
  photo = loadImage("Lenna.png");
  stroke(0);
  strokeWeight(pointSize);
  smooth();
  int resX = 20;
  int resY = 20;
  positions = new ArrayList<PVector>();
  //  photo.resize(512, 512);
  for (int x = 0; x < photo.width; x+=resX) {
    for (int y = 0; y < photo.height; y+=resY) {
      if (brightness(photo.get(x, y))>threshold) {
        stroke(0);
        positions.add(new PVector(x, y));
      } else {
        stroke(255);
      }

      point(x, y);
    }
  }
}

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

void updateWaterColor() {
  if (indexPos < positions.size() && doStart) {
    PVector curPos = positions.get(indexPos);
    int xx = (int)curPos.x;
    int yy = (int)curPos.y;
    float x = map(xx, 0, photo.width, 0, 512);
    float y = map(yy, 0, photo.height, 0, 512);
    ellipse(x, y, 4, 4);
    int deltaT = millis() - storeMillis;
    if (deltaT > delayRaise && doRaise) {
      println("raise");
      raiseBrush();
      doRaise = false;
    }
    if (deltaT > delayMove && doMove) {
      println("move");
      moveToAbs((int)x, (int)y, 100);
      doMove = false;
    }
    if (deltaT > delayLower && doLower) {
      println("lower");
      lowerBrush();

      doLower = false;
    }
    if (deltaT > delayMoveRelPos && doMoveRelPos) {
      println("pos");
      moveToRel(2, 0, 50);

      doMoveRelPos = false;
    }
    if (deltaT > delayMoveRelNeg && doMoveRelNeg) {
      println("neg");
      moveToRel(-2, 0, 50);

      storeMillis = millis();
      doMoveRelNeg = false;
      doRaise = true;
      doMove = true;
      doLower = true;
      doMoveRelPos = true;
      doMoveRelNeg = true;
      //increment positions index
      indexPos++;
    }
  }
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

void write(String command) {
  if (plugged) {
    myPort.write(command);  //Configure both steppers to 1/8 step mode
  }
  //readOk(command);
}

void configureColorBot() {
  write("EM,2\r");  //Configure both steppers to 1/8 step mode

    // Configure brush lift servo endpoints and speed
  write("SC,4," + str(ServoPaint) + "\r");  // Brush DOWN position, for painting
  write("SC,5," + str(ServoUp) + "\r");  // Brush UP position 

  //    myPort.write("SC,10,255\r"); // Set brush raising and lowering speed.
  write("SC,10,65535\r"); // Set brush raising and lowering speed.
}

void setup() 
{
  size(512, 512);
  println(Serial.list());
  if (plugged) {
    initWaterColorBot();
    configureColorBot();
  }
  initData();
  write("EM,0,0\r");
  raiseBrush();
  stroke(0);
}

void draw() {
  updateWaterColor();
}

void keyPressed() {
  if (key == 'u') {
    isRaised = !isRaised;
    if (isRaised) {
      raiseBrush();
    } else {
      lowerBrush();
    }
  }
  if (key == 'r') {
    raiseBrush();
    motorsOn = !motorsOn;
    if (motorsOn) {
      write("EM,0,0\r");
    } else {
      write("EM,2,2\r");
    }
  }
  if (key == 's') {
   doStart = true;
  }
}
///dev/cu.Bluetooth-Incoming-Port /dev/cu.Bluetooth-Modem /dev/cu.usbmodem1451 /dev/tty.Bluetooth-Incoming-Port /dev/tty.Bluetooth-Modem /dev/tty.usbmodem1451
