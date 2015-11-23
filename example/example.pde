import KinectPV2.*;
KinectPV2 kinect;
float ratioX, ratioY;
PImage img;

void setup() {
  size(1920, 1080);
  kinect = new KinectPV2(this);
  kinect.enableHDFaceDetection(true);
  kinect.enableColorImg(true); //to draw the color image
  kinect.init();
  
  img = loadImage("lion.png");
}

void draw() {
  imageMode(CENTER);
  background(0);

  // Draw the color Image
  image(kinect.getColorImage(), width/2, height/2);

  //Obtain the Vertex Face Points
  // 1347 Vertex Points for each user.
  ArrayList<HDFaceData> hdFaceData = kinect.getHDFaceVertex();

  for (int j = 0; j < hdFaceData.size(); j++) {
    //obtain a the HDFace object with all the vertex data
    HDFaceData HDfaceData = (HDFaceData)hdFaceData.get(j);

    if (HDfaceData.isTracked()) {

      //draw the vertex points
      stroke(0, 255, 0);
      beginShape(POINTS);
      for (int i = 0; i < KinectPV2.HDFaceVertexCount; i++) {
        float x = HDfaceData.getX(i);
        float y = HDfaceData.getY(i);
        vertex(x, y);
      }
      endShape();
      
      ratioX = HDfaceData.getX(HDFaceData.Face_Nose);
      ratioY = HDfaceData.getY(HDFaceData.Face_Nose);
      image(img, ratioX, ratioY - 70);
      println(ratioX, ratioY);
    }
  }
}
/*
void drawImage() {
  pushMatrix();
  translate(width/2, height/2);
  rectMode(CENTER);
  noStroke();
  fill(255);
  rect(ratioX, ratioY + 50, 100, 100);
  image(img, ratioX, ratioY);
  popMatrix();
  //println(joints[KinectPV2.JointType_SpineBase].getZ());
}
*/