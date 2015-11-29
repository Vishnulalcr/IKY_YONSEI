import KinectPV2.*;
KinectPV2 kinect;
float ratioX, ratioY;
PImage img;
int bgFill = 0;
int objAlpha = 1;
ArrayList<HDFaceData> hdFaceData;
ArrayList<KSkeleton> skeletonArray;
ArrayList<PImage> saveImage;
KJoint tempJoints[];
//////////////////////////////////////////////////////////
boolean btnStart = false;
int startCount = 0;
//////////////////////////////////////////////////////////
boolean btnRecord = false;
boolean updownControler = false;

void setup() {
  size(1920, 1080);
  kinect = new KinectPV2(this);
  kinect.enableHDFaceDetection(true);
  kinect.enableColorImg(true);
  kinect.enableSkeletonColorMap(true);
  kinect.init();
  imageMode(CENTER);
  textMode(CENTER);
  ellipseMode(CENTER);
  img = loadImage("lion.png");
}


void draw() {
  initializeSkeleton();
  if (!btnStart) { ////////////////////////////////////////////////////////// controled by btnStart
    image(kinect.getColorImage(), width/2, height/2);
    drawHead();
    drawBtnStart();
  } else {
    if (!btnRecord) { ////////////////////////////////////////////////////////// controled by btnRecord
      fadeInOut();
      timerObjAlpha(btnRecord);
    } else {
      fadeInOut();
      timerObjAlpha(btnRecord);
    }
  }
}


void drawHead() {
  hdFaceData = kinect.getHDFaceVertex();
  for (int j = 0; j < hdFaceData.size(); j++) {
    HDFaceData HDfaceData = (HDFaceData)hdFaceData.get(j);
    if (HDfaceData.isTracked()) {
      ratioX = HDfaceData.getX(HDFaceData.Face_Nose);
      ratioY = HDfaceData.getY(HDFaceData.Face_Nose) - 150;
      pushMatrix();
      fill(255);
      ellipse(ratioX, ratioY+100, 200, 200);
      popMatrix();
      image(img, ratioX, ratioY, 500, 500);
    }
  }
}


void initializeSkeleton() {
  float rightHandX;
  float rightHandY;
  skeletonArray =  kinect.getSkeletonColorMap();
  for (int i = 0; i < skeletonArray.size(); i++) {
    KSkeleton skeleton = (KSkeleton) skeletonArray.get(i);
    if (skeleton.isTracked()) {
      KJoint[] joints = skeleton.getJoints();
      rightHandX = joints[11].getX();
      rightHandY = joints[11].getY();
      controlBtnStart(rightHandX, rightHandY);
    }
  }
}


void drawBtnStart() {
  pushMatrix();
  noStroke();
  fill(255);
  ellipse(1500, 700, 100, 100);
  popMatrix();
  textSize(32);
  fill(0);
  text("Start", 1466, 713);
}


void controlBtnStart(float x, float y) {
  if (!btnStart) {
    if (1400 < x && x < 1600) {
      if (600 < y && y < 800) {
        startCount++;
        if (startCount > 100) {
          btnStart = true;
          startCount = 0;
        }
      } else
        startCount = 0;
    } else
      startCount = 0;
  }
}


void fadeInOut() {
  image(kinect.getColorImage(), width/2, height/2);
  drawHead();
  fill(bgFill, objAlpha);
  rect(0, 0, width, height);
}


void timerObjAlpha(boolean check) {
  if(!check) {
    if(objAlpha < 255)
      objAlpha++;
  } else if(check){
    if(objAlpha > 0)
      objAlpha--;
  }
  println(objAlpha);
}


void mousePressed() {
  btnRecord = true;
}