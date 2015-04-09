import processing.serial.*;

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

int MotorMinX = 0;
int MotorMinY = 0;
int MotorMaxX = 6282;
int MotorMaxY = 3561;

int currentX = 0;
int currentY = 0;

boolean isRaised = true;
boolean motorsOn;
void initWaterColorBot() {
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

void moveTo(int x_, int y_, int traveltime) {
  int x = max(x_, 0);
  x = min(x, MotorMaxX);
  int y = max(y_, 0);
  y = min(y, MotorMaxY);
  write("SM," + str(traveltime) + "," + str(x) + "," + str(y) + "\r");
  motorsOn = false;
}
void write(String command) {
  myPort.write(command);  //Configure both steppers to 1/8 step mode
  readOk(command);
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
  size(200, 200);

  println(Serial.list());
  initWaterColorBot();
  configureColorBot();
}

void draw() {
}

void keyPressed() {
  if (key == CODED) {
    if (key == UP) {
      currentY++;
      moveTo(currentX, currentY, 500);
    } else if (key == DOWN) {
      currentY--;
    } else if (key == LEFT) {
      currentX++;
    } else if (key == RIGHT) {
      currentX--;
    }
  } else {
    if (key == 'u') {
      isRaised = !isRaised;
      if (isRaised) {
        raiseBrush();
      } else {
        lowerBrush();
      }
    } else if (key == 't') {
      moveTo(0, 3000, 500);
    } else if (key == 'r') {
      motorsOn = !motorsOn;
      if (motorsOn) {
        write("EM,0,0\r");
      } else {
        write("EM,2,2\r");
      }
    }
  }
}
///dev/cu.Bluetooth-Incoming-Port /dev/cu.Bluetooth-Modem /dev/cu.usbmodem1451 /dev/tty.Bluetooth-Incoming-Port /dev/tty.Bluetooth-Modem /dev/tty.usbmodem1451
