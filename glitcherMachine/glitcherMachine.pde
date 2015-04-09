int resX = 1;
int resY = 1;
PImage photo;
int pointSize = 1;

int targetW = 10;
int targetH = 1;

float threshold = 180;

ArrayList<PVector> positions;

void setup() {
  size(512, 512);
  background(255);
  photo = loadImage("Lenna.png");
  stroke(0);
  strokeWeight(pointSize);
  smooth();

  positions = new ArrayList<PVector>();
  photo.resize(targetW, targetH);
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
  println(positions.size());
}

void draw() {
}
