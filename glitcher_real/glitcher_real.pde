import processing.serial.*;

/*
geeksprintGVA
 
 Lauret Novac
 Walid
 Ashley James Brown
 
 */







////////////////////
void setup() 
{
  size(512, 512);
  println(Serial.list());
  // 
  if (plugged) {
    initWaterColorBot();
    configureColorBot();
  }

  loadImageData("Lenna.png"); //start with basic from data folder
  prepareImageData();

  write("EM,0,0\r");
  raiseBrush();
  stroke(0);
}


void draw() {
  updateWaterColor();
}



/////////////////// keyboard interactions

void keyPressed() {
  
  // make these switch statements to be more efficient than ifs - ajb
  
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
    
    doStart = !doStart;
    //toggle so we can stop
    if (doStart){
      println("start drawing");
    }
    else
    {
      println("stop drawing!");
    }
  }
  
  
  if (key=='d'){
    //toggle debug console output
   debugWaterColorBot=!debugWaterColorBot;
   
  }
  
}
///dev/cu.Bluetooth-Incoming-Port /dev/cu.Bluetooth-Modem /dev/cu.usbmodem1451 /dev/tty.Bluetooth-Incoming-Port /dev/tty.Bluetooth-Modem /dev/tty.usbmodem1451

