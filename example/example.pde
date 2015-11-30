import KinectPV2.*;
import ddf.minim.*;
import java.util.*;

KinectPV2 kinect;
Minim minim;
AudioPlayer player;
//////////////////////////////////////////////////////////
PImage img;
float ratioX, ratioY;
int bgFill = 0;
int objAlpha = 1;
float headSize = 0;
float headZ = 0;
//////////////////////////////////////////////////////////
ArrayList<HDFaceData> hdFaceData;
ArrayList<KSkeleton> skeletonArray;
LinkedList<Float> headDepth = new LinkedList<Float>();
KJoint tempJoints[];
//////////////////////////////////////////////////////////
boolean btnStart = false;
int startCount = 0;
int colorBtnStart = 255;//start btn color
boolean startFlag = false;
//////////////////////////////////////////////////////////
boolean flgScreen = false;
boolean updownControler = false;
int screenTimer = 0;
int questionNum = 0;
//////////////////////////////////////////////////////////

void setup() {
  size(1920, 1080);
  kinect = new KinectPV2(this);
  kinect.enableHDFaceDetection(true);
  kinect.enableColorImg(true);
  //kinect.enableSkeletonColorMap(true);
  kinect.enableSkeleton3DMap(true);
  kinect.init();
  imageMode(CENTER);
  textMode(CENTER);
  ellipseMode(CENTER);
  img = loadImage("lion.png");
  minim = new Minim(this);
  player = minim.loadFile("Soulostar - Lost in Lights.wav");
}


void draw() {
  player.play();
  initializeSkeleton();

  if (!btnStart) { ////////////////////////////////////////////////////////// controled by btnStart
    image(kinect.getColorImage(), width/2, height/2);
    drawHead();
    drawBtnStart();
  } else {
    fadeInOutControl();
    if (flgScreen)
      makeScreenShot();
  }
}


void drawHandState(KJoint joint) {
  //System.out.println("drawHandState begin");
  noStroke();
  handState(joint.getState());
  pushMatrix();
  translate(joint.getX(), joint.getY(), joint.getZ());
  ellipse(0, 0, 70, 70);
  popMatrix();
}


void handState(int handState) {
  switch(handState) {
  case KinectPV2.HandState_Open:
    fill(0, 255, 0);
    break;
  case KinectPV2.HandState_Closed:
    fill(255, 0, 0);
    break;
  case KinectPV2.HandState_Lasso:
    fill(0, 0, 255);
    break;
  case KinectPV2.HandState_NotTracked:
    fill(255, 255, 255);
    break;
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
      ellipse(ratioX, ratioY+100, 100 * headSize, 100 * headSize);
      popMatrix();
      image(img, ratioX, ratioY+80, 200 * headSize, 200 * headSize);
    }
  }
}


void initializeSkeleton() {

  float rightHandX;
  float rightHandY;
  skeletonArray =  kinect.getSkeleton3d();
  for (int i = 0; i < skeletonArray.size(); i++) {
    KSkeleton skeleton = (KSkeleton) skeletonArray.get(0);
    if (skeleton.isTracked()) {
      KJoint[] joints = skeleton.getJoints();
      //drawHandState(joints[KinectPV2.JointType_HandRight]);
      rightHandX = joints[11].getX();
      rightHandY = joints[11].getY();
      headDepth.add(joints[3].getZ());
      if (joints[KinectPV2.JointType_HandRight].getState() == KinectPV2.HandState_Open)
        startFlag = false; 
      else if (joints[KinectPV2.JointType_HandRight].getState() == KinectPV2.HandState_Closed)
        startFlag = true;
      println("hello");
      calculateHeadZ();
      controlBtnStart(rightHandX, rightHandY);
    }
  }
}


void calculateHeadZ() {
  float sum;
  int count;
  while (headDepth.size() > 300)
    headDepth.pollFirst();
  if (headDepth.size() > 6) {
    sum = 0;
    count = 0;
    for (int k = headDepth.size() - 1; k >= 0 && k > headDepth.size() - 6; k--) {
      sum += headDepth.get(k);
      count++;
    }
    headZ = sum / count;
  }
  headSize = (5 - headZ)/2;
  println("headSize : " + headSize);
}


void drawBtnStart() {
  pushMatrix();
  noStroke();
  fill(colorBtnStart);
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
        println("lockon");
        if (startCount > 50 && startFlag == false) {
          println("start");
          colorBtnStart = 128;
        } else if (startCount > 100 && startFlag == true) {

          btnStart = true;
          startCount = 0;
        }
      } else
        startCount = 0;
    } else
      startCount = 0;
  }
}


void fadeInOutControl() {
  if (!flgScreen) {
    fadeInOut();
    timerObjAlpha(flgScreen);
  } else {
    fadeInOut();
    timerObjAlpha(flgScreen);
  }
}


void fadeInOut() {
  image(kinect.getColorImage(), width/2, height/2);
  drawHead();
  fill(bgFill, objAlpha);
  rect(0, 0, width, height);
}


void timerObjAlpha(boolean check) {
  if (!check) {
    if (objAlpha < 255)
      objAlpha++;
  } else if (check) {
    if (objAlpha > 0)
      objAlpha--;
  }
  println(objAlpha);
}


void makeScreenShot() {
  screenTimer++;
  if (screenTimer % 300 == 0 && screenTimer != 0) {
    saveFrame("screen" + screenTimer + "question" + questionNum);
    if (screenTimer == 1500) {
      flgScreen = false;
      screenTimer = 0;
      questionNum++;
    }
  }
}


void mousePressed() {
  if (!flgScreen)
    flgScreen = true;
  else
    flgScreen = false;
}