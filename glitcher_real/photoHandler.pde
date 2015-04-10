// - image handling variables - - 
PImage photo;


int pointSize = 4;
float threshold = 180;
ArrayList<PVector> positions;


//load photo into the global PImage
void loadImageData(String filename){
   photo = loadImage(filename);
}


//convert photo loaded to positional points for drawing
void prepareImageData() {
 
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




void getOnlineImage(String url, String filename) {
  String _url = url; //pull file - this needs to be retrieved from the tweet
  PImage onlineImg = loadImage(_url, "jpg");
  String _filename = filename;
  onlineImg.save(_filename); //saves to data folder
  //we can now reference this image into the photo
  
  loadImageData(_filename);
}



