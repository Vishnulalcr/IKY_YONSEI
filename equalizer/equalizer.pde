import ddf.minim.analysis.*;
import ddf.minim.*;
import KinectPV2.*;
import java.util.*;

Minim       minim;
AudioPlayer gg;
AudioSample kick;
AudioSample snare;
FFT         fft;
BeatDetect beat;
KinectPV2 kinect;

float r = 0;
float betweenTwoHands = 0;
float ratioX, ratioY, ratioZ;
HashMap<Integer, Boolean> hitList = new HashMap<Integer, Boolean>();
float rightHandX, rightHandY;
float leftHandX, leftHandY;
float gradiant = 0;
boolean isClap = false;


void setup()
{
  size(700, 700, P3D);
  ratioX = width * 1.0f / 1920;
  ratioY = height * 1.0f / 1080;
  ratioZ = 0;
  minim = new Minim(this);
  gg = minim.loadFile("kindred.mp3", 1024);
  kick = minim.loadSample( "BD.mp3", // filename
    512      // buffer size
    );
  snare = minim.loadSample("SD.wav", 512);
  beat = new BeatDetect();
  gg.loop();
  fft = new FFT( gg.bufferSize(), gg.sampleRate() );
  rectMode(CENTER);
  kinect = new KinectPV2(this);
  kinect.enableDepthImg(true);
  kinect.enableSkeletonColorMap(true);
  kinect.init();
  //colorMode(HSB, 100);
}

void draw()
{
  background(0);
  //stroke(0);
  fft.forward( gg.mix );
  beat.detect(gg.mix);
  translate(width/2, height/2);
  //println(betweenTwoHands);

  noFill();
  for (int i = 0; i < fft.specSize(); i++)
  {
    pushMatrix();
    //line( i, height/2, i, height/2 - fft.getBand(i)*5 );
    stroke(255);
    //if (r >=0 && r < 3.14)
    //rotateX(r);
    //else if (r >=3.14 && r < 6.28)
    //rotateY(r);
    //else if (r >=6.28 && r < 9.42)
    rotateZ(r);
    //else
    //r = 0;
    rect( 0, 0, height/2 - fft.getBand(i)*5, height/2 - fft.getBand(i)*5);
    
    popMatrix();
    
    //line( leftHandX + i, leftHandY + 50 + gg.left.get(i)*50, rightHandX + i+1, rightHandY + 50 + gg.left.get(i+1)*50 );
  }

  
  if (r >= 3.14)
    r = 0;


  r = r + betweenTwoHands / 10000;
  stroke( 255, 0, 0 );
  //float position = map( gg.position(), 0, gg.length(), 0, width );
  //line( position - width/2, -height/2, position - width/2, height );
  
  
  
  /*for (int i = 0; i < kick.bufferSize() - 1; i++)
   {
   float x1 = map(i, 0, kick.bufferSize(), 0, width);
   float x2 = map(i+1, 0, kick.bufferSize(), 0, width);
   line(x1, 50 - kick.mix.get(i)*50, x2, 50 - kick.mix.get(i+1)*50);
   line(x1, 150 - snare.mix.get(i)*50, x2, 150 - snare.mix.get(i+1)*50);
   }
   */
  image(kinect.getDepthImage(), -width/2, -height/2, width, height);
  translate(-width/2, -height/2);
  
  if(betweenTwoHands < 0.1)
    isClap = true;
  line(leftHandX, leftHandY, rightHandX , rightHandY);
 
  
  drawHands();
  
  
}

void keyPressed() 
{
  if ( key == 's' ) snare.trigger();
  if ( key == 'k' ) kick.trigger();
}

void drawHands() {
  noStroke();
  ArrayList<KSkeleton> skeletonArray =  kinect.getSkeletonColorMap();
  ArrayList<Integer> processedColor = new ArrayList<Integer>(skeletonArray.size());
  //individual JOINTS
  for (int i = 0; i < skeletonArray.size(); i++) {
    KSkeleton skeleton = (KSkeleton) skeletonArray.get(i);
    if (skeleton.isTracked()) {
      KJoint[] joints = skeleton.getJoints();

      color col  = skeleton.getIndexColor();
      processedColor.add(col);
      //fill(col);
      //stroke(col);

      //draw different color for each hand state
      //drawHandState(joints[KinectPV2.JointType_HandRight]);
      //drawHandState(joints[KinectPV2.JointType_HandLeft]);
      KJoint hands[] = {joints[KinectPV2.JointType_HandRight]};//, joints[KinectPV2.JointType_HandLeft]};
      noStroke();
      for (KJoint hand : hands) {
        switch(hand.getState()) {
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
        betweenTwoHands = sqrt(pow((joints[11].getX() - joints[7].getX()), 2) + 
          pow((joints[11].getY() - joints[7].getY()), 2));
        
        //println(joints[7].getX() - joints[11].getX());
        
        rightHandX = joints[11].getX() * ratioX;
        rightHandY = joints[11].getY() * ratioY;
        leftHandX = joints[7].getX() * ratioX;
        leftHandY = joints[7].getY() * ratioY;
        
        gradiant = (rightHandY - leftHandY) / (rightHandX - rightHandY);
        
        
        
        /*
        pushMatrix();
        translate(hand.getX() * ratioX, hand.getY() * ratioY, hand.getZ() * ratioZ);
        ellipse(0, 0, 70, 70);
        popMatrix();

        if (hand.getState() == KinectPV2.HandState_Closed) {
          Boolean hit = hitList.get(col);
          if (hit == null || hit == false) {
            //sound_do.rewind();
            //sound_do.play();
            //sc.playNote(60, 127, 4);
            hitList.put(col, true);
          }
        } else {
          hitList.put(col, false);
        }
        */
      }
    }
  }
  
  Iterator<Map.Entry<Integer, Boolean>> iter = hitList.entrySet().iterator();
  while (iter.hasNext()) {
    Map.Entry<Integer, Boolean> hit = iter.next();
    if (!processedColor.contains(hit.getKey())) {
      iter.remove();
    }
  }
}