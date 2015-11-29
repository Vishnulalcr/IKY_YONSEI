import KinectPV2.*;


KinectPV2 kinect;
float ratioX, ratioY, ratioZ;
PImage img;
KJoint[] joints;

void setup() {
  size(1920, 1080);
  kinect = new KinectPV2(this);
  kinect.enableHDFaceDetection(true);
  kinect.enableColorImg(true); //to draw the color image
  kinect.enableSkeleton3DMap(true);
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
  ArrayList<KSkeleton> skeletonArray =  kinect.getSkeleton3d();
  for (int i = 0; i < skeletonArray.size(); i++) {
    KSkeleton skeleton = (KSkeleton) skeletonArray.get(i);
    if (skeleton.isTracked()) {
      joints = skeleton.getJoints();
      ratioZ = joints[KinectPV2.JointType_SpineMid].getZ();
    }
  }

  ArrayList<HDFaceData> hdFaceData = kinect.getHDFaceVertex();

  for (int j = 0; j < hdFaceData.size(); j++) {
    //obtain a the HDFace object with all the vertex data
    HDFaceData HDfaceData = (HDFaceData)hdFaceData.get(j);

    if (HDfaceData.isTracked()) {

      ratioX = HDfaceData.getX(HDFaceData.Face_Nose);
      ratioY = HDfaceData.getY(HDFaceData.Face_Nose);
      
      drawImage();
      //image(img, ratioX, ratioY - 70, 200 - ratioZ * 100, 200 - ratioZ * 100);
      println(100 - ratioZ * 100);
    }
  }
}

void drawImage() {
 pushMatrix();
 translate(width/2, height/2);
 rectMode(CENTER);
 noStroke();
 fill(255);
 rect(ratioX, ratioY + 50, 100, 100);
 image(img, ratioX, ratioY - 70, 200 - ratioZ * 100, 200 - ratioZ * 100);
 popMatrix();
 println(joints[KinectPV2.JointType_SpineBase].getZ());
 }
 