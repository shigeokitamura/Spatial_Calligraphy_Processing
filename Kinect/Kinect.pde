import SimpleOpenNI.*;
import java.text.DecimalFormat;
import processing.net.*;

SimpleOpenNI kinect;
Client client;

float pHandX = 0.0f;
float pHandY = 0.0f;

float speed = 0.0f; //速度
float distance = 0.0f;
float pdistance = 0.0f;

boolean rgb = false;

DecimalFormat df;

void setup() {
  kinect = new SimpleOpenNI(this);
  if(kinect.isInit() == false) {
    println("Kinectを認識できません。");
    exit();
    return;
  }
  kinect.setMirror(true);  //ミラー反転を有効化
  kinect.enableDepth();    //深度画像を有効化
  kinect.enableRGB();      //カラー画像を有効化
  kinect.enableUser();  //ユーザトラッキングを有効化
  kinect.alternativeViewPointDepthToImage();
  //size(kinect.rgbWidth(), kinect.rgbHeight());
  size(640, 480);
  frameRate(30);
  df = new DecimalFormat("0.0000000000");
  client = new Client(this, "127.0.0.1", 20000);
}

void draw() {
  background(0, 0, 0);
  kinect.update(); //Kinectのデータの更新
  detectSpeed();
  if(rgb) {
    tint(255, 255, 255, 255/2);
    image(kinect.userImage(), 0, 0); //ユーザ画像の描画
    image(kinect.rgbImage(), 0, 0);  //カラー画像の描画
  } else {
    tint(255, 255, 255, 255);
    image(kinect.userImage(), 0, 0);
  }  
  //ユーザごとの骨格のトラッキングができていたら骨格を描画
  for(int userId = 1; userId <= kinect.getNumberOfUsers(); userId++) {
    if(kinect.isTrackingSkeleton(userId)) {
      strokeWeight(2);       //線の太さの設定
      stroke(255, 0, 0);      //線の色の設定
      drawSkeleton(userId);   //骨格の描画
      detectGesture(userId);  //ジェスチャ認識
    }
  }
  
  
}

//新しいユーザを見つけた場合の処理
void onNewUser(SimpleOpenNI curContext, int userId) {
  println("ユーザを認識しました。 userId: " + userId);
  kinect.startTrackingSkeleton(userId);  //骨格トラッキングの開始
}

//ユーザを見失った場合の処理
void onLostUser(SimpleOpenNI curContext, int userId) {
  println("userId: " + userId + "を見失いました。");
}

//骨格の描画
void drawSkeleton(int userId) {
  //関節間を結ぶ直線の描画
  kinect.drawLimb(userId, SimpleOpenNI.SKEL_HEAD,           SimpleOpenNI.SKEL_NECK);
  kinect.drawLimb(userId, SimpleOpenNI.SKEL_NECK,           SimpleOpenNI.SKEL_LEFT_SHOULDER);
  kinect.drawLimb(userId, SimpleOpenNI.SKEL_LEFT_SHOULDER,  SimpleOpenNI.SKEL_LEFT_ELBOW); 
  kinect.drawLimb(userId, SimpleOpenNI.SKEL_LEFT_ELBOW,     SimpleOpenNI.SKEL_LEFT_HAND);
  kinect.drawLimb(userId, SimpleOpenNI.SKEL_NECK,           SimpleOpenNI.SKEL_RIGHT_SHOULDER);
  kinect.drawLimb(userId, SimpleOpenNI.SKEL_RIGHT_SHOULDER, SimpleOpenNI.SKEL_RIGHT_ELBOW);
  kinect.drawLimb(userId, SimpleOpenNI.SKEL_RIGHT_ELBOW,    SimpleOpenNI.SKEL_RIGHT_HAND);
  kinect.drawLimb(userId, SimpleOpenNI.SKEL_LEFT_SHOULDER,  SimpleOpenNI.SKEL_TORSO);
  kinect.drawLimb(userId, SimpleOpenNI.SKEL_RIGHT_SHOULDER, SimpleOpenNI.SKEL_TORSO);
  kinect.drawLimb(userId, SimpleOpenNI.SKEL_TORSO,          SimpleOpenNI.SKEL_LEFT_HIP);
  kinect.drawLimb(userId, SimpleOpenNI.SKEL_LEFT_HIP,       SimpleOpenNI.SKEL_LEFT_KNEE);
  kinect.drawLimb(userId, SimpleOpenNI.SKEL_LEFT_KNEE,      SimpleOpenNI.SKEL_LEFT_FOOT);
  kinect.drawLimb(userId, SimpleOpenNI.SKEL_TORSO,          SimpleOpenNI.SKEL_RIGHT_HIP);
  kinect.drawLimb(userId, SimpleOpenNI.SKEL_RIGHT_HIP,      SimpleOpenNI.SKEL_RIGHT_KNEE);
  kinect.drawLimb(userId, SimpleOpenNI.SKEL_RIGHT_KNEE,     SimpleOpenNI.SKEL_RIGHT_FOOT);  
}

//ジェスチャ認識
void detectGesture(int userId) {
  //右手の3次元位置を取得する
  PVector hand3d_R = new PVector(); //3次元位置
  kinect.getJointPositionSkeleton(userId, SimpleOpenNI.SKEL_RIGHT_HAND, hand3d_R);
  
  //右手の2次元位置を取得する
  PVector hand2d_R = new PVector(); //2次元位置
  kinect.convertRealWorldToProjective(hand3d_R, hand2d_R);
  
  //左手の3次元位置を取得する
  PVector hand3d_L = new PVector();  //3次元位置
  kinect.getJointPositionSkeleton(userId, SimpleOpenNI.SKEL_LEFT_HAND, hand3d_L);
  
  //左手の2次元位置を取得する
  PVector hand2d_L = new PVector();  //2次元位置
  kinect.convertRealWorldToProjective(hand3d_L, hand2d_L);
  
  
  //右膝の3次元位置を取得する
  PVector knee3d_R = new PVector(); //3次元位置
  kinect.getJointPositionSkeleton(userId, SimpleOpenNI.SKEL_RIGHT_KNEE, knee3d_R);
  
  //右膝の2次元位置を取得する
  PVector knee2d_R = new PVector(); //2次元位置
  kinect.convertRealWorldToProjective(knee3d_R, knee2d_R);
  
  //左膝の3次元位置を取得する
  PVector knee3d_L = new PVector();  //3次元位置
  kinect.getJointPositionSkeleton(userId, SimpleOpenNI.SKEL_LEFT_KNEE, knee3d_L);
  
  //左膝の2次元位置を取得する
  PVector knee2d_L = new PVector();  //2次元位置
  kinect.convertRealWorldToProjective(knee3d_L, knee2d_L);
  

  noStroke();
  PVector kneeF = new PVector();
  //手前にある膝を判定
  if(knee3d_R.z >= knee3d_L.z) {
    kneeF = knee2d_L;
    kneeF.z = knee3d_L.z;
  }else{
    kneeF = knee2d_R;
    kneeF.z = knee3d_R.z;
  }
  fill(0, 255, 0);
  ellipse(kneeF.x, kneeF.y, 10, 10);  //手前にある膝を表示
  
  PVector handF = new PVector();
  //手前にある手を判定
  /*
  if(hand3d_R.z >= hand3d_L.z) {
    handF = hand2d_L;
    handF.z = hand3d_L.z;
  }else{
    handF = hand2d_R;
    handF.z = hand3d_R.z;
  }
  */
  handF = hand2d_R;
  handF.z = hand3d_R.z;
  
  if(handF.z < kneeF.z) {
    fill(255, 0, 0);
    ellipse(lerp(handF.x, pHandX, 0.5), lerp(handF.y, pHandY, 0.5), 10, 10);
    client.write(lerp(handF.x, pHandX, 0.5) + " " + lerp(handF.y, pHandY, 0.5) + " " + speed + " " + "true" + '\n');
  }else{
    client.write(lerp(handF.x, pHandX, 0.5) + " " + lerp(handF.y, pHandY, 0.5) + " " + speed + " " + "false" + '\n');
  }
  distance = handF.z;
  pHandX = handF.x;
  pHandY = handF.y;
}

void detectSpeed() {
  speed = (float)((pdistance - distance) * (float)frameRate);
  textSize(30);
  fill(255, 255, 255);
  if(speed >= 0) {
    text("+" + df.format(speed) + "m/s", 100, 100);
  }else{
    text(df.format(speed) + "m/s", 100, 100);
  }
  //println(speed);
  pdistance = distance;
}

void keyPressed() {
  rgb ^= true;
}
